import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:url_launcher/url_launcher.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _lastPeriodDateController = TextEditingController();
  String _userType = 'pregnant_woman'; // Default selection

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        DateTime? lastPeriodDate;
        DateTime? dueDate;
        int? weeksPregnant;

        if (_userType == 'pregnant_woman') {
          lastPeriodDate = DateTime.parse(
            _lastPeriodDateController.text.trim(),
          );
          dueDate = lastPeriodDate.add(Duration(days: 280)); // 40 weeks
          weeksPregnant = DateTime.now().difference(lastPeriodDate).inDays ~/ 7;
        }

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'email': _emailController.text.trim(),
              'phone': _phoneController.text.trim(),
              'userType': _userType,
              'username': _emailController.text.trim().split('@')[0],
              'emergency_contact': _emergencyContactController.text.trim(),
              if (_userType == 'pregnant_woman') ...{
                'last_period_date': Timestamp.fromDate(lastPeriodDate!),
                'due_date': Timestamp.fromDate(dueDate!),
                'weeks_pregnant': weeksPregnant,
              },
            });

        Navigator.pushReplacementNamed(context, '/dashboard');
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Signup failed: ${e.message}")));
      } on FormatException {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid date format. Use YYYY-MM-DD")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _userType,
                items: [
                  DropdownMenuItem(
                    value: 'pregnant_woman',
                    child: Text("Pregnant Woman"),
                  ),
                  DropdownMenuItem(
                    value: 'family_member',
                    child: Text("Family Member"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _userType = value!;
                  });
                },
                decoration: InputDecoration(labelText: "User Type"),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) {
                  if (value!.isEmpty) return "Please enter your email";
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return "Please enter your password";
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                validator: (value) {
                  if (value!.isEmpty) return "Please enter your phone number";
                  return null;
                },
              ),
              TextFormField(
                controller: _emergencyContactController,
                decoration: InputDecoration(labelText: "Emergency Contact"),
                validator: (value) {
                  if (value!.isEmpty)
                    return "Please enter your emergency contact";
                  return null;
                },
              ),
              if (_userType == 'pregnant_woman') // Show only for pregnant women
                TextFormField(
                  controller: _lastPeriodDateController,
                  decoration: InputDecoration(
                    labelText: "Last Period Date (YYYY-MM-DD)",
                  ),
                  validator: (value) {
                    if (_userType == 'pregnant_woman' &&
                        (value == null || value.isEmpty)) {
                      return "Please enter your last period date";
                    }
                    try {
                      if (value != null && value.isNotEmpty) {
                        DateTime.parse(value);
                      }
                    } catch (e) {
                      return "Invalid date format. Use YYYY-MM-DD";
                    }
                    return null;
                  },
                ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _signUp, child: Text("Sign Up")),
            ],
          ),
        ),
      ),
    );
  }
}
