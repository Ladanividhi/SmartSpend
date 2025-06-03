import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';

class EditExpensePage extends StatefulWidget {
  const EditExpensePage({super.key});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> allExpenses = [
    {
      'category': 'Food',
      'message': 'Pizza night',
      'amount': '450',
    },
    {
      'category': 'Transport',
      'message': 'Uber ride',
      'amount': '200',
    },
    {
      'category': 'Recharge',
      'message': 'Mobile Top-up',
      'amount': '149',
    },
  ];

  List<Map<String, dynamic>> filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    filteredExpenses = List.from(allExpenses);
  }

  void _filterExpenses(String query) {
    setState(() {
      filteredExpenses = allExpenses
          .where((expense) =>
      expense['category'].toLowerCase().contains(query.toLowerCase()) ||
          expense['message'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showEditDialog(int index) {
    final oldData = filteredExpenses[index];
    final TextEditingController categoryController =
    TextEditingController(text: oldData['category']);
    final TextEditingController messageController =
    TextEditingController(text: oldData['message']);
    final TextEditingController amountController =
    TextEditingController(text: oldData['amount']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bg_color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Expense",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary_color),
            onPressed: () {
              setState(() {
                final updatedExpense = {
                  'category': categoryController.text,
                  'message': messageController.text,
                  'amount': amountController.text,
                };

                // Update both the full list and filtered list
                int originalIndex = allExpenses.indexOf(oldData);
                allExpenses[originalIndex] = updatedExpense;
                _filterExpenses(_searchController.text);
              });
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'Edit Expenses',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary_color,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _filterExpenses,
              decoration: InputDecoration(
                hintText: "Search expenses...",
                prefixIcon: Icon(Icons.search, color: primary_color),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Expense Cards
            Expanded(
              child: ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  final expense = filteredExpenses[index];
                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        expense['category'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primary_color,
                            fontSize: 16),
                      ),
                      subtitle: Text(
                        expense['message'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: SizedBox(
                        width: 100, // adjust based on your spacing needs
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '₹ ${expense['amount']}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: primary_color),
                              onPressed: () => _showEditDialog(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
