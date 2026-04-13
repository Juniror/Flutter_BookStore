import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_folder_service.dart';
import '../models/user_folder.dart';
import '../../../core/utils/ui_utils.dart';

import 'folder_detail_page.dart';

class CustomFoldersPage extends StatefulWidget {
  const CustomFoldersPage({super.key});

  @override
  State<CustomFoldersPage> createState() => _CustomFoldersPageState();
}

class _CustomFoldersPageState extends State<CustomFoldersPage> {
  final _user = FirebaseAuth.instance.currentUser;

  Future<void> _onCreateFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter collection name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty && _user != null) {
      await UserFolderService.createFolder(_user.uid, name.trim());
      if (mounted) UIUtils.showSuccessSnackBar(context, 'Collection created!');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const Scaffold(body: Center(child: Text('Please log in')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collections'),
        elevation: 0,
      ),
      body: StreamBuilder<List<UserFolder>>(
        stream: UserFolderService.getUserFolders(_user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final folders = snapshot.data ?? [];

          if (folders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: context.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No collections yet', style: TextStyle(color: context.isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onCreateFolder,
                    child: const Text('Create Your First Collection'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return Card(
                elevation: 0,
                color: context.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.folder, color: Colors.orange),
                  title: Text(folder.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${folder.bookIds.length} books'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Collection?'),
                              content: const Text('This will permanently remove this collection.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await UserFolderService.deleteFolder(folder.id);
                          }
                        },
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FolderDetailPage(folder: folder),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateFolder,
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}
