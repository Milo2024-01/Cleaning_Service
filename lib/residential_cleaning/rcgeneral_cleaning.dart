import 'package:flutter/material.dart';

void main() {
  runApp(const RCGeneralCleaningApp());
}

class RCGeneralCleaningApp extends StatelessWidget {
  const RCGeneralCleaningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'General Cleaning Service',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.amber[700],
          elevation: 5,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const GeneralCleaningCalculator(),
    );
  }
}

class GeneralCleaningCalculator extends StatefulWidget {
  const GeneralCleaningCalculator({super.key});

  @override
  _GeneralCleaningCalculatorState createState() =>
      _GeneralCleaningCalculatorState();
}

class _GeneralCleaningCalculatorState extends State<GeneralCleaningCalculator> {
  int hours = 1;
  int cleaners = 1;
  final double ratePerHour = 350.0;

  double get totalCost => ratePerHour * hours * cleaners; // Auto calculation

  void _bookService() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.amber[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Booking Confirmation",
            style: TextStyle(
              color: Colors.amber[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "You have booked $cleaners cleaner(s) for $hours hour(s).\nTotal Cost: ₱${totalCost.toStringAsFixed(2)}",
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
                  color: Colors.amber[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cleaning Service'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade700, Colors.amber.shade400],
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
          child: SingleChildScrollView(
            child: Column(
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
                          'General Cleaning',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'We offer routine cleaning services for homes, including dusting, mopping, and sanitizing bathrooms and kitchens.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  'Cleaning Service Cost',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
                const SizedBox(height: 20),

                // Cost Calculator Card
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Hours Slider
                        Row(
                          children: [
                            Icon(Icons.timer, color: Colors.amber[800]),
                            const SizedBox(width: 10),
                            const Text(
                              'Hours:',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Slider(
                                value: hours.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: hours.toString(),
                                activeColor: Colors.amber[700],
                                inactiveColor: Colors.amber[100],
                                onChanged: (value) {
                                  setState(() {
                                    hours = value.toInt();
                                  });
                                },
                              ),
                            ),
                            Text(
                              '$hours',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Cleaners Slider
                        Row(
                          children: [
                            Icon(Icons.people, color: Colors.amber[800]),
                            const SizedBox(width: 10),
                            const Text(
                              'Cleaners:',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Slider(
                                value: cleaners.toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: cleaners.toString(),
                                activeColor: Colors.amber[700],
                                inactiveColor: Colors.amber[100],
                                onChanged: (value) {
                                  setState(() {
                                    cleaners = value.toInt();
                                  });
                                },
                              ),
                            ),
                            Text(
                              '$cleaners',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Total Cost
                Center(
                  child: Text(
                    'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[900],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Book Now Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _bookService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
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

                // Icon Decoration
                Center(
                  child: Icon(
                    Icons.cleaning_services,
                    size: 100,
                    color: Colors.amber[300],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
