import 'package:flutter/material.dart';

class GreaseTrapCleaningCalculator extends StatefulWidget {
  const GreaseTrapCleaningCalculator({super.key});

  @override
  _GreaseTrapCleaningCalculatorState createState() =>
      _GreaseTrapCleaningCalculatorState();
}

class _GreaseTrapCleaningCalculatorState
    extends State<GreaseTrapCleaningCalculator> {
  final int costPerTrap = 850; // Cost per grease trap
  int numberOfTraps = 1; // Default to 1 trap
  int totalCost = 850; // Default total cost for 1 trap

  void calculateTotalCost() {
    setState(() {
      totalCost = numberOfTraps * costPerTrap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grease Trap Cleaning',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[700], // Darker red for the app bar
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
                      'Grease Trap Cleaning Service',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900], // Dark red text
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'We offer professional cleaning and maintenance of grease traps in residential kitchens, preventing clogs and ensuring proper waste disposal.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30), // Spacer between the description and input
            Center(
              child: Text(
                'Cost per trap: ₱850',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900], // Dark red text
                ),
              ),
            ),
            SizedBox(height: 20),
            // Number of Traps Input
            Card(
              elevation: 5, // Shadow for the card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Number of Traps:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900], // Dark red text
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove,
                              color: Colors.red[700]), // Red icon
                          onPressed: () {
                            if (numberOfTraps > 1) {
                              setState(() {
                                numberOfTraps--;
                                calculateTotalCost();
                              });
                            }
                          },
                        ),
                        Text(
                          '$numberOfTraps',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900], // Dark red text
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add,
                              color: Colors.red[700]), // Red icon
                          onPressed: () {
                            setState(() {
                              numberOfTraps++;
                              calculateTotalCost();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                'Total Cost: ₱$totalCost',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900], // Dark red text
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Booking confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.red[50], // Light red background
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                        ),
                        title: Text(
                          "Booking Confirmation",
                          style: TextStyle(
                            color: Colors.red[900], // Dark red text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          "You have booked cleaning for $numberOfTraps trap(s).\nTotal Cost: ₱$totalCost",
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
                                color: Colors.red[900], // Dark red text
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
                  backgroundColor: Colors.red[700], // Red button
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
