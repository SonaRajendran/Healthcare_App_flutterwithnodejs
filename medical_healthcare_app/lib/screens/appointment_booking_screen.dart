// lib/screens/appointment_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/models/doctor.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart'; // New: Import DummyData
import 'package:medical_healthcare_app/models/appointment.dart'; // New: Import Appointment model

class AppointmentBookingScreen extends StatefulWidget {
  final Doctor doctor;

  const AppointmentBookingScreen({super.key, required this.doctor});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ), // Allow booking up to one year in advance
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: AppColors.textColor, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Function to show the time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: AppColors.textColor, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Function to handle appointment booking
  void _bookAppointment() {
    if (_selectedDate == null || _selectedTime == null) {
      // Show an error message if date or time is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select both a date and a time for the appointment.',
            style: AppStyles.bodyText1.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // New: Create and add the new appointment to DummyData
    final newAppointment = Appointment(
      id: DateTime.now().microsecondsSinceEpoch.toString(), // Simple unique ID
      doctor: widget.doctor,
      date: _selectedDate!,
      time: _selectedTime!.format(context),
      status: 'Upcoming',
    );
    DummyData.addAppointment(newAppointment);

    final String confirmationMessage =
        'Appointment booked with Dr. ${widget.doctor.name} on '
        '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at '
        '${_selectedTime!.format(context)}.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          confirmationMessage,
          style: AppStyles.bodyText1.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
    );

    // Navigate back to the doctor detail screen or home screen
    // Using `Navigator.pop()` will rebuild the previous screen if it was a StatefulWidget
    // which will then cause MyAppointmentsScreen to re-sort and display new data.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Book Appointment',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking for:', style: AppStyles.titleStyle),
            const SizedBox(height: 5),
            Text(
              'Dr. ${widget.doctor.name} - ${widget.doctor.specialty}',
              style: AppStyles.subtitleStyle,
            ),
            const SizedBox(height: 30),
            Text('Select Date:', style: AppStyles.titleStyle),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Choose Date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: AppStyles.bodyText1,
                    ),
                    Icon(Icons.calendar_today, color: AppColors.iconColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Select Time:', style: AppStyles.titleStyle),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime == null
                          ? 'Choose Time'
                          : _selectedTime!.format(context),
                      style: AppStyles.bodyText1,
                    ),
                    Icon(Icons.access_time, color: AppColors.iconColor),
                  ],
                ),
              ),
            ),
            const Spacer(), // Pushes the button to the bottom
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Confirm Appointment',
                  style: AppStyles.buttonTextStyle,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
