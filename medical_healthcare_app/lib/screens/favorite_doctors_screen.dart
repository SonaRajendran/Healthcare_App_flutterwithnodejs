// lib/screens/favorite_doctors_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';
import 'package:medical_healthcare_app/models/doctor.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:medical_healthcare_app/widgets/doctor_card.dart';
// New: Import flutter_svg (for consistency)

class FavoriteDoctorsScreen extends StatefulWidget {
  const FavoriteDoctorsScreen({super.key});

  @override
  State<FavoriteDoctorsScreen> createState() => _FavoriteDoctorsScreenState();
}

class _FavoriteDoctorsScreenState extends State<FavoriteDoctorsScreen> {
  List<Doctor> _favoriteDoctors = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteDoctors();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavoriteDoctors();
  }

  void _loadFavoriteDoctors() {
    setState(() {
      _favoriteDoctors = DummyData.getFavoriteDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'My Favorite Doctors',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: _favoriteDoctors.isEmpty
          ? Center(
              child: Text(
                'No favorite doctors added yet.',
                style: AppStyles.bodyText1.copyWith(
                  color: AppColors.lightTextColor,
                ),
              ),
            )
          : ListView.builder(
              itemCount: _favoriteDoctors.length,
              itemBuilder: (context, index) {
                final doctor = _favoriteDoctors[index];
                return DoctorCard(
                  doctor: doctor,
                  onToggleFavorite: _loadFavoriteDoctors,
                );
              },
            ),
    );
  }
}
