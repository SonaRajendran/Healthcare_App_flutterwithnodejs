// lib/screens/appointment_form_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/models/doctor.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';
import 'package:medical_healthcare_app/models/appointment.dart';
import 'package:intl/intl.dart';
import 'package:medical_healthcare_app/utils/notification_service.dart';

class AppointmentFormScreen extends StatefulWidget {
  final Doctor doctor;
  final Appointment? appointmentToEdit;

  const AppointmentFormScreen({
    super.key,
    required this.doctor,
    this.appointmentToEdit,
  });

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.appointmentToEdit != null) {
      _selectedDate = widget.appointmentToEdit!.date;
      final format = DateFormat.jm();
      _selectedTime = TimeOfDay.fromDateTime(
        format.parse(widget.appointmentToEdit!.time),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      // Allow past dates for editing existing, but not for new upcoming appointments
      firstDate: widget.appointmentToEdit != null
          ? DateTime.now().subtract(const Duration(days: 365 * 5))
          : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.textColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
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

  void _saveAppointment() async {
    if (_selectedDate == null || _selectedTime == null) {
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

    try {
      if (widget.appointmentToEdit != null) {
        // Editing an existing appointment
        final updatedAppointment = Appointment(
          id: widget.appointmentToEdit!.id,
          doctor: widget.doctor,
          date: _selectedDate!,
          time: _selectedTime!.format(context),
          status: widget.appointmentToEdit!.status, // Keep existing status
        );
        await DummyData.updateAppointment(
          updatedAppointment,
        ); // Use DummyData which calls service

        await NotificationService.cancelAppointmentNotification(
          updatedAppointment.id,
        );
        await NotificationService.scheduleAppointmentNotification(
          updatedAppointment,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment updated successfully!',
              style: AppStyles.bodyText1.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      } else {
        // Creating a new appointment
        final newAppointment = Appointment(
          id: DateTime.now().microsecondsSinceEpoch
              .toString(), // ID will be overwritten by backend
          doctor: widget.doctor,
          date: _selectedDate!,
          time: _selectedTime!.format(context),
          status: 'Upcoming',
        );
        await DummyData.addAppointment(
          newAppointment,
        ); // Use DummyData which calls service

        await NotificationService.scheduleAppointmentNotification(
          newAppointment,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appointment booked with Dr. ${widget.doctor.name} on '
              '${DateFormat('dd/MM/yyyy').format(_selectedDate!)} at ' // Use formatted date for message
              '${_selectedTime!.format(context)}.',
              style: AppStyles.bodyText1.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryColor,
          ),
        );
      }
      Navigator.of(context).pop(); // Navigate back
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving appointment: ${e.toString()}',
            style: AppStyles.bodyText1.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String screenTitle = widget.appointmentToEdit != null
        ? 'Edit Appointment'
        : 'Book Appointment';
    final String buttonText = widget.appointmentToEdit != null
        ? 'Save Changes'
        : 'Confirm Appointment';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          screenTitle,
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For Doctor:', style: AppStyles.titleStyle),
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
                          : DateFormat('dd/MM/yyyy').format(_selectedDate!),
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Text(buttonText, style: AppStyles.buttonTextStyle),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
