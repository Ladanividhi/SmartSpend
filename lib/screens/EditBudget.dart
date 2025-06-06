import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:SmartSpend/Constants.dart';

class EditBudgetPage extends StatefulWidget {
  const EditBudgetPage({Key? key}) : super(key: key);

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknownUser';
  final DateFormat formatter = DateFormat('dd MMM yyyy');

  Future<List<DocumentSnapshot>> _fetchBudgets() async {
    final budgetSnapshot = await FirebaseFirestore.instance
        .collection('Budget')
        .where('Id', isEqualTo: userId)
        .get();

    if (budgetSnapshot.docs.isNotEmpty) {
      return budgetSnapshot.docs;
    }

    final categoryBudgetSnapshot = await FirebaseFirestore.instance
        .collection('CategoryBudget')
        .where('Id', isEqualTo: userId)
        .get();

    return categoryBudgetSnapshot.docs;
  }


  Future<bool?> _showEditDialog(DocumentSnapshot doc) async {
    DateTime startDate = (doc['StartDate'] as Timestamp).toDate();
    DateTime endDate = (doc['EndDate'] as Timestamp).toDate();

    final TextEditingController amountController =
    TextEditingController(text: doc['Amount'].toString());
    final TextEditingController categoryController =
    TextEditingController(text: doc.data().toString().contains('Category') ? doc['Category'] : '');

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Budget", style: TextStyle(color: primary_color)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (categoryController.text.isNotEmpty)
                  TextField(
                    controller: categoryController,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text("Start Date"),
                  subtitle: Text(formatter.format(startDate)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: "You cannot edit the start date of the budget.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                      );
                    },
                  ),
                ),
                ListTile(
                  title: const Text("End Date"),
                  subtitle: Text(formatter.format(endDate)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => endDate = picked);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Are you sure?"),
                    content: const Text("Do you want to delete this budget permanently?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("No"),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.warning, color: Colors.white),
                        onPressed: () async {
                          final budgetRef = FirebaseFirestore.instance.collection('Budget').doc(doc.id);
                          final categoryBudgetRef = FirebaseFirestore.instance.collection('CategoryBudget').doc(doc.id);

                          // Check if the doc exists in 'Budget'
                          final budgetDoc = await budgetRef.get();
                          if (budgetDoc.exists) {
                            await budgetRef.delete();
                          } else {
                            // Else delete from 'CategoryBudget'
                            await categoryBudgetRef.delete();
                          }

                          Navigator.pop(ctx); // Close confirmation dialog
                          Navigator.pop(context, true); // Close edit dialog and trigger UI refresh
                          Fluttertoast.showToast(msg: "Budget deleted successfully");
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        label: const Text("Yes", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary_color),
              onPressed: () async {
                // Basic input validation
                if (amountController.text.trim().isEmpty ||
                    double.tryParse(amountController.text.trim()) == null ||
                    startDate == null ||
                    endDate == null) {
                  Fluttertoast.showToast(
                    msg: "Please enter all fields correctly",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                  );
                  return;
                }

                final hasCategory = categoryController.text.isNotEmpty;
                final targetCollection = hasCategory ? 'CategoryBudget' : 'Budget';

                await FirebaseFirestore.instance
                    .collection(targetCollection)
                    .doc(doc.id)
                    .update({
                  'Amount': double.parse(amountController.text.trim()),
                  'StartDate': startDate,
                  'EndDate': endDate,
                });

                Navigator.pop(context, true); // Close dialog and signal UI refresh
                Fluttertoast.showToast(
                  msg: "Budget updated successfully",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildBudgetCard(DocumentSnapshot doc, {required bool editable}) {
      final start = formatter.format((doc['StartDate'] as Timestamp).toDate());
      final end = formatter.format((doc['EndDate'] as Timestamp).toDate());
      final amount = doc['Amount'];
      final category = doc.data().toString().contains('Category') ? doc['Category'] : null;

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        color: bg_color,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            category != null ? "$category - ₹$amount" : "₹$amount",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text("$start to $end"),
          trailing: editable
              ? IconButton(
            icon: const Icon(Icons.edit, color: primary_color),
            onPressed: () async {
              final shouldRefresh = await _showEditDialog(doc);
              if (shouldRefresh == true) {
                setState(() {});
              }
            },
          )
              : null,
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          "Edit Budgets",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchBudgets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_sharp,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets found',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          final now = DateTime.now();
          final allBudgets = snapshot.data!;
          final activeBudgets = allBudgets.where((doc) {
            final endDate = (doc['EndDate'] as Timestamp).toDate();
            return endDate.isAfter(now) || endDate.isAtSameMomentAs(now);
          }).toList();
          final pastBudgets = allBudgets.where((doc) {
            final endDate = (doc['EndDate'] as Timestamp).toDate();
            return endDate.isBefore(now);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (activeBudgets.isNotEmpty) ...[
                const Text(
                  "Active Budgets",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...activeBudgets.map((doc) => _buildBudgetCard(doc, editable: true)).toList(),
              ],
              if (pastBudgets.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  "Past Budgets",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                ...pastBudgets.map((doc) => _buildBudgetCard(doc, editable: false)).toList(),
              ],
            ],
          );
        },
      ),

    );
  }
}
