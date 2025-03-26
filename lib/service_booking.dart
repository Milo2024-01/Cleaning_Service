import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'main.dart'; // Import LoginPage file

class ServiceBookingPage extends StatefulWidget {
  const ServiceBookingPage({super.key});

  @override
  State<ServiceBookingPage> createState() => _ServiceBookingPageState();
}

class _ServiceBookingPageState extends State<ServiceBookingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _dateFormat = DateFormat('MMM d, yyyy');
  
  // Search and filter variables
  String _searchQuery = '';
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _statusFilter;
  final TextEditingController _searchController = TextEditingController();

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

  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(docId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: ${e.toString()}')),
      );
    }
  }

  String _formatDate(dynamic dateData) {
    try {
      if (dateData is Timestamp) {
        return _dateFormat.format(dateData.toDate());
      } else if (dateData is String) {
        return _dateFormat.format(DateTime.parse(dateData));
      }
      return 'Invalid date';
    } catch (e) {
      return 'Date error';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _fromDate = null;
      _toDate = null;
      _statusFilter = null;
    });
  }

  bool _matchesFilters(Map<String, dynamic> data) {
    // Search by name
    final userName = data['firstName']?.toString().toLowerCase() ?? '';
    if (_searchQuery.isNotEmpty && 
        !userName.contains(_searchQuery.toLowerCase())) {
      return false;
    }

    // Filter by status
    final status = data['status']?.toString().toLowerCase() ?? '';
    if (_statusFilter != null && status != _statusFilter!.toLowerCase()) {
      return false;
    }

    // Filter by date range
    try {
      dynamic dateData = data['selectedDate'];
      DateTime bookingDate;
      
      if (dateData is Timestamp) {
        bookingDate = dateData.toDate();
      } else if (dateData is String) {
        bookingDate = DateTime.parse(dateData);
      } else {
        return false;
      }

      if (_fromDate != null && bookingDate.isBefore(_fromDate!)) {
        return false;
      }
      if (_toDate != null && bookingDate.isAfter(_toDate!)) {
        return false;
      }
    } catch (e) {
      return false;
    }

    return true;
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
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),
                
                // Date Range and Status Filters
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selectDate(context, true),
                        child: Text(
                          _fromDate == null 
                            ? 'From Date' 
                            : _dateFormat.format(_fromDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text(
                          _toDate == null 
                            ? 'To Date' 
                            : _dateFormat.format(_toDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      hint: const Text('Status'),
                      value: _statusFilter,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: const Text('All Status'),
                        ),
                        const DropdownMenuItem<String>(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        const DropdownMenuItem<String>(
                          value: 'confirmed',
                          child: Text('Confirmed'),
                        ),
                        const DropdownMenuItem<String>(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        const DropdownMenuItem<String>(
                          value: 'cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (value) => setState(() => _statusFilter = value),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_searchQuery.isNotEmpty || _fromDate != null || _toDate != null || _statusFilter != null)
                  OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Bookings List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('bookings').orderBy('selectedDate').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading bookings\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data!.docs;

                if (bookings.isEmpty) {
                  return const Center(
                    child: Text(
                      'No bookings available',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                // Apply filters
                final filteredBookings = bookings.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _matchesFilters(data);
                }).toList();

                if (filteredBookings.isEmpty) {
                  return const Center(
                    child: Text(
                      'No bookings match your filters',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    final data = booking.data() as Map<String, dynamic>;

                    final docId = booking.id;
                    final userName = data['firstName']?.toString() ?? 'Unknown User';
                    final serviceLabel = data['serviceLabel']?.toString() ?? 'Unknown Service';
                    final bookingDate = _formatDate(data['selectedDate']);
                    final bookingTime = data['selectedTime']?.toString() ?? 'No Time';
                    final price = data['totalCost']?.toString() ?? '0';
                    final status = data['status']?.toString() ?? 'Pending';
                    final statusColor = _getStatusColor(status);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withAlpha(51),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor.withAlpha(102),
                                    ),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              serviceLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 4),
                                Text(bookingDate),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 4),
                                Text(bookingTime),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$$price',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) => _updateStatus(docId, value),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: "confirmed",
                                      child: Text("Confirm Booking"),
                                    ),
                                    const PopupMenuItem(
                                      value: "completed",
                                      child: Text("Mark as Completed"),
                                    ),
                                    const PopupMenuItem(
                                      value: "cancelled",
                                      child: Text("Cancel Booking"),
                                    ),
                                  ],
                                  icon: const Icon(Icons.more_vert),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}