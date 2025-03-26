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
  // Color constants
  static const Color pendingColor = Colors.blue;
  static const Color confirmedColor = Colors.orange;
  static const Color completedColor = Colors.green;
  static const Color cancelledColor = Colors.grey;
  static const Color todayColor = Colors.purple;

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

  bool _canCancelBooking(DateTime bookingDate, String status) {
    final now = DateTime.now();
    final difference = bookingDate.difference(now);
    return difference.inHours > 48 && (status == 'pending' || status == 'confirmed');
  }

  Future<void> _cancelBooking(String docId) async {
    try {
      await _firestore.collection('bookings').doc(docId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking cancelled successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        _fetchBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    final bookingDate = booking['selectedDate'] as DateTime;
    final status = booking['status'] as String;
    final canCancel = _canCancelBooking(bookingDate, status);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 26), // Equivalent to black.withOpacity(0.1)
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              _buildModernDetailRow(Icons.cleaning_services, booking['serviceLabel']),
              _buildModernDetailRow(Icons.calendar_today, DateFormat('MMMM d, yyyy').format(bookingDate)),
              _buildModernDetailRow(Icons.access_time, booking['selectedTime']),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withAlpha(26), // ~10% opacity
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(status).withAlpha(77), // ~30% opacity
                    width: 1,
                  ),
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (canCancel)
                Text(
                  '⚠️ Cancellation possible until ${DateFormat('MMM d, h:mm a').format(bookingDate.subtract(const Duration(hours: 48)))}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                  if (canCancel) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _cancelBooking(booking['docId']);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Cancel Booking'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDetailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return completedColor;
      case 'confirmed':
        return confirmedColor;
      case 'cancelled':
        return cancelledColor;
      case 'pending':
      default:
        return pendingColor;
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

    switch (booking['status']) {
      case 'completed':
        return completedColor.withAlpha(51); // ~20% opacity
      case 'confirmed':
        return confirmedColor.withAlpha(51);
      case 'pending':
        return pendingColor.withAlpha(51);
      case 'cancelled':
        return cancelledColor.withAlpha(51);
      default:
        return Colors.transparent;
    }
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

    switch (booking['status']) {
      case 'completed':
        return completedColor;
      case 'confirmed':
        return confirmedColor;
      case 'pending':
        return pendingColor;
      case 'cancelled':
        return cancelledColor;
      default:
        return Colors.black;
    }
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
        color: isBooked ? _getDateColor(date) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? todayColor : Colors.grey.shade200,
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          if (isBooked)
            BoxShadow(
              color: Color.alphaBlend(
                _getTextColor(date).withAlpha(51), // ~20% opacity
                Colors.white,
              ),
              blurRadius: 6,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isBooked ? _getTextColor(date) : Colors.black87,
                  ),
                ),
                if (isBooked)
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: _getTextColor(date),
                  ),
              ],
            ),
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
        title: const Text(
          'My Bookings Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        shadowColor: Color.fromRGBO(103, 58, 183, 77), // deepPurple.withOpacity(0.3)
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(237, 231, 246, 1), // deepPurple.shade50
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 13), // black.withOpacity(0.05)
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => _changeMonth(-1),
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(103, 58, 183, 26), // deepPurple.withOpacity(0.1)
                          ),
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
                          style: IconButton.styleFrom(
                            backgroundColor: Color.fromRGBO(103, 58, 183, 26), // deepPurple.withOpacity(0.1)
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 13), // black.withOpacity(0.05)
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _WeekdayLabel('S'),
                        _WeekdayLabel('M'),
                        _WeekdayLabel('T'),
                        _WeekdayLabel('W'),
                        _WeekdayLabel('T'),
                        _WeekdayLabel('F'),
                        _WeekdayLabel('S'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 13), // black.withOpacity(0.05)
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: _buildCalendarGrid(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 13), // black.withOpacity(0.05)
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildStatusIndicator(pendingColor.withAlpha(51), pendingColor, 'Pending'),
                        _buildStatusIndicator(confirmedColor.withAlpha(51), confirmedColor, 'Confirmed'),
                        _buildStatusIndicator(completedColor.withAlpha(51), completedColor, 'Completed'),
                        _buildStatusIndicator(cancelledColor.withAlpha(51), cancelledColor, 'Cancelled'),
                        _buildStatusIndicator(Colors.white, todayColor, 'Today'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusIndicator(Color bgColor, Color iconColor, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: iconColor.withAlpha(77), // ~30% opacity
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 12, color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: iconColor,
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
      width: 32,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}