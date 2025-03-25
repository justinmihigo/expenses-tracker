import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreen();
}

class _AnalyticsScreen extends State<AnalyticsScreen> {
  int? value;
  List<Map<String, String>> spending = [
    {'expense': "Starbucks", 'date': "Jan 12, 2025", 'price': "\$500"},
    {'expense': "MTN", 'date': "FEB 12, 2024", 'price': "\$400"},
    {'expense': "Starbucks", 'date': "Jan 12, 2025", 'price': "\$500"},
    {'expense': "MTN", 'date': "FEB 12, 2024", 'price': "\$400"},
    {'expense': "MTN", 'date': "FEB 12, 2024", 'price': "\$400"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistics"),
        leading: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          spacing: 20,
          children: [
            SizedBox(
              width: 400,
              height: 200,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: false,
                    drawVerticalLine: false,
                    // horizontalInterval: 10,
                    // verticalInterval: 10,
                    // getDrawingHorizontalLine: (value) {
                    //   return FlLine(color: Colors.green, strokeWidth: 1);
                    // },
                    // getDrawingVerticalLine: (value) {
                    //   return FlLine(color: Colors.green, strokeWidth: 1);
                    // },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 10,
                        getTitlesWidget: bottomTitles,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        reservedSize: 42,
                        interval: 10,
                        getTitlesWidget: leftTitles,
                      ),
                    ),
                  ),
                  minX: 0,
                  minY: 0,
                  maxX: 50,
                  maxY: 50,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 10),
                        FlSpot(10, 20),
                        FlSpot(20, 30),
                        FlSpot(30, 40),
                        FlSpot(45, 20),
                        FlSpot(50, 47),
                      ],
                      isCurved: true,
                      color: Colors.black,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(160, 50, 227, 106),
                            Colors.white,
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
            SizedBox(
              width: 400,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Top Spending",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.currency_exchange),
                ],
              ),
            ),
            SizedBox(
              width: 400,
              height: 200,
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 10),
                padding: EdgeInsets.all(10),
                itemCount: spending.length,
                itemBuilder: (BuildContext context, int index) {
                  return topSpendingWidget(
                    spending[index]["expense"],
                    spending[index]["date"],
                    spending[index]["price"],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.black, fontSize: 10);
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
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 10:
        text = '10PPM';
        break;
      case 20:
        text = '20PPM';
        break;
      case 30:
        text = '30PPM';
        break;
      case 40:
        text = '40PPM';
        break;
      case 50:
        text = '50PPM';
        break;
      default:
        return Container();
    }
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Widget topSpendingWidget(String? expense, String? date, String? price) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 40,
          children: [
            Image.asset("assets/mtnlogo.jpg", width: 40),
            Column(
              children: [
                Text("$expense", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("$date"),
              ],
            ),
          ],
        ),

        Text(
          "$price",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
