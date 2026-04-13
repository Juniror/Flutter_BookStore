import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/widgets/inputs/custom_text_field.dart';
import '../../../core/widgets/inputs/primary_button.dart';
import '../../../core/widgets/layout/standard_header.dart';
import '../../../core/widgets/layout/section_label.dart';
import '../models/book.dart';
import '../services/category_service.dart';
import '../../../core/utils/ui_utils.dart';
import '../widgets/overlays/category_selector.dart';

/// A page for adding new books to the library collection.
/// Includes form validation and real-time category suggestions.
class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryInputController = TextEditingController();
  final _publishedYearController = TextEditingController();
  final _copiesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pdfUrlController = TextEditingController();

  final List<String> _selectedCategories = [];
  bool _isSaving = false;

  bool _validateInputs() {
    if (_titleController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _selectedCategories.isEmpty ||
        _publishedYearController.text.trim().isEmpty ||
        _copiesController.text.trim().isEmpty) {
      UIUtils.showErrorSnackBar(context, 'Please fill in all required fields (including at least one category)');
      return false;
    }

    if (int.tryParse(_copiesController.text.trim()) == null) {
      UIUtils.showErrorSnackBar(context, 'Total copies must be a valid number');
      return false;
    }
    return true;
  }

  void _addCategory(String category) {
    final clean = category.trim();
    if (clean.isNotEmpty && !_selectedCategories.contains(clean)) {
      setState(() {
        _selectedCategories.add(clean);
        _categoryInputController.clear();
      });
    }
  }

  void _removeCategory(String category) {
    setState(() {
      _selectedCategories.remove(category);
    });
  }

  Future<void> _submit() async {
    if (!_validateInputs()) return;

    setState(() => _isSaving = true);

    try {
      final totalCopies = int.parse(_copiesController.text.trim());
      
      final newBook = Book(
        id: '', // Firestore auto-generates ID on add()
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        categories: _selectedCategories,
        publishedYear: _publishedYearController.text.trim(),
        totalCopies: totalCopies,
        availableCopies: totalCopies,
        description: _descriptionController.text.trim(),
        pdfUrl: _pdfUrlController.text.trim(),
      );

      // Save categories globally so they appear in the filter chips
      await CategoryService.ensureCategoriesExist(newBook.categories);

      await FirebaseFirestore.instance.collection(FirebaseConstants.collections.books).add(newBook.toMap());

      if (mounted) {
        UIUtils.showSuccessSnackBar(context, 'Book added successfully!');
        Navigator.pop(context); // Go back to home page
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorSnackBar(context, 'Error adding book: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _categoryInputController.dispose();
    _publishedYearController.dispose();
    _copiesController.dispose();
    _descriptionController.dispose();
    _pdfUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: StandardPageHeader(
              title: 'Add New Book',
              subtitle: 'Expand the library collection',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionLabel(label: 'General Information'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _titleController,
                    labelText: 'Book Title',
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _authorController,
                    labelText: 'Author Name',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  
                  const SizedBox(height: 32),
                  const SectionLabel(label: 'Classification'),
                  const SizedBox(height: 16),
                  
                  CategorySelector(
                    selectedCategories: _selectedCategories,
                    inputController: _categoryInputController,
                    onAdd: _addCategory,
                    onRemove: _removeCategory,
                  ),

                  const SizedBox(height: 32),
                  const SectionLabel(label: 'Publication Details'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _publishedYearController,
                          labelText: 'Year',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.calendar_today_rounded),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _copiesController,
                          labelText: 'Copies',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.numbers_rounded),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const SectionLabel(label: 'Additional Content'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    labelText: 'Description (Optional)',
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _pdfUrlController,
                    labelText: 'PDF URL (Optional)',
                    prefixIcon: const Icon(Icons.picture_as_pdf_outlined),
                  ),
                  
                  const SizedBox(height: 48),
                  PrimaryButton(
                    text: 'Publish Book',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: _submit,
                    isLoading: _isSaving,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

