import 'package:flutter/material.dart';
import '../specialize_cleaning.dart'; // Import SpecializeCleaningPage
import '../calendar_booking.dart'; // Import CalendarBookingScreen

class WaterTankCleaningPage extends StatefulWidget {
  const WaterTankCleaningPage({super.key});

  @override
  _WaterTankCleaningPageState createState() => _WaterTankCleaningPageState();
}

class _WaterTankCleaningPageState extends State<WaterTankCleaningPage> {
  final TextEditingController _areaController = TextEditingController();
  final int pricePerSqm = 80;

  void _bookService() {
    double areaSize = double.tryParse(_areaController.text) ?? 0;

    if (areaSize <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid tank size.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Only passing serviceLabel for the navigation, no areaSize or totalCost
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarBookingScreen(
          serviceLabel: 'Water Tank Cleaning', // Passing only serviceLabel
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Tank Cleaning'),
        backgroundColor: Colors.purple[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SpecializeCleaningPage()),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade700, Colors.purple.shade400],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Water Tank Cleaning',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Professional cleaning and disinfection of water tanks to ensure safe drinking water.',
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Enter Tank Size (sqm)',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[900],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _areaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Tank Size (sqm)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _bookService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Book Service',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Icon(
                      Icons.water_drop,
                      size: 100,
                      color: Colors.purple[300],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
