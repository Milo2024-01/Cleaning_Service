import 'package:flutter/material.dart';
import '../payment_upload.dart';
import '../specialize_cleaning.dart';

class CarDetailingScreen extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const CarDetailingScreen({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  State<CarDetailingScreen> createState() => _CarDetailingScreenState();
}

class _CarDetailingScreenState extends State<CarDetailingScreen> {
  final List<Map<String, dynamic>> services = [
    {'type': 'Hatchback, Sedan, Coupe', 'price': 2500, 'quantity': 0},
    {'type': 'AUV, MPV, SUV, Pick Up', 'price': 3500, 'quantity': 0},
    {'type': 'Family Van', 'price': 5500, 'quantity': 0},
    {'type': 'Super Van', 'price': 7500, 'quantity': 0},
    {'type': 'Bus (60 Seater)', 'price': 20000, 'quantity': 0},
  ];

  // Define text styles
  final TextStyle subHeaderStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.teal,
  );

  int get totalCost => services.fold<int>(0, (sum, item) {
        return sum + ((item['price'] as num).toInt() * (item['quantity'] as int));
      });

  int get totalItems => services.fold<int>(0, (sum, item) {
        return sum + (item['quantity'] as int);
      });

  void _updateQuantity(int index, int change) {
    setState(() {
      final newQuantity = services[index]['quantity'] + change;
      services[index]['quantity'] = newQuantity >= 0 ? newQuantity : 0;
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
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  void _navigateToPayment() {
    if (totalItems == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service before booking.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check if total exceeds 10,000
    if (totalCost > 10000) {
      _showLargeOrderDialog();
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
      selectedTime = const TimeOfDay(hour: 12, minute: 0);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentUploadScreen(
          totalCost: totalCost,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          itemSize: totalItems,
          serviceLabel: 'Car Interior Detailing',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showWarning = totalCost > 10000;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Car Interior Detailing',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => SpecializeCleaningPage()),
              );
            }
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade800, Colors.teal.shade200],
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
                        'Car Interior Detailing Service',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Thorough cleaning of vehicle interiors, ensuring a fresh and sanitized environment.',
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: List.generate(services.length, (index) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                services[index]['type'],
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                              subtitle: Text(
                                'PHP ${services[index]['price']} per unit',
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.teal),
                                    onPressed: () => _updateQuantity(index, -1),
                                  ),
                                  Text(
                                    '${services[index]['quantity']}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.teal),
                                    onPressed: () => _updateQuantity(index, 1),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Text(
                            'Total Cost: PHP ${totalCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: showWarning ? Colors.red : Colors.teal,
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
                      const SizedBox(height: 30),
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
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _navigateToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
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