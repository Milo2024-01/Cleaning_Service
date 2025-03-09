import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceBookingPage extends StatefulWidget {
  const ServiceBookingPage({super.key});

  @override
  _ServiceBookingPageState createState() => _ServiceBookingPageState();
}

class _ServiceBookingPageState extends State<ServiceBookingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Bookings'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('service_bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final data = booking.data() as Map<String, dynamic>;

              return _buildBookingCard(data, booking.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> data, String bookingId) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${data['serviceName'] ?? 'N/A'}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('User: ${data['userEmail'] ?? 'N/A'}'),
            Text('Total Cost: ₱${data['totalCost'] ?? 'N/A'}'),
            Text('Address: ${data['address'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
