import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class WalletData {
  double totalBalance;
  List<TransactionData> transactions;
  List<TransactionData> upcomingBills;

  WalletData({
    required this.totalBalance,
    required this.transactions,
    required this.upcomingBills,
  });

  
  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'upcomingBills': upcomingBills.map((t) => t.toJson()).toList(),
    };
  }

  
  factory WalletData.fromJson(Map<String, dynamic> json) {
    return WalletData(
      totalBalance: json['totalBalance'] ?? 0.0,
      transactions: (json['transactions'] as List?)
          ?.map((t) => TransactionData.fromJson(t as Map<String, dynamic>))
          .toList() ??
          [],
      upcomingBills: (json['upcomingBills'] as List?)
          ?.map((t) => TransactionData.fromJson(t as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

 
  factory WalletData.initial() {
    return WalletData(
      totalBalance: 2548.00,
      transactions: [
        TransactionData(
            title: "Upwork", date: "Today", amount: 850.00, isCredit: true),
        TransactionData(
            title: "Transfer", date: "Yesterday", amount: 85.00, isCredit: false),
      ],
      upcomingBills: [
        TransactionData(
            title: "Netflix", date: "Aug 5, 2024", amount: 15.99, isCredit: false),
      ],
    );
  }
}

class TransactionData {
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final bool isScheduled;
  final String? scheduledDateStr; 

  TransactionData({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    this.isScheduled = false,
    DateTime? scheduledDate,
  }) : scheduledDateStr = scheduledDate?.toIso8601String();


  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'amount': amount,
      'isCredit': isCredit,
      'isScheduled': isScheduled,
      'scheduledDateStr': scheduledDateStr,
    };
  }

 
  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : json['amount'] ?? 0.0,
      isCredit: json['isCredit'] ?? false,
      isScheduled: json['isScheduled'] ?? false,
      scheduledDate: json['scheduledDateStr'] != null
          ? DateTime.parse(json['scheduledDateStr'])
          : null,
    );
  }
}


class WalletService {
  static const String _fileName = 'wallet_data.json';
  
  
  static Future<File> get _file async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
  
  
  static Future<void> saveWalletData(WalletData data) async {
    try {
      final file = await _file;
      final jsonData = jsonEncode(data.toJson());
      await file.writeAsString(jsonData);
    } catch (e) {
      print('Error saving wallet data: $e');
    }
  }
  
  
  static Future<WalletData> loadWalletData() async {
    try {
      final file = await _file;
      
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        return WalletData.fromJson(jsonDecode(jsonData));
      }
    } catch (e) {
      print('Error loading wallet data: $e');
    }
    
    
    return WalletData.initial();
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedIndex = 0;
  late WalletData _walletData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  
  Future<void> _loadWalletData() async {
    final data = await WalletService.loadWalletData();
    setState(() {
      _walletData = data;
      _isLoading = false;
    });
  }

  
  void _saveWalletData() {
    WalletService.saveWalletData(_walletData);
  }
  
