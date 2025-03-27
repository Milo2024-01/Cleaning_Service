import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../payment_upload.dart';

class GeneralCleaningCalculator extends StatefulWidget {
  final String? selectedDate;
  final String? selectedTime;

  const GeneralCleaningCalculator({
    super.key,
    this.selectedDate,
    this.selectedTime,
  });

  @override
  State<GeneralCleaningCalculator> createState() => _GeneralCleaningCalculatorState();
}

class _GeneralCleaningCalculatorState extends State<GeneralCleaningCalculator> {
  int hours = 1;
  final double ratePerHour = 350.0;
  final Logger _logger = Logger();

  double get totalCost => ratePerHour * hours;

  void _bookService() async {
    _logger.d('Booking initiated');

    if (widget.selectedDate == null || widget.selectedTime == null) {
      _showSnackbar('Please select date and time first');
      return;
    }

    try {
      final selectedDate = _parseDate(widget.selectedDate!);
      final selectedTime = _parseTime(widget.selectedTime!);

      if (!mounted) return;
      
      // Navigate to PaymentUploadScreen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentUploadScreen(
            totalCost: totalCost.toInt(),
            selectedDate: selectedDate,
            selectedTime: selectedTime,
            itemSize: 1,
            serviceLabel: 'General Cleaning',
          ),
        ),
      );
    } on FormatException catch (e) {
      _logger.e('Format error: $e');
      if (!mounted) return;
      _showSnackbar('Invalid date/time format. Please use HH:mm format (e.g., 14:30)');
    } catch (e) {
      _logger.e('Booking error: $e');
      if (!mounted) return;
      _showSnackbar('Error processing your booking: ${e.toString()}');
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      _logger.e('Date parsing error: $e');
      throw FormatException('Invalid date format. Expected yyyy-mm-dd');
    }
  }

  TimeOfDay _parseTime(String timeString) {
    try {
      // Handle both 24-hour and 12-hour formats
      if (timeString.contains(' ')) {
        return _parse12HourTime(timeString);
      }
      
      // Handle 24-hour format
      final parts = timeString.split(':');
      if (parts.length != 2) throw FormatException('Invalid time format');
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        throw FormatException('Time values out of range');
      }
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      _logger.e('Time parsing error: $e');
      throw FormatException('Invalid time format. Expected HH:mm or h:mm a');
    }
  }

  TimeOfDay _parse12HourTime(String timeString) {
    try {
      final timeParts = timeString.split(' ');
      if (timeParts.length != 2) throw FormatException('Invalid 12-hour format');
      
      final timeComponent = timeParts[0];
      final period = timeParts[1].toUpperCase();
      
      final components = timeComponent.split(':');
      if (components.length != 2) throw FormatException('Invalid time format');
      
      var hour = int.parse(components[0]);
      final minute = int.parse(components[1]);
      
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        throw FormatException('Time values out of range');
      }
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      _logger.e('12-hour time parsing error: $e');
      throw FormatException('Invalid 12-hour format. Expected h:mm AM/PM');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('General Cleaning Service'),
        backgroundColor: Colors.amber[700],
        elevation: 5,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade700, Colors.amber.shade400],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(2, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'General Cleaning',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'We offer routine cleaning services for homes, including dusting, mopping, and sanitizing bathrooms and kitchens.',
                          style: TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '💰 Rate: ₱350 per hour',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Cleaning Service Cost',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSlider(
                          icon: Icons.timer,
                          label: 'Hours',
                          value: hours.toDouble(),
                          min: 1,
                          max: 10,
                          onChanged: (value) => setState(() => hours = value.toInt()),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Total Cost: ₱${totalCost.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (widget.selectedDate != null && widget.selectedTime != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Text(
                          'Selected Date: ${widget.selectedDate}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                        Text(
                          'Selected Time: ${widget.selectedTime}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                Center(
                  child: ElevatedButton(
                    onPressed: _bookService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber[800]),
        const SizedBox(width: 10),
        Text('$label:', style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: value.toInt().toString(),
            activeColor: Colors.amber[700],
            inactiveColor: Colors.amber[100],
            onChanged: onChanged,
          ),
        ),
        Text(
          value.toInt().toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.amber[900],
          ),
        ),
      ],
    );
  }
}