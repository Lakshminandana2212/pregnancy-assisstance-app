import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart'; // Import LoginScreen
import 'screens/signup_preg.dart'; // Import SignupScreen
import 'screens/signup_family.dart'; // Import FamilySignupScreen
import 'screens/dashboard.dart'; // Import DashboardScreen

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(); // Corrected method name

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        '/signup_preg':
            (context) => SignupScreen(), // Signup Screen for Pregnant Women
        '/signup_family':
            (context) =>
                FamilySignupScreen(), // Signup Screen for Family Members
        '/dashboard': (context) => DashboardScreen(), // Dashboard Screen
      },
    );
  }
}
