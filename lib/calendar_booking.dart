import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'residential_cleaning/rcdecluretting_service.dart';
import 'residential_cleaning/rcconstructions_cleaning.dart';
import 'residential_cleaning/rcdeep_cleaning.dart';
import 'residential_cleaning/rcgeneral_cleaning.dart';
import 'residential_cleaning/rcglass_services.dart';
import 'residential_cleaning/rcgrease_cleaning.dart';
import 'specialized_cleaning/sccarinterior_cleaning.dart';
import 'specialized_cleaning/sccarpet_cleaning.dart';
import 'specialized_cleaning/scfurniture_cleaning.dart';
import 'specialized_cleaning/sclargeitem_clearning.dart';
import 'specialized_cleaning/scpestcontrol_service.dart';
import 'specialized_cleaning/scwatertank_cleaning.dart';

class CalendarBookingScreen extends StatefulWidget {
  final String serviceLabel;

  const CalendarBookingScreen({super.key, required this.serviceLabel});

  @override
  _CalendarBookingScreenState createState() => _CalendarBookingScreenState();
}

class _CalendarBookingScreenState extends State<CalendarBookingScreen> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  final DateTime _today = DateTime.now();
  final int _disabledDaysCount = 3; // Today + next 2 days (3 days total)

  @override
  void initState() {
    super.initState();
    // Set initial selected date to first available date after disabled period
    _selectedDate = _today.add(Duration(days: _disabledDaysCount));
  }

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

  bool _isDateDisabled(DateTime day) {
    // Disable today and the next (_disabledDaysCount - 1) days
    return day.isBefore(_today.add(Duration(days: _disabledDaysCount))) && 
           !isSameDay(day, _today.add(Duration(days: _disabledDaysCount)));
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
      'Post Construction Cleaning': (context) => ConstructionCleaningCalculator(
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
      'Car Interior Detailing': (context) => CarDetailingScreen(
            selectedDate: formattedDate,
            selectedTime: formattedTime,
          ),         
      'Carpet Cleaning': (context) => CarpetCleaningScreen(
            selectedDate: formattedDate,
            selectedTime: formattedTime,
          ),      
      'Furniture Cleaning': (context) => FurnitureCleaningScreen(
            selectedDate: formattedDate,
            selectedTime: formattedTime,
          ),
      'Large Item Cleaning': (context) => LargeItemCleaningPage(
            selectedDate: formattedDate,
            selectedTime: formattedTime,
          ),   
      'General Pest Control Services': (context) => PestControlPage(
            selectedDate: formattedDate,
            selectedTime: formattedTime,
          ),   
      'Water Tank Cleaning': (context) => WaterTankCleaningPage(
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime(2101),
                    focusedDay: _selectedDate,
                    selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!_isDateDisabled(selectedDay)) {
                        setState(() {
                          _selectedDate = selectedDay;
                        });
                      }
                    },
                    enabledDayPredicate: (day) => !_isDateDisabled(day),
                    calendarStyle: CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Colors.blueAccent, 
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.blueAccent.withOpacity(0.3), 
                        shape: BoxShape.circle,
                      ),
                      disabledDecoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      disabledTextStyle: TextStyle(color: Colors.grey[400]),
                      outsideDaysVisible: false,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Confirm Booking', 
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Note: Bookings are available starting from ${DateFormat('MMMM d').format(_today.add(Duration(days: _disabledDaysCount)))}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}