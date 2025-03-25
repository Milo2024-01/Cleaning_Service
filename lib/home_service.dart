import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'main.dart';
import 'residential_cleaning.dart';
import 'specialize_cleaning.dart';
import 'my_calendar_booking.dart';

void main() {
  runApp(const MyApp());
}

final List<Map<String, dynamic>> categories = [
  {
    'icon': Icons.home,
    'label': 'Residential Cleaning',
    'color': Colors.blueAccent,
  },
  {
    'icon': Icons.cleaning_services,
    'label': 'Special Cleaning Service',
    'color': Colors.orangeAccent,
  },
];

class HomeServicePage extends StatefulWidget {
  const HomeServicePage({super.key});

  @override
  _HomeServicePageState createState() => _HomeServicePageState();
}

class _HomeServicePageState extends State<HomeServicePage> {
  final List<String> imagePaths = [
    'assets/images/csimg1.png',
    'assets/images/csimg2.png',
    'assets/images/csimg3.png',
    'assets/images/csimg4.png',
  ];
  late PageController _pageController;
  int _currentIndex = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.delayed(const Duration(seconds: 3), _autoSlide);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _autoSlide() {
    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % imagePaths.length;
    });

    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 3), _autoSlide);
  }

  void _onItemTapped(int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
    });

    switch (_selectedIndex) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeServicePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingCalendar()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
      case 3:
        _logout();
        break;
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error logging out: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cleeners Clean Service',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        centerTitle: true,
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
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Icon(Icons.error, color: Colors.white);
                  }

                  String firstName = snapshot.data?.get('first_name') ?? "Guest";

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
                                builder: (context) => const ProfilePage()),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: 400,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      imagePaths[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (categories[index]['label'] == 'Residential Cleaning') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ResidentialCleaningPage(),
                          ),
                        );
                      } else if (categories[index]['label'] ==
                          'Special Cleaning Service') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpecializeCleaningPage(),
                          ),
                        );
                      }
                    },
                    child: CategoryCard(
                      icon: categories[index]['icon'],
                      label: categories[index]['label'],
                      color: categories[index]['color'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Logout'),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// ✅ CategoryCard Widget (Previously Missing)
class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 10),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
