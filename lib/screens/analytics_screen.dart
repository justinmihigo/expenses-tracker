import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../providers/wallet_provider.dart';
import '../styles/app_colors.dart';
import '../sqlite.dart';
import 'package:provider/provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedPeriod = 'Month';
  final List<String> periods = ['Week', 'Month', 'Year'];
  String selectedChart = 'Pie';
  final List<String> chartTypes = ['Pie', 'Bar'];
  double totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTotalBalance();
  }

  Future<void> _loadTotalBalance() async {
    final transactions = await SQLiteDB.instance.getTransactions();
    double balance = 0.0;
    
    for (var transaction in transactions) {
      if (transaction['isCredit'] == 1) {
        balance += transaction['amount'] as double;
      } else {
        balance -= transaction['amount'] as double;
      }
    }
    
    setState(() {
      totalBalance = balance;
    });
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, provider, child) {
        final transactions = provider.transactions;
        final filteredTransactions = _filterTransactionsByPeriod(transactions);
        
        final categoryData = _getCategoryData(filteredTransactions);
        final timeSeriesData = _getTimeSeriesData(filteredTransactions);
        final totalIncome = filteredTransactions
            .where((t) => t.isCredit)
            .fold(0.0, (sum, t) => sum + t.amount);
        final totalExpenses = filteredTransactions
            .where((t) => !t.isCredit)
            .fold(0.0, (sum, t) => sum + t.amount);

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Analytics',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C1F63),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list, color: Color(0xFF2C1F63)),
                        onPressed: () {
                          // TODO: Implement advanced filters
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Balance Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1F63),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Balance',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rwf ${_formatAmount(totalBalance)}',
                                    style: TextStyle(
                                      color: totalBalance >= 0 ? Colors.white : Colors.red,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB800),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(Icons.add, color: Colors.black, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Time period selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2C1F63).withOpacity(0.2)),
                    ),
                    child: SegmentedButton<String>(
                      segments: periods.map((period) => 
                        ButtonSegment<String>(
                          value: period,
                          label: Text(period),
                        )
                      ).toList(),
                      selected: {selectedPeriod},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          selectedPeriod = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return const Color(0xFF2C1F63);
                            }
                            return Colors.white;
                          },
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.white;
                            }
                            return const Color(0xFF2C1F63);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Income and Expenses Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F5EC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Income',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Rwf ${_formatAmount(totalIncome)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBE7E7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Expenses',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Rwf ${_formatAmount(totalExpenses)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Income vs Expenses Over Time
                  const Text(
                    'Income vs Expenses Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1F63),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2C1F63).withOpacity(0.2)),
                    ),
                    child: LineChart(
                      LineChartData(
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: const Color(0xFF2C1F63).withOpacity(0.1),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 10,
                              getTitlesWidget: (value, meta) {
                                const style = TextStyle(
                                  color: Color(0xFF2C1F63),
                                  fontSize: 10,
                                );
                                Widget text;
                                switch (value.toInt()) {
                                  case 0:
                                    text = const Text('JAN', style: style);
                                    break;
                                  case 10:
                                    text = const Text('FEB', style: style);
                                    break;
                                  case 20:
                                    text = const Text('MAR', style: style);
                                    break;
                                  case 30:
                                    text = const Text('APR', style: style);
                                    break;
                                  case 40:
                                    text = const Text('MAY', style: style);
                                    break;
                                  case 50:
                                    text = const Text('JUN', style: style);
                                    break;
                                  default:
                                    text = const Text('', style: style);
                                }
                                return SideTitleWidget(meta: meta, child: text);
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              interval: 10,
                              getTitlesWidget: (value, meta) {
                                const style = TextStyle(
                                  color: Color(0xFF2C1F63),
                                  fontSize: 10,
                                );
                                String text;
                                switch (value.toInt()) {
                                  case 10:
                                    text = '10K';
                                    break;
                                  case 20:
                                    text = '20K';
                                    break;
                                  case 30:
                                    text = '30K';
                                    break;
                                  case 40:
                                    text = '40K';
                                    break;
                                  case 50:
                                    text = '50K';
                                    break;
                                  default:
                                    return Container();
                                }
                                return Text(text, style: style, textAlign: TextAlign.left);
                              },
                            ),
                          ),
                        ),
                        minX: 0,
                        minY: 0,
                        maxX: 50,
                        maxY: 50,
                        lineBarsData: [
                          LineChartBarData(
                            spots: timeSeriesData.map((e) => 
                              FlSpot(e['day']!.toDouble(), e['income']! / 1000)
                            ).toList(),
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.withOpacity(0.3),
                                  Colors.green.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          LineChartBarData(
                            spots: timeSeriesData.map((e) => 
                              FlSpot(e['day']!.toDouble(), e['expenses']! / 1000)
                            ).toList(),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.withOpacity(0.3),
                                  Colors.red.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chart Type Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2C1F63).withOpacity(0.2)),
                    ),
                    child: SegmentedButton<String>(
                      segments: chartTypes.map((type) => 
                        ButtonSegment<String>(
                          value: type,
                          label: Text(type),
                        )
                      ).toList(),
                      selected: {selectedChart},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          selectedChart = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return const Color(0xFF2C1F63);
                            }
                            return Colors.white;
                          },
                        ),
                        foregroundColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.white;
                            }
                            return const Color(0xFF2C1F63);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Spending by Category
                  const Text(
                    'Spending by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C1F63),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2C1F63).withOpacity(0.2)),
                    ),
                    child: selectedChart == 'Pie' 
                      ? PieChart(
                          PieChartData(
                            sections: _createPieSections(categoryData),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: categoryData.values.reduce((a, b) => a > b ? a : b) * 1.2,
                            barGroups: _createBarGroups(categoryData),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final categories = categoryData.keys.toList();
                                    if (value.toInt() >= 0 && value.toInt() < categories.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          categories[value.toInt()],
                                          style: const TextStyle(
                                            color: Color(0xFF2C1F63),
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                          ),
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Category Legend
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: categoryData.entries.map((entry) {
                      final index = categoryData.keys.toList().indexOf(entry.key);
                      final color = _getCategoryColor(index);
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.key} (${entry.value.toStringAsFixed(0)})',
                            style: const TextStyle(
                              color: Color(0xFF2C1F63),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<TransactionData> _filterTransactionsByPeriod(List<TransactionData> transactions) {
    final now = DateTime.now();
    return transactions.where((t) {
      final date = _parseDate(t.date);
      switch (selectedPeriod) {
        case 'Week':
          return now.difference(date).inDays <= 7;
        case 'Month':
          return date.month == now.month && date.year == now.year;
        case 'Year':
          return date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  Map<String, double> _getCategoryData(List<TransactionData> transactions) {
    final categoryMap = <String, double>{};
    for (var transaction in transactions.where((t) => !t.isCredit)) {
      final category = transaction.title.split(' ')[0]; // Simplified category extraction
      categoryMap[category] = (categoryMap[category] ?? 0) + transaction.amount;
    }
    return categoryMap;
  }

  List<Map<String, double>> _getTimeSeriesData(List<TransactionData> transactions) {
    final timeSeriesMap = <int, Map<String, double>>{};
    
    for (var transaction in transactions) {
      final date = _parseDate(transaction.date);
      final day = date.day;
      
      if (!timeSeriesMap.containsKey(day)) {
        timeSeriesMap[day] = {'day': day.toDouble(), 'income': 0, 'expenses': 0};
      }
      
      if (transaction.isCredit) {
        timeSeriesMap[day]!['income'] = (timeSeriesMap[day]!['income'] ?? 0) + transaction.amount;
      } else {
        timeSeriesMap[day]!['expenses'] = (timeSeriesMap[day]!['expenses'] ?? 0) + transaction.amount;
      }
    }
    
    return timeSeriesMap.values.toList()..sort((a, b) => a['day']!.compareTo(b['day']!));
  }

  List<PieChartSectionData> _createPieSections(Map<String, double> categoryData) {
    return categoryData.entries.map((entry) {
      final index = categoryData.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
        color: _getCategoryColor(index),
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _createBarGroups(Map<String, double> categoryData) {
    return categoryData.entries.map((entry) {
      final index = categoryData.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: _getCategoryColor(index),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF2C1F63),
      const Color(0xFF023E7D),
      const Color(0xFF979DAC),
      const Color(0xFFFFB302),
      Colors.green,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  DateTime _parseDate(String dateStr) {
    if (dateStr == "Today") {
      return DateTime.now();
    } else if (dateStr == "Yesterday") {
      return DateTime.now().subtract(const Duration(days: 1));
    } else {
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
      };
      
      final parts = dateStr.split(' ');
      final month = months[parts[0]] ?? 1;
      final day = int.parse(parts[1].replaceAll(',', ''));
      final year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    }
  }
}