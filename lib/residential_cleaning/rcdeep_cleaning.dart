import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../payment_upload.dart'; // Import PaymentUploadScreen

class DeepCleaningCalculator extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const DeepCleaningCalculator({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  _DeepCleaningCalculatorState createState() => _DeepCleaningCalculatorState();
}

class _DeepCleaningCalculatorState extends State<DeepCleaningCalculator> {
  double areaSize = 1.0; // Default to 1 sqm
  final double ratePerSqm = 55.0; // Cost per square meter for deep cleaning

  // Function to book now and navigate to booking screen
  void _bookNow() async {
    final selectedDate = DateTime.now(); // Default to the current date
    final selectedTime = TimeOfDay.now(); // Default to the current time

    if (areaSize < 1) {
      _showSnackbar('Please select an area size of at least 1 sqm.');
      return;
    }

    // Navigate to PaymentUploadScreen and pass the correct total cost
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentUploadScreen(
          totalCost: (areaSize * ratePerSqm).toInt(), // Fix applied here
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          itemSize: 1,
          serviceLabel: 'Deep Cleaning',
        ),
      ),
    );

    if (result != null) {
      final String selectedDateString = result['date'];
      final String selectedTimeString = result['time'];

      if (kDebugMode) {
        print('Selected Date: $selectedDateString');
        print('Selected Time: $selectedTimeString');
      }

      try {
        final DateTime selectedDate = DateTime.parse(selectedDateString);
        final TimeOfDay selectedTime = TimeOfDay.fromDateTime(
            DateTime.parse('1970-01-01 $selectedTimeString'));

        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => PaymentUploadScreen(
              totalCost: (areaSize * ratePerSqm).toInt(), // Fix applied here
              selectedDate: selectedDate,
              selectedTime: selectedTime,
              itemSize: 1,
              serviceLabel: 'Deep Cleaning',
            ),
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing date/time: $e');
        }
        _showSnackbar('Invalid date/time format. Please try again.');
      }
    } else {
      if (kDebugMode) {
        print('No date/time selected.');
      }
      _showSnackbar('No date/time selected. Please try again.');
    }
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
        backgroundColor: Colors.deepOrange[800],
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
            boxShadow: const [
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
                        'Deep Cleaning Service',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange[900],
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
                  color: Colors.deepOrange[900],
                ),
              ),
              const SizedBox(height: 10),
              Slider(
                value: areaSize,
                min: 1.0,
                max: 100.0,
                divisions: 99,
                label: '${areaSize.toStringAsFixed(1)} sqm',
                activeColor: Colors.deepOrange[700],
                inactiveColor: Colors.deepOrange[200],
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
                    color: Colors.black87,
                  ),
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

              // Book Now Button
              Center(
                child: ElevatedButton(
                  onPressed: _bookNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange[800],
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