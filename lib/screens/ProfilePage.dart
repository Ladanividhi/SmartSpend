import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? gender;
  String mobileNumber = '';
  String address = '';
  String pincode = '';

  final _formKey = GlobalKey<FormState>();

  List<String> genderOptions = ['Male', 'Female', 'Others'];

  @override
  void initState() {
    super.initState();
    _loadGoogleUserData();
  }

  Future<void> _loadGoogleUserData() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final account = await googleSignIn.signInSilently();
      if (account != null) {
        setState(() {
           String name = account.displayName ?? '';
           String email = account.email;
          nameController.text = name;
          emailController.text = email;
        });
      }
    } catch (error) {
      print('Google Sign-In error: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg_color,
      appBar: AppBar(
        backgroundColor: primary_color,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Name'),
              TextFormField(
                controller: nameController,
                readOnly: true,
                decoration: _inputDecoration('Enter your name'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Email'),
              TextFormField(
                controller: emailController,
                readOnly: true,
                decoration: _inputDecoration('Your email'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Gender'),
              DropdownButtonFormField<String>(
                value: gender,
                items: genderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: _inputDecoration('Select your gender'),
                onChanged: (value) {
                  setState(() {
                    gender = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('Mobile Number'),
              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 10,
                onChanged: (value) => mobileNumber = value,
                decoration: _inputDecoration('Enter 10-digit mobile number'),
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('Address'),
              TextFormField(
                maxLines: 2,
                onChanged: (value) => address = value,
                decoration: _inputDecoration('Enter your address'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Pincode'),
              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) => pincode = value,
                decoration: _inputDecoration('Enter pincode'),
              ),
              const SizedBox(height: 32),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save logic here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Changes saved successfully!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary_color,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
