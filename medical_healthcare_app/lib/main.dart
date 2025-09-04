// lib/main.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/screens/home_screen.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical_healthcare_app/utils/notification_service.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotifications();
  await DummyData.loadData(); // Load data from SharedPreferences and backend
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Healthcare App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          color: AppColors.primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
