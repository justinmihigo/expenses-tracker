import 'package:flutter/material.dart';
import '../models/savings_plan.dart';
import '../services/savings_service.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  List<SavingsPlan> _savingsPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavingsPlans();
  }

  Future<void> _loadSavingsPlans() async {
    final plans = await SavingsService.loadSavingsPlans();
    setState(() {
      _savingsPlans = plans;
      _isLoading = false;
    });
  }

  void _showAddSavingsPlanDialog() {
    final titleController = TextEditingController();
    final targetAmountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Savings Plan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: targetAmountController,
                  decoration: InputDecoration(
                    labelText: 'Target Amount',
                    prefixText: 'Rwf ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text('Target Date'),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (date != null) {
                      selectedDate = date;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    targetAmountController.text.isNotEmpty) {
                  final plan = SavingsPlan(
                    title: titleController.text,
                    targetAmount: double.parse(targetAmountController.text),
                    currentAmount: 0,
                    targetDate: selectedDate,
                    description: descriptionController.text,
                  );
                  SavingsService.addSavingsPlan(plan);
                  _loadSavingsPlans();
                  Navigator.pop(context);
                }
              },
              child: Text('Create'),
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Savings Plans'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddSavingsPlanDialog,
          ),
        ],
      ),
      body: _savingsPlans.isEmpty
          ? Center(
              child: Text(
                'No savings plans yet.\nTap + to create one!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _savingsPlans.length,
              itemBuilder: (context, index) {
                final plan = _savingsPlans[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await SavingsService.deleteSavingsPlan(plan);
                                _loadSavingsPlans();
                              },
                            ),
                          ],
                        ),
                        if (plan.description.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            plan.description,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                        SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: plan.progressPercentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rwf ${plan.currentAmount.toStringAsFixed(2)} / Rwf ${plan.targetAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${plan.progressPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${plan.daysRemaining} days remaining',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
} 