import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:preg/screens/doctors.dart';
import 'package:preg/screens/pregnancy_info.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userType = '';
  int _weeksPregnant = 0;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          _userType = userDoc['userType'];

          if (_userType == 'pregnant_woman' && userDoc.data() != null) {
            var userData = userDoc.data() as Map<String, dynamic>;

            // Ensure last_period_date exists before using it
            if (userData.containsKey('last_period_date')) {
              Timestamp lastPeriodTimestamp = userData['last_period_date'];
              DateTime lastPeriodDate = lastPeriodTimestamp.toDate();
              _weeksPregnant =
                  DateTime.now().difference(lastPeriodDate).inDays ~/ 7;
            }

            // Ensure due_date exists before using it
            if (userData.containsKey('due_date')) {
              _dueDate = userData['due_date'].toDate();
            }
          }
        });
      }
    }
  }

  Future<void> _sendEmergencyAlert() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      String emergencyContact = userDoc['emergency_contact'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Emergency Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.phone),
                  label: Text('Call Emergency Contact'),
                  onPressed: () async {
                    final Uri phoneUri = Uri(
                      scheme: 'tel',
                      path: emergencyContact,
                    );
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    }
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.message),
                  label: Text('Send WhatsApp Message'),
                  onPressed: () async {
                    final Uri whatsappUri = Uri.parse(
                      'https://wa.me/${emergencyContact}?text=Emergency! I need help!',
                    );
                    if (await canLaunchUrl(whatsappUri)) {
                      await launchUrl(whatsappUri);
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  void _navigateToDoctorList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DoctorListScreen()),
    );
  }

  void _navigateToChatbot() {
    Navigator.pushNamed(context, '/chatbot');
  }

  void _navigateToPregnancyInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PregnancyInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userType == 'pregnant_woman') ...[
              Text(
                "You are $_weeksPregnant weeks pregnant",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Due Date: ${_dueDate?.toLocal().toString().split(' ')[0]}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _sendEmergencyAlert,
              child: Text("Emergency Alert"),
            ),
            ElevatedButton(
              onPressed: _navigateToDoctorList,
              child: Text("Online Doctor Consultation"),
            ),
            ElevatedButton(
              onPressed: _navigateToChatbot,
              child: Text("Symptom Tracker & Chatbot"),
            ),
            ElevatedButton(
              onPressed: _navigateToPregnancyInfo,
              child: Text("Know Your Due Date & Info"),
            ),
          ],
        ),
      ),
    );
  }
}
