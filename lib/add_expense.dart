import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spendlite/currency_provider.dart';
import 'package:spendlite/expense_model.dart';
import 'package:spendlite/expense_provider.dart' show expenseServiceProvider, expenseCategories;

import 'package:spendlite/main.dart'; // Import main for custom colors

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize with a default category
    _selectedCategory = expenseCategories.first;
  }

  // Fast date picker (optional for speed)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        // Apply custom dark theme to the date picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: SpendLiteApp.primaryColor,
              onPrimary: Colors.white,
              surface: SpendLiteApp.cardColor,
              onSurface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: SpendLiteApp.primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null || _selectedCategory == null) return;

      final newExpense = Expense(
        amount: amount,
        category: _selectedCategory!,
        date: _selectedDate,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      );

      // Call the service layer to add the expense
      await ref.read(expenseServiceProvider.notifier).addExpense(newExpense);
      
      // Close the bottom sheet with a smooth animation
      if (mounted) Navigator.of(context).pop();

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('-\$${amount.toStringAsFixed(2)} for $_selectedCategory recorded.'),
        duration: const Duration(seconds: 2),
        backgroundColor: SpendLiteApp.primaryColor,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: SpendLiteApp.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Record New Spend',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Amount Input Field
            TextFormField(
  controller: _amountController,
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  autofocus: true,
  style: const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: SpendLiteApp.accentColor,
  ),
  decoration: InputDecoration(
    prefixText: ref.watch(currencyProvider) + ' ', // dynamically show the selected currency
    hintText: '0.00',
    hintStyle: const TextStyle(color: Colors.white24),
    border: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  ),
  validator: (value) {
    if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Enter a valid amount.';
    }
    return null;
  },
),

            const Divider(color: Colors.white12),

            // Description Input Field
            TextFormField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: SpendLiteApp.primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category Selector
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: expenseCategories.map((category) {
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: SpendLiteApp.primaryColor,
                  disabledColor: Colors.white10,
                  backgroundColor: SpendLiteApp.cardColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Date Picker Row
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: SpendLiteApp.accentColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _saveExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: SpendLiteApp.primaryColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
              ),
              child: const Text(
                'Record Spend',
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}