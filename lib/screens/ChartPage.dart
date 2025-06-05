import 'package:SmartSpend/screens/AddExpense.dart';
import 'package:SmartSpend/screens/ProfilePage.dart';
import 'package:SmartSpend/screens/RecordPage.dart';
import 'package:SmartSpend/screens/BudgetsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int _selectedIndex = 1;
  bool isLoading = true;
  double totalExpenses = 0;
  Map<String, double> categoryTotals = {};
  Map<String, List<Map<String, dynamic>>> detailedTransactions = {};

  // 24 distinct colors for categories
  final List<Color> categoryColors = [
    const Color(0xFFE57373), // Red
    const Color(0xFFF06292), // Pink
    const Color(0xFFBA68C8), // Purple
    const Color(0xFF9575CD), // Deep Purple
    const Color(0xFF7986CB), // Indigo
    const Color(0xFF64B5F6), // Blue
    const Color(0xFF4FC3F7), // Light Blue
    const Color(0xFF4DD0E1), // Cyan
    const Color(0xFF4DB6AC), // Teal
    const Color(0xFF81C784), // Green
    const Color(0xFFAED581), // Light Green
    const Color(0xFFFFD54F), // Yellow
    const Color(0xFFFFB74D), // Orange
    const Color(0xA1887F), // Brown (Corrected hex length)
    const Color(0xFF90A4AE), // Blue Grey
    const Color(0xFF78909C), // Blue Grey Dark
    const Color(0xFFEF5350), // Red Light
    const Color(0xEC407A), // Pink Light (Corrected hex length)
    const Color(0xFFAB47BC), // Purple Light
    const Color(0xFF7E57C2), // Deep Purple Light
    const Color(0xFF5C6BC0), // Indigo Light
    const Color(0x42A5F5), // Blue Light (Corrected hex length)
    const Color(0x29B6F6), // Light Blue Light (Corrected hex length)
    const Color(0x26C6DA), // Cyan Light (Corrected hex length)
  ];

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
  int a = 0;
  String date = '';
  String start = '';
  String end = '';

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
      categoryTotals = {};
      detailedTransactions = {};
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
      categoryTotals = {};
      detailedTransactions = {};
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
        // categoryTotals = {};
        totalExpenses = 0;
        isLoading = false;
      });
      return;
    }

    Map<String, double> categoryTotals = {};
    Map<String, List<Map<String, dynamic>>> categoryDetails = {};

    for (var doc in docs) {
      final data = doc.data();
      String category = data['Category'];
      double amount = (data['Amount'] as num).toDouble();
      String message = data['Message'] ?? '';
      DateTime date = (data['Date'] as Timestamp).toDate();

      // Update category totals
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;

      // Add to detailed transactions
      if (!categoryDetails.containsKey(category)) {
        categoryDetails[category] = [];
      }
      categoryDetails[category]!.add({
        'amount': amount,
        'message': message,
        'date': date,
        'id': doc.id,
      });
    }

    // Sort detailed transactions by date (newest first)
    categoryDetails.forEach((category, transactions) {
      transactions.sort((a, b) => b['date'].compareTo(a['date']));
    });

    setState(() {
      this.categoryTotals = categoryTotals;
      detailedTransactions = categoryDetails;
      totalExpenses = categoryTotals.values.fold(
        0,
        (sum, amount) => sum + amount,
      );
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
      setState(() {
        isLoading = true;
        categoryTotals = {};
        detailedTransactions = {};
      });

      try {
        final snapshot =
            await FirebaseFirestore.instance
                .collection('Expenses')
                .where('Id', isEqualTo: user.uid)
                .get();

        Map<String, double> totals = {};
        Map<String, List<Map<String, dynamic>>> details = {};

        for (var doc in snapshot.docs) {
          final data = doc.data();
          String category = data['Category'];
          double amount = (data['Amount'] as num).toDouble();
          String message = data['Message'] ?? '';
          DateTime date = (data['Date'] as Timestamp).toDate();

          totals[category] = (totals[category] ?? 0) + amount;

          if (!details.containsKey(category)) {
            details[category] = [];
          }
          details[category]!.add({
            'amount': amount,
            'message': message,
            'date': date,
            'id': doc.id,
          });
        }

        // Sort transactions by date (newest first)
        details.forEach((category, transactions) {
          transactions.sort((a, b) => b['date'].compareTo(a['date']));
        });

        setState(() {
          categoryTotals = totals;
          detailedTransactions = details;
          totalExpenses = totals.values.fold(0, (sum, amount) => sum + amount);
          isLoading = false;
        });
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
      case 'today':
        a = 1;
        final today = DateTime.now();
        date = 'Today';
        fetchExpensesByDate(today);
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
            final DateFormat formatter = DateFormat('MMM d, yyyy');
            start = formatter.format(startDate);
            end = formatter.format(endDate);
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Charts',
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
                          value: 'today',
                          child: Row(
                            children: [
                              Icon(Icons.today, color: primary_color),
                              const SizedBox(width: 12),
                              const Text('Today'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'select_date',
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: primary_color),
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
                              Icon(Icons.calendar_month, color: primary_color),
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
          ),
          // Main content area
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(color: primary_color),
                    )
                    : categoryTotals.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses found for this period.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Expenses Summary Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a == 1
                                      ? 'Total Expenses Today'
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
                                      : 'Total Expenses Till Now',
                                  style: const TextStyle(
                                    color: primary_color,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₹${totalExpenses.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: primary_color,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Chart and Legend Card
                          Container(
                            padding: const EdgeInsets.all(16),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Pie Chart with Total
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height:
                                        220, // Increased height for the chart
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        PieChart(
                                          PieChartData(
                                            sections: _createPieChartSections(),
                                            centerSpaceRadius:
                                                40, // Make it a donut chart
                                            sectionsSpace: 2,
                                            startDegreeOffset:
                                                270, // Start from top
                                          ),
                                        ),
                                        Text(
                                          '₹${totalExpenses.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: text_color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Legend
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        categoryTotals.entries.map((entry) {
                                          final color =
                                              categoryColors[categoryTotals.keys
                                                      .toList()
                                                      .indexOf(entry.key) %
                                                  categoryColors.length];
                                          final percentage =
                                              totalExpenses > 0
                                                  ? (entry.value /
                                                          totalExpenses *
                                                          100)
                                                      .toStringAsFixed(1)
                                                  : '0.0';
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2.0,
                                            ), // Adjusted vertical padding
                                            child: Row(
                                              children: [
                                                Container(
                                                  width:
                                                      8, // Slightly reduced dot size
                                                  height:
                                                      8, // Slightly reduced dot size
                                                  decoration: BoxDecoration(
                                                    color: color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 6,
                                                ), // Slightly reduced spacing
                                                Expanded(
                                                  child: Text(
                                                    entry.key,
                                                    style: TextStyle(
                                                      color: text_color
                                                          .withOpacity(0.7),
                                                      fontSize: 11,
                                                    ), // Reduced font size
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  '$percentage%',
                                                  style: TextStyle(
                                                    color: text_color,
                                                    fontSize: 11,
                                                  ), // Reduced font size
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Category List with Progress
                          ListView.builder(
                            shrinkWrap: true,
                            physics:
                                const NeverScrollableScrollPhysics(), // Disable listview's own scrolling
                            itemCount: categoryTotals.length,
                            itemBuilder: (context, index) {
                              final entry = categoryTotals.entries.elementAt(
                                index,
                              );
                              final category = entry.key;
                              final totalAmount = entry.value;
                              final percentage =
                                  totalExpenses > 0
                                      ? (totalAmount / totalExpenses * 100)
                                          .toStringAsFixed(1)
                                      : '0.0';

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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          // Category Icon
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: icons_shade.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Image.asset(
                                              'assets/icons/${categoryIcons[category] ?? 'others.png'}',
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  category,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '$percentage%',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '₹${totalAmount.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Progress Bar
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value:
                                              totalExpenses > 0
                                                  ? totalAmount / totalExpenses
                                                  : 0,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                categoryColors[categoryTotals
                                                        .keys
                                                        .toList()
                                                        .indexOf(category) %
                                                    categoryColors.length],
                                              ),
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RecordPage()),
                );
                break;
              case 1:
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddExpense()),
                );
                _selectedIndex = 1; // Stay on Chart tab after adding expense
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
                _selectedIndex = 1; // Stay on Chart tab after viewing profile
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

  List<PieChartSectionData> _createPieChartSections() {
    final List<PieChartSectionData> sections = [];
    final categories = categoryTotals.keys.toList();

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final amount = categoryTotals[category]!;

      sections.add(
        PieChartSectionData(
          color: categoryColors[i % categoryColors.length],
          value: amount,
          title: '',
          radius: 90, // Adjusted radius for a slightly larger donut
          titleStyle: const TextStyle(
            fontSize: 0, // Hide title on chart sections
          ),
        ),
      );
    }

    return sections;
  }
}
