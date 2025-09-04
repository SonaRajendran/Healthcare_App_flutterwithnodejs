// lib/widgets/doctor_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medical_healthcare_app/models/doctor.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:medical_healthcare_app/screens/doctor_detail_screen.dart';
import 'package:medical_healthcare_app/data/dummy_data.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onToggleFavorite;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onToggleFavorite,
  });

  bool _isSvg(String? url) {
    return url != null && url.toLowerCase().endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    bool isFavorite = DummyData.isDoctorFavorite(doctor.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailScreen(
              doctor: doctor,
              onToggleFavorite: onToggleFavorite,
            ),
          ),
        ).then((_) {
          onToggleFavorite();
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: AppColors.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    doctor.imageUrl !=
                        null // Keep this check as imageUrl is nullable
                    ? _isSvg(doctor.imageUrl)
                          ? SvgPicture.network(
                              doctor
                                  .imageUrl!, // Retain '!' as imageUrl is checked above
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Image.network(
                              doctor
                                  .imageUrl!, // Retain '!' as imageUrl is checked above
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                    : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name, style: AppStyles.cardTitleStyle),
                    const SizedBox(height: 4),
                    Text(doctor.specialty, style: AppStyles.cardSubtitleStyle),
                    const SizedBox(height: 8),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.solidStar,
                            color: AppColors.ratingColor,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              doctor.rating.toString(),
                              style: AppStyles.bodyText2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Icon(
                            FontAwesomeIcons.briefcaseMedical,
                            color: AppColors.iconColor,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              doctor.experience ?? 'N/A',
                              style: AppStyles.bodyText2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : AppColors.lightTextColor,
                    ),
                    onPressed: () {
                      DummyData.toggleFavorite(doctor.id);
                      onToggleFavorite();
                    },
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.lightTextColor.withOpacity(0.7),
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
