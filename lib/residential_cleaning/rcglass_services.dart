import 'package:flutter/material.dart';
import '../payment_upload.dart';

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
  double panelCount = 1.0;
  double totalCost = 150.0; // 150 Pesos per panel

  void calculateTotalCost() {
    setState(() {
      totalCost = panelCount * 150;
    });
  }

  void _bookService() {
    // Check if total exceeds 10,000
    if (totalCost > 10000) {
      _showLargeOrderDialog();
      return;
    }

    // Ensure selectedDate is valid
    DateTime selectedDate;
    try {
      selectedDate = widget.selectedDate != null
          ? DateTime.parse(widget.selectedDate!)
          : DateTime.now();
    } catch (e) {
      selectedDate = DateTime.now();
    }

    // Ensure selectedTime is valid
    TimeOfDay selectedTime;
    try {
      if (widget.selectedTime != null) {
        final timeParts = widget.selectedTime!.split(":");
        selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      } else {
        selectedTime = const TimeOfDay(hour: 12, minute: 0);
      }
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
          serviceLabel: 'Glass Detailing',
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
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showWarning = totalCost > 10000;

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
        backgroundColor: Colors.teal[800],
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
                        'We provide specialized cleaning for all types of glass surfaces, ensuring clarity and shine.',
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
                    calculateTotalCost();
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
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
              ),
              const SizedBox(height: 20),
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
                  onPressed: _bookService,
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
              if (widget.selectedDate != null && widget.selectedTime != null)
                Center(
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
                      const SizedBox(height: 20),
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