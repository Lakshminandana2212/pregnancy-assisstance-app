import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors Available"),
        backgroundColor: Colors.blueAccent, // Stylish app bar color
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('consultations')
            .doc('Online Medical Consultations')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching data."));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No doctors available."));
          }

          var data = snapshot.data!;
          List<dynamic>? names = data['doctor_name'] as List<dynamic>?;
          List<dynamic>? emails = data['doctor_email'] as List<dynamic>?;
          List<dynamic>? contacts = data['doctor_contact'] as List<dynamic>?;

          // Check if lists are null or empty
          if (names == null || emails == null || contacts == null || names.isEmpty) {
            return const Center(child: Text("No doctors found."));
          }

          return ListView.builder(
            itemCount: names.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.local_hospital, color: Colors.red),
                  title: Text(
                    names[index].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${emails[index]} | ${contacts[index]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      // Implement calling feature if needed
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
