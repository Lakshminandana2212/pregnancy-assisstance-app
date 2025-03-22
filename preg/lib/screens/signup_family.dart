import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FamilySignupScreen extends StatefulWidget {
  const FamilySignupScreen({super.key});

  @override
  _FamilySignupScreenState createState() => _FamilySignupScreenState();
}

class _FamilySignupScreenState extends State<FamilySignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pregnantUsernameController = TextEditingController();

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Fetch the pregnant woman's user ID using her username
        var snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: _pregnantUsernameController.text.trim())
            .get();

        if (snapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Pregnant woman not found")),
          );
          return;
        }

        String pregnantUserId = snapshot.docs.first.id;

        // Create a Firebase Authentication account for the family member
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String familyMemberId = userCredential.user!.uid;

        // Store family member data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(familyMemberId).set({
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'userType': 'family_member',
          'pregnant_user': pregnantUserId,
        });

        // Navigate to Dashboard
        Navigator.pushReplacementNamed(context, '/dashboard');

      } on FirebaseAuthException catch (e) {
        print("Auth Error: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: ${e.message}")),
        );
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Family Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value!.isEmpty) return "Please enter your name";
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
                controller: _pregnantUsernameController,
                decoration: InputDecoration(labelText: "Pregnant Woman's Username"),
                validator: (value) {
                  if (value!.isEmpty) return "Please enter the pregnant woman's username";
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                child: Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
