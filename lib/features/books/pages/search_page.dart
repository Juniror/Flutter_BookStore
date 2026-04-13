import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../models/book.dart';
import '../widgets/cards/book_card.dart';
import '../services/category_service.dart';
import '../../../core/widgets/inputs/custom_text_field.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/skeleton_loader.dart';
import '../../../core/utils/ui_utils.dart';

/// A page for searching books by title, author, or category.
/// Features a searchable text field and category suggestions.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),

          // Horizontal list of suggested categories
          SliverToBoxAdapter(
            child: _searchQuery.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                        child: Text(
                          'Explore Categories',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: StreamBuilder<List<String>>(
                          stream: CategoryService.getCategories(),
                          builder: (context, snapshot) {
                            final categories = snapshot.data ?? [];
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ActionChip(
                                    label: Text(categories[index]),
                                    onPressed: () {
                                      _searchController.text = categories[index];
                                    },
                                    backgroundColor: Theme.of(context).primaryColor.withAlpha(context.isDarkMode ? 50 : 15),
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // Live search results matching the query
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(FirebaseConstants.collections.books)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SkeletonLoader.bookCard(width: double.infinity, height: 160),
                      ),
                      childCount: 3,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.library_books_rounded,
                    title: 'Library is Empty',
                    message: 'Coming soon! We are stockig our shelves with new books.',
                  ),
                );
              }

              final allBooks = snapshot.data!.docs
                  .map((doc) => Book.fromFirestore(doc))
                  .toList();

              final filteredBooks = allBooks.where((book) {
                final title = book.title.toLowerCase();
                final author = book.author.toLowerCase();
                final categories = book.categories.map((c) => c.toLowerCase()).toList();
                
                return title.contains(_searchQuery) ||
                    author.contains(_searchQuery) ||
                    categories.any((c) => c.contains(_searchQuery));
              }).toList();

              if (_searchQuery.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.manage_search_rounded,
                    title: 'Find your Next Favorite',
                    message: 'Search for titles, authors, or categories above to explore.',
                  ),
                );
              }

              if (filteredBooks.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState.noSearchResults(query: _searchQuery),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: BookCard(book: filteredBooks[index]),
                      );
                    },
                    childCount: filteredBooks.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          gradient: context.gradients.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Discover',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _searchController,
                hintText: 'Find books or authors...',
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
