// lib/screens/user_profile_edit_screen.dart
import 'package:flutter/material.dart';
// Keep for default user ID
import 'package:medical_healthcare_app/models/user.dart';
import 'package:medical_healthcare_app/utils/app_colors.dart';
import 'package:medical_healthcare_app/utils/app_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:typed_data';
import 'package:medical_healthcare_app/services/user_service.dart'; // New: Import UserService

class UserProfileEditScreen extends StatefulWidget {
  final User user;

  const UserProfileEditScreen({super.key, required this.user});

  @override
  State<UserProfileEditScreen> createState() => _UserProfileEditScreenState();
}

class _UserProfileEditScreenState extends State<UserProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _imageUrlController;
  File? _pickedImage;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _imageUrlController = TextEditingController(text: widget.user.imageUrl);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  bool _isSvgContent(String? path, {Uint8List? bytes}) {
    if (path != null && path.toLowerCase().endsWith('.svg')) {
      return true;
    }
    if (bytes != null && bytes.length >= 10) {
      try {
        final svgHeader = String.fromCharCodes(
          bytes.sublist(0, 10),
        ).toLowerCase();
        if (svgHeader.startsWith('<svg') ||
            (svgHeader.startsWith('<?xml') &&
                String.fromCharCodes(bytes).toLowerCase().contains('<svg'))) {
          return true;
        }
      } catch (e) {
        print('Error checking SVG header from bytes: $e');
      }
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      final Uint8List imageBytes = await pickedFile.readAsBytes();

      setState(() {
        _pickedImage = null; // Not used on web
        _pickedImageBytes = imageBytes;
        // Clear the URL field to avoid conflict
        _imageUrlController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image selected from ${source == ImageSource.camera ? 'Camera' : 'Gallery'}.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No image selected.')));
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      String? finalImageUrl = _imageUrlController.text.isNotEmpty
          ? _imageUrlController.text
          : widget.user.imageUrl;

      if (_pickedImageBytes != null) {
        try {
          final uploadedUrl = await UserService.uploadImage(_pickedImageBytes!);
          finalImageUrl = uploadedUrl;
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }
      }

      final updatedUser = widget.user.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text.isNotEmpty
            ? _phoneController.text
            : null,
        imageUrl: finalImageUrl,
      );

      try {
        User updatedUserResponse = await UserService.updateUser(updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: AppStyles.bodyText1.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryColor,
          ),
        );
        Navigator.of(context).pop(updatedUserResponse);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: ${e.toString()}',
              style: AppStyles.bodyText1.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentProfileImageWidget;
    const double avatarRadius = 60.0;
    const double imageSize = avatarRadius * 2;

    if (_pickedImageBytes != null) {
      if (_isSvgContent(null, bytes: _pickedImageBytes)) {
        currentProfileImageWidget = SvgPicture.memory(
          _pickedImageBytes!,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            width: imageSize,
            height: imageSize,
            color: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey, size: avatarRadius),
          ),
        );
      } else {
        currentProfileImageWidget = Image.memory(
          _pickedImageBytes!,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: imageSize,
            height: imageSize,
            color: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey, size: avatarRadius),
          ),
        );
      }
    } else if (_imageUrlController.text.isNotEmpty) {
      if (_isSvgContent(_imageUrlController.text)) {
        currentProfileImageWidget = SvgPicture.network(
          _imageUrlController.text,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          placeholderBuilder: (context) => Container(
            width: imageSize,
            height: imageSize,
            color: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey, size: avatarRadius),
          ),
        );
      } else {
        currentProfileImageWidget = Image.network(
          _imageUrlController.text,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: imageSize,
            height: imageSize,
            color: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.grey, size: avatarRadius),
          ),
        );
      }
    } else {
      currentProfileImageWidget = Icon(
        Icons.camera_alt,
        size: avatarRadius,
        color: Colors.white.withOpacity(0.8),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: AppStyles.headline2.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showImageSourceSelection,
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: AppColors.accentColor,
                    backgroundImage: null,
                    child: ClipOval(
                      child: SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: currentProfileImageWidget,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  prefixIcon: const Icon(
                    Icons.person,
                    color: AppColors.iconColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.cardColor,
                ),
                style: AppStyles.bodyText1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(
                    Icons.email,
                    color: AppColors.iconColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.cardColor,
                ),
                keyboardType: TextInputType.emailAddress,
                style: AppStyles.bodyText1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  prefixIcon: const Icon(
                    Icons.phone,
                    color: AppColors.iconColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.cardColor,
                ),
                keyboardType: TextInputType.phone,
                style: AppStyles.bodyText1,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Profile Image URL (Optional)',
                  prefixIcon: const Icon(
                    Icons.image,
                    color: AppColors.iconColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: AppColors.cardColor,
                ),
                keyboardType: TextInputType.url,
                style: AppStyles.bodyText1,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: Text('Save Changes', style: AppStyles.buttonTextStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
