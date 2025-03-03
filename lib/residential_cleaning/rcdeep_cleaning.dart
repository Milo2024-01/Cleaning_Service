// rcdeep_cleaning.dart
import 'package:flutter/material.dart';

class DeepCleaningCalculator extends StatefulWidget {
  const DeepCleaningCalculator({super.key});

  @override
  _DeepCleaningCalculatorState createState() => _DeepCleaningCalculatorState();
}

class _DeepCleaningCalculatorState extends State<DeepCleaningCalculator> {
  double areaSize = 1.0; // Default to 1 sqm
  double totalCost = 55.0; // Cost per square meter for deep cleaning

  void calculateTotalCost() {
    setState(() {
      totalCost = areaSize * 55; // 55 Pesos per sqm for deep cleaning
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Deep Cleaning',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700], // Darker blue for the app bar
        elevation: 5, // Shadow for the app bar
        centerTitle: true, // Center the title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Details Card with Drop Shadow
            Card(
              elevation: 5, // Shadow for the card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deep Cleaning',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900], // Dark blue text
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'A thorough cleaning that covers all areas of the home, including hard-to-reach spots, appliances, and detailed surface cleaning. Using Premium Hydro vacuum and Ecofriendly Biodegradable solutions, this includes free UVG Disinfections with Ozone Treatment.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30), // Spacer between the description and slider
            Text(
              'Enter the area size (in sqm):',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900], // Dark blue text
              ),
            ),
            SizedBox(height: 10),
            Slider(
              value: areaSize,
              min: 1.0,
              max: 100.0,
              divisions: 99,
              label: '${areaSize.toStringAsFixed(1)} sqm',
              activeColor: Colors.blue[700], // Blue slider
              inactiveColor: Colors.blue[100], // Light blue
              onChanged: (double value) {
                setState(() {
                  areaSize = value;
                  calculateTotalCost();
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900], // Dark blue text
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add your booking or action logic here
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor:
                            Colors.blue[50], // Light blue background
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                        ),
                        title: Text(
                          "Booking Confirmation",
                          style: TextStyle(
                            color: Colors.blue[900], // Dark blue text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          "You have booked cleaning for ${areaSize.toStringAsFixed(1)} sqm.\nTotal Cost: ₱${totalCost.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(
                                color: Colors.blue[900], // Dark blue text
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 25, 210, 81), // Blue button
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded button
                  ),
                ),
                child: Text(
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
    );
  }
}
