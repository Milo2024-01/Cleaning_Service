import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'home_service.dart'; // Import HomeServicePage
import 'profile_page.dart'; // Import ProfilePage
import 'main.dart'; // Import MyApp from main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SpecializeCleaningPage extends StatelessWidget {
  SpecializeCleaningPage({super.key});

  // Define a list of new specialized cleaning services
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
    // Get the current logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Specialized Cleaning',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple, // Modern app bar color
        elevation: 0, // Remove shadow for a flat design
        actions: [
          // User profile icon in the top right corner
          if (user != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users') // Assuming the collection is 'users'
                    .doc(user.uid) // Get the user document by their UID
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                        color: Colors.white); // Show loading spinner
                  }
                  if (snapshot.hasError) {
                    return Icon(Icons.error, color: Colors.white); // Error icon
                  }

                  String firstName =
                      snapshot.data?.get('first_name') ?? "Guest";

                  return Row(
                    children: [
                      Text(
                        firstName, // Display the fetched first_name
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
                                builder: (context) => ProfilePage()),
                          );
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
            // Displaying service categories in a Grid
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
                        // Add your navigation logic here for each service
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceDetailPage(
                              service: services[index],
                            ),
                          ),
                        );
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
              onPressed: () {
                // Action when 'See All' button is pressed
              },
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
      // Bottom navigation bar
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
          // Handle bottom navigation taps here
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeServicePage()),
              );
              break;
            case 1:
              // Calendar navigation (You can create a calendar screen here)
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
            case 3:
              _logout(context); // Pass context here
              break;
          }
        },
        selectedItemColor: Colors.deepPurple, // Set selected icon color
        unselectedItemColor: Colors.grey, // Set unselected icon color
        showUnselectedLabels: true,
      ),
    );
  }

  // Function to handle user logout
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => MyApp()), // Navigate to MyApp (Main Screen)
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error logging out: $e");
      } // Log any errors that happen during logout
    }
  }
}

// Example service detail page (You can replace it with a detailed service page)
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
