// lib/screens/profile_wrapper_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/screens/user_profile_screen.dart';
import 'package:medical_healthcare_app/screens/settings_screen.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';

class ProfileWrapperScreen extends StatefulWidget {
  const ProfileWrapperScreen({super.key});

  @override
  State<ProfileWrapperScreen> createState() => _ProfileWrapperScreenState();
}

class _ProfileWrapperScreenState extends State<ProfileWrapperScreen> {
  int _selectedIndex = 0; // 0 for Profile, 1 for Settings

  // This callback will be passed to UserProfileScreen to trigger a rebuild
  // in ProfileWrapperScreen when the user data is updated, ensuring the
  // "Me" tab icon reflects any image changes if necessary (though not directly
  // handled by the BottomNavigationBar here, it's good practice for state management).
  void _onUserUpdated() {
    setState(() {
      // Rebuild to ensure any UI elements that depend on user data are refreshed
      // (e.g., if we had a profile picture in the AppBar of the wrapper itself).
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          _selectedIndex == 0 ? 'My Account' : 'Settings',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          UserProfileScreen(onUserUpdated: _onUserUpdated),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.lightTextColor,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
