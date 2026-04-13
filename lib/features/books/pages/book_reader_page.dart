import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../../../../core/utils/ui_utils.dart';
import '../widgets/sections/book_reader_app_bar.dart';

/// An immersive page for reading book PDFs.
/// Utilizes SfPdfViewer for high-performance rendering and navigation.
class BookReaderPage extends StatefulWidget {
  final Book book;

  const BookReaderPage({super.key, required this.book});

  @override
  State<BookReaderPage> createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  // Search State
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  PdfTextSearchResult _searchResult = PdfTextSearchResult();

  // Progress State
  int _savedPageNumber = 1;

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPageNumber = prefs.getInt('book_progress_${widget.book.id}') ?? 1;
    });
  }

  Future<void> _saveProgress(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('book_progress_${widget.book.id}', pageNumber);
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _searchResult.clear();
      return;
    }
    // Perform text search over the entire PDF document
    _searchResult = _pdfViewerController.searchText(query);
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      appBar: BookReaderAppBar(
        book: widget.book,
        isSearching: _isSearching,
        searchController: _searchController,
        searchResult: _searchResult,
        onSearchToggle: () => setState(() => _isSearching = true),
        onCloseSearch: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
            _searchResult.clear();
          });
        },
        onSearch: _performSearch,
        onNextInstance: () {
          _searchResult.nextInstance();
          setState(() {});
        },
        onPreviousInstance: () {
          _searchResult.previousInstance();
          setState(() {});
        },
      ),
      body: SfPdfViewer.network(
        widget.book.pdfUrl.trim(),
        controller: _pdfViewerController,
        key: _pdfViewerKey,
        canShowScrollHead: false,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          // Jump to saved page once loaded
          if (_savedPageNumber > 1) {
            _pdfViewerController.jumpToPage(_savedPageNumber);
            UIUtils.showInfoSnackBar(context, 'Resumed at page $_savedPageNumber');
          }
        },
        onPageChanged: (PdfPageChangedDetails details) {
          _saveProgress(details.newPageNumber);
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          UIUtils.showErrorSnackBar(context, 'Failed to load PDF: ${details.description}');
        },
      ),
    );
  }
}
