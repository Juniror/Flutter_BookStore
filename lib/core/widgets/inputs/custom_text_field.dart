import 'package:flutter/material.dart';
import '../../utils/ui_utils.dart';

/// A themed text input field with consistent styling and shadow.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final String? hintText;
  final Function(String)? onSubmitted;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText = '',
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.hintText,
    this.onSubmitted,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.isDarkMode ? Colors.black.withAlpha(80) : Colors.black.withAlpha(15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onSubmitted: onSubmitted,
        maxLines: maxLines,
        style: TextStyle(
          color: context.isDarkMode ? Colors.white : const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: labelText.isNotEmpty ? labelText : null,
          hintText: hintText,
          hintStyle: TextStyle(
            color: context.isDarkMode ? Colors.white38 : const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          labelStyle: TextStyle(
            color: context.isDarkMode ? Colors.white60 : const Color(0xFF64748B),
            fontSize: 14,
          ),
          prefixIcon: prefixIcon != null ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IconTheme(
              data: IconThemeData(
                color: context.isDarkMode 
                    ? Theme.of(context).primaryColor.withAlpha(200) 
                    : Theme.of(context).primaryColor,
                size: 20,
              ),
              child: prefixIcon!,
            ),
          ) : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}
