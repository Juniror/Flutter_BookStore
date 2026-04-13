import 'package:flutter/material.dart';
import '../models/user_folder.dart';
import '../models/book.dart';
import '../services/user_folder_service.dart';
import '../widgets/cards/book_grid_card.dart';
import '../../../core/constants/ui_constants.dart';

/// Displays the contents of a specific user collection.
class FolderDetailPage extends StatelessWidget {
  final UserFolder folder;

  const FolderDetailPage({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(folder.name),
      ),
      body: StreamBuilder<List<Book>>(
        stream: UserFolderService.getBooksByIds(folder.bookIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No books in this collection yet',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(UIConstants.paddingLarge),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return BookGridCard(book: books[index]);
            },
          );
        },
      ),
    );
  }
}
