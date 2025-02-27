import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart'; // Import ProfilePage
import 'main.dart'; // Import MyApp from main.dart
import 'residential_cleaning.dart'; // Import ResidentialCleaningPage
import 'specialize_cleaning.dart'; // Import SpecializeCleaningPage

void main() {
  runApp(MyApp());
}

final List<Map<String, dynamic>> categories = [
  {
    'icon': Icons.build,
    'label': 'Residential Cleaning'
  }, // This is the category for Residential Cleaning
  {'icon': Icons.cleaning_services, 'label': 'Special Cleaning Service'},
];

class HomeServicePage extends StatefulWidget {
  const HomeServicePage({super.key});

  @override
  _HomeServicePageState createState() => _HomeServicePageState();
}

class _HomeServicePageState extends State<HomeServicePage> {
  final List<String> imagePaths = [
    'assets/images/csimg1.png', // Local Image 1
    'assets/images/csimg2.png', // Local Image 2
    'assets/images/csimg3.png', // Local Image 3
    'assets/images/csimg4.png', // Local Image 4
  ];
  late PageController _pageController;
  int _currentIndex = 0;

  // Set up bottom navigation
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Set the interval for automatic sliding
    Future.delayed(Duration(seconds: 3), _autoSlide);
  }

  void _autoSlide() {
    if (_currentIndex < imagePaths.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
      _currentIndex++;
    } else {
      _pageController.animateToPage(
        0,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
      _currentIndex = 0;
    }
    // Call _autoSlide again to keep sliding
    Future.delayed(Duration(seconds: 3), _autoSlide);
  }

  // Function to handle navigation based on the selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:
        // When "Home" button is tapped, stay on HomeServicePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomeServicePage()), // Stay on the HomeServicePage
        );
        break;
      case 1:
        // Handle calendar navigation (You can create a calendar screen here)
        if (kDebugMode) {
          print('Calendar tapped');
        }
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilePage()), // ProfilePage navigation
        );
        break;
      case 3:
        _logout(); // Handle Logout
        break;
    }
  }

  // Function to handle user logout
  Future<void> _logout() async {
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
        print(
            "Error logging out: $e"); // Log any errors that happen during logout
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current logged-in user
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cleeners Clean Service'),
        backgroundColor: Colors.yellow,
        actions: [
          // User profile icon in the top right corner
          user != null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection(
                            'users') // Assuming the collection is 'users'
                        .doc(user.uid) // Get the user document by their UID
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show loading spinner while fetching
                      }
                      if (snapshot.hasError) {
                        return Icon(Icons
                            .error); // If error fetching data, show error icon
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
                )
              : Container(), // If no user is logged in, no avatar will be shown
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Slideshow of images
            SizedBox(
              height: 200, // Fixed height of the container
              width: 400, // Fixed width of the container
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    imagePaths[index], // Load images from the assets
                    width: 400, // Explicit width
                    height: 200, // Explicit height
                    fit: BoxFit.fill, // Ensures images fit perfectly
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // Search Box
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (categories[index]['label'] ==
                          'Residential Cleaning') {
                        // Navigate to the Residential Cleaning page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResidentialCleaningPage(),
                          ),
                        );
                      } else if (categories[index]['label'] ==
                          'Special Cleaning Service') {
                        // Navigate to the Special Cleaning Service page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpecializeCleaningPage(),
                          ),
                        );
                      }
                    },
                    child: CategoryCard(
                      icon: categories[index]['icon'] as IconData,
                      label: categories[index]['label'] as String,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: Text('See All', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
        backgroundColor: Color.fromARGB(255, 226, 226, 223),
        selectedItemColor: const Color.fromARGB(255, 238, 203, 2),
        unselectedItemColor: Colors.black,
      ),
    );
  }
}

// Category Card widget
class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blueAccent),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
