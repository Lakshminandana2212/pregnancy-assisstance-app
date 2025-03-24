import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  final DateTime lastPeriodDate; // Pass the lastPeriodDate from the previous screen

  DashboardScreen({required this.lastPeriodDate});

  // Function to calculate pregnancy weeks
  int calculatePregnancyWeeks(DateTime lastPeriodDate) {
    DateTime now = DateTime.now();
    int weeks = now.difference(lastPeriodDate).inDays ~/ 7;
    return weeks;
  }

  // Function to calculate due date
  DateTime calculateDueDate(DateTime lastPeriodDate) {
    return lastPeriodDate.add(Duration(days: 280)); // 40 weeks
  }

  // Function to fetch pregnancy info
  Future<Map<String, dynamic>> getPregnancyInfo(int week) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('pregnancy_info')
        .where('week', isEqualTo: week)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    } else {
      throw Exception("No data found for week $week");
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentWeek = calculatePregnancyWeeks(lastPeriodDate);
    DateTime dueDate = calculateDueDate(lastPeriodDate);

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: getPregnancyInfo(currentWeek),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No data available for this week."));
            } else {
              var pregnancyInfo = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pregnancy Progress
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pregnancy Progress",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: currentWeek / 40, // 40 weeks total
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Week $currentWeek of 40",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Due Date: ${dueDate.toLocal().toString().split(' ')[0]}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Weekly Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Week $currentWeek",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              pregnancyInfo['info'],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Weekly Tips
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tips for This Week",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              pregnancyInfo['tips'],
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}