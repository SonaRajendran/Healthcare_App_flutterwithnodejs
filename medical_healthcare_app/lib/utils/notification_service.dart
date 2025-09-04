// lib/utils/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:medical_healthcare_app/models/appointment.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';
import 'package:timezone/data/latest.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  }

  static Future<void> scheduleAppointmentNotification(
    Appointment appointment,
  ) async {
    if (!DummyData.areNotificationsEnabled()) {
      print(
        'Notifications are globally disabled. Not scheduling for ${appointment.id}',
      );
      return;
    }

    final int notificationId = int.parse(appointment.id.substring(0, 9));

    DateTime appointmentDateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
    );

    final String timeString = appointment.time.toUpperCase().trim();
    final bool isPm = timeString.contains('PM');
    List<String> parts = timeString
        .replaceAll(RegExp(r'[APM]+'), '')
        .split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    if (isPm && hour != 12) {
      hour += 12;
    } else if (!isPm && hour == 12) {
      hour = 0;
    }

    appointmentDateTime = appointmentDateTime.add(
      Duration(hours: hour, minutes: minute),
    );

    final tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      appointmentDateTime.year,
      appointmentDateTime.month,
      appointmentDateTime.day,
      appointmentDateTime.hour,
      appointmentDateTime.minute,
    ).subtract(const Duration(minutes: 15));

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print(
        'Cannot schedule notification in the past for appointment ${appointment.id}',
      );
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'appointment_channel_id',
          'Appointment Reminders',
          channelDescription: 'Reminders for your medical appointments',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Upcoming Appointment!',
      'You have an appointment with Dr. ${appointment.doctor.name} at ${appointment.time} on ${appointment.date.day}/${appointment.date.month}.',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
    print(
      'Scheduled notification for appointment ${appointment.id} at $scheduledDate',
    );
  }

  static Future<void> cancelAppointmentNotification(
    String appointmentId,
  ) async {
    final int notificationId = int.parse(appointmentId.substring(0, 9));
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    print('Cancelled notification for appointment $appointmentId');
  }

  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('Cancelled all scheduled notifications.');
  }

  static Future<void> rescheduleAllUpcomingNotifications() async {
    final now = DateTime.now();
    final upcomingAppointments = DummyData.getAppointments()
        .where((app) => app.date.isAfter(now) && app.status == 'Upcoming')
        .toList();

    for (var appointment in upcomingAppointments) {
      await scheduleAppointmentNotification(appointment);
    }
    print('Rescheduled ${upcomingAppointments.length} upcoming notifications.');
  }
}
