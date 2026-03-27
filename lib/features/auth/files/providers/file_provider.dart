import 'package:file_manager/data/model/file_item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:file_manager/data/services/local_storage_service.dart';

class FileProvider extends ChangeNotifier {
  final LocalStorageService _localStorageService = LocalStorageService();

  final List<FileItem> _files = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<FileItem> get allFiles => List.unmodifiable(_files);
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<FileItem> get filteredFiles {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_files);
    }

    final query = _searchQuery.trim().toLowerCase();

    return _files
        .where((file) => file.name.toLowerCase().contains(query))
        .toList();
  }

  Future<void> loadFiles() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedFiles = await _localStorageService.loadFiles();

      _files
        ..clear()
        ..addAll(savedFiles);
    } catch (e) {
      debugPrint('Erro ao carregar arquivos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final picked = result.files.first;

      if (picked.path == null) {
        return;
      }

      final fileItem = FileItem(
        name: picked.name,
        path: picked.path!,
        size: picked.size,
      );

      _files.add(fileItem);
      await _persistFiles();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao selecionar arquivo: $e');
    }
  }

  Future<void> deleteFile(FileItem file) async {
    _files.remove(file);
    await _persistFiles();
    notifyListeners();
  }

  Future<void> renameFile({
    required FileItem file,
    required String newName,
  }) async {
    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) {
      return;
    }

    final index = _files.indexOf(file);
    if (index == -1) {
      return;
    }

    _files[index] = file.copyWith(name: trimmedName);

    await _persistFiles();
    notifyListeners();
  }

  Future<void> _persistFiles() async {
    await _localStorageService.saveFiles(_files);
  }
}