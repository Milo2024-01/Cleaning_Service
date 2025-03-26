import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:text101/my_calendar_booking.dart';
import 'package:text101/profile_page.dart';
import 'main.dart';
import 'residential_cleaning.dart';
import 'specialize_cleaning.dart';

class HomeServicePage extends StatefulWidget {
  const HomeServicePage({super.key});

  @override
  _HomeServicePageState createState() => _HomeServicePageState();
}

class _HomeServicePageState extends State<HomeServicePage> with SingleTickerProviderStateMixin {
  final List<String> imagePaths = [
    'assets/images/csimg1.png',
    'assets/images/csimg2.png',
    'assets/images/csimg3.png',
    'assets/images/csimg4.png',
  ];
  late PageController _pageController;
  int _currentIndex = 0;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _recommendedServices = [];
  bool _isLoadingRecommendations = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    Future.delayed(const Duration(seconds: 3), _autoSlide);
    _loadRecommendedServices();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecommendedServices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoadingRecommendations = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (snapshot.docs.isEmpty) {
        if (kDebugMode) {
          print("No bookings found for user: ${user.uid}");
        }
        setState(() {
          _isLoadingRecommendations = false;
          _recommendedServices = [];
        });
        return;
      }

      // Count service frequencies
      final serviceCounts = <String, int>{};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final service = data['serviceLabel']?.toString() ?? 'Unknown Service';
        serviceCounts[service] = (serviceCounts[service] ?? 0) + 1;
      }

      final sortedServices = serviceCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Define our new color scheme
      final serviceColors = [
        const Color.fromARGB(255, 218, 24, 176),        // First service - Green
        Colors.lightBlue,    // Second service - Light Blue
        Colors.pink,         // Third service - Pink
      ];

      setState(() {
        _recommendedServices = sortedServices.take(3).map((entry) {
          return {
            'label': entry.key,
            'icon': entry.key.toLowerCase().contains('residential') 
                ? Icons.home 
                : Icons.cleaning_services,
            'color': serviceColors[_recommendedServices.length % serviceColors.length],
          };
        }).toList();
        _isLoadingRecommendations = false;
      });

      // Start animation after data loads
      _animationController.forward();

    } catch (e) {
      if (kDebugMode) {
        print("Error loading recommendations: $e");
      }
      setState(() => _isLoadingRecommendations = false);
    }
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
            Expanded(
              child: Column(
                children: [
                  // Main services
                  Expanded(
                    flex: 2,
                    child: GridView.builder(
                      itemCount: 2,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (index == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResidentialCleaningPage(),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SpecializeCleaningPage(),
                                ),
                              );
                            }
                          },
                          child: CategoryCard(
                            icon: index == 0 ? Icons.home : Icons.cleaning_services,
                            label: index == 0 ? 'Residential Cleaning' : 'Special Cleaning',
                            color: index == 0 ? Colors.blueAccent : Colors.orangeAccent,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Recommended services section with animation
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Recommended Services',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  
                  _isLoadingRecommendations
                      ? const CircularProgressIndicator()
                      : _recommendedServices.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'No booking history yet',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : SizedBox(
                              height: 120,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _recommendedServices.length,
                                  itemBuilder: (context, index) {
                                    final service = _recommendedServices[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: ServiceCard(
                                        icon: service['icon'],
                                        label: service['label'],
                                        color: service['color'],
                                        delay: index * 200, // Staggered delay
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                  
                  // Ratings section
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Customer Satisfaction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 28),
                            Icon(Icons.star, color: Colors.amber, size: 28),
                            Icon(Icons.star, color: Colors.amber, size: 28),
                            Icon(Icons.star, color: Colors.amber, size: 28),
                            Icon(Icons.star, color: Colors.amber, size: 28),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '4.9/5.0 from 128 reviews',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            // Add view all reviews functionality
                          },
                          child: const Text(
                            'View All Reviews',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

class ServiceCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int delay;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.delay = 0,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Start animation after delay
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          width: 135,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: widget.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              // ignore: deprecated_member_use
              color: widget.color.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 40, color: widget.color),
              const SizedBox(height: 8),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}