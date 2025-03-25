//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_page.dart';
import 'calendar_booking.dart';
import 'residential_cleaning/rcgeneral_cleaning.dart';

class ResidentialCleaningPage extends StatefulWidget {
  const ResidentialCleaningPage({super.key});

  @override
  _ResidentialCleaningPageState createState() => _ResidentialCleaningPageState();
}

class _ResidentialCleaningPageState extends State<ResidentialCleaningPage> {
  final List<Map<String, dynamic>> services = [
    {'label': 'General Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.blue.shade700},
    {'label': 'Post Construction Cleaning', 'icon': Icons.build, 'color': Colors.green.shade700},
    {'label': 'Deep Cleaning', 'icon': Icons.local_laundry_service, 'color': Colors.orange.shade700},
    {'label': 'Grease Trap Cleaning', 'icon': Icons.local_shipping, 'color': Colors.red.shade700},
    {'label': 'Decluttering Services', 'icon': Icons.home_repair_service, 'color': Colors.purple.shade700},
    {'label': 'Glass Detailing Services', 'icon': Icons.window, 'color': Colors.teal.shade700},
  ];

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Residential Cleaning',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }
                  if (snapshot.hasError) {
                    return const Icon(Icons.error, color: Colors.white);
                  }

                  String firstName = snapshot.data?.get('first_name') ?? "Guest";

                  return Row(
                    children: [
                      Text(
                        firstName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              user.photoURL ?? "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y"),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Choose Your Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: services.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    // ignore: deprecated_member_use
                    shadowColor: Colors.deepPurple.withOpacity(0.2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CalendarBookingScreen(serviceLabel: services[index]['label']),
                          ),
                        );

                        if (result != null && services[index]['label'] == 'General Cleaning') {
                          if (!mounted) return;
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => GeneralCleaningCalculator(
                                selectedDate: result['date'],
                                selectedTime: result['time'],
                              ),
                            ),
                          );
                        }
                        else if (result != null && services[index]['label'] == 'Post Construction Cleaning') {
                          if (!mounted) return;
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => GeneralCleaningCalculator(
                                selectedDate: result['date'],
                                selectedTime: result['time'],
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              services[index]['icon'],
                              size: 50,
                              color: services[index]['color'],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              services[index]['label'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}