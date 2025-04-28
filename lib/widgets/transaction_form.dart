import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionForm extends StatefulWidget {
  final Function(TransactionData) onSave;
  final VoidCallback onClose;
  final TransactionData? initialData;
  final bool isEditing;

  const TransactionForm({
    required this.onSave,
    required this.onClose,
    this.initialData,
    this.isEditing = false,
    super.key,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late double amount;
  late bool isCredit;
  late bool isScheduled;
  DateTime? scheduledDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      title = widget.initialData!.title;
      amount = widget.initialData!.amount;
      isCredit = widget.initialData!.isCredit;
      isScheduled = widget.initialData!.isScheduled;
      scheduledDate = widget.initialData!.scheduledDate;
    } else {
      title = '';
      amount = 0.0;
      isCredit = true;
      isScheduled = false;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEditing ? 'Edit Transaction' : 'Add Transaction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      initialValue: title,
                      onChanged: (value) => title = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                      initialValue: amount.toString(),
                      onChanged: (value) {
                        amount = double.tryParse(value) ?? 0.0;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Income"),
                        Radio<bool>(
                          value: true,
                          groupValue: isCredit,
                          onChanged: (value) {
                            setState(() => isCredit = value ?? true);
                          },
                        ),
                        Text("Expense"),
                        Radio<bool>(
                          value: false,
                          groupValue: isCredit,
                          onChanged: (value) {
                            setState(() => isCredit = value ?? false);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(),
                    Row(
                      children: [
                        Checkbox(
                          value: isScheduled,
                          onChanged: (value) {
                            setState(() {
                              isScheduled = value ?? false;
                              if (!isScheduled) {
                                scheduledDate = null;
                              } else scheduledDate ??= DateTime.now().add(
                                  const Duration(days: 7),
                                );
                            });
                          },
                        ),
                        Text("Schedule an upcoming bill"),
                      ],
                    ),
                    if (isScheduled)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Schedule Date:",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: scheduledDate ?? DateTime.now().add(const Duration(days: 7)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setState(() => scheduledDate = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      scheduledDate == null
                                          ? "Select Date"
                                          : _formatDate(scheduledDate!),
                                    ),
                                    Icon(Icons.calendar_today, color: Colors.grey.shade700),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (isScheduled && scheduledDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please select a date for your scheduled transaction")),
                            );
                            return;
                          }

                          final dateString = isScheduled ? _formatDate(scheduledDate!) : "Today";

                          final transaction = TransactionData(
                            title: title,
                            date: dateString,
                            amount: amount,
                            isCredit: isCredit,
                            isScheduled: isScheduled,
                            scheduledDate: scheduledDate,
                          );

                          widget.onSave(transaction);

                          if (!widget.isEditing) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isScheduled
                                      ? "Upcoming bill added successfully"
                                      : "Transaction added successfully",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                          widget.onClose();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 21, 27, 84),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(widget.isEditing ? 'Update' : 'Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}