import 'package:flutter/material.dart';
import 'package:expenses_tracker/models/budget_goal.dart';
import 'package:expenses_tracker/styles/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:expenses_tracker/providers/wallet_provider.dart';
import 'package:expenses_tracker/models/transaction.dart';

class BudgetGoalsScreen extends StatefulWidget {
  const BudgetGoalsScreen({super.key});

  @override
  State<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends State<BudgetGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _monthlyIncomeController = TextEditingController();
  final _savingsTargetController = TextEditingController();
  final Map<String, TextEditingController> _categoryControllers = {};
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each category
    for (var category in TransactionCategory.values) {
      if (category.toString().contains('other')) continue;
      _categoryControllers[category.toString().split('.').last] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _savingsTargetController.dispose();
    for (var controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveBudgetGoal() {
    if (_formKey.currentState!.validate()) {
      final monthlyIncome = double.parse(_monthlyIncomeController.text);
      final savingsTarget = double.parse(_savingsTargetController.text);
      
      final categoryLimits = <String, double>{};
      for (var entry in _categoryControllers.entries) {
        if (entry.value.text.isNotEmpty) {
          categoryLimits[entry.key] = double.parse(entry.value.text);
        }
      }

      final budgetGoal = BudgetGoal(
        monthlyIncome: monthlyIncome,
        savingsTarget: savingsTarget,
        categoryLimits: categoryLimits,
        startDate: _startDate,
        endDate: _endDate,
      );

      // TODO: Save budget goal using provider
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Goals'),
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
              TextFormField(
                controller: _monthlyIncomeController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Income',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your monthly income';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _savingsTargetController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Savings Target',
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your savings target';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Category Spending Limits',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...TransactionCategory.values.where((category) => 
                !category.toString().contains('other')).map((category) {
                final categoryName = category.toString().split('.').last;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: _categoryControllers[categoryName],
                    decoration: InputDecoration(
                      labelText: '${categoryName[0].toUpperCase()}${categoryName.substring(1)} Limit',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text('Start: ${_startDate.toString().split(' ')[0]}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text('End: ${_endDate.toString().split(' ')[0]}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveBudgetGoal,
                  child: const Text('Save Budget Goals'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 