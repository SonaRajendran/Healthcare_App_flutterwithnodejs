// lib/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:medical_healthcare_app/models/user.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:medical_healthcare_app/screens/user_profile_edit_screen.dart';
import 'package:medical_healthcare_app/services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  final VoidCallback onUserUpdated;

  const UserProfileScreen({super.key, required this.onUserUpdated});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User? _user;
  bool _isLoading = true;
  String? _error;

  // Define a static user ID and email for our default user for now
  static const String _defaultUserId =
      'd034237d-1c3f-4e1b-8b0d-6e01d67e8c3b'; // FIX: Use a valid UUID format
  static const String _defaultUserEmail = 'new.user@example.com';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // 1. Attempt to fetch the user by its hardcoded ID
      User? fetchedUser = await UserService.fetchUser(_defaultUserId);

      if (fetchedUser == null) {
        // 2. If user not found (fetchUser returned null), attempt to create a default user
        print(
          'User with ID $_defaultUserId not found on backend. Attempting to create default user...',
        );
        try {
          fetchedUser = await UserService.createUser(
            User(
              id: _defaultUserId,
              name: 'New User',
              email: _defaultUserEmail,
              imageUrl: 'https://placehold.co/100x100/CCCCCC/000000?text=NU',
              phoneNumber: '',
            ),
          );
          print('Default user created successfully.');
        } catch (e) {
          if (e.toString().contains('User with this email already exists')) {
            // 3. If creation fails due to email conflict, it means the user was created
            //    by a previous run. Try fetching it again by ID (which should now succeed).
            print(
              'Default user email already exists. Re-fetching the existing user...',
            );
            fetchedUser = await UserService.fetchUser(_defaultUserId);
            if (fetchedUser == null) {
              throw Exception('Failed to fetch existing user after conflict.');
            }
            print('Existing user fetched successfully after conflict.');
          } else {
            // Re-throw other creation errors
            rethrow;
          }
        }
      }

      setState(() {
        _user = fetchedUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load/create user: ${e.toString()}';
        _isLoading = false;
      });
      print('Error in _loadUser: $_error');
    }
  }

  void _navigateToEditProfile() {
    if (_user == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileEditScreen(user: _user!),
      ),
    ).then((updatedUser) {
      // When returning from edit screen, reload user data and notify parent
      if (updatedUser != null && updatedUser is User) {
        setState(() {
          _user = updatedUser;
        });
        widget.onUserUpdated();
      } else {
        _loadUser();
        widget.onUserUpdated();
      }
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
                'Error loading profile: $_error',
                style: AppStyles.bodyText1.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loadUser, child: const Text('Retry')),
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
          'My Profile',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  shape: BoxShape.circle,
                ),
                child: _user!.imageUrl != null && _user!.imageUrl!.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          _user!.imageUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading profile image: $error');
                            return Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white.withOpacity(0.8),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white.withOpacity(0.8),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // User Name
            Text(
              _user!.name,
              style: AppStyles.headline1.copyWith(color: AppColors.textColor),
            ),
            const SizedBox(height: 10),
            // User Email
            Text(
              _user!.email,
              style: AppStyles.bodyText1.copyWith(
                color: AppColors.lightTextColor,
              ),
            ),
            const SizedBox(height: 30),
            // Profile Details Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: AppColors.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    _buildProfileInfoRow(
                      Icons.person_outline,
                      'Name',
                      _user!.name,
                    ),
                    const Divider(height: 30),
                    _buildProfileInfoRow(
                      Icons.email_outlined,
                      'Email',
                      _user!.email,
                    ),
                    if (_user!.phoneNumber != null &&
                        _user!.phoneNumber!.isNotEmpty) ...[
                      const Divider(height: 30),
                      _buildProfileInfoRow(
                        Icons.phone_outlined,
                        'Phone',
                        _user!.phoneNumber!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.bodyText2.copyWith(
                  color: AppColors.lightTextColor,
                ),
              ),
              Text(
                value,
                style: AppStyles.bodyText1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
