import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:preg/screens/dashboard.dart';
import 'package:preg/screens/signup_preg.dart';
import 'package:preg/screens/login_screen.dart';
import 'package:preg/screens/chatbot_screen.dart';
import 'package:preg/screens/doctors.dart';
import 'package:preg/screens/pregnancy_info.dart';
import 'package:preg/screens/signup_decision.dart';
import 'package:preg/screens/signup_family.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await dotenv.load(fileName: "assets/.env");
    print("API Key loaded: ${dotenv.env['GEMINI_API_KEY']}");
  } catch (e) {
    print("Error loading .env: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PregnaCare',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: AuthWrapper(),
      routes: {
        '/dashboard': (context) => DashboardScreen(),
        '/signup_preg': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/chatbot': (context) => ChatbotScreen(),
        '/doctors': (context) => DoctorListScreen(),
        '/signup_decision': (context) => SignupDecisionScreen(),
        '/signup_family': (context) => FamilySignupScreen(),
        '/pregnancy_info': (context) => PregnancyInfoScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          } else {
            return LoginScreen();
          }
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
