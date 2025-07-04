import 'package:SmartSpend/screens/AboutUs.dart';
import 'package:SmartSpend/screens/EditBudget.dart';
import 'package:SmartSpend/screens/EditExpense.dart';
import 'package:SmartSpend/screens/FAQs.dart';
import 'package:SmartSpend/screens/Help.dart';
import 'package:SmartSpend/screens/Login.dart';
import 'package:SmartSpend/screens/ProfilePage.dart';
import 'package:SmartSpend/screens/TermsCondition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  signout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Dangerous Operation ⚠️",
              style: TextStyle(color: Colors.red, fontSize: 21),
            ),
            content: const Text(
              "This operation will permanently delete all your expenses and budgets saved till now. "
              "We will not be responsible for any data loss. Once deleted, your data cannot be recovered. "
              "Please proceed with caution.",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _showFinalResetWarning(context);
                },
                child: const Text(
                  "Okay",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _showFinalResetWarning(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Final Warning ⚠️",
              style: TextStyle(color: Colors.red),
            ),
            content: const Text(
              "Are you absolutely sure you want to delete all your expenses and budgets saved till now? "
              "This action is irreversible and will permanently wipe your financial records.",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("No"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteAllUserData();
                  Fluttertoast.showToast(
                    msg: "All your data has been permanently deleted",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.CENTER,
                  );
                },
                child: const Text(
                  "Yes, Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAllUserData() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    // Delete from Expense collection
    final expenseDocs =
        await firestore
            .collection('Expenses')
            .where('Id', isEqualTo: userId)
            .get();

    for (var doc in expenseDocs.docs) {
      await doc.reference.delete();
    }

    // Delete from Budget collection
    final budgetDocs =
        await firestore
            .collection('Budget')
            .where('Id', isEqualTo: userId)
            .get();

    for (var doc in budgetDocs.docs) {
      await doc.reference.delete();
    }

    // Delete from CategoryBudget collection
    final categoryBudgetDocs =
        await firestore
            .collection('CategoryBudget')
            .where('Id', isEqualTo: userId)
            .get();

    for (var doc in categoryBudgetDocs.docs) {
      await doc.reference.delete();
    }
  }

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme switched to ${isDarkMode ? "Dark" : "Light"}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primary_color,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCardOption(Icons.edit, 'Edit Expense', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditExpensePage()),
            );
          }),

          _buildCardOption(Icons.receipt, 'Edit Budget', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditBudgetPage()),
            );
          }),

          Card(
            elevation: 2,
            color: bg_color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text(
                'Dark Mode',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              secondary: const Icon(Icons.dark_mode, color: primary_color),
              value: isDarkMode,
              onChanged: toggleTheme,
              activeColor: primary_color,
            ),
          ),

          _buildCardOption(Icons.policy, 'Terms and Conditions', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TermsAndConditionsPage()),
            );
          }),

          _buildCardOption(Icons.help, 'Help', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpPage()),
            );
          }),

          _buildCardOption(Icons.question_answer, 'FAQs', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FaqsPage()),
            );
          }),

          _buildCardOption(Icons.info_outline, 'About Us', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AboutUsPage()),
            );
          }),

          Card(
            elevation: 2,
            color: bg_color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                "Reset All Data",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              onTap: () => _showResetConfirmation(context),
            ),
          ),

          Card(
            color: Colors.red.shade50,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirm Logout"),
                      content: Text("Are you sure you want to log out from this account?"),
                      actions: [
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();  // closes the dialog
                          },
                        ),
                        TextButton(
                          child: Text("Yes"),
                          onPressed: () {
                            Navigator.of(context).pop(); // close dialog first
                            signout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => Login()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },

            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardOption(IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 2,
      color: bg_color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: primary_color),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
