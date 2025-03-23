import 'package:flutter/material.dart';
import '../calendar_booking.dart'; // Import CalendarBookingScreen
import '../payment_upload.dart'; // Import PaymentUploadScreen

class RCCDeclutteringServicePage extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const RCCDeclutteringServicePage({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  State<RCCDeclutteringServicePage> createState() =>
      _RCCDeclutteringServicePageState();
}

class _RCCDeclutteringServicePageState
    extends State<RCCDeclutteringServicePage> {
  int hours = 1; // Default value
  final double ratePerHour = 550.0;

  // Function to book now and navigate to booking screen
  void _bookNow() async {
    
    if (hours < 1) {
      _showSnackbar('Please select at least 1 hour.');
      return;
    }

    // Navigate to CalendarBookingScreen and wait for the result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarBookingScreen(
          serviceLabel: 'Decluttering Services', // Pass the service label
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
            totalCost: (ratePerHour * hours).toInt(),
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            itemSize: 1, // You can adjust this as needed
            serviceLabel: 'Decluttering Services', // Pass the service label
          ),
        ),
      );
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
          'Decluttering Services',
          style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade200],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Decluttering Services',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Transform your space with our Decluttering Services! We help you sort, remove, and organize unwanted items, creating a serene and functional environment. Say goodbye to clutter and hello to clarity.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Rate: ₱$ratePerHour per hour',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (hours > 1) hours--;
                              });
                            },
                            icon: const Icon(Icons.remove_circle),
                            color: Colors.deepPurple,
                            iconSize: 40,
                          ),
                          Column(
                            children: [
                              Text(
                                '$hours hrs',
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Total: ₱${(hours * ratePerHour).toInt()}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                hours++;
                              });
                            },
                            icon: const Icon(Icons.add_circle),
                            color: Colors.deepPurple,
                            iconSize: 40,
                          ),
                        ],
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
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _bookNow, // Navigate to booking
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
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
