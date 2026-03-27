import 'package:file_manager/data/model/file_item.dart';
import 'package:file_manager/data/services/env_service.dart';
import 'package:file_manager/features/auth/files/providers/file_provider.dart';
import 'package:file_manager/features/auth/providers/auth_provider.dart';
import 'package:file_manager/features/auth/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileManagerPage extends StatefulWidget {
  const FileManagerPage({super.key});

  @override
  State<FileManagerPage> createState() => _FileManagerPageState();
}

class _FileManagerPageState extends State<FileManagerPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FileProvider>().loadFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final fileProvider = context.watch<FileProvider>();
    final files = fileProvider.filteredFiles;
    final nameApp = EnvService.appName;

    return Scaffold(
      appBar: AppBar(
        title: Text(nameApp),
        actions: [
          IconButton(
            onPressed: () async {
              await authProvider.logout();

              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.read<FileProvider>().pickFile();
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Adicionar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: fileProvider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Buscar arquivos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    fileProvider.setSearchQuery('');
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: fileProvider.isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : files.isEmpty
                  ? const Center(
                child: Text(
                  'Nenhum arquivo encontrado.',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.separated(
                itemCount: files.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final file = files[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(file.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_formatBytes(file.size)),
                          Text(
                            file.path,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: authProvider.isAdmin
                          ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'rename') {
                            _showRenameDialog(file);
                          } else if (value == 'delete') {
                            _showDeleteDialog(file);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'rename',
                            child: Text('Renomear'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Excluir'),
                          ),
                        ],
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showRenameDialog(FileItem file) async {
    final controller = TextEditingController(text: file.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Renomear arquivo'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Novo nome',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;

                FocusScope.of(dialogContext).unfocus();
                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (newName == null || newName.trim().isEmpty) return;

    await context.read<FileProvider>().renameFile(
      file: file,
      newName: newName,
    );
  }

  Future<void> _showDeleteDialog(FileItem file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir arquivo'),
          content: Text('Deseja excluir "${file.name}" da lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await context.read<FileProvider>().deleteFile(file);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }


}