import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _dataSharingEnabled = false;
  bool _biometricEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Privacy & Security',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Settings', style: AppStyles.titleStyle),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.share, color: AppColors.iconColor),
                    title: Text('Data Sharing', style: AppStyles.bodyText1),
                    subtitle: Text(
                      'Allow sharing of anonymized data for app improvement',
                      style: AppStyles.bodyText2,
                    ),
                    trailing: Switch(
                      value: _dataSharingEnabled,
                      onChanged: (value) {
                        setState(() {
                          _dataSharingEnabled = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Data sharing enabled'
                                  : 'Data sharing disabled',
                            ),
                          ),
                        );
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(
                      Icons.fingerprint,
                      color: AppColors.iconColor,
                    ),
                    title: Text(
                      'Biometric Authentication',
                      style: AppStyles.bodyText1,
                    ),
                    subtitle: Text(
                      'Use fingerprint or face ID for login',
                      style: AppStyles.bodyText2,
                    ),
                    trailing: Switch(
                      value: _biometricEnabled,
                      onChanged: (value) {
                        setState(() {
                          _biometricEnabled = value;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? 'Biometric authentication enabled'
                                  : 'Biometric authentication disabled',
                            ),
                          ),
                        );
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.delete_forever, color: Colors.red),
                    title: Text(
                      'Delete Account',
                      style: AppStyles.bodyText1.copyWith(color: Colors.red),
                    ),
                    subtitle: Text(
                      'Permanently delete your account and all data',
                      style: AppStyles.bodyText2,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.lightTextColor,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                            'Are you sure you want to delete your account? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Account deletion not implemented yet.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Security Information', style: AppStyles.titleStyle),
            const SizedBox(height: 15),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Your data is encrypted and stored securely. We follow industry-standard security practices to protect your personal information.',
                  style: AppStyles.bodyText1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
