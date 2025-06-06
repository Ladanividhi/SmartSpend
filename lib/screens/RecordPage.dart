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
  int a = 0;
  int _selectedIndex = 0;
  double totalExpenses = 0;
  double totalIncome = 0;
  String date = '';
  String start = '';
  String end = '';

  Map<String, bool> expandedStates = {};
  final FocusNode _focusNode = FocusNode();

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
  Map<String, List<Map<String, dynamic>>> detailedTransactions = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExpensesByDate(DateTime.now());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> fetchExpensesByDate(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      isLoading = true;
      expandedStates = {};
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Expenses')
              .where('Id', isEqualTo: user.uid)
              .get();

      final filteredDocs =
          snapshot.docs.where((doc) {
            final data = doc.data();
            final Timestamp timestamp = data['Date'];
            final DateTime docDate = timestamp.toDate();

            return docDate.year == date.year &&
                docDate.month == date.month &&
                docDate.day == date.day;
          }).toList();

      _processAndSetTransactions(filteredDocs);
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
      expandedStates = {};
    });

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('Expenses')
              .where('Id', isEqualTo: user.uid)
              .get();

      final startDateTime = DateTime(start.year, start.month, start.day);
      final endDateTime = DateTime(end.year, end.month, end.day, 23, 59, 59);

      final filteredDocs =
          snapshot.docs.where((doc) {
            final data = doc.data();
            final Timestamp timestamp = data['Date'];
            final DateTime docDate = timestamp.toDate();

            return (docDate.isAtSameMomentAs(startDateTime) ||
                (docDate.isAfter(startDateTime) &&
                    docDate.isBefore(endDateTime)) ||
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

  void _processAndSetTransactions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    if (docs.isEmpty) {
      setState(() {
        transactions = [];
        detailedTransactions = {};
        totalExpenses = 0;
        totalIncome = 0;
        isLoading = false;
      });
      return;
    }

    Map<String, double> categoryTotals = {};
    Map<String, List<Map<String, dynamic>>> categoryDetails = {};
    double currentTotalExpenses = 0;
    double currentTotalIncome = 0;

    for (var doc in docs) {
      final data = doc.data();
      String category = data['Category'];
      double amount = (data['Amount'] as num).toDouble();
      String message = data['Message'] ?? '';
      DateTime date = (data['Date'] as Timestamp).toDate();
      String type =
          data['Type'] ?? 'Expense'; // Assuming you have a 'Type' field

      // Update category totals
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;

      // Calculate total expenses and income for the period
      if (type == 'Expense') {
        currentTotalExpenses += amount;
      } else if (type == 'Income') {
        currentTotalIncome += amount;
      }

      // Add to detailed transactions
      if (!categoryDetails.containsKey(category)) {
        categoryDetails[category] = [];
      }
      categoryDetails[category]!.add({
        'amount': amount,
        'message': message,
        'date': date,
        'id': doc.id,
        'type': type, // Include type in detailed transaction
      });
    }

    // Sort detailed transactions by date (newest first)
    categoryDetails.forEach((category, transactions) {
      transactions.sort((a, b) => b['date'].compareTo(a['date']));
    });

    setState(() {
      transactions =
          categoryTotals.entries.map((entry) {
            return {
              'label': entry.key,
              'amount':
                  entry
                      .value, // This is the total for the category in the period
              'icon': categoryIcons[entry.key] ?? 'others.png',
            };
          }).toList();
      detailedTransactions = categoryDetails;
      totalExpenses = currentTotalExpenses;
      totalIncome = currentTotalIncome;
      isLoading = false;
    });
  }

  void fetchThisWeek() {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final endOfWeek = DateTime(
      now.year,
      now.month,
      now.day + (7 - now.weekday),
      23,
      59,
      59,
    );
    fetchExpensesInRange(startOfWeek, endOfWeek);
  }

  void fetchThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    fetchExpensesInRange(startOfMonth, endOfMonth);
  }

  void fetchThisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
    fetchExpensesInRange(startOfYear, endOfYear);
  }

  Future<void> fetchExpensesByCategory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        isLoading = true;
        expandedStates = {};
      });

      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('Expenses')
                .where('Id', isEqualTo: user.uid)
                .get();

        _processAndSetTransactions(snapshot.docs);
      } catch (e) {
        print("Error fetching expenses: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _onMenuSelected(String value) async {
    switch (value) {
      case 'till_now':
        a = 1;
        final today = DateTime.now();
        date = 'Till Now';
        fetchExpensesByCategory();
        break;

      case 'select_date':
        a = 2;
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          final DateFormat formatter = DateFormat('MMM d, yyyy');
          date = formatter.format(picked);
          fetchExpensesByDate(picked);
        }
        break;
      case 'this_week':
        a = 3;
        fetchThisWeek();
        break;
      case 'this_month':
        a = 4;
        fetchThisMonth();
        break;
      case 'this_year':
        a = 5;
        fetchThisYear();
        break;
      case 'custom':
        a = 6;
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
            firstDate: startDate, // End date cannot be before start date
            lastDate: DateTime.now(),
          );

          if (endDate != null) {
            fetchExpensesInRange(startDate, endDate);
            final DateFormat formatter = DateFormat('MMM d, yyyy');
            start = formatter.format(startDate);
            end = formatter.format(endDate);
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
    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        backgroundColor: bg_color,
        body: Column(
          children: [
            // Modern Header Design
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
                      const Text(
                        'Records',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: _onMenuSelected,
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(
                                value: 'till_now',
                                child: Row(
                                  children: [
                                    Icon(Icons.access_time_filled_sharp, color: primary_color),
                                    const SizedBox(width: 12),
                                    const Text('Till Now'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'select_date',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: primary_color,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Select Date'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'this_week',
                                child: Row(
                                  children: [
                                    Icon(Icons.date_range, color: primary_color),
                                    const SizedBox(width: 12),
                                    const Text('This Week'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'this_month',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: primary_color,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('This Month'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'this_year',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_view_month,
                                      color: primary_color,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('This Year'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'custom',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.date_range_outlined,
                                      color: primary_color,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Customize Range'),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a == 1
                                    ? 'Total Expenses Till Now'
                                    : a == 2
                                    ? 'Total Expenses on $date'
                                    : a == 3
                                    ? 'Total Expenses This Week'
                                    : a == 4
                                    ? 'Total Expenses This Month'
                                    : a == 5
                                    ? 'Total Expenses This Year'
                                    : a == 6
                                    ? 'Total Expenses from $start to $end'
                                    : 'Total Expenses Today',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 8),
                              Text(
                                '₹${totalExpenses.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Transactions List
            Expanded(
              child:
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: primary_color),
                        )
                      : transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions found for this period.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final tx = transactions[index];
                            final isExpanded = expandedStates[tx['label']] ?? false;
                            final categoryTransactions =
                                detailedTransactions[tx['label']] ?? [];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        expandedStates[tx['label']] = !isExpanded;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: icons_shade.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                            child: Image.asset(
                                              'assets/icons/${tx["icon"]}',
                                              width: 32,
                                              height: 32,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              tx["label"],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '₹${tx["amount"].toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color:
                                                  tx["amount"] > 0
                                                      ? Colors.red
                                                      : Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isExpanded && categoryTransactions.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Column(
                                        children:
                                            categoryTransactions.map((transaction) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        transaction['message']
                                                                    ?.trim()
                                                                    .isNotEmpty ==
                                                                true
                                                            ? transaction['message']
                                                            : '---',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹${transaction['amount'].toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  DateFormat(
                                                    'dd MMM yyyy, HH:mm',
                                                  ).format(transaction['date']),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
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
                  ).then((_) {
                    switch (a) {
                      case 1:
                        fetchExpensesByCategory();
                        break;
                      case 2:
                        fetchExpensesByDate(date as DateTime);
                        break;
                      case 3:
                        fetchThisWeek();
                        break;
                      case 4:
                        fetchThisMonth();
                        break;
                      case 5:
                        fetchThisYear();
                        break;
                      case 6:
                        fetchExpensesInRange(start as DateTime, end as DateTime);
                        break;
                      default:
                        fetchExpensesByDate(DateTime.now());
                    }
                  });
                  _selectedIndex = 0; // Stay on Records tab after adding expense
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
                  _selectedIndex = 0; // Stay on Records tab after viewing profile
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
      ),
    );
  }
}
