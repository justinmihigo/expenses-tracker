import 'package:flutter/material.dart';
import 'package:expenses_tracker/models/transaction.dart';
import 'package:expenses_tracker/providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/styles/app_colors.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isCredit = false;
  TransactionCategory _selectedCategory = TransactionCategory.food;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState!.validate()) {
      final transaction = TransactionData(
        title: _titleController.text,
        date: _selectedDate.toIso8601String(),
        amount: double.parse(_amountController.text),
        isCredit: _isCredit,
        category: _selectedCategory,
      );

      context.read<WalletProvider>().addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCredit ? 'Add Income' : 'Add Expense'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text(_isCredit ? 'Income' : 'Expense'),
                value: _isCredit,
                onChanged: (bool value) {
                  setState(() {
                    _isCredit = value;
                    // Reset category to appropriate default
                    _selectedCategory = _isCredit 
                        ? TransactionCategory.salary 
                        : TransactionCategory.food;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: TransactionCategory.values
                    .where((category) => 
                        _isCredit ? 
                        category.toString().contains('Income') || category == TransactionCategory.salary :
                        !category.toString().contains('Income'))
                    .map((category) {
                  final categoryName = category.toString().split('.').last;
                  return DropdownMenuItem(
                    value: category,
                    child: Text('${categoryName[0].toUpperCase()}${categoryName.substring(1)}'),
                  );
                }).toList(),
                onChanged: (TransactionCategory? value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(_selectedDate.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  child: Text(_isCredit ? 'Add Income' : 'Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
