// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart'; // New: Import DummyData
import 'package:medical_healthcare_app/utils/notification_service.dart'; // New: Import NotificationService
import 'package:medical_healthcare_app/screens/privacy_security_screen.dart';
import 'package:medical_healthcare_app/screens/about_app_screen.dart';

class SettingsScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = DummyData.areNotificationsEnabled();
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });
    await DummyData.setNotificationsEnabled(value); // Persist the setting

    if (value) {
      // If notifications are enabled, reschedule all upcoming ones
      await NotificationService.rescheduleAllUpcomingNotifications();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Appointment reminders enabled.')));
    } else {
      // If disabled, cancel all existing notifications
      await NotificationService.cancelAllNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment reminders disabled.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Settings', style: AppStyles.titleStyle),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: AppColors.iconColor,
                    ),
                    title: Text(
                      'Notification Preferences',
                      style: AppStyles.bodyText1,
                    ),
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                      activeColor: AppColors.primaryColor,
                    ),
                    onTap: () {
                      // Tapping the list tile can also toggle the switch
                      _toggleNotifications(!_notificationsEnabled);
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.security, color: AppColors.iconColor),
                    title: Text(
                      'Privacy & Security',
                      style: AppStyles.bodyText1,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.lightTextColor,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySecurityScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: AppColors.iconColor,
                    ),
                    title: Text('About App', style: AppStyles.bodyText1),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.lightTextColor,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutAppScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
