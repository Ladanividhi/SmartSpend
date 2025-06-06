import 'package:SmartSpend/screens/EditBudget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:SmartSpend/Constants.dart';

class ViewBudgetPage extends StatefulWidget {
  const ViewBudgetPage({Key? key}) : super(key: key);

  @override
  State<ViewBudgetPage> createState() => _ViewBudgetPageState();
}

class _ViewBudgetPageState extends State<ViewBudgetPage> {
  List<Map<String, dynamic>> pastBudgetList = [];
  List<Map<String, dynamic>> pastCategoryBudgetList = [];

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknownUser";
  final DateFormat formatter = DateFormat('dd MMM yyyy');

  List<Map<String, dynamic>> budgetList = [];
  List<Map<String, dynamic>> categoryBudgetList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBudgets();
  }

  Future<void> fetchBudgets() async {
    try {
      DateTime now = DateTime.now();

      final budgetSnapshot = await FirebaseFirestore.instance
          .collection('Budget')
          .where('Id', isEqualTo: userId)
          .get();

      final categoryBudgetSnapshot = await FirebaseFirestore.instance
          .collection('CategoryBudget')
          .where('Id', isEqualTo: userId)
          .get();

      final allBudgets = budgetSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      final allCategoryBudgets = categoryBudgetSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        budgetList = allBudgets.where((budget) {
          return !(budget['EndDate'] as Timestamp).toDate().isBefore(now);
        }).toList();

        pastBudgetList = allBudgets.where((budget) {
          return (budget['EndDate'] as Timestamp).toDate().isBefore(now);
        }).toList();

        categoryBudgetList = allCategoryBudgets.where((budget) {
          return !(budget['EndDate'] as Timestamp).toDate().isBefore(now);
        }).toList();

        pastCategoryBudgetList = allCategoryBudgets.where((budget) {
          return (budget['EndDate'] as Timestamp).toDate().isBefore(now);
        }).toList();

        isLoading = false;
      });
    } catch (e) {
      print("Error fetching budgets: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  Widget buildBudgetCard(Map<String, dynamic> budget) {
    String startDate = formatter.format(
      (budget['StartDate'] as Timestamp).toDate(),
    );
    String endDate = formatter.format(
      (budget['EndDate'] as Timestamp).toDate(),
    );
    double amount = budget['Amount']?.toDouble() ?? 0.0;

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.account_balance_wallet, color: primary_color),
        title: Text(
          'Total Budget: ₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('From $startDate to $endDate'),
      ),
    );
  }

  Widget buildCategoryBudgetCard(Map<String, dynamic> budget) {
    String startDate = formatter.format(
      (budget['StartDate'] as Timestamp).toDate(),
    );
    String endDate = formatter.format(
      (budget['EndDate'] as Timestamp).toDate(),
    );
    double amount = budget['Amount']?.toDouble() ?? 0.0;
    String category = budget['Category'] ?? 'Unknown';

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.category, color: primary_color),
        title: Text(
          '$category: ₹${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('From $startDate to $endDate'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'View Budgets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'edit_budget') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditBudgetPage()),
                ).then((_) {
                  fetchBudgets();
                });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit_budget',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: primary_color),
                    const SizedBox(width: 12),
                    const Text('Edit Budget'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (budgetList.isEmpty &&
          categoryBudgetList.isEmpty &&
          pastBudgetList.isEmpty &&
          pastCategoryBudgetList.isEmpty)
          ? const Center(
        child: Text(
          'No budgets set till now.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView(
        children: [
          if (budgetList.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Total Budgets',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ...budgetList.map((budget) => buildBudgetCard(budget)),
          ],
          if (categoryBudgetList.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Category-wise Budgets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...categoryBudgetList.map((budget) => buildCategoryBudgetCard(budget)),
          ],
          if (pastBudgetList.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Past Budgets',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            ...pastBudgetList.map((budget) => buildBudgetCard(budget)),
          ],
          if (pastCategoryBudgetList.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Past Category-wise Budgets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            ...pastCategoryBudgetList.map((budget) => buildCategoryBudgetCard(budget)),
          ],
        ],
      ),
    );
  }
}
