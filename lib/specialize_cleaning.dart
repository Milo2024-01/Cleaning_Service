import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'home_service.dart';
import 'profile_page.dart';
import 'main.dart';
import 'specialized_cleaning/sccarpet_cleaning.dart';
import 'specialized_cleaning/scfurniture_cleaning.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import Furniture Cleaning Page

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
        title: Text(
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
                    return CircularProgressIndicator(color: Colors.white);
                  }
                  if (snapshot.hasError) {
                    return Icon(Icons.error, color: Colors.white);
                  }

                  String firstName =
                      snapshot.data?.get('first_name') ?? "Guest";

                  return Row(
                    children: [
                      Text(
                        firstName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
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
            Text(
              'Choose Your Specialized Service',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: services.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                              builder: (context) =>
                                  SCCarpetCleaningPage(), // Navigate to Carpet Cleaning Page
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
                            SizedBox(height: 12),
                            Text(
                              services[index]['label'],
                              style: TextStyle(
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
            SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: Text(
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeServicePage()),
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
            case 3:
              _logout(context);
              break;
          }
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error logging out: $e");
      }
    }
  }
}

class SCCarpetCleaningApp {}

class ServiceDetailPage extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          service['label'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: service['color'],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Text(
            'Details for ${service['label']}',
            style: TextStyle(fontSize: 24, color: Colors.deepPurple),
          ),
        ),
      ),
    );
  }
}
