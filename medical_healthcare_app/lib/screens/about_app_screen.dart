import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'About App',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 10),
                  Text('Medical Healthcare App', style: AppStyles.headline1),
                  const SizedBox(height: 5),
                  Text('Version 1.0.0', style: AppStyles.bodyText2),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('About', style: AppStyles.titleStyle),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'This app helps you manage your healthcare appointments, connect with doctors, and stay on top of your health. Features include appointment booking, doctor profiles, messaging, and personalized health tracking.',
                  style: AppStyles.bodyText1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Developer', style: AppStyles.titleStyle),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developed by: Medical App Team',
                      style: AppStyles.bodyText1,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Contact: support@medicalapp.com',
                      style: AppStyles.bodyText2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Features', style: AppStyles.titleStyle),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFeatureItem('Appointment Booking'),
                    _buildFeatureItem('Doctor Profiles'),
                    _buildFeatureItem('Secure Messaging'),
                    _buildFeatureItem('Notification Reminders'),
                    _buildFeatureItem('Health Records'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Privacy Policy', style: AppStyles.titleStyle),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.privacy_tip, color: AppColors.iconColor),
                title: Text('View Privacy Policy', style: AppStyles.bodyText1),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: AppColors.lightTextColor,
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy not implemented yet.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20),
          const SizedBox(width: 10),
          Text(feature, style: AppStyles.bodyText1),
        ],
      ),
    );
  }
}