  // Add method to handle transaction edits
  void _handleEditTransaction(int index, TransactionData transaction, bool isUpcomingBill) {
    // Calculate the original balance impact
    double originalBalanceImpact = 0;
    if (!transaction.isScheduled) {
      originalBalanceImpact = transaction.isCredit 
        ? transaction.amount 
        : -transaction.amount;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TransactionForm(
          initialData: transaction,
          isEditing: true,
          onSave: (TransactionData updatedTransaction) {
            setState(() {
              // Update total balance if not scheduled
              if (!updatedTransaction.isScheduled && !transaction.isScheduled) {
                // Remove original transaction impact from balance
                _walletData.totalBalance -= originalBalanceImpact;
                
                // Add updated transaction impact to balance
                if (updatedTransaction.isCredit) {
                  _walletData.totalBalance += updatedTransaction.amount;
                } else {
                  _walletData.totalBalance -= updatedTransaction.amount;
                }
              } 
              // If transaction changed from scheduled to immediate
              else if (!updatedTransaction.isScheduled && transaction.isScheduled) {
                if (updatedTransaction.isCredit) {
                  _walletData.totalBalance += updatedTransaction.amount;
                } else {
                  _walletData.totalBalance -= updatedTransaction.amount;
                }
              }
              // If transaction changed from immediate to scheduled
              else if (updatedTransaction.isScheduled && !transaction.isScheduled) {
                _walletData.totalBalance -= originalBalanceImpact;
              }

              // Handle the case where a transaction moves between lists
              if (updatedTransaction.isScheduled != transaction.isScheduled) {
                // If it was regular and now scheduled, remove from transactions and add to bills
                if (updatedTransaction.isScheduled) {
                  if (!isUpcomingBill) {
                    _walletData.transactions.removeAt(index);
                    _walletData.upcomingBills.add(updatedTransaction);
                  }
                } 
                // If it was scheduled and now regular, remove from bills and add to transactions
                else {
                  if (isUpcomingBill) {
                    _walletData.upcomingBills.removeAt(index);
                    _walletData.transactions.add(updatedTransaction);
                  }
                }
              } else {
                // Just update in the current list
                if (isUpcomingBill) {
                  _walletData.upcomingBills[index] = updatedTransaction;
                } else {
                  _walletData.transactions[index] = updatedTransaction;
                }
              }
              
              _saveWalletData();
            });
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
  
  // Add method to handle transaction deletion
  void _handleDeleteTransaction(int index, TransactionData transaction, bool isUpcomingBill) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  // If it's not a scheduled transaction, update the balance
                  if (!transaction.isScheduled) {
                    // If it was a credit, remove the amount from the balance
                    // If it was a debit, add the amount back to the balance
                    if (transaction.isCredit) {
                      _walletData.totalBalance -= transaction.amount;
                    } else {
                      _walletData.totalBalance += transaction.amount;
                    }
                  }
                  
                  // Remove from the appropriate list
                  if (isUpcomingBill) {
                    _walletData.upcomingBills.removeAt(index);
                  } else {
                    _walletData.transactions.removeAt(index);
                  }
                  
                  _saveWalletData();
                  
                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transaction deleted successfully'),
                      backgroundColor: Colors.red,
                    )
                  );
                });
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: const Color.fromARGB(255, 21, 27, 84),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Wallet",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 24),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
            toolbarHeight: 120,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Text("Total Balance", style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      "\$${_walletData.totalBalance.toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 10, 17, 90),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WalletActionButton(
                  icon: Icons.add,
                  label: "Add Transaction",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TransactionForm(
                          onSave: (TransactionData transaction) {
                            setState(() {
                              // Update the total balance for immediate transactions
                              if (!transaction.isScheduled) {
                                if (transaction.isCredit) {
                                  _walletData.totalBalance += transaction.amount;
                                } else {
                                  _walletData.totalBalance -= transaction.amount;
                                }
                              }
                              
                              if (transaction.isScheduled) {
                                _walletData.upcomingBills.add(transaction);
                              } else {
                                _walletData.transactions.add(transaction);
                              }
                              
                              _saveWalletData();
                            });
                          },
                          onClose: () {
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 10),
                WalletActionButton(
                  icon: Icons.history,
                  label: "History",
                  onPressed: () {
                    // Add your history action here
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Color.fromARGB(255, 30, 38, 120),
              isSelected: [selectedIndex == 0, selectedIndex == 1],
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Transactions", style: GoogleFonts.poppins()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Upcoming Bills", style: GoogleFonts.poppins()),
                ),
              ],
              onPressed: (int index) {
                setState(() => selectedIndex = index);
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedIndex == 0
                ? TransactionsList(
                    transactions: _walletData.transactions,
                    onEdit: (index, transaction) => _handleEditTransaction(index, transaction, false),
                    onDelete: (index, transaction) => _handleDeleteTransaction(index, transaction, false),
                  )
                : UpcomingBillsList(
                    upcomingBills: _walletData.upcomingBills,
                    onEdit: (index, bill) => _handleEditTransaction(index, bill, true),
                    onDelete: (index, bill) => _handleDeleteTransaction(index, bill, true),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}


class WalletActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const WalletActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.deepPurple.shade100,
            child: Icon(icon, color: Colors.deepPurple, size: 28),
          ),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }
}

class TransactionsList extends StatelessWidget {
  final List<TransactionData> transactions;
  final Function(int index, TransactionData transaction) onEdit;
  final Function(int index, TransactionData transaction) onDelete;
  
  const TransactionsList({
    required this.transactions, 
    required this.onEdit,
    required this.onDelete,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Text(
          "No transactions yet",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return WalletTransactionItem(
          title: transaction.title,
          date: transaction.date,
          amount: (transaction.isCredit ? "+" : "-") + "\$${transaction.amount.toStringAsFixed(2)}",
          isCredit: transaction.isCredit,
          onEdit: () => onEdit(index, transaction),
          onDelete: () => onDelete(index, transaction),
        );
      },
    );
  }
}

