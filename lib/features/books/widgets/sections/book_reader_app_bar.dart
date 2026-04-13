import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../models/book.dart';

class BookReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Book book;
  final bool isSearching;
  final TextEditingController searchController;
  final PdfTextSearchResult searchResult;
  final VoidCallback onSearchToggle;
  final VoidCallback onCloseSearch;
  final ValueChanged<String> onSearch;
  final VoidCallback onNextInstance;
  final VoidCallback onPreviousInstance;

  const BookReaderAppBar({
    super.key,
    required this.book,
    required this.isSearching,
    required this.searchController,
    required this.searchResult,
    required this.onSearchToggle,
    required this.onCloseSearch,
    required this.onSearch,
    required this.onNextInstance,
    required this.onPreviousInstance,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onCloseSearch,
        ),
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search within book...',
            border: InputBorder.none,
          ),
          onSubmitted: onSearch,
          onChanged: (val) {
            if (val.isEmpty) onCloseSearch();
          },
        ),
        actions: [
          if (searchResult.hasResult) ...[
            Center(
              child: Text(
                '${searchResult.currentInstanceIndex} of ${searchResult.totalInstanceCount}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up),
              onPressed: onPreviousInstance,
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: onNextInstance,
            ),
          ],
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCloseSearch,
          ),
        ],
      );
    }

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            book.author,
            style: TextStyle(
              fontSize: 12,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchToggle,
        ),
      ],
    );
  }
}
