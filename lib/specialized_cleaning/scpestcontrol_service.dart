import 'package:flutter/material.dart';
import '../payment_upload.dart';
import '../specialize_cleaning.dart';

class PestControlPage extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const PestControlPage({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  _PestControlPageState createState() => _PestControlPageState();
}

class _PestControlPageState extends State<PestControlPage> {
  final TextEditingController _areaController = TextEditingController();
  final int pricePerSqm = 65; // ₱65 per sqm
  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    _areaController.addListener(_updateTotalCost);
  }

  @override
  void dispose() {
    _areaController.removeListener(_updateTotalCost);
    _areaController.dispose();
    super.dispose();
  }

  void _updateTotalCost() {
    setState(() {
      double areaSize = double.tryParse(_areaController.text) ?? 0;
      _totalCost = areaSize * pricePerSqm;
    });
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
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _bookService() {
    double areaSize = double.tryParse(_areaController.text) ?? 0;

    if (areaSize <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid area size.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check if total exceeds 10,000
    if (_totalCost > 10000) {
      _showLargeOrderDialog();
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
          totalCost: _totalCost.toInt(),
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          itemSize: areaSize.round(),
          serviceLabel: 'General Pest Control',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showWarning = _totalCost > 10000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Pest Control'),
        backgroundColor: Colors.red[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SpecializeCleaningPage()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade700, Colors.red.shade400],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'General Pest Control Services',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'General pest control solutions to manage and eliminate common household pests. FDA and DOH Approved.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                '₱$pricePerSqm per sqm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _areaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter Area Size (sqm)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Text(
                    'Total Cost: ₱${_totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: showWarning ? Colors.red : Colors.white,
                    ),
                  ),
                  if (showWarning)
                    const Text(
                      '(Visit shop for payment)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.selectedDate != null || widget.selectedTime != null)
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (widget.selectedDate != null)
                          Text(
                            'Selected Date: ${widget.selectedDate}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                        if (widget.selectedTime != null)
                          Text(
                            'Selected Time: ${widget.selectedTime}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
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
                    backgroundColor: Colors.red[700],
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
              const SizedBox(height: 40),
              Center(
                child: Icon(
                  Icons.pest_control,
                  size: 100,
                  color: Colors.red[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}