/*import 'package:flutter/material.dart';
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
  final _pregnantEmailController = TextEditingController();

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Fetch the pregnant woman's user ID using her username
        var snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: _pregnantEmailController.text.trim())
                .get();

        if (snapshot.docs.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Pregnant woman not found")));
          return;
        }

        String pregnantUserId = snapshot.docs.first.id;

        // Create a Firebase Authentication account for the family member
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        String familyMemberId = userCredential.user!.uid;

        // Store family member data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(familyMemberId)
            .set({
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Signup failed: ${e.message}")));
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Signup failed: $e")));
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
                controller: _pregnantEmailController,
                decoration: InputDecoration(
                  labelText: "Pregnant Woman's Email id",
                ),
                validator: (value) {
                  if (value!.isEmpty)
                    return "Please enter the pregnant woman's email";
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
}*/

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
  final _pregnantEmailController = TextEditingController();

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Fetch the pregnant woman's user ID using her username
        var snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: _pregnantEmailController.text.trim())
                .get();

        if (snapshot.docs.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Pregnant woman not found")));
          return;
        }

        String pregnantUserId = snapshot.docs.first.id;

        // Create a Firebase Authentication account for the family member
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        String familyMemberId = userCredential.user!.uid;

        // Store family member data in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(familyMemberId)
            .set({
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Signup failed: ${e.message}")));
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Signup failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/family.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent Overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Centered Form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Name Field
                      _buildTransparentContainer(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Name",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value!.isEmpty) return "Please enter your name";
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      // Phone Number Field
                      _buildTransparentContainer(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: "Phone Number",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value!.isEmpty) return "Please enter your phone number";
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      // Email Field
                      _buildTransparentContainer(
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value!.isEmpty) return "Please enter your email";
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      // Password Field
                      _buildTransparentContainer(
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          obscureText: true,
                          validator: (value) {
                            if (value!.isEmpty) return "Please enter your password";
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      // Pregnant Woman's Email Field
                      _buildTransparentContainer(
                        child: TextFormField(
                          controller: _pregnantEmailController,
                          decoration: InputDecoration(
                            labelText: "Pregnant Woman's Email id",
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value!.isEmpty)
                              return "Please enter the pregnant woman's email";
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      // Sign Up Button
                      ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          foregroundColor: Colors.black,
                        ),
                        child: Text("Sign Up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create transparent white containers
  Widget _buildTransparentContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: child,
    );
  }
}
