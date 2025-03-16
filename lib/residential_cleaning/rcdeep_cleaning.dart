import 'package:flutter/material.dart';
import '../calendar_booking.dart'; // Import the Calendar Booking Screen

class DeepCleaningCalculator extends StatefulWidget {
  const DeepCleaningCalculator({super.key});

  @override
  _DeepCleaningCalculatorState createState() => _DeepCleaningCalculatorState();
}

class _DeepCleaningCalculatorState extends State<DeepCleaningCalculator> {
  double areaSize = 1.0; // Default to 1 sqm
  final double ratePerSqm = 55.0; // Cost per square meter for deep cleaning

  // Function to book now and navigate to booking screen
  void _bookNow() {
    if (areaSize < 1) {
      _showSnackbar('Please select an area size of at least 1 sqm.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarBookingScreen(serviceLabel: 'Deep Cleaning'), // Pass the service label
      ),
    );
  }

  // Function to show a snackbar
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deep Cleaning',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepOrange[800], // Dark orange for contrast
        elevation: 5,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepOrange.shade700, Colors.deepOrange.shade400],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Details Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deep Cleaning Service',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange[900], // Darker orange text
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Thorough deep cleaning covering all areas, including appliances and hard-to-reach spots. Uses premium hydro vacuum and eco-friendly solutions. Free UVG Disinfection with Ozone Treatment included.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Area Input Section
              Text(
                'Enter the area size (in sqm):',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange[900], // Dark orange text
                ),
              ),
              const SizedBox(height: 10),
              Slider(
                value: areaSize,
                min: 1.0,
                max: 100.0,
                divisions: 99,
                label: '${areaSize.toStringAsFixed(1)} sqm',
                activeColor: Colors.deepOrange[700], // Darker orange slider
                inactiveColor: Colors.deepOrange[200], // Light orange
                onChanged: (double value) {
                  setState(() {
                    areaSize = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Total Cost Display
              Center(
                child: Text(
                  'Total Cost: ₱${(areaSize * ratePerSqm).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Dark text for contrast
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Book Now Button
              Center(
                child: ElevatedButton(
                  onPressed: _bookNow, // Navigate to booking screen
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange[800], // Dark orange button
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Book Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
