import '../../profile/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../widgets/sections/category_filter_row.dart';
import '../widgets/sections/book_grid_stream.dart';
import '../../../core/utils/ui_utils.dart';
import 'add_book_page.dart';

/// The primary library view, allowing users to browse books by category.
class MyBooksPage extends StatefulWidget {
  const MyBooksPage({super.key});

  @override
  State<MyBooksPage> createState() => _MyBooksPageState();
}

class _MyBooksPageState extends State<MyBooksPage> {
  String _selectedCategory = 'All';
  int _gridColumnCount = 3;

  @override
  Widget build(BuildContext context) {
    Query bookQuery = FirebaseFirestore.instance.collection(
      FirebaseConstants.collections.books,
    );

    if (_selectedCategory != 'All') {
      bookQuery = bookQuery.where(
        FirebaseConstants.fields.bookCategory,
        arrayContains: _selectedCategory,
      );
    }

    return Scaffold(
      backgroundColor: context.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(
            child: CategoryFilterRow(
              selectedCategory: _selectedCategory,
              onSelected: (val) => setState(() => _selectedCategory = val),
            ),
          ),
          _buildSectionHeader(context),
          BookGridStream(
            bookQuery: bookQuery,
            gridColumnCount: _gridColumnCount,
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton:
          (UserService.currentRole == FirebaseConstants.roles.admin)
          ? FloatingActionButton(
              elevation: 4,
              backgroundColor: Colors.blue,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddBookPage()),
                );
              },
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          gradient: context.gradients.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: const SafeArea(
          top: true,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Library',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Explore thousands of titles',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSectionHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCategory == 'All' ? 'Full Collection' : '$_selectedCategory Books',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.isDarkMode ? Colors.white10 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildLayoutOption(3),
                  _buildLayoutOption(4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutOption(int count) {
    final isSelected = _gridColumnCount == count;
    return GestureDetector(
      onTap: () => setState(() => _gridColumnCount = count),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? (context.isDarkMode ? Colors.white10 : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
        ),
        child: Text(
          count.toString(),
          style: const TextStyle(
          ),
        ),
      ),
    );
  }
}
