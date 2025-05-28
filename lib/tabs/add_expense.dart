import 'package:flutter/material.dart';
import 'package:expenses_tracker/models/transaction.dart';
import 'package:expenses_tracker/models/notification.dart';
import 'package:expenses_tracker/providers/wallet_provider.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/styles/app_colors.dart';
import 'package:expenses_tracker/services/notification_service.dart';
import 'package:expenses_tracker/sqlite.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notificationService = NotificationService();
  final _db = SQLiteDB.instance;
  bool _isCredit = false;
  bool _isScheduled = false;
  TransactionCategory _selectedCategory = TransactionCategory.food;
  DateTime _selectedDate = DateTime.now();
  DateTime? _scheduledDate;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null, // null means use default app icon
      [
        NotificationChannel(
          channelKey: 'transactions',
          channelName: 'Transaction Notifications',
          channelDescription: 'Notifications for transaction updates',
          defaultColor: const Color(0xFF2C1F63),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
        ),
      ],
    );

    // Request permission to show notifications
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  Future<void> _showNotification(String title, String message) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'transactions',
          title: title,
          body: message,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Social,
          wakeUpScreen: true,
          fullScreenIntent: false,
          criticalAlert: false,
        ),
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, {bool isScheduled = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isScheduled ? (_scheduledDate ?? DateTime.now()) : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isScheduled) {
          _scheduledDate = picked;
        } else {
          _selectedDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      try {
        debugPrint('Creating new transaction...');
        final transaction = TransactionData(
          title: _titleController.text,
          date: TransactionData.formatDateForStorage(_selectedDate),
          amount: double.parse(_amountController.text),
          isCredit: _isCredit,
          category: _selectedCategory,
          isScheduled: _isScheduled,
          scheduledDate: _scheduledDate,
        );
        debugPrint('Transaction created: ${transaction.toMap()}');

        // Add transaction to SQLite through WalletProvider
        debugPrint('Adding transaction through WalletProvider...');
        await context.read<WalletProvider>().addTransaction(transaction);
        debugPrint('Transaction added successfully');

        // Add notification to database
        debugPrint('Creating notification...');
        final notification = NotificationData(
          title: _isCredit ? 'Income Added' : 'Expense Added',
          message: '${transaction.title} - ${transaction.amount.toStringAsFixed(2)} Rwf has been ${_isCredit ? 'added' : 'deducted'}',
          timestamp: DateTime.now(),
          transactionId: transaction.id,
        );
        await _notificationService.addNotification(notification);
        debugPrint('Notification added successfully');

        // Show system notification
        debugPrint('Showing system notification...');
        await _showNotification(
          _isCredit ? 'Income Added' : 'Expense Added',
          '${transaction.title} - ${transaction.amount.toStringAsFixed(2)} Rwf has been ${_isCredit ? 'added' : 'deducted'}',
        );
        debugPrint('System notification shown');

        // If it's a scheduled transaction, check for upcoming bill notification
        if (_isScheduled && _scheduledDate != null) {
          debugPrint('Checking for upcoming bill notification...');
          final daysUntilDue = _scheduledDate!.difference(DateTime.now()).inDays;
          if (daysUntilDue <= 2) {
            await _notificationService.checkUpcomingBill(
              transaction,
              daysUntilDue,
              (message) async {
                await _showNotification('Upcoming Bill', message);
              },
            );
          }
        }

        if (mounted) {
          // Show toast message
          debugPrint('Showing success toast...');
          Fluttertoast.showToast(
            msg: '${_isCredit ? 'Income' : 'Expense'} added successfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          // Wait for toast to be visible before popping
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            debugPrint('Navigating back...');
            Navigator.pop(context);
          }
        }
      } catch (e, stackTrace) {
        debugPrint('Error saving transaction: $e');
        debugPrint('Stack trace: $stackTrace');
        if (mounted) {
          Fluttertoast.showToast(
            msg: 'Error saving transaction: $e',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      }
    }
  }

  String _formatDisplayDate(DateTime date) {
    final months = {
      1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
      7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec'
    };
    return "${months[date.month]} ${date.day}, ${date.year}";
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
              SwitchListTile(
                title: const Text('Schedule for Later'),
                value: _isScheduled,
                onChanged: (bool value) {
                  setState(() {
                    _isScheduled = value;
                    if (value && _scheduledDate == null) {
                      _scheduledDate = DateTime.now().add(const Duration(days: 1));
                    }
                  });
                },
              ),
              if (_isScheduled) ...[
                ListTile(
                  title: const Text('Scheduled Date'),
                  subtitle: Text(_scheduledDate != null 
                    ? TransactionData.formatDateForDisplay(_scheduledDate!) 
                    : 'Select date'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, isScheduled: true),
                ),
                const SizedBox(height: 16),
              ],
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
                  prefixText: 'Rwf ',
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
                subtitle: Text(TransactionData.formatDateForDisplay(_selectedDate)),
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
