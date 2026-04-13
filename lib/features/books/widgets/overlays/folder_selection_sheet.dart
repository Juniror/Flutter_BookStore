import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../models/user_folder.dart';
import '../../services/user_folder_service.dart';
import '../../models/book.dart';

/// A bottom sheet for adding a book to user-defined collections.
class FolderSelectionSheet extends StatelessWidget {
  final Book book;
  final String userId;

  const FolderSelectionSheet({
    super.key,
    required this.book,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add to Collection',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: StreamBuilder<List<UserFolder>>(
              stream: UserFolderService.getUserFolders(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final folders = snapshot.data ?? [];

                if (folders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No collections yet. Create one in Profile > My Collections',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: folders.length,
                  itemBuilder: (context, index) {
                    final folder = folders[index];
                    final bool alreadyIn = folder.bookIds.contains(book.id);

                    return ListTile(
                      leading: Icon(
                        alreadyIn ? Icons.check_circle : Icons.folder_outlined,
                        color: alreadyIn ? Colors.green : Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(folder.name),
                      onTap: alreadyIn 
                        ? null 
                        : () async {
                            await UserFolderService.addBookToFolder(folder.id, book.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              UIUtils.showSuccessSnackBar(context, 'Added to ${folder.name}');
                            }
                          },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create New Collection'),
            onTap: () {
              Navigator.pop(context);
              UIUtils.showInfoSnackBar(context, 'Go to Profile > My Collections to create new ones');
            },
          ),
        ],
      ),
    );
  }
}
