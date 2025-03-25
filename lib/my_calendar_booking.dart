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
  List<DateTime> _bookedDates = [];
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

      final dates = snapshot.docs.map((doc) {
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
        
        return DateTime(date.year, date.month, date.day);
      }).toList();

      if (mounted) {
        setState(() {
          _bookedDates = dates;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isDateBooked(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _bookedDates.any((bookedDate) => 
      bookedDate.year == normalizedDate.year &&
      bookedDate.month == normalizedDate.month &&
      bookedDate.day == normalizedDate.day
    );
  }

  Widget _buildDateCell(int day) {
    final date = DateTime(_currentDate.year, _currentDate.month, day);
    final isBooked = _isDateBooked(date);
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isBooked ? Colors.red[100] : Colors.transparent,
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
                color: isBooked ? Colors.red[800] : Colors.black,
              ),
            ),
            if (isBooked) const Icon(Icons.bookmark, size: 12, color: Colors.red),
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
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Booked dates', style: TextStyle(fontSize: 14)),
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