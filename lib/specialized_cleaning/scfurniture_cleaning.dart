import 'package:flutter/material.dart';
import '../specialize_cleaning.dart';
import '../calendar_booking.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final Map<String, int> services = {
    'Single Bed': 1000,
    'Twin Bed': 1250,
    'Queen Sized Bed': 1500,
    'King Sized Bed': 2000,
    'Regular Headboard': 500,
    'Medium Headboard': 800,
    'Large Headboard': 1000,
    'Sleeping Pillow': 150,
    'Decorative Pillow': 100,
    'Sofa': 400,
    'Office Chair': 150,
    'Executive Chair': 250,
    'Bench': 600,
    'Accent Chair': 800,
    'Queen Chair': 1000,
    'King Chair': 1200,
    'Couple Chair': 1500,
  };

  Map<String, int> quantities = {};

  int getTotalPrice() {
    int total = 0;
    services.forEach((key, price) {
      total += (quantities[key] ?? 0) * price;
    });
    return total;
  }

  int getTotalItems() {
    int totalItems = 0;
    quantities.forEach((key, value) {
      totalItems += value;
    });
    return totalItems;
  }

  void _navigateToBooking() {
    int totalItems = getTotalItems();

    if (totalItems == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service before booking.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Find the selected service label. In this case, you may want to pass a single service
    String selectedService = 'Furniture Cleaning';  // Adjust as needed for the service you're booking

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarBookingScreen(serviceLabel: selectedService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Furniture Cleaning Services",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
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
            colors: [Colors.blueAccent.shade700, Colors.blueAccent.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Furniture Cleaning - Deep cleaning of all types of furniture, ensuring a fresh and sanitized environment. Using premium Hydro Vacuum, special and anti-bacterial shampoo.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: services.keys.map((service) {
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "₱${services[service]}",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      if ((quantities[service] ?? 0) > 0) {
                                        quantities[service] =
                                            (quantities[service] ?? 0) - 1;
                                      }
                                    });
                                  },
                                ),
                                Text((quantities[service] ?? 0).toString(),
                                    style: const TextStyle(fontSize: 18)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      quantities[service] =
                                          (quantities[service] ?? 0) + 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Items:",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            "${getTotalItems()}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Price:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("₱${getTotalPrice()}",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _navigateToBooking, // Navigate to Calendar Booking
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text("Book Service",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
