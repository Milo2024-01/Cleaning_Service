import 'package:flutter/material.dart';
import '../payment_upload.dart'; // Import only the PaymentUploadScreen

class GeneralCleaningCalculator extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const GeneralCleaningCalculator({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  _GeneralCleaningCalculatorState createState() =>
      _GeneralCleaningCalculatorState();
}

class _GeneralCleaningCalculatorState extends State<GeneralCleaningCalculator> {
  int hours = 1;
  int cleaners = 1;
  final double ratePerHour = 350.0;

  double get totalCost => ratePerHour * hours * cleaners; // Auto calculation

  void _bookService() async {
    // Use the current date and time as default values
    final selectedDate = DateTime.now(); // Default to the current date
    final selectedTime = TimeOfDay.now(); // Default to the current time

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentUploadScreen(
          totalCost: totalCost.toInt(),
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          itemSize: 1, // You can adjust this as needed
          serviceLabel: 'General Cleaning', // Pass the service label
        ),
      ),
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
                        const SizedBox(height: 10),
                        Text(
                          '💰 Rate: 350 per hour, per cleaner',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
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
                        const SizedBox(height: 15),
                        Text(
                          'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
                if (widget.selectedDate != null && widget.selectedTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        Text(
                          'Selected Date: ${widget.selectedDate}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                        Text(
                          'Selected Time: ${widget.selectedTime}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
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