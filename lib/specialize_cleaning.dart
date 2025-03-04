import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'specialized_cleaning/sccarpet_cleaning.dart';
import 'specialized_cleaning/scfurniture_cleaning.dart';
import 'specialized_cleaning/sclargeitem_clearning.dart';
import 'specialized_cleaning/scpestcontrol_service.dart';
import 'specialized_cleaning/scwatertank_cleaning.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpecializeCleaningPage extends StatelessWidget {
  SpecializeCleaningPage({super.key});

  final List<Map<String, dynamic>> services = [
    {
      'label': 'Furniture Cleaning',
      'icon': Icons.chair,
      'color': Colors.blue.shade700,
    },
    {
      'label': 'Carpet Cleaning',
      'icon': Icons.cut,
      'color': Colors.green.shade700,
    },
    {
      'label': 'Large Item Cleaning',
      'icon': Icons.more_horiz,
      'color': Colors.orange.shade700,
    },
    {
      'label': 'General Pest Control Services',
      'icon': Icons.bug_report,
      'color': Colors.red.shade700,
    },
    {
      'label': 'Water Tank Cleaning',
      'icon': Icons.water_damage,
      'color': Colors.purple.shade700,
    },
    {
      'label': 'Car Interior Detailing',
      'icon': Icons.directions_car,
      'color': Colors.teal.shade700,
    },
  ];

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Specialized Cleaning',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }
                  if (snapshot.hasError) {
                    return const Icon(Icons.error, color: Colors.white);
                  }

                  String firstName =
                      snapshot.data?.get('first_name') ?? "Guest";

                  return Row(
                    children: [
                      Text(
                        firstName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()));
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            user.photoURL ??
                                "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y",
                          ),
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
              'Choose Your Specialized Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    // ignore: deprecated_member_use
                    shadowColor: Colors.deepPurple.withOpacity(0.2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (services[index]['label'] == 'Furniture Cleaning') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceScreen(),
                            ),
                          );
                        } else if (services[index]['label'] ==
                            'Carpet Cleaning') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SCCarpetCleaningPage(),
                            ),
                          );
                        } else if (services[index]['label'] ==
                            'Large Item Cleaning') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LargeItemCleaningPage(),
                            ),
                          );
                        } else if (services[index]['label'] ==
                            'General Pest Control Services') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PestControlPage(),
                            ),
                          );
                        } else if (services[index]['label'] ==
                            'Water Tank Cleaning') {
                          // ✅ Navigation for Water Tank Cleaning
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WaterTankCleaningPage(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceDetailPage(
                                service: services[index],
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
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
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Service Detail Page for fallback navigation
class ServiceDetailPage extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(service['label']),
        backgroundColor: service['color'],
      ),
      body: Center(
        child: Text('Details for ${service['label']}'),
      ),
    );
  }
}
