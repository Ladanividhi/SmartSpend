import 'package:SmartSpend/screens/ViewBudget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategoryWiseBudgetPage extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const CategoryWiseBudgetPage({
    Key? key,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  State<CategoryWiseBudgetPage> createState() => _CategoryWiseBudgetPageState();
}

class _CategoryWiseBudgetPageState extends State<CategoryWiseBudgetPage> {

  final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknownUser";

  final List<Map<String, String>> categories = [
    {'label': 'Beauty', 'icon': 'beauty.png'},
    {'label': 'Birthday', 'icon': 'birthday.png'},
    {'label': 'Children', 'icon': 'children.png'},
    {'label': 'Clothing', 'icon': 'clothing.png'},
    {'label': 'Donation', 'icon': 'donation.png'},
    {'label': 'Education', 'icon': 'education.png'},
    {'label': 'Entertainment', 'icon': 'entertainment.png'},
    {'label': 'Fees', 'icon': 'fees.png'},
    {'label': 'Food', 'icon': 'food.png'},
    {'label': 'Friends', 'icon': 'friends.png'},
    {'label': 'Gifts', 'icon': 'gifts.png'},
    {'label': 'Grocery', 'icon': 'grocery.png'},
    {'label': 'Gym', 'icon': 'gym.png'},
    {'label': 'Health', 'icon': 'health.png'},
    {'label': 'Homedecor', 'icon': 'homedecor.png'},
    {'label': 'Investments', 'icon': 'investments.png'},
    {'label': 'Movie', 'icon': 'movie.png'},
    {'label': 'Party', 'icon': 'party.png'},
    {'label': 'Pet', 'icon': 'pet.png'},
    {'label': 'Petrol', 'icon': 'petrol.png'},
    {'label': 'Recharge', 'icon': 'recharge.png'},
    {'label': 'Repairing', 'icon': 'repair.png'},
    {'label': 'Shopping', 'icon': 'shopping.png'},
    {'label': 'Social', 'icon': 'social.png'},
    {'label': 'Snacks', 'icon': 'snacks.png'},
    {'label': 'Sports', 'icon': 'sport.png'},
    {'label': 'Transport', 'icon': 'transportation.png'},
    {'label': 'Travel', 'icon': 'travel.png'},
    {'label': 'Others', 'icon': 'others.png'},
  ];

  Future<void> addBudgetToFirestore({
    required String userId,
    required String start,
    required String end,
    required String category,
    required double amount,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('CategoryBudget').add({
        'Id': userId,
        'StartDate': widget.startDate,
        'Category' : category,
        'Amount': amount,
        'EndDate': widget.endDate,
      });

      Fluttertoast.showToast(
        msg: "Budget added successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      print("Error setting budget: $e");
      Fluttertoast.showToast(
        msg: "Failed to set budget",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void _showBudgetDialog(BuildContext context, String category) {
    final TextEditingController _budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set Budget for $category"),
        content: TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter budget amount",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final budget = _budgetController.text.trim();
              if (budget.isEmpty) {
                Fluttertoast.showToast(msg: "Please enter an amount.");
                return;
              }

              try {
                final double amount = double.parse(budget);
                addBudgetToFirestore(
                  userId: userId,
                  start: widget.startDate.toIso8601String(),
                  end: widget.endDate.toIso8601String(),
                  amount: amount,
                  category: category,
                );
                Navigator.pop(context);
              } catch (e) {
                Fluttertoast.showToast(msg: "Invalid amount entered.");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primary_color),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primary_color,
        title: const Text(
          'Set Budget by Category',
          style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold),
        ),
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
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view_budget',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: primary_color),
                    const SizedBox(width: 12),
                    const Text('View all Budgets'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () => _showBudgetDialog(context, category['label']!),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: icons_shade,
                          child: Image.asset(
                            'assets/icons/${category['icon']}',
                            width: 30,
                            height: 30,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          category['label']!,
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
