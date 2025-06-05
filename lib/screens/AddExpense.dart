import 'package:SmartSpend/Constants.dart';
import 'package:SmartSpend/screens/ViewExpenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: primary_color,
        title: Text(
          'Add Expense',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'add_category') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Add New Category"),
                    content: TextField(
                      decoration: InputDecoration(
                        hintText: "Enter category name",
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Save new category logic
                          Navigator.pop(context);
                        },
                        child: Text("Add"),
                      ),
                    ],
                  ),
                );
              }
              else if (value == 'view_expense') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewExpensePage()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view_expense',
                child: Row(
                  children: [
                    Icon(Icons.currency_rupee_sharp, color: primary_color),
                    const SizedBox(width: 12),
                    const Text('View all Expenses'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add_category',
                child: Row(
                  children: [
                    Icon(Icons.add_box, color: primary_color),
                    const SizedBox(width: 12),
                    const Text('Add new category'),
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
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.9,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () => _showExpenseDialog(context, category['label']!),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        // backgroundColor: Colors.grey.shade200,
                        backgroundColor: icons_shade,
                        child: Image.asset(
                          'assets/icons/${category['icon']}',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        category['label']!,
                        style: TextStyle(fontSize: 12),
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

  Future<void> addExpenseToFirestore({
    required String userId,
    required String category,
    required double amount,
    String? message,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('Expenses').add({
        'Id': userId,
        'Category': category,
        'Amount': amount,
        'Message': message ?? "",
        'Date': Timestamp.now(),
      });

      Fluttertoast.showToast(
        msg: "Expense added successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      print("Error adding expense: $e");
      Fluttertoast.showToast(
        msg: "Failed to add expense",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showExpenseDialog(BuildContext context, String category) {
    final amountController = TextEditingController();
    final memoController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Add $category Expense"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: "Enter Amount"),
                ),
                TextField(
                  controller: memoController,
                  decoration: InputDecoration(
                    labelText: "Enter Message (optional)",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  final memo = memoController.text.isNotEmpty ? memoController.text : null;

                  if (amount > 0) {
                    addExpenseToFirestore(
                      userId: userId,  // replace with your auth userId
                      category: category,
                      amount: amount,
                      message: memo,
                    );

                    Navigator.pop(context);
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please enter a valid amount",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
    );
  }
}
