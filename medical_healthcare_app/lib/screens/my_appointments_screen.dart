// lib/screens/my_appointments_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';
import 'package:medical_healthcare_app/models/appointment.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:intl/intl.dart';
import 'package:medical_healthcare_app/screens/appointment_form_screen.dart';
import 'package:medical_healthcare_app/utils/notification_service.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _completedAppointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAndSortAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is generally called when dependencies change, or after initState,
    // so it's a good place to ensure data is fresh.
    _loadAndSortAppointments();
  }

  Future<void> _loadAndSortAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Reload all data from DummyData (which will fetch from backend)
      await DummyData.loadData();
      // FIX: Use DummyData.getAppointments() instead of DummyData.appointments
      final allAppointments = DummyData.getAppointments();

      final now = DateTime.now();
      _upcomingAppointments =
          allAppointments
              .where((app) => app.date.isAfter(now) && app.status == 'Upcoming')
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      _completedAppointments =
          allAppointments
              .where(
                (app) =>
                    app.date.isBefore(now) ||
                    app.status == 'Completed' ||
                    app.status == 'Cancelled',
              )
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load appointments: ${e.toString()}';
        _isLoading = false;
      });
      print('Error in _loadAndSortAppointments: $_error');
    }
  }

  void _onCancelAppointment(String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Appointment', style: AppStyles.titleStyle),
          content: Text(
            'Are you sure you want to cancel this appointment?',
            style: AppStyles.bodyText1,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: AppStyles.buttonTextStyle.copyWith(
                  color: AppColors.lightTextColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await DummyData.cancelAppointment(
                    appointmentId,
                  ); // Use DummyData which calls service
                  await NotificationService.cancelAppointmentNotification(
                    appointmentId,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Appointment cancelled successfully.',
                        style: AppStyles.bodyText1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to cancel appointment: ${e.toString()}',
                        style: AppStyles.bodyText1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
                Navigator.of(context).pop();
                _loadAndSortAppointments(); // Reload and refresh UI
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Yes, Cancel', style: AppStyles.buttonTextStyle),
            ),
          ],
        );
      },
    );
  }

  void _onEditAppointment(Appointment appointment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentFormScreen(
          doctor: appointment.doctor,
          appointmentToEdit: appointment,
        ),
      ),
    ).then((_) {
      _loadAndSortAppointments(); // Reload and refresh UI when returning from edit screen
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading appointments: $_error',
                style: AppStyles.bodyText1.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadAndSortAppointments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'My Appointments',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Appointments', style: AppStyles.titleStyle),
            const SizedBox(height: 10),
            _upcomingAppointments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      'No upcoming appointments.',
                      style: AppStyles.bodyText2,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _upcomingAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _upcomingAppointments[index];
                      return AppointmentCard(
                        appointment: appointment,
                        onCancel: _onCancelAppointment,
                        onEdit: _onEditAppointment,
                      );
                    },
                  ),
            const SizedBox(height: 30),
            Text('Past Appointments', style: AppStyles.titleStyle),
            const SizedBox(height: 10),
            _completedAppointments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      'No past appointments.',
                      style: AppStyles.bodyText2,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _completedAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _completedAppointments[index];
                      return AppointmentCard(
                        appointment: appointment,
                        onCancel: null,
                        onEdit: null,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final Function(String)? onCancel;
  final Function(Appointment)? onEdit;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onCancel,
    this.onEdit,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return AppColors.lightTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: AppColors.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dr. ${appointment.doctor.name}',
                  style: AppStyles.cardTitleStyle,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.status,
                    style: AppStyles.bodyText2.copyWith(
                      color: _getStatusColor(appointment.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              appointment.doctor.specialty,
              style: AppStyles.cardSubtitleStyle,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEE, MMM d, yyyy').format(appointment.date),
                  style: AppStyles.bodyText1,
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: AppColors.iconColor,
                ),
                const SizedBox(width: 8),
                Text(appointment.time, style: AppStyles.bodyText1),
              ],
            ),
            if (appointment.status == 'Upcoming')
              Column(
                children: [
                  const Divider(height: 25, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (onEdit != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.primaryColor,
                            ),
                            label: Text(
                              'Edit',
                              style: AppStyles.buttonTextStyle.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            onPressed: () => onEdit!(appointment),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (onEdit != null && onCancel != null)
                        const SizedBox(width: 10),
                      if (onCancel != null)
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.redAccent,
                            ),
                            label: Text(
                              'Cancel',
                              style: AppStyles.buttonTextStyle.copyWith(
                                color: Colors.redAccent,
                              ),
                            ),
                            onPressed: () => onCancel!(appointment.id),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
