import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../../../core/utils/ui_utils.dart';

class CategoryFilterRow extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryFilterRow({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: StreamBuilder<List<String>>(
        stream: CategoryService.getCategories(),
        builder: (context, snapshot) {
          final dbCategories = snapshot.data ?? [];
          final categories = ['All', ...dbCategories];
          
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) onSelected(category);
                    },
                    showCheckmark: false,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected 
                        ? Colors.white 
                        : (context.isDarkMode ? Colors.white70 : Colors.black87),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected 
                            ? Colors.transparent 
                            : (context.isDarkMode ? Colors.white10 : Colors.grey.shade200),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
