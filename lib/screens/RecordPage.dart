import 'package:SmartSpend/Constants.dart';
import 'package:SmartSpend/screens/AddExpense.dart';
import 'package:SmartSpend/screens/ChartPage.dart';
import 'package:SmartSpend/screens/ProfilePage.dart';
import 'package:SmartSpend/screens/BudgetsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  int _selectedIndex = 0;

  Map<String, String> categoryIcons = {
    'Beauty': 'beauty.png',
    'Birthday': 'birthday.png',
    'Children': 'children.png',
    'Clothing': 'clothing.png',
    'Donation': 'donation.png',
    'Education': 'education.png',
    'Entertainment': 'entertainment.png',
    'Fees': 'fees.png',
    'Food': 'food.png',
    'Friends': 'friends.png',
    'Gifts': 'gifts.png',
    'Grocery': 'grocery.png',
    'Gym': 'gym.png',
    'Health': 'health.png',
    'Homedecor': 'homedecor.png',
    'Investments': 'homedecor.png',
    'Movie': 'movie.png',
    'Party': 'party.png',
    'Pet': 'pet.png',
    'Petrol': 'petrol.png',
    'Recharge': 'recharge.png',
    'Repairing': 'repair.png',
    'Shopping': 'shopping.png',
    'Social': 'social.png',
    'Snacks': 'snacks.png',
    'Sports': 'sport.png',
    'Transport': 'transportation.png',
    'Travel': 'travel.png',
    'Others': 'others.png',
  };

  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExpensesByCategory();
  }

  Future<void> fetchExpensesByDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final snapshot = await FirebaseFirestore.instance
          .collection('Expenses')
          .where('Id', isEqualTo: user.uid)
          .get();

      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final Timestamp timestamp = data['Date'];
        final DateTime docDate = timestamp.toDate();

        return docDate.year == date.year &&
            docDate.month == date.month &&
            docDate.day == date.day;
      }).toList();


      if (filteredDocs.isEmpty) {
        Fluttertoast.showToast(
          msg: "No expenses on this date.",
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
        );
        setState(() {
          transactions = [];
          isLoading = false;
        });
        return;
      }

      Map<String, double> categoryTotals = {};

      for (var doc in filteredDocs) {
        final data = doc.data();
        String category = data['Category'];
        double amount = (data['Amount'] as num).toDouble();

        if (categoryTotals.containsKey(category)) {
          categoryTotals[category] = categoryTotals[category]! + amount;
        } else {
          categoryTotals[category] = amount;
        }
      }

      setState(() {
        transactions = categoryTotals.entries.map((entry) {
          return {
            'label': entry.key,
            'amount': entry.value,
            'icon': categoryIcons[entry.key] ?? 'others.png',
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching expenses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> fetchExpensesInRange(DateTime start, DateTime end) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Expenses')
          .where('Id', isEqualTo: user.uid)
          .get();

      final startDateTime = DateTime(start.year, start.month, start.day);
      final endDateTime = DateTime(end.year, end.month, end.day, 23, 59, 59);

      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final Timestamp timestamp = data['Date'];
        final DateTime docDate = timestamp.toDate();

        return (docDate.isAtSameMomentAs(startDateTime) ||
            (docDate.isAfter(startDateTime) && docDate.isBefore(endDateTime)) ||
            docDate.isAtSameMomentAs(endDateTime));
      }).toList();


      _processAndSetTransactions(filteredDocs);
    } catch (e) {
      print("Error fetching expenses in range: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _processAndSetTransactions(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) {
      Fluttertoast.showToast(
        msg: "No expenses in this period.",
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        gravity: ToastGravity.CENTER,
      );
      setState(() {
        transactions = [];
        isLoading = false;
      });
      return;
    }

    Map<String, double> categoryTotals = {};

    for (var doc in docs) {
      final data = doc.data();
      String category = data['Category'];
      double amount = (data['Amount'] as num).toDouble();

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    setState(() {
      transactions = categoryTotals.entries.map((entry) {
        return {
          'label': entry.key,
          'amount': entry.value,
          'icon': categoryIcons[entry.key] ?? 'others.png',
        };
      }).toList();
      isLoading = false;
    });
  }

  void fetchThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    fetchExpensesInRange(startOfWeek, endOfWeek);
  }

  void fetchThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    fetchExpensesInRange(startOfMonth, endOfMonth);
  }

  void fetchThisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    fetchExpensesInRange(startOfYear, endOfYear);
  }

  Future<void> fetchExpensesByCategory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('Expenses')
          .where('Id', isEqualTo: user.uid)
          .get();

      Map<String, double> categoryTotals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String category = data['Category'];
        double amount = (data['Amount'] as num).toDouble();

        if (categoryTotals.containsKey(category)) {
          categoryTotals[category] = categoryTotals[category]! + amount;
        } else {
          categoryTotals[category] = amount;
        }
      }

      setState(() {
        transactions = categoryTotals.entries.map((entry) {
          return {
            'label': entry.key,
            'amount': entry.value,
            'icon': categoryIcons[entry.key] ?? 'others.png',
          };
        }).toList();
        isLoading = false;
      });
    }
  }

  Future<void> _onMenuSelected(String value) async {
    switch (value) {
      case 'today':
        final today = DateTime.now();
        fetchExpensesByDate(today);
        break;

      case 'select_date':
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          fetchExpensesByDate(picked);
        }
        break;
      case 'this_week':
        fetchThisWeek();
        break;
      case 'this_month':
        fetchThisMonth();
        break;
      case 'this_year':
        fetchThisMonth();
        break;
      case 'custom':
        DateTime? startDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (startDate != null) {
          DateTime? endDate = await showDatePicker(
            context: context,
            initialDate: startDate,
            firstDate: startDate,
            lastDate: DateTime.now(),
          );

          if (endDate != null) {
            fetchExpensesInRange(startDate, endDate);
          } else {
            Fluttertoast.showToast(
              msg: "End date not selected.",
              backgroundColor: Colors.black87,
              textColor: Colors.white,
              gravity: ToastGravity.CENTER,
            );
          }
        } else {
          Fluttertoast.showToast(
            msg: "Start date not selected.",
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            gravity: ToastGravity.CENTER,
          );
        }
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
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primary_color))
          : ListView.builder(
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
            title: Text(
              tx["label"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              '${tx["amount"] > 0 ? "-" : ""}${tx["amount"].toStringAsFixed(2)}',
              style: TextStyle(
                color: tx["amount"] > 0 ? Colors.red : Colors.green,
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
                _selectedIndex = 0;
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BudgetsPage()),
                );
                break;
              case 4:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
                _selectedIndex = 0;
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
