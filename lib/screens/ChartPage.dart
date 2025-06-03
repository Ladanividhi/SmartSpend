import 'package:SmartSpend/screens/AddExpense.dart';
import 'package:SmartSpend/screens/ProfilePage.dart';
import 'package:SmartSpend/screens/RecordPage.dart';
import 'package:SmartSpend/screens/BudgetsPage.dart';
import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categoryData = [
      {
        'label': 'Shopping',
        'value': 236.0,
        'color': const Color(0xFFC8BE68),
        'icon': 'shopping.png',
      },
      {
        'label': 'Beauty',
        'value': 136.0,
        'color': const Color(0xFFCD76D3),
        'icon': 'beauty.png',
      },
      {
        'label': 'Pet',
        'value': 76.0,
        'color': const Color(0xFF108898),
        'icon': 'pet.png',
      },
      {
        'label': 'Entertainment',
        'value': 71.0,
        'color': const Color(0xFFBA6B86),
        'icon': 'entertainment.png',
      },
      {
        'label': 'Home',
        'value': 63.0,
        'color': const Color(0xFF8EC18F),
        'icon': 'homedecor.png',
      },
    ];

    double total = categoryData.fold(0, (sum, item) => sum + item['value']);

    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        backgroundColor: primary_color,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Charts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {},
            itemBuilder:
                (context) => const [
                  PopupMenuItem(value: 'today', child: Text('Today')),
                  PopupMenuItem(
                    value: 'select_date',
                    child: Text('Select Date'),
                  ),
                  PopupMenuItem(value: 'this_week', child: Text('This Week')),
                  PopupMenuItem(value: 'this_month', child: Text('This Month')),
                  PopupMenuItem(value: 'this_year', child: Text('This Year')),
                  PopupMenuItem(
                    value: 'custom',
                    child: Text('Customize Range'),
                  ),
                ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections:
                        categoryData.map((item) {
                          final percentage = (item['value'] / total) * 100;
                          return PieChartSectionData(
                            value: item['value'],
                            color: item['color'],
                            radius: 60,
                            title: '${percentage.toStringAsFixed(1)}%',
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        }).toList(),
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    centerSpaceColor: bg_color,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Top lists',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...categoryData.map((item) {
                final percent = (item['value'] / total) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: icons_shade,
                        radius: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset(
                            'assets/icons/${item['icon']}',
                            width: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['label']} ${percent.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: item['value'] / total,
                              color: item['color'],
                              backgroundColor: Colors.grey.shade300,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item['value'].toStringAsFixed(0)),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
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
                _selectedIndex = 1;
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
                _selectedIndex = 1;
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
