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
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await dotenv.load(fileName: "assets/.env");
    print("API Key loaded: ${dotenv.env['GEMINI_API_KEY']}");
  } catch (e) {
    print("Error loading .env: $e");
  }
  await populatePregnancyInfo();
  runApp(MyApp());
}

Future<void> populatePregnancyInfo() async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  
  try {
    // Check if data already exists
    final snapshot = await db.collection('pregnancy_info').limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      print('Pregnancy info data already exists');
      return;
    }

    final batch = db.batch();
    
    for (int week = 1; week <= 40; week++) {
      final docRef = db.collection('pregnancy_info').doc('week_$week');
      batch.set(docRef, {
        'week_number': week,
        'description': getWeekDescription(week),
        'tips': getWeekTips(week),
      });
    }
    
    await batch.commit();
    print('Successfully populated pregnancy info');
  } catch (e) {
    print('Error populating pregnancy info: $e');
  }
}

String getWeekDescription(int week) {
  // Add real descriptions for each week
  switch (week) {
    case 1:
      return 'Your pregnancy journey begins! The fertilized egg implants in your uterus.';
    case 2:
      return 'Your baby is now called a blastocyst and is developing rapidly.';
    // Add more weeks...
    default:
      return 'Week $week of your pregnancy journey.';
  }
}

List<String> getWeekTips(int week) {
  // Add real tips for each week
  switch (week) {
    case 1:
      return [
        'Start taking prenatal vitamins',
        'Quit smoking and avoid alcohol',
        'Schedule your first prenatal appointment'
      ];
    case 2:
      return [
        'Maintain a healthy diet',
        'Stay hydrated',
        'Get plenty of rest'
      ];
    // Add more weeks...
    default:
      return [
        'Stay active with light exercise',
        'Keep taking prenatal vitamins',
        'Stay in touch with your healthcare provider'
      ];
  }
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
