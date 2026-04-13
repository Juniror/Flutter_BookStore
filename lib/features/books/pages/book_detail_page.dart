import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';
import '../services/borrow_service.dart';
import '../services/favorite_service.dart';
import '../services/history_service.dart';
import '../../../core/utils/ui_utils.dart';
import '../widgets/sections/book_detail_actions.dart';
import '../widgets/sections/book_detail_body.dart';
import '../widgets/overlays/folder_selection_sheet.dart';
import '../widgets/overlays/borrow_options_sheet.dart';
import '../../../core/widgets/feedback/optimized_network_image.dart';

/// Displays comprehensive details about a specific book.
/// Provides borrow, share, and favorite functionality.
class BookDetailPage extends StatefulWidget {
  final Book book;
  final String? heroTag;

  const BookDetailPage({super.key, required this.book, this.heroTag});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _isBorrowing = false;
  late final String _effectiveHeroTag;
  final ScrollController _scrollController = ScrollController();
  bool _isBottomBarVisible = true;

  @override
  void initState() {
    super.initState();
    _effectiveHeroTag = widget.heroTag ?? 'book_image_${widget.book.id}';
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final direction = _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.reverse && currentOffset > 100) {
      if (_isBottomBarVisible) setState(() => _isBottomBarVisible = false);
    } else if (direction == ScrollDirection.forward || currentOffset <= 0) {
      if (!_isBottomBarVisible) setState(() => _isBottomBarVisible = true);
    }
    
    // Always show at the very bottom
    if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
      if (!_isBottomBarVisible) setState(() => _isBottomBarVisible = true);
    }
  }

  void _toggleSave() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      UIUtils.showErrorSnackBar(context, 'Please log in to save books');
      return;
    }
    
    final isSaved = await HistoryService.isInHistory(user.uid, widget.book.id).first;
    if (isSaved) {
      await HistoryService.removeFromHistory(user.uid, widget.book.id);
      if (mounted) UIUtils.showInfoSnackBar(context, 'Removed from My Books');
    } else {
      await HistoryService.addToHistory(book: widget.book, userId: user.uid);
      if (mounted) UIUtils.showSuccessSnackBar(context, 'Saved to My Books!');
    }
  }

  void _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      UIUtils.showErrorSnackBar(context, 'Please log in to favorite books');
      return;
    }
    await FavoriteService.toggleFavorite(
      userId: user.uid,
      book: widget.book,
    );
  }

  void _handleBorrow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      UIUtils.showErrorSnackBar(context, 'Please log in to borrow books');
      return;
    }

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BorrowOptionsSheet(book: widget.book),
    );

    if (result == null) return; // User canceled

    final String type = result['type'];
    final String? deliveryAddress = result['address'];

    setState(() => _isBorrowing = true);

    try {
      await BorrowService.borrowBook(
        book: widget.book,
        userId: user.uid,
        type: type,
        deliveryAddress: deliveryAddress,
      );
      if (mounted) {
        UIUtils.showSuccessSnackBar(context, 'Successfully borrowed!');
      }
    } catch (e) {
      if (mounted) UIUtils.showErrorSnackBar(context, 'Failed to borrow: $e');
    } finally {
      if (mounted) setState(() => _isBorrowing = false);
    }
  }

  void _showFolderSelection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      UIUtils.showErrorSnackBar(context, 'Please log in to use collections');
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => FolderSelectionSheet(book: widget.book, userId: user.uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: context.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(context, user),
              SliverToBoxAdapter(
                child: BookDetailBody(book: widget.book),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: _isBottomBarVisible ? Offset.zero : const Offset(0, 1.2),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              child: BookDetailActions(
                book: widget.book,
                isBorrowing: _isBorrowing,
                onBorrow: _handleBorrow,
                onShare: () => UIUtils.showInfoSnackBar(context, 'Social sharing integration coming soon.'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, User? user) {
    final themeColor = context.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    
    return SliverAppBar(
      expandedHeight: 440,
      pinned: true,
      floating: false,
      snap: false,
      elevation: 0,
      stretch: true,
      backgroundColor: themeColor,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: context.isDarkMode ? Colors.black45 : Colors.white24,
            shape: BoxShape.circle,
            border: Border.all(color: context.isDarkMode ? Colors.white.withAlpha(51) : Colors.white.withAlpha(77)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        if (user != null) _buildSaveButton(user),
        if (user != null) _buildFavoriteButton(user),
        if (user != null) _buildFolderButton(),
        const SizedBox(width: 14),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate background opacity based on collapse progress.
            const double expandedHeight = 440.0;
            final double currentHeight = constraints.maxHeight;
            // 0.0 represents fully expanded, 1.0 represents fully collapsed.
            final double collapseRatio = ((expandedHeight - currentHeight) / (expandedHeight - kToolbarHeight)).clamp(0.0, 1.0);
            
            return Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: _effectiveHeroTag,
                  child: OptimizedNetworkImage(
                    imageUrl: widget.book.coverImageUrl,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
                // Color overlay that transitions as the user scrolls.
                Opacity(
                  opacity: collapseRatio,
                  child: Container(color: themeColor),
                ),
                // Top shadow scrim (transitions out as the solid background fades in).
                Opacity(
                  opacity: (1.0 - collapseRatio).clamp(0.0, 1.0),
                  child: Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(150),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton(User user) {
    return StreamBuilder<bool>(
      stream: HistoryService.isInHistory(user.uid, widget.book.id),
      builder: (context, snapshot) {
        final isSaved = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.black45 : Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(color: context.isDarkMode ? Colors.white.withAlpha(51) : Colors.white.withAlpha(77)),
            ),
            child: IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                color: isSaved ? Theme.of(context).primaryColor : Colors.white,
              ),
              onPressed: _toggleSave,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteButton(User user) {
    return StreamBuilder<bool>(
      stream: FavoriteService.isFavorite(user.uid, widget.book.id),
      builder: (context, snapshot) {
        final isFav = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: context.isDarkMode ? Colors.black45 : Colors.white24,
              shape: BoxShape.circle,
              border: Border.all(color: context.isDarkMode ? Colors.white.withAlpha(51) : Colors.white.withAlpha(77)),
            ),
            child: IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.red : Colors.white,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFolderButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.black45 : Colors.white24,
          shape: BoxShape.circle,
          border: Border.all(color: context.isDarkMode ? Colors.white.withAlpha(51) : Colors.white.withAlpha(77)),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.create_new_folder_outlined, 
            color: Colors.white,
          ),
          onPressed: _showFolderSelection,
        ),
      ),
    );
  }
}
