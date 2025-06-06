import 'package:SmartSpend/Constants.dart';
import 'package:SmartSpend/screens/AddExpense.dart';
import 'package:SmartSpend/screens/ChartPage.dart';
import 'package:SmartSpend/screens/RecordPage.dart';
import 'package:SmartSpend/screens/BudgetsPage.dart';
import 'package:SmartSpend/screens/ProfilePage.dart';
import 'package:SmartSpend/screens/Settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0; // Default index, but won't show as selected
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
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
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'settings') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(),
                            ),
                          );
                        } else if (value == 'budgets') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BudgetsPage(),
                            ),
                          );
                        } else if (value == 'records') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecordPage(),
                            ),
                          );
                        } else if (value == 'chart') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChartPage(),
                            ),
                          );
                        } else if (value == 'expense') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddExpense(),
                            ),
                          );
                        }
                      },
                      itemBuilder:
                          (BuildContext context) => [
                            PopupMenuItem(
                              value: 'records',
                              child: Row(
                                children: [
                                  Icon(Icons.receipt, color: primary_color),
                                  const SizedBox(width: 12),
                                  const Text('View Records'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'chart',
                              child: Row(
                                children: [
                                  Icon(Icons.pie_chart, color: primary_color),
                                  const SizedBox(width: 12),
                                  const Text('View Charts'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'expense',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.currency_rupee,
                                    color: primary_color,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Add Expense'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'budgets',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.monetization_on_rounded,
                                    color: primary_color,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Budgets'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'settings',
                              child: Row(
                                children: [
                                  Icon(Icons.settings, color: primary_color),
                                  const SizedBox(width: 12),
                                  const Text('Settings'),
                                ],
                              ),
                            ),
                          ],
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
                const SizedBox(height: 24),
                // Financial Overview Cards
              ],
            ),
          ),
          // Empty space for content
          Expanded(child: Container()),
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
          selectedItemColor: Colors.grey, // Same as unselected color
          unselectedItemColor: Colors.grey,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            switch (index) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordPage()),
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChartPage()),
                );
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddExpense()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BudgetsPage()),
                );
                break;
              case 4:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Records',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_rounded),
              label: 'Chart',
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
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Budgets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }
}
