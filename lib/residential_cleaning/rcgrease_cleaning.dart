import 'package:flutter/material.dart';
import '../calendar_booking.dart'; // Import CalendarBookingScreen
import '../payment_upload.dart'; // Import PaymentUploadScreen

class GreaseTrapCleaningCalculator extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const GreaseTrapCleaningCalculator({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

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

  void _bookService() async {
    // Navigate to CalendarBookingScreen and wait for the result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarBookingScreen(
          serviceLabel: 'Grease Trap Cleaning', // Pass the service label
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
            totalCost: totalCost,
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            itemSize: 1, // You can adjust this as needed
            serviceLabel: 'Grease Trap Cleaning', // Pass the service label
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grease Trap Cleaning',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[800], // Dark red for contrast
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
            colors: [Colors.red.shade700, Colors.red.shade400],
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
                        'Grease Trap Cleaning Service',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'We offer professional grease trap cleaning to prevent clogs and ensure proper waste disposal. Ideal for residential and commercial kitchens.',
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
              Center(
                child: Text(
                  'Cost per trap: ₱850',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                  ),
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
                      Text(
                        'Number of Traps:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
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
                              color: Colors.red[900],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.red),
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
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Total Cost: ₱$totalCost',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _bookService, // Navigate to the booking screen
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
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