import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'residential_cleaning/rcdecluretting_service.dart';
import 'residential_cleaning/rcconstructions_cleaning.dart';
import 'residential_cleaning/rcdeep_cleaning.dart';
import 'residential_cleaning/rcgeneral_cleaning.dart';
import 'residential_cleaning/rcglass_services.dart';
import 'residential_cleaning/rcgrease_cleaning.dart';

class CalendarBookingScreen extends StatefulWidget {
  final String serviceLabel;

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

  final serviceScreens = {
    'General Cleaning': (context) => GeneralCleaningCalculator(
          selectedDate: formattedDate,
          selectedTime: formattedTime,
        ),
    'Post Construction Cleaning': (context) => RCConstructionCleaningApp(
          selectedDate: formattedDate,
          selectedTime: formattedTime,
        ),
    'Deep Cleaning': (context) => DeepCleaningCalculator(
          selectedDate: formattedDate,
          selectedTime: formattedTime,
        ),
    'Grease Trap Cleaning': (context) => GreaseTrapCleaningCalculator(
          selectedDate: formattedDate,
          selectedTime: formattedTime,
        ),
    'Decluttering Services': (context) => RCCDeclutteringServicePage(
          selectedDate: formattedDate,
          selectedTime: formattedTime,
        ),
    'Glass Detailing Services': (context) => GlassDetailingCalculator(
          selectedDate: formattedDate,
          selectedTime: formattedTime,
        ),
  };

  final screenBuilder = serviceScreens[widget.serviceLabel];

  if (screenBuilder != null) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: screenBuilder),
    );
  } else {
    Navigator.pop(context, {'date': formattedDate, 'time': formattedTime});
  }
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
        title: Text('${widget.serviceLabel} Booking'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
                      leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.blueAccent),
                      rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.blueAccent),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm Booking', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
