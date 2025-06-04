import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';
import 'package:intl/intl.dart';

class EditExpensePage extends StatefulWidget {
  const EditExpensePage({super.key});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false;
  List<Map<String, dynamic>> allExpenses = [];

  List<Map<String, dynamic>> filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Expenses')
              .where('Id', isEqualTo: user.uid)
              .get(); // Removed orderBy

      List<Map<String, dynamic>> data =
          snapshot.docs.map((doc) {
            final d = doc.data();
            return {
              'id': doc.id,
              'category': d['Category'],
              'message': d['Message'],
              'amount': d['Amount'],
              'date': d['Date'].toDate(), // Convert Timestamp to DateTime
            };
          }).toList();

      // Sort manually by date descending
      data.sort((a, b) => b['date'].compareTo(a['date']));

      setState(() {
        allExpenses = data;
        filteredExpenses = List.from(allExpenses);
      });
    }
  }

  void _filterExpenses(String query) {
    setState(() {
      filteredExpenses =
          allExpenses
              .where(
                (expense) =>
                    expense['category'].toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    expense['message'].toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  void _showEditDialog(int index) {
    final oldData = filteredExpenses[index];
    final TextEditingController categoryController = TextEditingController(
      text: oldData['category'],
    );
    final TextEditingController messageController = TextEditingController(
      text: oldData['message'],
    );
    final TextEditingController amountController = TextEditingController(
      text: oldData['amount'].toString(),
    );

    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: bg_color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Edit Expense",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content:
                  isLoading
                      ? const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                          ),
                          TextField(
                            controller: messageController,
                            decoration: const InputDecoration(
                              labelText: 'Message',
                            ),
                          ),
                          TextField(
                            controller: amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                            ),
                          ),
                        ],
                      ),
              actions:
                  isLoading
                      ? []
                      : [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary_color,
                          ),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });

                            final updatedExpense = {
                              'Category': categoryController.text,
                              'Message': messageController.text,
                              'Amount':
                                  double.tryParse(amountController.text) ?? 0,
                            };

                            final docId = oldData['id'];

                            try {
                              await FirebaseFirestore.instance
                                  .collection('Expenses')
                                  .doc(docId)
                                  .update(updatedExpense);

                              // Update local list
                              final updatedLocalExpense = {
                                ...oldData,
                                ...{
                                  'category': categoryController.text,
                                  'message': messageController.text,
                                  'amount':
                                      double.tryParse(amountController.text) ??
                                      0,
                                },
                              };

                              setState(() {
                                int originalIndex = allExpenses.indexOf(
                                  oldData,
                                );
                                allExpenses[originalIndex] =
                                    updatedLocalExpense;
                                _filterExpenses(_searchController.text);
                              });

                              Navigator.pop(context);
                            } catch (e) {
                              print("Update failed: $e");
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
            );
          },
        );
      },
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
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM d, yyyy').format(expense['date']),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expense['category'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primary_color,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      subtitle: Text(
                        expense['message'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Text(
                              '₹ ${expense['amount']}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
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
