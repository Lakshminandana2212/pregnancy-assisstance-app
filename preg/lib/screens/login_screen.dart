
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        String uid = userCredential.user!.uid;

        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          print("User Data: ${userDoc.data()}");
        } else {
          print("No user data found in Firestore.");
        }

        Navigator.pushReplacementNamed(context, '/dashboard');
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.message}")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred. Please try again.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
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
                image: AssetImage('assets/images/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Centered Login Form
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo or App Name
                    Text(
                      '   ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),

                    // Email Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: Icon(Icons.email, color: Colors.green),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20, 
                            vertical: 15
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: Icon(Icons.lock, color: Colors.green),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible 
                                ? Icons.visibility 
                                : Icons.visibility_off,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20, 
                            vertical: 15
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 30),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                    ),

                    // Sign Up Button
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup_decision');
                      },
                      child: Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}