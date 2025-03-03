import 'package:flutter/material.dart';

void main() {
  runApp(RCGeneralCleaningApp());
}

class RCGeneralCleaningApp extends StatelessWidget {
  const RCGeneralCleaningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'General Cleaning Service',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.yellow[700],
          elevation: 5,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: GeneralCleaningCalculator(),
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
  double totalCost = 350.0;

  void calculateTotalCost() {
    setState(() {
      totalCost = (350 * hours * cleaners) as double;
    });
  }

  void bookService() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.yellow[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Booking Confirmation",
            style: TextStyle(
              color: Colors.yellow[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "You have booked $cleaners cleaner(s) for $hours hour(s).\nTotal Cost: ₱${totalCost.toStringAsFixed(2)}",
            style: TextStyle(
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
                  color: Colors.yellow[900],
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
        title: Text('Cleaning Service'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
                        'General Cleaning',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow[900],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'We offer routine cleaning services for homes, including dusting, mopping, and sanitizing bathrooms and kitchens.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Cleaning Service Cost',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow[900],
                ),
              ),
              SizedBox(height: 30),
              // Slider for Hours and Cleaners
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, color: Colors.yellow[800]),
                          SizedBox(width: 10),
                          Text(
                            'Hours:',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Slider(
                              value: hours.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: hours.toString(),
                              activeColor: Colors.yellow[700],
                              inactiveColor: Colors.yellow[100],
                              onChanged: (value) {
                                setState(() {
                                  hours = value.toInt();
                                  calculateTotalCost();
                                });
                              },
                            ),
                          ),
                          Text(
                            '$hours',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow[900],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.people, color: Colors.yellow[800]),
                          SizedBox(width: 10),
                          Text(
                            'Cleaners:',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Slider(
                              value: cleaners.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: cleaners.toString(),
                              activeColor: Colors.yellow[700],
                              inactiveColor: Colors.yellow[100],
                              onChanged: (value) {
                                setState(() {
                                  cleaners = value.toInt();
                                  calculateTotalCost();
                                });
                              },
                            ),
                          ),
                          Text(
                            '$cleaners',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow[900],
                            ),
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
                  'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[900],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: bookService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
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
