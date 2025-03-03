import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Import your main app for routing
// ignore: library_prefixes
import 'package:text101/main.dart' as mainApp;
// Import your rcconstruction_cleaning.dart for the post construction cleaning page
//import 'package:text101/residential_cleaning/rcconstructions_cleaning.dart';

// Import ProfilePage and Firebase
import 'profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'residential_cleaning/rcconstructions_cleaning.dart';
import 'residential_cleaning/rcgeneral_cleaning.dart';

class ResidentialCleaningPage extends StatelessWidget {
  ResidentialCleaningPage({super.key});

  final List<Map<String, dynamic>> services = [
    {
      'label': 'General Cleaning',
      'icon': Icons.cleaning_services,
      'color': Colors.blue
    },
    {
      'label': 'Post Construction Cleaning',
      'icon': Icons.build,
      'color': Colors.green
    },
    {
      'label': 'Deep Cleaning',
      'icon': Icons.local_laundry_service,
      'color': Colors.orange
    },
    {
      'label': 'Grease Trap Cleaning',
      'icon': Icons.local_shipping,
      'color': Colors.red
    },
    {
      'label': 'Decluttering Services',
      'icon': Icons.home_repair_service,
      'color': Colors.purple
    },
    {
      'label': 'Glass Detailing Services',
      'icon': Icons.window,
      'color': Colors.teal
    },
  ];

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Residential Cleaning'),
        backgroundColor: Colors.yellow,
        actions: [
          user != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Icon(Icons.error);
                      }

                      String firstName =
                          snapshot.data?.get('first_name') ?? "Guest";

                      return Row(
                        children: [
                          Text(
                            firstName,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
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
                )
              : Container(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Choose Your Service',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
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
                  return GestureDetector(
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
                      }
                      // Add other navigation logic here for other services
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              services[index]['icon'],
                              size: 50,
                              color: services[index]['color'],
                            ),
                            SizedBox(height: 8),
                            Text(
                              services[index]['label'],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
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
              child: Text('See All', style: TextStyle(fontSize: 16)),
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
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => mainApp
                          .MyApp())); // Use the alias `mainApp` for MyApp from main.dart
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
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
              builder: (context) =>
                  mainApp.MyApp())); // Use the alias `mainApp`
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print("Error logging out: $e");
        }
      }
    }
  }
}