class UpcomingBillsList extends StatelessWidget {
  final List<TransactionData> upcomingBills;
  final Function(int index, TransactionData bill) onEdit;
  final Function(int index, TransactionData bill) onDelete;
  
  const UpcomingBillsList({
    required this.upcomingBills, 
    required this.onEdit,
    required this.onDelete,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    if (upcomingBills.isEmpty) {
      return Center(
        child: Text(
          "No upcoming bills",
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: upcomingBills.length,
      itemBuilder: (context, index) {
        final bill = upcomingBills[index];
        return WalletTransactionItem(
          title: bill.title,
          date: bill.date,
          amount: "-\$${bill.amount.toStringAsFixed(2)}",
          isCredit: false,
          onEdit: () => onEdit(index, bill),
          onDelete: () => onDelete(index, bill),
        );
      },
    );
  }
}

class WalletTransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isCredit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WalletTransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            // Leading icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                backgroundColor: isCredit ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(isCredit ? Icons.arrow_upward : Icons.arrow_downward, 
                     color: isCredit ? Colors.green : Colors.red),
              ),
            ),
            
            // Title and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  Text(date, style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            ),
            
            // Amount
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            
            // Edit button
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit, size: 20, color: Colors.grey.shade600),
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
            
            // Delete button
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete, size: 20, color: Colors.blue.shade600),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.only(left: 8.0, right: 12.0),
              ),
          ],
        ),
      ),
    );
  }
}

// Unified form that handles both adding and editing transactions
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
    super.key
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
    // Initialize with provided data if editing
    if (widget.initialData != null) {
      title = widget.initialData!.title;
      amount = widget.initialData!.amount;
      isCredit = widget.initialData!.isCredit;
      isScheduled = widget.initialData!.isScheduled;
      scheduledDate = widget.initialData!.scheduledDateStr != null 
          ? DateTime.parse(widget.initialData!.scheduledDateStr!)
          : null;
    } else {
      // Default values for new transactions
      title = '';
      amount = 0.0;
      isCredit = true;
      isScheduled = false;
      scheduledDate = null;
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
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
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
                      onChanged: (value) {
                        setState(() {
                          title = value;
                        });
                      },
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
                        setState(() {
                          amount = double.tryParse(value) ?? 0.0;
                        });
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
                        Text("Income", style: GoogleFonts.poppins()),
                        Radio<bool>(
                          value: true,
                          groupValue: isCredit,
                          onChanged: (value) {
                            setState(() {
                              isCredit = value ?? true;
                            });
                          },
                        ),
                        Text("Expense", style: GoogleFonts.poppins()),
                        Radio<bool>(
                          value: false,
                          groupValue: isCredit,
                          onChanged: (value) {
                            setState(() {
                              isCredit = value ?? false;
                            });
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
                              } else if (scheduledDate == null) {
                                scheduledDate = DateTime.now().add(const Duration(days: 7));
                              }
                            });
                          },
                        ),
                        Text("Schedule an upcoming bill", style: GoogleFonts.poppins()),
                      ],
                    ),
                    
                    if (isScheduled)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Schedule Date:", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
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
                                  setState(() {
                                    scheduledDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                                          : "${scheduledDate!.day}/${scheduledDate!.month}/${scheduledDate!.year}",
                                      style: GoogleFonts.poppins(),
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
                              const SnackBar(content: Text("Please select a date for your scheduled transaction"))
                            );
                            return;
                          }
                          
                          String dateString;
                          if (isScheduled && scheduledDate != null) {
                            dateString = _formatDate(scheduledDate!);
                          } else {
                            dateString = "Today";
                          }
                          
                          final updatedTransaction = TransactionData(
                            title: title,
                            date: dateString,
                            amount: amount,
                            isCredit: isCredit,
                            isScheduled: isScheduled,
                            scheduledDate: scheduledDate,
                          );
                          
                          widget.onSave(updatedTransaction);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(widget.isEditing 
                                ? "Transaction updated successfully" 
                                : (isScheduled 
                                  ? "Upcoming bill added successfully" 
                                  : "Transaction added successfully")),
                              backgroundColor: Colors.green,
                            )
                          );
                          
                          widget.onClose();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 21, 27, 84),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(widget.isEditing ? 'Update' : 'Save', style: GoogleFonts.poppins()),
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