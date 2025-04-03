

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/doc_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('consultations')
                  .doc('Online Medical Consultations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Error fetching data.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      "No doctors available.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                var data = snapshot.data!;
                List<dynamic>? names = data['doctor_name'] as List<dynamic>?;
                List<dynamic>? emails = data['doctor_email'] as List<dynamic>?;
                List<dynamic>? contacts = data['doctor_contact'] as List<dynamic>?;

                if (names == null ||
                    emails == null ||
                    contacts == null ||
                    names.isEmpty) {
                  return const Center(
                    child: Text(
                      "No doctors found.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Container(
                  height: MediaQuery.of(context).size.height * 0.7, // Occupy 70% of screen height
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: names.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 15),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, 
                            vertical: 10
                          ),
                          leading: Icon(
                            Icons.local_hospital, 
                            color: Colors.white.withOpacity(0.7),
                            size: 35,
                          ),
                          title: Text(
                            names[index].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            "${emails[index]} | ${contacts[index]}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.call, 
                              color: Colors.white.withOpacity(0.7),
                              size: 35,
                            ),
                            onPressed: () => _makePhoneCall(contacts[index].toString()),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}