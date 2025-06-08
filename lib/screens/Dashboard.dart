import 'package:SmartSpend/Constants.dart';
import 'package:SmartSpend/screens/AddExpense.dart';
import 'package:SmartSpend/screens/ChartPage.dart';
import 'package:SmartSpend/screens/RecordPage.dart';
import 'package:SmartSpend/screens/BudgetsPage.dart';
import 'package:SmartSpend/screens/ProfilePage.dart';
import 'package:SmartSpend/screens/Settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  User? user;
  double todayExpenses = 0;
  double yesterdayExpenses = 0;
  double thisWeekExpenses = 0;
  double thisMonthExpenses = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final snapshot = await FirebaseFirestore.instance
          .collection('Expenses')
          .where('Id', isEqualTo: user!.uid)
          .get();

      double todayTotal = 0;
      double yesterdayTotal = 0;
      double weekTotal = 0;
      double monthTotal = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final Timestamp timestamp = data['Date'];
        final DateTime expenseDate = timestamp.toDate();
        final double amount = (data['Amount'] as num).toDouble();

        // Today's expenses
        if (expenseDate.year == today.year &&
            expenseDate.month == today.month &&
            expenseDate.day == today.day) {
          todayTotal += amount;
        }

        // Yesterday's expenses
        if (expenseDate.year == yesterday.year &&
            expenseDate.month == yesterday.month &&
            expenseDate.day == yesterday.day) {
          yesterdayTotal += amount;
        }

        // This week's expenses
        if (expenseDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            expenseDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          weekTotal += amount;
        }

        // This month's expenses
        if (expenseDate.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            expenseDate.isBefore(endOfMonth.add(const Duration(days: 1)))) {
          monthTotal += amount;
        }
      }

      setState(() {
        todayExpenses = todayTotal;
        yesterdayExpenses = yesterdayTotal;
        thisWeekExpenses = weekTotal;
        thisMonthExpenses = monthTotal;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading expenses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      body: Column(
        children: [
          // New Header Design
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 48,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            decoration: BoxDecoration(
              color: primary_color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Smart Spend',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.account_circle, color: Colors.white, size: 35),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // New Welcome Section
                Text(
                  'Hello, ${user!.displayName ?? 'User'}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Good to see you! Ready to track your spending?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expense Cards Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                    children: [
                      _buildExpenseCard(
                        "Today's Expense",
                        Icons.today_rounded,
                        '₹${todayExpenses.toStringAsFixed(2)}',
                        primary_color,
                            () {
                        },
                      ),
                      _buildExpenseCard(
                        'Yesterday',
                        Icons.history_rounded,
                        '₹${yesterdayExpenses.toStringAsFixed(2)}',
                        primary_color,
                            () {
                        },
                      ),
                      _buildExpenseCard(
                        'This Week',
                        Icons.date_range_rounded,
                        '₹${thisWeekExpenses.toStringAsFixed(2)}',
                        primary_color,
                            () {
                        },
                      ),
                      _buildExpenseCard(
                        'This Month',
                        Icons.calendar_month_rounded,
                        '₹${thisMonthExpenses.toStringAsFixed(2)}',
                        primary_color,
                            () {
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primary_color, // Same as unselected color
          unselectedItemColor: Colors.grey,
          // selectedFontSize: 15,
          // unselectedFontSize: 13,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            switch (index) {
              case 0:
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordPage()),
                ).then((_) {
                  _loadExpenses();
                });
                _selectedIndex=0;
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddExpense()),
                ).then((_) {
                  _loadExpenses();
                });
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChartPage()),
                ).then((_) {
                  _loadExpenses();
                });
                _selectedIndex=0;
                break;
              case 4:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BudgetsPage()),
                ).then((_) {
                  _loadExpenses();
                });
                _selectedIndex=0;
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primary_color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary_color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: Colors.white, size: 28),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart),
              label: 'Charts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Budgets',
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildExpenseCard(String title, IconData icon, String amount, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              amount,
              style: TextStyle(
                color: primary_color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
