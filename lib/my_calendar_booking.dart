import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingCalendar extends StatefulWidget {
  const BookingCalendar({super.key});

  @override
  _BookingCalendarState createState() => _BookingCalendarState();
}

class _BookingCalendarState extends State<BookingCalendar> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime _currentDate = DateTime.now();
  List<Map<String, dynamic>> _bookings = []; // Changed to store booking data
  String? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (_currentUserId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final bookings = snapshot.docs.map((doc) {
        final data = doc.data();
        dynamic dateData = data['selectedDate'];
        
        DateTime date;
        if (dateData is Timestamp) {
          date = dateData.toDate();
        } else if (dateData is String) {
          date = DateTime.parse(dateData);
        } else {
          date = DateTime.now();
        }
        
        return {
          'date': DateTime(date.year, date.month, date.day),
          'status': data['status'] ?? 'pending',
          'docId': doc.id,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _getDateColor(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final booking = _bookings.firstWhere(
      (booking) {
        final bookedDate = booking['date'] as DateTime;
        return bookedDate.year == normalizedDate.year &&
               bookedDate.month == normalizedDate.month &&
               bookedDate.day == normalizedDate.day;
      },
      orElse: () => {'status': ''},
    );

    if (booking['status'] == 'completed') {
      return Colors.green[100]!;
    } else if (booking['status'] == 'pending') {
      return Colors.red[100]!;
    }
    return Colors.transparent;
  }

  Color _getTextColor(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final booking = _bookings.firstWhere(
      (booking) {
        final bookedDate = booking['date'] as DateTime;
        return bookedDate.year == normalizedDate.year &&
               bookedDate.month == normalizedDate.month &&
               bookedDate.day == normalizedDate.day;
      },
      orElse: () => {'status': ''},
    );

    if (booking['status'] == 'completed') {
      return Colors.green[800]!;
    } else if (booking['status'] == 'pending') {
      return Colors.red[800]!;
    }
    return Colors.black;
  }

  bool _isDateBooked(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _bookings.any((booking) {
      final bookedDate = booking['date'] as DateTime;
      return bookedDate.year == normalizedDate.year &&
             bookedDate.month == normalizedDate.month &&
             bookedDate.day == normalizedDate.day;
    });
  }

  Widget _buildDateCell(int day) {
    final date = DateTime(_currentDate.year, _currentDate.month, day);
    final isBooked = _isDateBooked(date);
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isBooked ? _getDateColor(date) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isBooked ? _getTextColor(date) : Colors.black,
              ),
            ),
            if (isBooked) Icon(
              Icons.bookmark,
              size: 12,
              color: _getTextColor(date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: daysInMonth + firstWeekday - 1,
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) return const SizedBox.shrink();
        final day = index - firstWeekday + 2;
        return _buildDateCell(day);
      },
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + delta, 1);
      _fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings Calendar'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_currentDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _WeekdayLabel('Sun'),
                      _WeekdayLabel('Mon'),
                      _WeekdayLabel('Tue'),
                      _WeekdayLabel('Wed'),
                      _WeekdayLabel('Thu'),
                      _WeekdayLabel('Fri'),
                      _WeekdayLabel('Sat'),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildCalendarGrid(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: Colors.red[100],
                        child: const Icon(Icons.bookmark, size: 12, color: Colors.red),
                      ),
                      const SizedBox(width: 8),
                      const Text('Pending', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 16),
                      Container(
                        width: 16,
                        height: 16,
                        color: Colors.green[100],
                        child: const Icon(Icons.bookmark, size: 12, color: Colors.green),
                      ),
                      const SizedBox(width: 8),
                      const Text('Completed', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}