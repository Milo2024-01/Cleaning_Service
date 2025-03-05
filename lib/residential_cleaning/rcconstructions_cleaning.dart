import 'package:flutter/material.dart';
import '../calendar_booking.dart'; // Import CalendarBookingScreen

class PostConstructionCleaningCalculator extends StatefulWidget {
  const PostConstructionCleaningCalculator({super.key});

  @override
  _PostConstructionCleaningCalculatorState createState() =>
      _PostConstructionCleaningCalculatorState();
}

class _PostConstructionCleaningCalculatorState
    extends State<PostConstructionCleaningCalculator> {
  double areaSize = 1.0; // Default to 1 sqm
  final double ratePerSqm = 60.0;

  double get totalCost => areaSize * ratePerSqm; // Auto calculate

  void _bookNow() {
    if (areaSize <= 0) {
      _showSnackbar('Please enter a valid area size.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarBookingScreen(
          itemSize: areaSize.toInt(),
          totalCost: totalCost.toInt(),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Post Construction Cleaning',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700], // Dark green for the app bar
        elevation: 5,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade700, Colors.green.shade300],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Post Construction Cleaning',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Using Premium Hydro Vacuum. Removal of excess paint, construction dust, and elimination of unwanted smells.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Rate: ₱$ratePerSqm per sqm',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Enter the area size (in sqm):',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Slider(
                        value: areaSize,
                        min: 1.0,
                        max: 100.0,
                        divisions: 99,
                        label: '${areaSize.toStringAsFixed(1)} sqm',
                        activeColor: Colors.green[700],
                        inactiveColor: Colors.green[100],
                        onChanged: (double value) {
                          setState(() {
                            areaSize = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity, // Full width button
                        child: ElevatedButton(
                          onPressed: _bookNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 40),
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
              ),
              const SizedBox(height: 30), // Space for better UI
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
}
