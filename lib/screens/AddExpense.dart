import 'package:SmartSpend/Constants.dart';
import 'package:flutter/material.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final List<Map<String, String>> categories = [
    {'label': 'Beauty', 'icon': 'beauty.png'},
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
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'add_category',
                child: Text('Add New Category'),
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
                    labelText: "Enter Memo (optional)",
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
                  final amount = amountController.text;
                  final memo = memoController.text;
                  print("Category: $category, Amount: $amount, Memo: $memo");

                  // TODO: Save this to your DB or state
                  Navigator.pop(context);
                },
                child: Text("Save"),
              ),
            ],
          ),
    );
  }
}
