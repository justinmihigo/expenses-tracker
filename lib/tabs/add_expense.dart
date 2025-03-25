import 'package:flutter/material.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});
  @override
  State<AddExpense> createState() => _AddExpense();
}

class _AddExpense extends State<AddExpense> {
  final controller = TextEditingController();
  List<String> dropItems = ["MTN", "TIGO", "AMAJYANE"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add expense"),
        leading: Icon(Icons.arrow_back),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: SizedBox(
              width: constraints.maxWidth * 0.8,
              child: Column(
                spacing: 40,
                children: [
                  Column(
                    spacing: 20,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text("Expense Name", textAlign: TextAlign.left),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        hint: Text("Expense"),
                        isExpanded: true,
                        items:
                            dropItems.map((String value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (_) {},
                      ),
                    ],
                  ),

                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      label: Text("Price"),
                      // floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      label: Text("Date"),
                      // floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add), Text("Add invoice")],
                      ),
                      // floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      // style: ButtonStyle(
                      //   fixedSize: WidgetStateProperty.all<Size>(
                      //     Size.fromWidth(300),
                      //   ),
                      // ),
                      child: Text("Add expense"),
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
