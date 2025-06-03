import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:SmartSpend/Constants.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _formKey = GlobalKey<FormState>();
  String subject = '';
  String message = '';
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadGoogleUserData();
  }

  Future<void> _loadGoogleUserData() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        setState(() {
          userName = account.displayName ?? '';
          userEmail = account.email;
        });
      }
    } catch (e) {
      print('Failed to fetch Google user: $e');
    }
  }

  Future<void> _submitHelp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final Uri emailUri = Uri.parse(
        Uri.encodeFull(
          'mailto:codecrafters79@gmail.com'
              '?subject=$subject'
              '&body=Name: $userName\nEmail: $userEmail\n\n$message',
        ),
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        
        // After launching email client, show a confirmation dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Message Prepared"),
                content: const Text(
                    "Your help request has been prepared in your email app.\nPlease send it and stay tuned — we'll get back to you soon!"),
                actions: [
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      setState(() {
                        subject = '';
                        message = '';
                      });
                      _formKey.currentState!.reset();
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch email client. Please make sure you have an email app installed.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        title: const Text('Help',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: primary_color,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  color: bg_color,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) => subject = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a subject';
                            }
                            return null;
                          },
                          initialValue: subject,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'What help do you need?',
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) => message = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please describe your issue';
                            }
                            return null;
                          },
                          initialValue: message,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _submitHelp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary_color,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Submit Help',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
