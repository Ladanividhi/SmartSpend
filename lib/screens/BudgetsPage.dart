import 'package:SmartSpend/screens/AddExpense.dart';
import 'package:SmartSpend/screens/CategoryWiseBudget.dart';
import 'package:SmartSpend/screens/ChartPage.dart';
import 'package:SmartSpend/screens/EditBudget.dart';
import 'package:SmartSpend/screens/SetBudget.dart';
import 'package:SmartSpend/screens/ProfilePage.dart';
import 'package:SmartSpend/screens/RecordPage.dart';
import 'package:SmartSpend/screens/ViewBudget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  int _selectedIndex = 3;
  List<Map<String, dynamic>> activeBudgets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadActiveBudgets();
  }

  Future<void> loadActiveBudgets() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          isLoading = false;
          activeBudgets = [];
        });
        return;
      }

      final now = DateTime.now();

      QuerySnapshot budgetSnapshot = await FirebaseFirestore.instance
          .collection('Budget')
          .where('Id', isEqualTo: userId)
          .get();

      QuerySnapshot categoryBudgetSnapshot = await FirebaseFirestore.instance
          .collection('CategoryBudget')
          .where('Id', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> allBudgets = [];

      for (var doc in budgetSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          if (data['StartDate'] == null || data['EndDate'] == null || data['Amount'] == null) {
            continue; // Skip invalid documents
          }
          
          final start = (data['StartDate'] as Timestamp).toDate();
          final end = (data['EndDate'] as Timestamp).toDate();
          
          if (now.isAfter(start) && now.isBefore(end)) {
            data['type'] = 'total';
            allBudgets.add(data);
          }
        } catch (e) {
          print("Error processing budget document: $e");
          continue; // Skip problematic documents
        }
      }

      for (var doc in categoryBudgetSnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          if (data['StartDate'] == null || data['EndDate'] == null || data['Amount'] == null || data['Category'] == null) {
            continue; // Skip invalid documents
          }
          
          final start = (data['StartDate'] as Timestamp).toDate();
          final end = (data['EndDate'] as Timestamp).toDate();
          
          if (now.isAfter(start) && now.isBefore(end)) {
            data['type'] = 'category';
            allBudgets.add(data);
          }
        } catch (e) {
          print("Error processing category budget document: $e");
          continue; // Skip problematic documents
        }
      }

      setState(() {
        activeBudgets = allBudgets;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading budgets: $e");
      setState(() {
        isLoading = false;
        activeBudgets = [];
      });
      Fluttertoast.showToast(
        msg: "Error loading budgets. Please try again.",
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  Future<double> calculateSpent(String userId, DateTime start, DateTime end, [String? category]) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('Expenses')
          .where('Id', isEqualTo: userId);

      final snapshot = await query.get();
      double totalSpent = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) {
          print('Skipping document with null data: ${doc.id}');
          continue;
        }

        // Safely access and check Timestamp
        final dynamic timestampData = data['Timestamp'];
        if (timestampData == null || !(timestampData is Timestamp)) {
          print('Skipping document with invalid or missing Timestamp: ${doc.id}');
          continue;
        }
        final Timestamp timestamp = timestampData as Timestamp;
        final docDate = timestamp.toDate();

        // Safely access and check Type
        final dynamic typeData = data['Type'];
        final String? type = typeData is String ? typeData : null;
        if (type != 'Expense') {
          // Only process expense transactions for spent calculation
          continue;
        }

        // Safely access Category
        final dynamic categoryData = data['Category'];
        final String? docCategory = categoryData is String ? categoryData : null;

        // Filter by category if specified
        if (category != null && docCategory != category) {
           continue;
        }

        // Normalize budget period start and end to the beginning and end of the day
        final startOfDay = DateTime(start.year, start.month, start.day);
        final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);

        // Filter by date range, including start and end dates
        if (docDate.isAtSameMomentAs(startOfDay) ||
            (docDate.isAfter(startOfDay) && docDate.isBefore(endOfDay)) ||
            docDate.isAtSameMomentAs(endOfDay)) {

          // Safely access and check Amount
          final dynamic amountData = data['Amount'];
          if (amountData == null || !(amountData is num)) {
             print('Skipping document with invalid or missing Amount: ${doc.id}');
             continue;
          }
          final double amount = (amountData as num).toDouble();

          totalSpent += amount;
        }
      }

      return totalSpent;
    } catch (e) {
      print("Error calculating spent amount: $e");
      return 0.0;
    }
  }

  Widget buildBudgetCard(Map<String, dynamic> budget) {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final formatter = DateFormat('dd MMM yyyy');
      
      if (budget['StartDate'] == null || budget['EndDate'] == null || budget['Amount'] == null) {
        return const SizedBox.shrink(); // Return empty widget if required data is missing
      }

      final start = (budget['StartDate'] as Timestamp).toDate();
      final end = (budget['EndDate'] as Timestamp).toDate();
      final daysLeft = end.difference(DateTime.now()).inDays;
      final total = (budget['Amount'] as num).toDouble();
      final isCategory = budget['type'] == 'category';
      final category = budget['Category'] ?? '';

      return FutureBuilder<double>(
        future: calculateSpent(userId, start, end, isCategory ? category : null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (snapshot.hasError) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error loading budget: ${snapshot.error}'),
              ),
            );
          }

          final spent = snapshot.data ?? 0.0;
          final remaining = (total - spent).clamp(0, total);
          final percentUsed = (spent / total).clamp(0.0, 1.0);
          final barColor = spent > total ? Colors.red : Colors.green;
          final labelColor = spent > total ? Colors.red : Colors.black;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: barColor.withOpacity(0.1),
                        child: Icon(
                          isCategory ? Icons.category : Icons.wallet,
                          color: barColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isCategory ? category : 'Total Budget',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text("(${DateFormat('MMM, yyyy').format(start)})"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Limit: ₹${total.toStringAsFixed(2)}"),
                  Text("Spent: ₹${spent.toStringAsFixed(2)}",
                      style: TextStyle(color: labelColor)),
                  Text("Remaining: ₹${remaining.toStringAsFixed(2)}",
                      style: TextStyle(color: barColor)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentUsed,
                    minHeight: 8,
                    color: barColor,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  if (spent > total)
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text("*Limit exceeded",
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                  const SizedBox(height: 8),
                  Text("From ${formatter.format(start)} to ${formatter.format(end)}"),
                  Text("Remaining Days: $daysLeft"),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      print("Error building budget card: $e");
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error displaying budget: $e'),
        ),
      );
    }
  }


  void _checkAndNavigateToSetBudget(BuildContext context, String userId) async {
    final now = DateTime.now();

    // Query Budget collection for active budgets
    final budgetQuery = await FirebaseFirestore.instance
        .collection('Budget')
        .where('Id', isEqualTo: userId)
        .get();

    // Query CategoryBudget collection for active budgets
    final categoryBudgetQuery = await FirebaseFirestore.instance
        .collection('CategoryBudget')
        .where('Id', isEqualTo: userId)
        .get();

    bool hasActiveBudget = false;

    // Function to check if now is between start and end date
    bool isActiveBudget(DocumentSnapshot doc) {
      final startDate = (doc['StartDate'] as Timestamp).toDate();
      final endDate = (doc['EndDate'] as Timestamp).toDate();
      return now.isAfter(startDate) && now.isBefore(endDate);
    }

    // Check in Budget collection
    for (var doc in budgetQuery.docs) {
      if (isActiveBudget(doc)) {
        hasActiveBudget = true;
        break;
      }
    }

    // If no active budget found, check in CategoryBudget collection
    if (!hasActiveBudget) {
      for (var doc in categoryBudgetQuery.docs) {
        if (isActiveBudget(doc)) {
          hasActiveBudget = true;
          break;
        }
      }
    }

    if (hasActiveBudget) {
      // Show alert dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Active Budget Found'),
          content: const Text(
              'You already have one active budget right now.\n\n'
                  'For more details, kindly click on "View Budget" or cancel.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // just close dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewBudgetPage()),
                );// or navigate however you view budgets
              },
              child: const Text('View Budget'),
            ),
          ],
        ),
      );
    } else {
      // No active budget, navigate to SetBudgetPage
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SetBudgetPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        backgroundColor: primary_color,
        title: const Text(
          'Budgets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'view_budget') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewBudgetPage()),
                );
              }
              else if (value == 'edit_budget'){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditBudgetPage()),
                );
              }
              else if (value == 'set_budget') {
                final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                _checkAndNavigateToSetBudget(context, userId);
              }

            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'set_budget',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long, color: primary_color),
                    const SizedBox(width: 12),
                    const Text('Set Budget'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'view_budget',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: primary_color),
                    const SizedBox(width: 12),
                    const Text('View Budget'),
                  ],
                ),
              ),
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
          : activeBudgets.isEmpty
          ? const Center(child: Text("No active budgets found."))
          : ListView(
        children: activeBudgets
            .map((budget) => buildBudgetCard(budget))
            .toList(),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primary_color,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RecordPage()),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChartPage()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddExpense()),
                );
                _selectedIndex = 3;
                break;
              case 3:
                break;
              case 4:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
                _selectedIndex = 3;
                break;
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Records',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_rounded),
              label: 'Chart',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primary_color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary_color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Budgets',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }
}
