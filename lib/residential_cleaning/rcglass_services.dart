import 'package:flutter/material.dart';
//import '../calendar_booking.dart'; // Import CalendarBookingScreen
import '../payment_upload.dart'; // Import PaymentUploadScreen

class GlassDetailingCalculator extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const GlassDetailingCalculator({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

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

  void _bookService() {
  // Ensure selectedDate is not null and is in a valid format
  DateTime selectedDate;
  try {
    selectedDate = widget.selectedDate != null
        ? DateTime.parse(widget.selectedDate!)
        : DateTime.now();
  } catch (e) {
    selectedDate = DateTime.now(); // Fallback to current date in case of error
  }

  // Ensure selectedTime is not null and is in a valid format
  TimeOfDay selectedTime;
  try {
    if (widget.selectedTime != null) {
      final timeParts = widget.selectedTime!.split(":");
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } else {
      selectedTime = const TimeOfDay(hour: 12, minute: 0); // Default to 12:00 PM
    }
  } catch (e) {
    selectedTime = const TimeOfDay(hour: 12, minute: 0); // Fallback in case of error
  }

  // Navigate to PaymentUploadScreen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PaymentUploadScreen(
        totalCost: totalCost.toInt(),
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        itemSize: 1, // Adjust as needed
        serviceLabel: 'Glass Detailing', // Pass the service label
      ),
    ),
  );
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
                          color: Colors.teal[900],
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
              Text(
                'Enter the number of glass panels:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
              const SizedBox(height: 10),
              Slider(
                value: panelCount,
                min: 1.0,
                max: 100.0,
                divisions: 99,
                label: panelCount.toStringAsFixed(1),
                activeColor: Colors.teal,
                inactiveColor: Colors.teal[100],
                onChanged: (double value) {
                  setState(() {
                    panelCount = value;
                    calculateTotalCost(); // Recalculate the cost when the slider changes
                  });
                },
              ),
              const SizedBox(height: 20),
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
              // Add a note about cost per panel
              Center(
                child: Text(
                  'Cost per panel: ₱150',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.teal[900],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _bookService, // Navigate to the booking screen
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
              const SizedBox(height: 30),

              // Selected Date and Time Display
             // Selected Date and Time Display (Centered)
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
            ],
          ),
        ),
      ),
    );
  }
}