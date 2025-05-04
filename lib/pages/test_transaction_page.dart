import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/transaction.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';


class TestTransactionPage extends StatefulWidget {
  const TestTransactionPage({super.key});

  @override
  State<TestTransactionPage> createState() => _TestTransactionPageState();
}

class _TestTransactionPageState extends State<TestTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final _notificationService = NotificationService();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isCredit = false;
  bool _isScheduled = false;
  TransactionCategory _selectedCategory = TransactionCategory.food;
  final DateTime _date = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Future<void> _createTransaction() async {
    if (_formKey.currentState!.validate()) {
      try {
        final transaction = TransactionData(
          title: _titleController.text,
          date: _formatDate(_date),
          amount: double.parse(_amountController.text),
          isCredit: _isCredit,
          isScheduled: _isScheduled,
          category: _selectedCategory,
        );

        await _firebaseService.createTransaction(transaction);
        
        // Send FCM notification
        await _firebaseService.sendTransactionNotification(transaction);
        
        // Create and store local notification
        final notification = NotificationData(
          title: 'Transaction Created',
          message: '${transaction.title} - ${transaction.amount.toStringAsFixed(2)} Rwf has been ${transaction.isCredit ? 'added' : 'deducted'}',
          timestamp: DateTime.now(),
          transactionId: transaction.id,
        );
        
        await _notificationService.addNotification(notification);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction created successfully!')),
          );
          _formKey.currentState!.reset();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating transaction: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Transaction Creation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Is Credit'),
                      value: _isCredit,
                      onChanged: (value) {
                        setState(() {
                          _isCredit = value ?? false;
                          // Reset category based on transaction type
                          _selectedCategory = _isCredit 
                              ? TransactionCategory.salary 
                              : TransactionCategory.food;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Is Scheduled'),
                      value: _isScheduled,
                      onChanged: (value) {
                        setState(() {
                          _isScheduled = value ?? false;
                        });
                      },
                    ),
                  ),
                ],
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
              ElevatedButton(
                onPressed: _createTransaction,
                child: const Text('Create Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 