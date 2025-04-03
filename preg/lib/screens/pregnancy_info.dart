
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PregnancyInfoScreen extends StatelessWidget {
  const PregnancyInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/info.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 80.0), // Increased top padding
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pregnancy_info')
                  .orderBy('week')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    ),
                  );
                }

                final weeks = snapshot.data?.docs ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: weeks.length,
                  itemBuilder: (context, index) {
                    final weekData = weeks[index].data() as Map<String, dynamic>;
                    final weekNumber = weekData['week']?.toString() ?? '';
                    final info = weekData['info'] ?? '';
                    final message = weekData['message'] ?? '';
                    final tips = weekData['tips'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      color: const Color.fromARGB(255, 131, 255, 228).withOpacity(0.9),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 10, 129, 63),
                          child: Text(weekNumber),
                        ),
                        title: Text(
                          'Week $weekNumber',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (info.isNotEmpty) ...[
                                  Text(
                                    'Know your baby size!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 188, 10, 120),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(info),
                                  const SizedBox(height: 16),
                                ],
                                if (message.isNotEmpty) ...[
                                  Text(
                                    'Oh look! Baby has something to say:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 9, 74, 114),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(message),
                                  const SizedBox(height: 16),
                                ],
                                if (tips.isNotEmpty) ...[
                                  Text(
                                    'For Mommy:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(243, 149, 4, 216),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(tips.toString())),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
