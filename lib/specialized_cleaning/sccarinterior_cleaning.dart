import 'package:flutter/material.dart';
import '../specialize_cleaning.dart';
import '../calendar_booking.dart';

void main() {
  runApp(const CarDetailingApp());
}

class CarDetailingApp extends StatelessWidget {
  const CarDetailingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CarDetailingScreen(),
    );
  }
}

class CarDetailingScreen extends StatefulWidget {
  const CarDetailingScreen({super.key});

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

  int get totalCost => services.fold<int>(0, (sum, item) {
        return sum +
            ((item['price'] as num).toInt() * (item['quantity'] as int));
      });

  int get totalItems => services.fold<int>(0, (sum, item) {
        return sum + (item['quantity'] as int);
      });

  void _increaseQuantity(int index) {
    setState(() {
      services[index]['quantity'] = (services[index]['quantity'] as int) + 1;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if ((services[index]['quantity'] as int) > 0) {
        services[index]['quantity'] = (services[index]['quantity'] as int) - 1;
      }
    });
  }

  void _navigateToBooking() {
    if (totalItems == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service before booking.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarBookingScreen(
          itemSize: totalItems,
          totalCost: totalCost,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                                    onPressed: () => _decreaseQuantity(index),
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
                                    onPressed: () => _increaseQuantity(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Total Cost: PHP ${totalCost.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _navigateToBooking,
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
