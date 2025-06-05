import 'package:SmartSpend/screens/CategoryWiseBudget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:SmartSpend/Constants.dart';

class SetBudgetPage extends StatefulWidget {
  const SetBudgetPage({super.key});

  @override
  State<SetBudgetPage> createState() => _SetBudgetPageState();
}

class _SetBudgetPageState extends State<SetBudgetPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  final userId = FirebaseAuth.instance.currentUser?.uid ?? "unknownUser";

  void _pickStartDate() async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  void _pickEndDate() async {
    if (_startDate == null) {
      _showAlert("Please select a start date first.");
      return;
    }

    final DateTime lastValid = DateTime.now().add(const Duration(days: 365));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(const Duration(days: 1)),
      firstDate: _startDate!,
      lastDate: lastValid,
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _submitBudgetFlow() {
    if (_startDate == null || _endDate == null) {
      _showAlert("Please select both start and end dates.");
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Set Budget"),
            content: const Text(
              "Would you like to set the budget category-wise?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => CategoryWiseBudgetPage(
                            startDate: _startDate!,
                            endDate: _endDate!,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: primary_color),
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAmountInputDialog();
                },
                style: ElevatedButton.styleFrom(backgroundColor: primary_color),
                child: const Text("No", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _showAmountInputDialog() {
    final TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Enter Budget Amount"),
            content: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter total amount (₹)",
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = _amountController.text.trim();
                  if (amount.isEmpty) {
                    Fluttertoast.showToast(msg: "Please enter amount.");
                    return;
                  }
                  Navigator.pop(context);
                  _showFinalConfirmation(amount);
                },
                style: ElevatedButton.styleFrom(backgroundColor: primary_color),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> addBudgetToFirestore({
    required String userId,
    required String start,
    required String end,
    required double amount,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('Budget').add({
        'Id': userId,
        'StartDate': _startDate,
        'Amount': amount,
        'EndDate': _endDate,
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
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showFinalConfirmation(String amount) {
    final start = formatter.format(_startDate!);
    final end = formatter.format(_endDate!);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm Budget"),
            content: Text(
              "Are you sure you want to set the budget of ₹$amount\nfrom $start to $end?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("No"),
              ),
              ElevatedButton(
                onPressed: () {
                  addBudgetToFirestore(
                    userId: userId, // replace with your auth userId
                    start: start,
                    end: end,
                    amount: double.tryParse(amount) ?? 0.0,
                  );
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: "Budget set successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: primary_color),
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _showAlert(String msg) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Text(msg),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          "Set Budget",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Start Date"),
              subtitle: Text(
                _startDate != null
                    ? formatter.format(_startDate!)
                    : "Select start date",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickStartDate,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text("End Date"),
              subtitle: Text(
                _endDate != null
                    ? formatter.format(_endDate!)
                    : "Select end date",
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickEndDate,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBudgetFlow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary_color,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
