import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // Import LoginScreen
import 'screens/signup_decision.dart'; // Import SignupDecisionScreen
import 'screens/signup_preg.dart'; // Import SignupScreen for Pregnant Women
import 'screens/signup_family.dart'; // Import SignupScreen for Family Members
import 'screens/dashboard.dart'; // Import DashboardScreen

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Pregnancy Assistance App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login', // Set initial route
      routes: {
        '/login': (context) => LoginScreen(), // Login Screen
        '/signup_decision':
            (context) => SignupDecisionScreen(), // Signup Decision Screen
        '/signup_preg':
            (context) => SignupScreen(), // Signup Screen for Pregnant Women
        '/signup_family':
            (context) =>
                FamilySignupScreen(), // Signup Screen for Family Members
        '/dashboard': (context) {
          // Retrieve the lastPeriodDate from the arguments
          final DateTime lastPeriodDate =
              ModalRoute.of(context)!.settings.arguments as DateTime;
          return DashboardScreen(lastPeriodDate: lastPeriodDate);
        },
      },
    );
  }
}
