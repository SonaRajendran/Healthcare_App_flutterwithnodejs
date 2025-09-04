// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:medical_healthcare_app/models/user.dart';

class UserService {
  // Base URL for your Node.js backend.
  // IMPORTANT: For local development, use your machine's IP address if testing on a physical device,
  // or '10.0.2.2' for Android Emulator, 'localhost' for iOS Simulator/Web.
  static const String _baseUrl =
      'http://localhost:3000/api/users'; // Adjust if your backend runs on a different port/host

  // Fetch a single user by ID. Returns null if user not found (404).
  static Future<User?> fetchUser(String id) async {
    // FIX: Changed return type to User?
    final response = await http.get(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      print(
        'User with ID $id not found on backend. Returning null.',
      ); // Log for debugging
      return null; // FIX: Return null on 404
    } else {
      throw Exception(
        'Failed to load user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Create a new user (Note: For a real app, this would likely be part of an auth flow)
  static Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      // 201 Created
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 409) {
      throw Exception(
        'User with this email already exists.',
      ); // Keep throwing for conflict
    } else {
      throw Exception(
        'Failed to create user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Update an existing user
  static Future<User> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 404) {
      throw Exception('User not found for update: ${user.id}');
    } else if (response.statusCode == 409) {
      throw Exception('Email already in use by another user.');
    } else {
      throw Exception(
        'Failed to update user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Delete a user
  static Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));

    if (response.statusCode == 204) {
      // 204 No Content for successful deletion
      return;
    } else if (response.statusCode == 404) {
      throw Exception('User not found for deletion: $id');
    } else {
      throw Exception(
        'Failed to delete user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Upload image
  static Future<String> uploadImage(Uint8List imageBytes) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:3000/api/upload'),
    );
    request.files.add(
      http.MultipartFile.fromBytes('image', imageBytes, filename: 'image.jpg'),
    );
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var json = jsonDecode(responseData);
      return json['imageUrl'];
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}
