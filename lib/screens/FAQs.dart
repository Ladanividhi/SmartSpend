import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';

class FaqsPage extends StatefulWidget {
  const FaqsPage({super.key});

  @override
  State<FaqsPage> createState() => _FaqsPageState();
}

class _FaqsPageState extends State<FaqsPage> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I record a new expense?',
      'answer':
          'To record a new transaction, tap the central ' +
          ' icon in the bottom navigation bar. Select the category under which the expense falls, fill in the details like amount, message and save.',
    },
    {
      'question': 'How can I view my records?',
      'answer':
          'Your records are displayed on the records icon in the bottom navigation bar. You can filter them by date using the menu in the app bar on the Records page.',
    },
    {
      'question': 'How do I set a budget?',
      'answer':
          'You can set budgets for different categories or overall spending. Go to the Budgets section (accessible via the navigation bar or from the appbar of the dashboard) and create a new budget.',
    },
    {
      'question': 'Can I edit or delete a recorded transaction?',
      'answer':
          'Yes, you can usually edit or delete past transactions. Navigate to settings, tap on the edit expense, you will see the list of all transactions, tap on the edit icon of the transaction you wish to modify, and look for edit or delete options.',
    },
    {
      'question': 'How can I see charts and reports of my spending?',
      'answer':
          'Tap on the Chart icons in the bottom navigation bar to view visual representations and detailed reports of your financial activity.',
    },
    {
      'question': 'How do I reset my data or clear all records?',
      'answer':
      'You can clear all your data by going to Settings and selecting the "Reset Data" option. Please note, this action is irreversible.',
    },
    {
      'question': 'Is there a way to export my transactions?',
      'answer':
      'Currently, the app allows viewing detailed records, but export options like PDF or Excel will be added in a future update.',
    },
    {
      'question': 'Can I customize transaction categories?',
      'answer':
      'At the moment, the app supports predefined categories. In future updates, you will be able to add and manage your own custom categories.',
    },
    {
      'question': 'How is my total balance calculated?',
      'answer':
          'Your total balance is calculated by summing all your expenses recorded in the app.',
    },
    {
      'question': 'What are the different transaction categories available?',
      'answer':
          'The app provides a predefined list of common categories like Food, Transport, Shopping, etc. You can select the most appropriate category when recording a transaction.',
    },
    {
      'question': 'Is my financial data secure?',
      'answer':
          'Yes, your data is stored securely. The app uses Firebase Authentication and Firestore for managing user accounts and data.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text(
          'FAQs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primary_color,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children:
                faqs.map((faq) {
                  return Card(
                    color: bg_color,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          collapsedBackgroundColor: bg_color,
                          backgroundColor: bg_color,
                          collapsedIconColor: primary_color,
                          iconColor: primary_color,
                          title: Text(
                            faq['question']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Text(
                                faq['answer']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
