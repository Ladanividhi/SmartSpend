import 'package:SmartSpend/Constants.dart';
import 'package:SmartSpend/screens/AddExpense.dart';
import 'package:SmartSpend/screens/ChartPage.dart';
import 'package:SmartSpend/screens/ProfilePage.dart';
import 'package:SmartSpend/screens/ReportsPage.dart';
import 'package:flutter/material.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> transactions = [
    {'label': 'Beauty', 'icon': 'beauty.png', 'amount': -100},
    {'label': 'Children', 'icon': 'children.png', 'amount': -50},
    {'label': 'Clothing', 'icon': 'clothing.png', 'amount': -150},
    {'label': 'Donation', 'icon': 'donation.png', 'amount': -200},
    {'label': 'Education', 'icon': 'education.png', 'amount': -80},
    {'label': 'Entertainment', 'icon': 'entertainment.png', 'amount': -60},
    {'label': 'Fees', 'icon': 'fees.png', 'amount': -90},
    {'label': 'Food', 'icon': 'food.png', 'amount': -120},
    {'label': 'Friends', 'icon': 'friends.png', 'amount': -70},
    {'label': 'Gifts', 'icon': 'gifts.png', 'amount': -40},
    {'label': 'Grocery', 'icon': 'grocery.png', 'amount': -300},
    {'label': 'Gym', 'icon': 'gym.png', 'amount': -110},
    {'label': 'Health', 'icon': 'health.png', 'amount': -130},
    {'label': 'Homedecor', 'icon': 'homedecor.png', 'amount': -90},
    {'label': 'Investments', 'icon': 'homedecor.png', 'amount': 11000},
    {'label': 'Movie', 'icon': 'movie.png', 'amount': -70},
    {'label': 'Party', 'icon': 'party.png', 'amount': -150},
    {'label': 'Pet', 'icon': 'pet.png', 'amount': -60},
    {'label': 'Petrol', 'icon': 'petrol.png', 'amount': -100},
    {'label': 'Recharge', 'icon': 'recharge.png', 'amount': -50},
    {'label': 'Repairing', 'icon': 'repair.png', 'amount': -200},
    {'label': 'Shopping', 'icon': 'shopping.png', 'amount': -250},
    {'label': 'Social', 'icon': 'social.png', 'amount': -30},
    {'label': 'Snacks', 'icon': 'snacks.png', 'amount': -40},
    {'label': 'Sports', 'icon': 'sport.png', 'amount': -60},
    {'label': 'Transport', 'icon': 'transportation.png', 'amount': -70},
    {'label': 'Travel', 'icon': 'travel.png', 'amount': -500},
    {'label': 'Others', 'icon': 'others.png', 'amount': -20},
  ];

  void _onMenuSelected(String value) {
    switch (value) {
      case 'today':
      // handle today
        break;
      case 'select_date':
      // handle date picker
        break;
      case 'this_week':
      // handle this week
        break;
      case 'this_month':
      // handle this month
        break;
      case 'this_year':
      // handle this year
        break;
      case 'custom':
      // handle custom range
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primary_color,
        title: const Text(
          'Records',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _onMenuSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('Today')),
              const PopupMenuItem(value: 'select_date', child: Text('Select Date')),
              const PopupMenuItem(value: 'this_week', child: Text('This Week')),
              const PopupMenuItem(value: 'this_month', child: Text('This Month')),
              const PopupMenuItem(value: 'this_year', child: Text('This Year')),
              const PopupMenuItem(value: 'custom', child: Text('Customize Range')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: icons_shade,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Image.asset(
                  'assets/icons/${tx["icon"]}',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            title: Text(tx["label"], style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: Text(
              '${tx["amount"] > 0 ? "+" : ""}${tx["amount"].toString()}',
              style: TextStyle(
                color: tx["amount"] > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            const BoxShadow(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddExpense()),
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
              label: 'Reports',
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
