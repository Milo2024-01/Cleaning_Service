import 'package:flutter/material.dart';
import '../payment_upload.dart';

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
  int hours = 1;
  final double ratePerHour = 550.0;

  void _bookNow() {
    final totalCost = ratePerHour * hours;
    
    // Check if total exceeds 10,000
    if (totalCost > 10000) {
      _showLargeOrderDialog();
      return;
    }

    if (hours < 1) {
      _showSnackbar('Please select at least 1 hour.');
      return;
    }

    DateTime selectedDate;
    try {
      selectedDate = DateTime.parse(widget.selectedDate ?? DateTime.now().toString());
    } catch (e) {
      selectedDate = DateTime.now();
    }

    TimeOfDay selectedTime;
    try {
      final timeParts = widget.selectedTime?.split(":") ?? ["12", "00"];
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    } catch (e) {
      selectedTime = const TimeOfDay(hour: 12, minute: 0);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentUploadScreen(
          totalCost: totalCost.toInt(),
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          itemSize: 1,
          serviceLabel: 'Decluttering Services',
        ),
      ),
    );
  }

  void _showLargeOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Large Order Notice'),
        content: const Text(
          'For service exceeding ₱10,000, please visit our shop for payment arrangements.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

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
    final totalCost = ratePerHour * hours;
    final showWarning = totalCost > 10000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decluttering Services'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Decluttering Services',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'We help you sort, remove, and organize unwanted items.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Rate: ₱$ratePerHour per hour',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  icon: const Icon(Icons.remove_circle, size: 40),
                  color: Colors.deepPurple,
                ),
                Column(
                  children: [
                    Text(
                      '$hours hrs',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Total: ₱${totalCost.toInt()}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: showWarning ? Colors.red : Colors.black,
                      ),
                    ),
                    if (showWarning)
                      const Text(
                        '(Visit shop for payment)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      hours++;
                    });
                  },
                  icon: const Icon(Icons.add_circle, size: 40),
                  color: Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (widget.selectedDate != null || widget.selectedTime != null)
              Column(
                children: [
                  if (widget.selectedDate != null)
                    Text(
                      'Selected Date: ${widget.selectedDate}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  if (widget.selectedTime != null)
                    Text(
                      'Selected Time: ${widget.selectedTime}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            Center(
              child: ElevatedButton(
                onPressed: _bookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
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
    );
  }
}