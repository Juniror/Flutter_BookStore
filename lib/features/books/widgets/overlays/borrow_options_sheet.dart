import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/widgets/inputs/primary_button.dart';

class BorrowOptionsSheet extends StatefulWidget {
  final Book book;

  const BorrowOptionsSheet({super.key, required this.book});

  @override
  State<BorrowOptionsSheet> createState() => _BorrowOptionsSheetState();
}

class _BorrowOptionsSheetState extends State<BorrowOptionsSheet> {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    Navigator.pop(context, {
      'type': 'physical',
      'address': _addressController.text.trim(),
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request Physical Copy',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Provide your address below and we will mail the book to your doorstep.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Delivery Address',
                hintText: 'Enter your full shipping address',
                prefixIcon: const Icon(Icons.home_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Address is required for physical delivery';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Confirm Delivery',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
