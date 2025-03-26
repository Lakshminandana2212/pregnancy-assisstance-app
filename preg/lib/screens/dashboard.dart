/*import 'package:flutter/material.dart';
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
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) throw Exception('User data not found');

      String emergencyContact = userDoc['emergency_contact'] ?? '';
      if (emergencyContact.isEmpty)
        throw Exception('No emergency contact found');

      // Format phone number for WhatsApp
      String formattedNumber = emergencyContact.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (!formattedNumber.startsWith('+')) {
        formattedNumber = '+91$formattedNumber'; // Add country code for India
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Emergency Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Emergency Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () async {
                    final Uri phoneUri = Uri(
                      scheme: 'tel',
                      path: emergencyContact,
                    );
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      throw Exception('Could not launch phone call');
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text('Send WhatsApp Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () async {
                    try {
                      // Remove any non-numeric characters and spaces
                      String cleanNumber = formattedNumber.replaceAll(
                        RegExp(r'\D'),
                        '',
                      );

                      // Ensure number starts with country code
                      if (!cleanNumber.startsWith('91')) {
                        cleanNumber = '91$cleanNumber';
                      }

                      final message = Uri.encodeComponent(
                        'Emergency! I need immediate medical assistance. '
                        'This is an automated emergency alert from my pregnancy care app.',
                      );

                      // Try mobile WhatsApp first
                      final mobileUrl = Uri.parse(
                        'whatsapp://send?phone=$cleanNumber&text=$message',
                      );
                      if (await canLaunchUrl(mobileUrl)) {
                        await launchUrl(
                          mobileUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Fallback to web WhatsApp
                        final webUrl = Uri.parse(
                          'https://wa.me/$cleanNumber?text=$message',
                        );
                        if (await canLaunchUrl(webUrl)) {
                          await launchUrl(
                            webUrl,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          throw Exception('WhatsApp is not installed');
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to open WhatsApp: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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
}*/


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
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userType = userDoc['userType'] ?? '';

            if (_userType == 'pregnant_woman' && userDoc.data() != null) {
              var userData = userDoc.data() as Map<String, dynamic>;

              if (userData.containsKey('last_period_date')) {
                Timestamp lastPeriodTimestamp = userData['last_period_date'];
                DateTime lastPeriodDate = lastPeriodTimestamp.toDate();
                _weeksPregnant =
                    DateTime.now().difference(lastPeriodDate).inDays ~/ 7;
              }

              if (userData.containsKey('due_date')) {
                _dueDate = userData['due_date'].toDate();
              }
            }
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _sendEmergencyAlert() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) throw Exception('User data not found');

      String emergencyContact = userDoc['emergency_contact'] ?? '';
      if (emergencyContact.isEmpty)
        throw Exception('No emergency contact found');

      // Format phone number for WhatsApp
      String formattedNumber = emergencyContact.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      if (!formattedNumber.startsWith('+')) {
        formattedNumber = '+91$formattedNumber'; // Add country code for India
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Emergency Contact'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Emergency Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () async {
                    final Uri phoneUri = Uri(
                      scheme: 'tel',
                      path: emergencyContact,
                    );
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      throw Exception('Could not launch phone call');
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text('Send WhatsApp Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () async {
                    try {
                      // Remove any non-numeric characters and spaces
                      String cleanNumber = formattedNumber.replaceAll(
                        RegExp(r'\D'),
                        '',
                      );

                      // Ensure number starts with country code
                      if (!cleanNumber.startsWith('91')) {
                        cleanNumber = '91$cleanNumber';
                      }

                      final message = Uri.encodeComponent(
                        'Emergency! I need immediate medical assistance. '
                        'This is an automated emergency alert from my pregnancy care app.',
                      );

                      // Try mobile WhatsApp first
                      final mobileUrl = Uri.parse(
                        'whatsapp://send?phone=$cleanNumber&text=$message',
                      );
                      if (await canLaunchUrl(mobileUrl)) {
                        await launchUrl(
                          mobileUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Fallback to web WhatsApp
                        final webUrl = Uri.parse(
                          'https://wa.me/$cleanNumber?text=$message',
                        );
                        if (await canLaunchUrl(webUrl)) {
                          await launchUrl(
                            webUrl,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          throw Exception('WhatsApp is not installed');
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to open WhatsApp: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Pregnancy Info at Right Top-Middle
              if (_userType == 'pregnant_woman')
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).size.height * 0.1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "You are\n$_weeksPregnant weeks\npregnant",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (_dueDate != null)
                        Text(
                          "Due Date:\n${_dueDate?.toLocal().toString().split(' ')[0]}",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                    ],
                  ),
                ),

              // Options at bottom with larger size
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTransparentButton(
                        'Doctor Consultation', 
                        _navigateToDoctorList,
                      ),
                      SizedBox(height: 16),
                      _buildTransparentButton(
                        'Symptom Tracker', 
                        _navigateToChatbot,
                      ),
                      SizedBox(height: 16),
                      _buildTransparentButton(
                        'Your Due Date & Info', 
                        _navigateToPregnancyInfo,
                      ),
                      SizedBox(height: 20),
                      _buildEmergencyButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransparentButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 25),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return ElevatedButton(
      onPressed: _sendEmergencyAlert,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        "EMERGENCY!!",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}