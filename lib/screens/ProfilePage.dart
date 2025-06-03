import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:SmartSpend/Constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;

  String userId = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

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
        String email = account.email;
        nameController.text = account.displayName ?? '';
        emailController.text = email;

        var snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .where('Email', isEqualTo: email)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          var doc = snapshot.docs.first;
          userId = doc.id;

          var data = doc.data();
          setState(() {
            genderController.text = data['Gender'] ?? '';
            mobileController.text = data['Mobile'] ?? '';
            addressController.text = data['Address'] ?? '';
            pincodeController.text = data['Pincode'] ?? '';
            gender = data['Gender'] ?? '';
            mobileNumber = data['Mobile'] ?? '';
            address = data['Address'] ?? '';
            pincode = data['Pincode'] ?? '';
            _isLoading = false;  // DATA LOADED
          });
        } else {
          setState(() {
            _isLoading = false; // No user found but loading done
          });
        }
      } else {
        setState(() {
          _isLoading = false; // No Google account signed in
        });
      }
    } catch (error) {
      print('Google Sign-In error: $error');
      setState(() {
        _isLoading = false; // On error loading done
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
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
                value: genderOptions.contains(gender) ? gender : null,
                items:
                    genderOptions.map((String value) {
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
                hint: const Text('Select your gender'),
              ),

              const SizedBox(height: 16),

              _buildLabel('Mobile Number'),
              TextFormField(
                controller: mobileController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: _inputDecoration('Enter 10-digit mobile number'),
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Enter a valid 10-digit number';
                  }
                  return null;
                },
                onChanged: (value) => mobileNumber = value,
              ),

              const SizedBox(height: 16),

              _buildLabel('Address'),
              TextFormField(
                controller: addressController,
                maxLines: 2,
                decoration: _inputDecoration('Enter your address'),
                onChanged: (value) => address = value,
              ),

              const SizedBox(height: 16),

              _buildLabel('Pincode'),
              TextFormField(
                controller: pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _inputDecoration('Enter pincode'),
                onChanged: (value) => pincode = value,
              ),

              const SizedBox(height: 32),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userId)
                            .update({
                              'Gender': gender,
                              'Mobile': mobileNumber,
                              'Address': address,
                              'Pincode': pincode,
                            });

                        Fluttertoast.showToast(
                          msg: 'Profile updated successfully!',
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: 'Profile update failed. Try again.',
                        );
                      }
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary_color,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
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
