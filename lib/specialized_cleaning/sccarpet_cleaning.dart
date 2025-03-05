import 'package:flutter/material.dart';
import '../calendar_booking.dart'; // Import CalendarBookingScreen

class SCCarpetCleaningPage extends StatefulWidget {
  const SCCarpetCleaningPage({super.key});

  @override
  State<SCCarpetCleaningPage> createState() => _SCCarpetCleaningPageState();
}

class _SCCarpetCleaningPageState extends State<SCCarpetCleaningPage> {
  int sqm = 1; // Default square meters
  final double ratePerSqm = 150.0;
  final int maxSqm = 1000; // Maximum allowed square meters

  double get totalCost => sqm * ratePerSqm; // Auto calculate

  void _increaseSqm() {
    if (sqm < maxSqm) {
      setState(() => sqm++);
    } else {
      _showSnackbar('Maximum limit reached');
    }
  }

  void _decreaseSqm() {
    if (sqm > 1) {
      setState(() => sqm--);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _bookNow() {
    if (sqm <= 0) {
      _showSnackbar('Please select a valid carpet size.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarBookingScreen(
          itemSize: sqm,
          totalCost: totalCost.toInt(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carpet Cleaning',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade800, Colors.teal.shade200],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceCard(),
              const SizedBox(height: 20),
              Center(
                child: Icon(
                  Icons.cleaning_services,
                  size: 100,
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Carpet Cleaning Service',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(height: 20),
            const Text(
              'Comprehensive cleaning solutions for carpets and rugs, removing dirt and stains using Premium Hydro Vacuum and eco-friendly biodegradable solutions.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Rate: ₱$ratePerSqm per sqm',
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decreaseSqm,
                  icon: const Icon(Icons.remove_circle,
                      color: Colors.teal, size: 40),
                ),
                Text('$sqm sqm',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _increaseSqm,
                  icon: const Icon(Icons.add_circle,
                      color: Colors.teal, size: 40),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _bookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
