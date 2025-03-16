import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarBookingScreen extends StatefulWidget {
  final String serviceLabel; // Receives service name from clicked icon

  const CalendarBookingScreen({super.key, required this.serviceLabel});

  @override
  _CalendarBookingScreenState createState() => _CalendarBookingScreenState();
}

class _CalendarBookingScreenState extends State<CalendarBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _confirmBooking() {
    if (_selectedTime == null) {
      _showSnackbar('Please select a time for your booking.');
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    String formattedTime = _selectedTime!.format(context);

    // Navigate to the confirmation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          serviceLabel: widget.serviceLabel,
          selectedDate: formattedDate,
          selectedTime: formattedTime,
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.serviceLabel} Booking', // Display the clicked service label
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Calendar Selection
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime(2101),
                    focusedDay: _selectedDate,
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                      // ignore: deprecated_member_use
                      todayDecoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.3), shape: BoxShape.circle),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.blueAccent),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.blueAccent),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Time Selection
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  onTap: _pickTime,
                  leading: const Icon(Icons.access_time, color: Colors.blueAccent),
                  title: Text(
                    _selectedTime == null ? 'Select Time' : 'Selected: ${_selectedTime!.format(context)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 30),

              // Confirm Booking Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: const Text('Confirm Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Booking Confirmation Screen
class BookingConfirmationScreen extends StatelessWidget {
  final String serviceLabel;
  final String selectedDate;
  final String selectedTime;

  const BookingConfirmationScreen({
    super.key,
    required this.serviceLabel,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmation'), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: $serviceLabel', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('Date: $selectedDate', style: const TextStyle(fontSize: 18)),
            Text('Time: $selectedTime', style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 30),

            // Button to proceed
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Home', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
