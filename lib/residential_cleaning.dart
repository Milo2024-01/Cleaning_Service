import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Import your main app for routing
// ignore: library_prefixes
import 'package:text101/main.dart' as mainApp;
// Import ProfilePage and Firebase
import 'profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your cleaning pages
import 'residential_cleaning/rcconstructions_cleaning.dart';
import 'residential_cleaning/rcdecluretting_service.dart';
import 'residential_cleaning/rcgeneral_cleaning.dart';
import 'residential_cleaning/rcdeep_cleaning.dart'; // Import Deep Cleaning page
import 'residential_cleaning/rcglass_services.dart'; // Import Glass Detailing page
import 'residential_cleaning/rcgrease_cleaning.dart'; // Import Grease Trap Cleaning page

import 'home_service.dart'; // <-- Import home_service.dart

class ResidentialCleaningPage extends StatelessWidget {
  ResidentialCleaningPage({super.key});

  final List<Map<String, dynamic>> services = [
    {
      'label': 'General Cleaning',
      'icon': Icons.cleaning_services,
      'color': Colors.blue.shade700
    },
    {
      'label': 'Post Construction Cleaning',
      'icon': Icons.build,
      'color': Colors.green.shade700
    },
    {
      'label': 'Deep Cleaning', // Add Deep Cleaning here
      'icon': Icons.local_laundry_service,
      'color': Colors.orange.shade700
    },
    {
      'label': 'Grease Trap Cleaning',
      'icon': Icons.local_shipping,
      'color': Colors.red.shade700
    },
    {
      'label': 'Decluttering Services',
      'icon': Icons.home_repair_service,
      'color': Colors.purple.shade700
    },
    {
      'label': 'Glass Detailing Services',
      'icon': Icons.window,
      'color': Colors.teal.shade700
    },
  ];

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Residential Cleaning',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple, // Modern app bar color
        elevation: 0, // Remove shadow for a flat design
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
                            color: Colors.white),
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
                          backgroundImage: NetworkImage(user.photoURL ??
                              "https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y"),
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
              'Choose Your Service',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
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
                        if (services[index]['label'] == 'General Cleaning') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GeneralCleaningCalculator(),
                            ),
                          );
                        } else if (services[index]['label'] ==
                            'Post Construction Cleaning') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostConstructionCleaningCalculator(),
                            ),
                          );
                        } else if (services[index]['label'] ==
                            'Deep Cleaning') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeepCleaningCalculator(),
                            ),
                          );
                        } else if (services[index]['label'] ==
                            'Glass Detailing Services') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GlassDetailingCalculator(),
                            ),
                          );
                        } else if (services[index]['label'] ==
                            'Grease Trap Cleaning') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GreaseTrapCleaningCalculator(),
                            ),
                          );
                        } else if (services[index]['label'] ==
                            'Decluttering Services') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RCCDeclutteringServicePage(),
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
                                  color: Colors.deepPurple),
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
              onPressed: () {
                // Action when 'See All' button is pressed
              },
              child: Text(
                'See All',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to home_service.dart when the home icon is clicked
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HomeServicePage()), // <-- Navigate to HomeServicePage here
              );
              break;
            case 1:
              // Calendar navigation (create a calendar screen here)
              break;
            case 2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
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
          MaterialPageRoute(
              builder: (context) =>
                  mainApp.MyApp())); // Use the alias `mainApp`
    } catch (e) {
      if (kDebugMode) {
        print("Error logging out: $e");
      }
    }
  }
}
