import 'package:flutter/material.dart';
import '../calendar_booking.dart';
import '../payment_upload.dart';

void main() {
  runApp(const RCConstructionCleaningApp());
}

class RCConstructionCleaningApp extends StatelessWidget {
  final String? selectedDate;
  final String? selectedTime;

  const RCConstructionCleaningApp({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Construction Cleaning Service',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700],
          elevation: 5,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: ConstructionCleaningCalculator(
        selectedDate: selectedDate,
        selectedTime: selectedTime,
      ),
    );
  }
}

class ConstructionCleaningCalculator extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const ConstructionCleaningCalculator({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  _ConstructionCleaningCalculatorState createState() =>
      _ConstructionCleaningCalculatorState();
}

class _ConstructionCleaningCalculatorState
    extends State<ConstructionCleaningCalculator> {
  int hours = 1;
  int cleaners = 1;
  final double ratePerHour = 450.0;

  double get totalCost => ratePerHour * hours * cleaners;

  void _bookService() async {
    // Navigate to CalendarBookingScreen and wait for the result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarBookingScreen(
          serviceLabel: 'Construction Cleaning', // Pass the service label here
        ),
      ),
    );

    // If the result is not null, it means the user confirmed the booking
    if (result != null) {
      // Extract the selected date and time from the result
      final selectedDate = DateTime.parse(result['date']);
      final selectedTime = TimeOfDay.fromDateTime(
          DateTime.parse('1970-01-01 ${result['time']}'));

      // Navigate to the PaymentUploadScreen with the selected date and time
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (context) => PaymentUploadScreen(
            totalCost: totalCost.toInt(),
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            itemSize: 1, // You can adjust this as needed
            serviceLabel: 'Construction Cleaning', // Pass the service label
          ),
        ),
      );
    }
  }

  Widget _buildSlider({
    required IconData icon,
    required String label,
    required int value,
    required int min,
    required int max,
    required Function(int) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.green[800]),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: value.toString(),
            activeColor: Colors.green[700],
            inactiveColor: Colors.green[100],
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Cleaning Service'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade700, Colors.green.shade400],
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
                          'Construction Cleaning',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'We offer cleaning services for post-construction sites, including debris removal and thorough cleaning.',
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
                    color: Colors.green[900],
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
                        _buildSlider(
                          icon: Icons.timer,
                          label: 'Hours',
                          value: hours,
                          min: 1,
                          max: 10,
                          onChanged: (value) {
                            setState(() {
                              hours = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildSlider(
                          icon: Icons.people,
                          label: 'Cleaners',
                          value: cleaners,
                          min: 1,
                          max: 10,
                          onChanged: (value) {
                            setState(() {
                              cleaners = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Total cost display
                Text(
                  'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                 const SizedBox(height: 30),

              // Selected Date and Time Display
              if (widget.selectedDate != null && widget.selectedTime != null)
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      const SizedBox(height: 20), // Space between time and button
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _bookService, // Navigate to booking screen
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}