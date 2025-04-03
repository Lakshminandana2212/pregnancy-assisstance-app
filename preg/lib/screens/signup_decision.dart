

import 'package:flutter/material.dart';

class SignupDecisionScreen extends StatelessWidget {
  const SignupDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/decision_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pregnant Women Option
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup_preg');
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pregnant Woman Icon
                        Icon(
                          Icons.pregnant_woman,
                          size: 100,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "PREGNANT WOMEN",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Family Members Option
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/signup_family');
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Family Icon
                        Icon(
                          Icons.family_restroom,
                          size: 100,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "FAMILY MEMBERS",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
