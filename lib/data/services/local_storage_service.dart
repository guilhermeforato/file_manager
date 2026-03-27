import 'dart:convert';

import 'package:file_manager/data/model/file_item.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LocalStorageService {
  static const String _filesKey = 'saved_files';

  Future<void> saveFiles(List<FileItem> files) async {
    final prefs = await SharedPreferences.getInstance();

    final encodedList = files
        .map((file) => jsonEncode(file.toMap()))
        .toList();

    await prefs.setStringList(_filesKey, encodedList);
  }

  Future<List<FileItem>> loadFiles() async {
    final prefs = await SharedPreferences.getInstance();

    final savedList = prefs.getStringList(_filesKey) ?? [];

    return savedList
        .map((item) => FileItem.fromMap(jsonDecode(item)))
        .toList();
  }

  Future<void> clearFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_filesKey);
  }
}