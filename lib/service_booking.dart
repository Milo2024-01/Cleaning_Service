import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Forward declaration for LoginPage
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  // ignore: no_logic_in_create_state
  State<LoginPage> createState() => throw UnimplementedError();
}

class ServiceBookingPage extends StatefulWidget {
  const ServiceBookingPage({super.key});

  @override
  State<ServiceBookingPage> createState() => _ServiceBookingPageState();
}

class _ServiceBookingPageState extends State<ServiceBookingPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data!.docs[index];
              return ListTile(
                title: Text(booking['serviceType'] ?? 'Unknown Service'),
                subtitle: Text(booking['customerEmail'] ?? 'No email'),
              );
            },
          );
        },
      ),
    );
  }
}