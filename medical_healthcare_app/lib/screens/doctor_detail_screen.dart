// lib/screens/doctor_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medical_healthcare_app/models/doctor.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:medical_healthcare_app/screens/appointment_form_screen.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;
  final VoidCallback onToggleFavorite;

  const DoctorDetailScreen({
    super.key,
    required this.doctor,
    required this.onToggleFavorite,
  });

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late bool _isFavorite;

  bool _isSvg(String? url) {
    return url != null && url.toLowerCase().endsWith('.svg');
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = DummyData.isDoctorFavorite(widget.doctor.id);
  }

  void _toggleFavoriteStatus() {
    setState(() {
      DummyData.toggleFavorite(widget.doctor.id);
      _isFavorite = !_isFavorite;
    });
    widget.onToggleFavorite();
  }

  @override
  Widget build(BuildContext context) {
    Widget doctorImage;
    if (widget.doctor.imageUrl != null) {
      if (_isSvg(widget.doctor.imageUrl)) {
        doctorImage = SvgPicture.network(
          widget.doctor.imageUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.person, color: Colors.grey, size: 50),
          ),
        );
      } else {
        doctorImage = Image.network(
          widget.doctor.imageUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.person, color: Colors.grey, size: 50),
          ),
        );
      }
    } else {
      doctorImage = Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(Icons.person, color: Colors.grey, size: 50),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Doctor Details',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavoriteStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Header Section
            Container(
              color: AppColors.primaryColor,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: doctorImage,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.name,
                          style: AppStyles.headline1.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.doctor.specialty,
                          style: AppStyles.subtitleStyle.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.solidStar,
                              color: AppColors.ratingColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.doctor.rating.toString(),
                              style: AppStyles.bodyText1.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Icon(
                              FontAwesomeIcons.briefcaseMedical,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.doctor.experience ?? 'N/A',
                              style: AppStyles.bodyText1.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About Doctor Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Doctor', style: AppStyles.titleStyle),
                  const SizedBox(height: 10),
                  Text(
                    widget.doctor.bio ?? 'No bio available.',
                    style: AppStyles.bodyText1,
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  Text('Availability', style: AppStyles.titleStyle),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            widget.doctor.availableTime ?? 'Not specified',
                            style: AppStyles.bodyText1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AppointmentFormScreen(doctor: widget.doctor),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            child: Text('Book Appointment', style: AppStyles.buttonTextStyle),
          ),
        ),
      ),
    );
  }
}
