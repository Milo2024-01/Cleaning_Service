import 'package:flutter/material.dart';
import '../payment_upload.dart';

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
  double areaSize = 1.0; // Default to 1 sqm
  static const double ratePerSqm = 60.0; // Cost per sqm (compile-time constant)
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

  void _bookNow() {
    if (areaSize < 1) {
      _showSnackbar('Please select an area size of at least 1 sqm.');
      return;
    }

    // Safe date/time parsing with fallbacks
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
      selectedTime = const TimeOfDay(hour: 12, minute: 0); // Default to noon
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentUploadScreen(
          totalCost: (areaSize * ratePerSqm).toInt(),
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          itemSize: 1,
          serviceLabel: 'Construction Cleaning',
        ),
      ),
    );
  }

  void _showSnackbar(String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reusable text styles
    final TextStyle headerStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.green[900],
    );

    final TextStyle subHeaderStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.green[900],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Construction Cleaning'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Post-Construction Cleaning',
              style: headerStyle,
            ),
            const SizedBox(height: 10),
            const Text(
              'Removes excess paint, dust, and construction debris using premium hydro vacuum.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Area Size Input (Slider + TextField)
            Text(
              'Enter the area size (in sqm):',
              style: subHeaderStyle,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Slider(
                    value: areaSize,
                    min: 1.0,
                    max: 100.0,
                    divisions: 99,
                    label: '${areaSize.toStringAsFixed(1)} sqm',
                    activeColor: Colors.green[700],
                    inactiveColor: Colors.green[200],
                    onChanged: (double value) {
                      setState(() {
                        areaSize = value;
                        _areaController.text = value.toStringAsFixed(1);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _areaController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onChanged: (value) {
                      final newValue = double.tryParse(value) ?? 1.0;
                      setState(() {
                        areaSize = newValue.clamp(1.0, 100.0);
                      });
                    },
                  ),
                ),
              ],
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
            if (widget.selectedDate != null || widget.selectedTime != null)
              Center(
                child: Column(
                  children: [
                    if (widget.selectedDate != null)
                      Text(
                        'Selected Date: ${widget.selectedDate}',
                        style: subHeaderStyle,
                      ),
                    if (widget.selectedTime != null)
                      Text(
                        'Selected Time: ${widget.selectedTime}',
                        style: subHeaderStyle,
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
                  backgroundColor: Colors.green[700],
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