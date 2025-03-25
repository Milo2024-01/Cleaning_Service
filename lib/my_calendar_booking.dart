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
  List<Map<String, dynamic>> _bookings = [];
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
          'serviceLabel': data['serviceLabel'] ?? 'Unknown Service',
          'selectedTime': data['selectedTime'] ?? 'Unknown Time',
          'selectedDate': date,
          'createdAt': data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate() 
              : DateTime.now(),
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

  bool _canCancelBooking(DateTime bookingDate) {
    final now = DateTime.now();
    final difference = bookingDate.difference(now);
    return difference.inHours > 48;
  }

  Future<void> _cancelBooking(String docId) async {
    try {
      await _firestore.collection('bookings').doc(docId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled successfully')),
        );
        _fetchBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel booking: $e')),
        );
      }
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final bookingDate = booking['selectedDate'] as DateTime;
    final canCancel = _canCancelBooking(bookingDate) && booking['status'] == 'pending';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Service:', booking['serviceLabel']),
            _buildDetailRow('Date:', DateFormat('MMMM d, yyyy').format(bookingDate)),
            _buildDetailRow('Time:', booking['selectedTime']),
            _buildDetailRow('Status:', booking['status'].toString().toUpperCase(),
              color: booking['status'] == 'completed' 
                  ? Colors.green 
                  : booking['status'] == 'pending' 
                      ? Colors.orange 
                      : Colors.red),
            const SizedBox(height: 16),
            if (canCancel)
              Text(
                'You can cancel this booking until ${DateFormat('MMM d, h:mm a').format(bookingDate.subtract(const Duration(hours: 48)))}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (canCancel)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelBooking(booking['docId']);
              },
              child: const Text('Cancel Booking', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
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
    } else if (booking['status'] == 'cancelled') {
      return Colors.grey[300]!;
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
    } else if (booking['status'] == 'cancelled') {
      return Colors.grey[800]!;
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

    return GestureDetector(
      onTap: () {
        if (isBooked) {
          final booking = _bookings.firstWhere((b) {
            final bookedDate = b['date'] as DateTime;
            return bookedDate.year == date.year &&
                   bookedDate.month == date.month &&
                   bookedDate.day == date.day;
          });
          _showBookingDetails(booking);
        }
      },
      child: Container(
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
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    children: [
                      _buildStatusIndicator(Colors.red[100]!, Colors.red, 'Pending'),
                      _buildStatusIndicator(Colors.green[100]!, Colors.green, 'Completed'),
                      _buildStatusIndicator(Colors.grey[300]!, Colors.grey, 'Cancelled'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatusIndicator(Color bgColor, Color iconColor, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: bgColor,
          child: Icon(Icons.bookmark, size: 12, color: iconColor),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
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