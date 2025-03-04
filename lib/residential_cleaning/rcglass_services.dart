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
        title: const Text(
          'Glass Detailing Services',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal[800], // Dark teal for contrast
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
            colors: [Colors.teal.shade700, Colors.teal.shade400],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
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
                        'Glass Detailing Services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900], // Dark teal text
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We provide specialized cleaning for all types of glass surfaces, ensuring clarity and shine. We use professional-grade products to remove water marks and stains.',
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

              // Slider Label
              Text(
                'Enter the number of glass panels:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
              const SizedBox(height: 10),

              // Number of Panels Slider
              Slider(
                value: panelCount,
                min: 1.0,
                max: 100.0,
                divisions: 99,
                label: panelCount.toStringAsFixed(1),
                activeColor: Colors.teal, // Teal slider
                inactiveColor: Colors.teal[100], // Light teal
                onChanged: (double value) {
                  setState(() {
                    panelCount = value;
                    calculateTotalCost();
                  });
                },
              ),
              const SizedBox(height: 20),

              // Total Cost Display
              Center(
                child: Text(
                  'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Book Now Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.teal[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: Text(
                            "Booking Confirmation",
                            style: TextStyle(
                              color: Colors.teal[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            "You have booked glass detailing for ${panelCount.toStringAsFixed(1)} panels.\nTotal Cost: ₱${totalCost.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  color: Colors.teal[900],
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
                    backgroundColor: Colors.teal[800],
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
                      color: Colors.white,
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
