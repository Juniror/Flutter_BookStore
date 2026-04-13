import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/widgets/inputs/custom_text_field.dart';
import '../../services/category_service.dart';

/// A widget for managing book categories with chips, input, and suggestions.
class CategorySelector extends StatelessWidget {
  final List<String> selectedCategories;
  final TextEditingController inputController;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const CategorySelector({
    super.key,
    required this.selectedCategories,
    required this.inputController,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Selected Categories chips
        if (selectedCategories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedCategories.map((cat) => _buildCategoryChip(context, cat)).toList(),
            ),
          ),
        
        // Category Input
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: inputController,
                labelText: 'Add Category (e.g. Fiction)',
                prefixIcon: const Icon(Icons.category_outlined),
                onSubmitted: onAdd,
              ),
            ),
            const SizedBox(width: 12),
            _buildAddButton(),
          ],
        ),
        const SizedBox(height: 12),

        // Category Suggestions
        _buildCategorySuggestions(context),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, String cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(context.isDarkMode ? 40 : 10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            cat,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onRemove(cat),
            child: const Icon(Icons.close_rounded, size: 14, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => onAdd(inputController.text),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildCategorySuggestions(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: CategoryService.getCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
        
        final suggestions = snapshot.data!
            .where((c) => !selectedCategories.contains(c))
            .take(5)
            .toList();
            
        if (suggestions.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Suggestions:',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = suggestions[index];
                  return ActionChip(
                    label: Text(cat),
                    onPressed: () => onAdd(cat),
                    padding: EdgeInsets.zero,
                    labelStyle: TextStyle(
                      fontSize: 12, 
                      color: context.isDarkMode ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: context.isDarkMode ? Colors.white10 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: context.isDarkMode ? Colors.white10 : Colors.grey.shade300),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    );
  }
}
