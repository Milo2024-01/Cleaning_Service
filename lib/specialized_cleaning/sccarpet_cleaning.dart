import 'package:flutter/material.dart';
import '../payment_upload.dart';

class CarpetCleaningScreen extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const CarpetCleaningScreen({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  State<CarpetCleaningScreen> createState() => _CarpetCleaningScreenState();
}

class _CarpetCleaningScreenState extends State<CarpetCleaningScreen> {
  double areaSize = 1.0; // Default to 1 sqm
  static const double ratePerSqm = 150.0; // ₱150 per sqm
  final TextEditingController _areaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _areaController.text = areaSize.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  void _showLargeOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Large service Notice'),
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

  void _bookNow() {
    final totalCost = areaSize * ratePerSqm;
    
    // Check if total exceeds 10,000
    if (totalCost > 10000) {
      _showLargeOrderDialog();
      return;
    }

    if (areaSize < 1) {
      _showSnackbar('Please select an area size of at least 1 sqm.');
      return;
    }

    // Parse date/time with fallbacks
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
          itemSize: areaSize.round(),
          serviceLabel: 'Carpet Cleaning',
        ),
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
    final totalCost = areaSize * ratePerSqm;
    final showWarning = totalCost > 10000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carpet Cleaning'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professional Carpet Cleaning',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[900],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Comprehensive cleaning solutions for carpets and rugs, removing dirt and stains using Premium Hydro Vacuum and eco-friendly biodegradable solutions.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Area Size Input
            Text(
              'Enter carpet area size (in sqm):',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[900],
              ),
            ),
            Slider(
              value: areaSize,
              min: 1.0,
              max: 100.0,
              divisions: 99,
              label: '${areaSize.toStringAsFixed(1)} sqm',
              activeColor: Colors.deepPurple,
              inactiveColor: Colors.deepPurple[200],
              onChanged: (double value) {
                setState(() {
                  areaSize = value;
                  _areaController.text = value.toStringAsFixed(1);
                });
              },
            ),
            const SizedBox(height: 20),

            // Total Cost Display
            Column(
              children: [
                Text(
                  'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: showWarning ? Colors.red : Colors.black87,
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
            const SizedBox(height: 30),

            // Selected Date and Time Display
            if (widget.selectedDate != null || widget.selectedTime != null)
              Center(
                child: Column(
                  children: [
                    if (widget.selectedDate != null)
                      Text(
                        'Selected Date: ${widget.selectedDate}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                    if (widget.selectedTime != null)
                      Text(
                        'Selected Time: ${widget.selectedTime}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

            // Book Now Button
            Center(
              child: ElevatedButton(
                onPressed: _bookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
    );
  }
}