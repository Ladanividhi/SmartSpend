import 'package:SmartSpend/Constants.dart';
import 'package:SmartSpend/screens/ChartPage.dart';
import 'package:SmartSpend/screens/ProfilePage.dart';
import 'package:SmartSpend/screens/ReportsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  int _selectedIndex = 0;

  // Mock data for demonstration
  final List<Map<String, dynamic>> transactions = [
    {"icon": Icons.savings, "color": Colors.pink[100], "label": "Investments", "amount": 500.00},
    {"icon": Icons.card_giftcard, "color": Colors.green[100], "label": "Gift", "amount": -10.00},
    {"icon": Icons.pets, "color": Colors.teal[100], "label": "Pet", "amount": -20.00},
    {"icon": Icons.shopping_cart, "color": Colors.green[200], "label": "Shopping", "amount": -236.00},
    {"icon": Icons.volunteer_activism, "color": Colors.blue[100], "label": "Donate", "amount": -20.00},
    {"icon": Icons.restaurant, "color": Colors.teal[200], "label": "Food", "amount": -5.00},
    {"icon": Icons.pets, "color": Colors.teal[100], "label": "Pet", "amount": -56.00},
    {"icon": Icons.icecream, "color": Colors.yellow[100], "label": "Snacks", "amount": -5.00},
    {"icon": Icons.home, "color": Colors.purple[100], "label": "Home", "amount": -63.00},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: primary_color,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
          ),
          // Date Row
          // Transaction List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx["color"],
                    child: Icon(tx["icon"], color: primary_color),
                  ),
                  title: Text(tx["label"], style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text(
                    tx["amount"] > 0 ? "+${tx["amount"]}" : "${tx["amount"]}",
                    style: TextStyle(
                      color: tx["amount"] > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Attractive Bottom Navigation Bar
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
          selectedItemColor: primary_color,
          unselectedItemColor: Colors.grey,
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChartPage()),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RecordPage()),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ReportsPage()),
                );
                break;
              case 4:
                Navigator.pushReplacement(
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
              label: 'Reports',
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
