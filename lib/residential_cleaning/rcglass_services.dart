import 'package:flutter/material.dart';

class GlassDetailingCalculator extends StatefulWidget {
  const GlassDetailingCalculator({super.key});

  @override
  _GlassDetailingCalculatorState createState() =>
      _GlassDetailingCalculatorState();
}

class _GlassDetailingCalculatorState extends State<GlassDetailingCalculator> {
  double panelCount = 1.0; // Default to 1 panel
  double totalCost = 150.0; // Cost per panel (150 Pesos)

  void calculateTotalCost() {
    setState(() {
      totalCost = panelCount * 150; // 150 Pesos per panel
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Glass Detailing Services'),
        backgroundColor: Colors.teal, // Teal color for the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Details Card
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
                      'Glass Detailing Services',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal, // Teal text color
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'We provide specialized cleaning and maintenance for all types of glass surfaces, ensuring clarity and shine. Our team uses professional-grade products and techniques to enhance the appearance and longevity of your glass features. This includes the removal of water marks and stains.',
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
              'Enter the number of glass panels:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal, // Teal text color
              ),
            ),
            SizedBox(height: 10),
            Slider(
              value: panelCount,
              min: 1.0,
              max: 100.0,
              divisions: 99,
              label: panelCount.toStringAsFixed(1),
              activeColor: Colors.teal, // Green slider
              inactiveColor: Colors.teal[100], // Light teal
              onChanged: (double value) {
                setState(() {
                  panelCount = value;
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
                  color: Colors.teal, // Teal text color
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
                            Colors.teal[50], // Light teal background
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                        ),
                        title: Text(
                          "Booking Confirmation",
                          style: TextStyle(
                            color: Colors.teal, // Teal text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          "You have booked glass detailing for ${panelCount.toStringAsFixed(1)} panels.\nTotal Cost: ₱${totalCost.toStringAsFixed(2)}",
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
                                color: Colors.teal, // Teal text
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
                  backgroundColor: Colors.teal, // Teal button color
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
