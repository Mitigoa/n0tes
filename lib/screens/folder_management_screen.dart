import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/folder_provider.dart';
import '../widgets/color_picker.dart';
import '../models/folder_model.dart';

class FolderManagementScreen extends StatefulWidget {
  const FolderManagementScreen({Key? key}) : super(key: key);

  @override
  State<FolderManagementScreen> createState() => _FolderManagementScreenState();
}

class _FolderManagementScreenState extends State<FolderManagementScreen> {
  void _showCreateFolderDialog() {
    String folderName = '';
    int selectedColor = 0xFFF28B82; // Default red
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Folder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Folder Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => folderName = val,
                  ),
                  const SizedBox(height: 16),
                  const Text('Color:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ColorPicker(
                    selectedColor: selectedColor,
                    onColorSelected: (color) {
                      setState(() {
                        selectedColor = color;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (folderName.trim().isEmpty) return;
                    try {
                      await context.read<FolderProvider>().createFolder(
                        folderName.trim(),
                        selectedColor,
                      );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteFolderDialog(Folder folder) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Folder'),
          content: Text('Are you sure you want to delete "${folder.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await context.read<FolderProvider>().deleteFolder(folder.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
      ),
      body: Consumer<FolderProvider>(
        builder: (context, folderProvider, child) {
          if (folderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final folders = folderProvider.folders;

          if (folders.isEmpty) {
            return const Center(child: Text('No folders.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: folders.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final folder = folders[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Color(folder.colorCode),
                  child: const Icon(Icons.folder, color: Colors.white),
                ),
                title: Text(folder.name),
                trailing: folder.id == FolderProvider.generalFolderId
                    ? null // Cannot delete generic folder
                    : IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _showDeleteFolderDialog(folder),
                      ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateFolderDialog,
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}
