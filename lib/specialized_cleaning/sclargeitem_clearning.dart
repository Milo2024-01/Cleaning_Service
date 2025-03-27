import 'package:flutter/material.dart';
import '../payment_upload.dart';
import '../specialize_cleaning.dart';

class LargeItemCleaningPage extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const LargeItemCleaningPage({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  _LargeItemCleaningPageState createState() => _LargeItemCleaningPageState();
}

class _LargeItemCleaningPageState extends State<LargeItemCleaningPage> {
  static const double pricePerItem = 2000.0;
  int itemCount = 1;

  double get totalPrice => pricePerItem * itemCount;

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
            child: const Text('OK', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  void _bookService() {
    // Check if total exceeds 10,000
    if (totalPrice > 10000) {
      _showLargeOrderDialog();
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
          totalCost: totalPrice.toInt(),
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          itemSize: itemCount,
          serviceLabel: 'Large Item Cleaning',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showWarning = totalPrice > 10000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Large Item Cleaning'),
        backgroundColor: Colors.amber[700],
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
            colors: [Colors.amber.shade700, Colors.amber.shade400],
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
                        'Large Item Cleaning',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Professional cleaning for large items like life-size stuffed toys, ensuring they remain in pristine condition using specialized equipment and cleaning solutions.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Price per Item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '₱${pricePerItem.toStringAsFixed(2)} per item',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.red[700]),
                            onPressed: () {
                              if (itemCount > 1) {
                                setState(() {
                                  itemCount--;
                                });
                              }
                            },
                          ),
                          Text(
                            '$itemCount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.green[700]),
                            onPressed: () {
                              setState(() {
                                itemCount++;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Text(
                            'Total Cost: ₱${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: showWarning ? Colors.red : Colors.green[700],
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
                              color: Colors.amber[900],
                            ),
                          ),
                        if (widget.selectedTime != null)
                          Text(
                            'Selected Time: ${widget.selectedTime}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[900],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _bookService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Book Cleaning',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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