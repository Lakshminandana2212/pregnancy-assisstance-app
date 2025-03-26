import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PregnancyInfoScreen extends StatelessWidget {
  const PregnancyInfoScreen({super.key});

  List<String> _sortWeeks(List<dynamic> weeks) {
    return List<String>.from(weeks)..sort((a, b) {
      int weekA = int.tryParse(a.toString().replaceAll('week ', '')) ?? 0;
      int weekB = int.tryParse(b.toString().replaceAll('week ', '')) ?? 0;
      return weekA.compareTo(weekB);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pregnancy Week by Week"),
        backgroundColor: Colors.pink[100],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pregnancy_info')
                .orderBy('week_number')
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.pink[200]!,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Loading pregnancy information...'),
                ],
              ),
            );
          }

          final weeks = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: weeks.length,
            itemBuilder: (context, index) {
              final weekData = weeks[index].data() as Map<String, dynamic>;
              final weekNumber = weekData['week_number']?.toString() ?? '';
              final description = weekData['description'] ?? '';
              final tips = weekData['tips'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink[100],
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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Development:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pink[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(description),
                          const SizedBox(height: 16),
                          if (tips.isNotEmpty) ...[
                            Text(
                              'Tips for this week:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.pink[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...tips
                                .map(
                                  (tip) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(tip.toString())),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
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
    );
  }
}
