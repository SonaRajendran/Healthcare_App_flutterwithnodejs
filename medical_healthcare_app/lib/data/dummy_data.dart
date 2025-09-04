// lib/data/dummy_data.dart
import 'dart:convert';
import 'package:medical_healthcare_app/models/doctor.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medical_healthcare_app/models/appointment.dart';
import 'package:medical_healthcare_app/models/user.dart';
import 'package:medical_healthcare_app/models/message.dart'; // New: Import Message model
import 'package:medical_healthcare_app/services/appointment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DummyData {
  // REMOVED: static const String _kAppointmentsKey = 'appointments'; // No longer used as appointments are managed by AppointmentService
  static const String _kFavoriteDoctorIdsKey = 'favoriteDoctorIds';
  static const String _kCurrentUserKey = 'currentUser';
  static const String _kNotificationsEnabledKey =
      'notificationsEnabled'; // New: Key for notification persistence
  static const String _kMessagesKey =
      'messages'; // New: Key for message persistence

  static List<Doctor> doctors = [
    Doctor(
      id: '12345678-1234-1234-1234-123456789abc',
      name: 'Dr. Sarah Johnson',
      specialty: 'Cardiologist',
      imageUrl: 'https://placehold.co/100x100/4CAF50/FFFFFF?text=SJ',
      rating: 4.8,
      experience: '10 years',
      bio:
          'Dr. Johnson is a highly experienced cardiologist dedicated to heart health.',
      availableTime: 'Mon, Wed, Fri (9 AM - 5 PM)',
    ),
    Doctor(
      id: '22345678-2234-2234-2234-223456789abc',
      name: 'Dr. Michael Lee',
      specialty: 'Pediatrician',
      imageUrl: 'https://placehold.co/100x100/8BC34A/FFFFFF?text=ML',
      rating: 4.5,
      experience: '8 years',
      bio:
          'Dr. Lee specializes in pediatric care, ensuring the well-being of children.',
      availableTime: 'Tue, Thu (10 AM - 6 PM)',
    ),
    Doctor(
      id: '32345678-3234-3234-3234-323456789abc',
      name: 'Dr. Emily Chen',
      specialty: 'Dermatologist',
      imageUrl: 'https://placehold.co/100x100/66BB6A/FFFFFF?text=EC',
      rating: 4.9,
      experience: '12 years',
      bio:
          'Dr. Chen provides expert care for skin conditions and cosmetic treatments.',
      availableTime: 'Mon, Tue, Wed (11 AM - 7 PM)',
    ),
    Doctor(
      id: '42345678-4234-4234-4234-423456789abc',
      name: 'Dr. David Williams',
      specialty: 'Neurologist',
      imageUrl: 'https://placehold.co/100x100/A5D6A7/FFFFFF?text=DW',
      rating: 4.7,
      experience: '15 years',
      bio: 'Dr. Williams focuses on neurological disorders and brain health.',
      availableTime: 'Thu, Fri (8 AM - 4 PM)',
    ),
  ];

  static List<Map<String, dynamic>> categories = [
    {
      'name': 'Cardiology',
      'icon': FontAwesomeIcons.heartbeat,
      'color': Colors.redAccent,
    },
    {
      'name': 'Pediatrics',
      'icon': FontAwesomeIcons.child,
      'color': Colors.blueAccent,
    },
    {
      'name': 'Dermatology',
      'icon': FontAwesomeIcons.spa,
      'color': Colors.orangeAccent,
    },
    {
      'name': 'Neurology',
      'icon': FontAwesomeIcons.brain,
      'color': Colors.purpleAccent,
    },
    {
      'name': 'Dentistry',
      'icon': FontAwesomeIcons.tooth,
      'color': Colors.greenAccent,
    },
    {
      'name': 'Ophthalmology',
      'icon': FontAwesomeIcons.eye,
      'color': Colors.tealAccent,
    },
  ];

  // Appointments will now be fetched from the backend, not stored locally in DummyData
  // We'll keep a temporary list for immediate UI updates, but backend is source of truth.
  static List<Appointment> _cachedAppointments = [];

  static User currentUser = User(
    id: 'd034237d-1c3f-4e1b-8b0d-6e01d67e8c3b',
    name: 'John Doe',
    email: 'john.doe@example.com',
    imageUrl: 'https://placehold.co/100x100/4CAF50/FFFFFF?text=JD',
    phoneNumber: '+91 9876543210',
  );

  static final Set<String> _favoriteDoctorIds = {};
  static bool _notificationsEnabled = true;

  static List<Message> messages = []; // New: List to store messages

  // New: Method to get cached appointments (primarily for synchronous access)
  static List<Appointment> getAppointments() {
    return _cachedAppointments;
  }

  // New: Helper to set cached appointments
  static void _setCachedAppointments(List<Appointment> appointments) {
    _cachedAppointments = appointments;
  }

  static bool areNotificationsEnabled() => _notificationsEnabled;

  static Future<void> setNotificationsEnabled(bool enable) async {
    _notificationsEnabled = enable;
    await _saveData();
  }

  static Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // No longer saving appointments here, they are managed by AppointmentService
    // We only save preferences and user data that aren't managed by a dedicated service.

    await prefs.setStringList(
      _kFavoriteDoctorIdsKey,
      _favoriteDoctorIds.toList(),
    );

    await prefs.setString(
      _kCurrentUserKey,
      jsonEncode({
        'id': currentUser.id,
        'name': currentUser.name,
        'email': currentUser.email,
        'imageUrl': currentUser.imageUrl,
        'phoneNumber': currentUser.phoneNumber,
      }),
    );

    await prefs.setBool(_kNotificationsEnabledKey, _notificationsEnabled);

    // New: Save messages to SharedPreferences
    final List<String> messagesJson = messages
        .map(
          (msg) => jsonEncode({
            'id': msg.id,
            'recipientId': msg.recipient.id,
            'sender': msg.sender.index, // Store enum index
            'content': msg.content,
            'timestamp': msg.timestamp.toIso8601String(),
          }),
        )
        .toList();
    await prefs.setStringList(_kMessagesKey, messagesJson);
  }

  // Modified loadData to fetch user and appointments from backend
  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load favorite doctor IDs
    final List<String>? favoriteIds = prefs.getStringList(
      _kFavoriteDoctorIdsKey,
    );
    if (favoriteIds != null) {
      _favoriteDoctorIds
        ..clear()
        ..addAll(favoriteIds);
    }

    // Load current user from SharedPreferences or set default.
    // This is primarily for getting the userId needed to fetch data from the backend.
    final String? userJson = prefs.getString(_kCurrentUserKey);
    if (userJson != null) {
      final Map<String, dynamic> map = jsonDecode(userJson);
      currentUser = User(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        imageUrl: map['imageUrl'],
        phoneNumber: map['phoneNumber'],
      );
    }

    _notificationsEnabled = prefs.getBool(_kNotificationsEnabledKey) ?? true;

    // After loading current user (especially its ID), fetch appointments from backend
    try {
      if (currentUser.id.isNotEmpty) {
        final fetchedAppointments = await AppointmentService.fetchAppointments(
          currentUser.id,
        );
        _setCachedAppointments(fetchedAppointments);
      }
    } catch (e) {
      print('Error loading appointments from backend: $e');
      _setCachedAppointments(
        [],
      ); // Ensure appointments list is not null on error
    }

    // New: Load messages from SharedPreferences
    final List<String>? messagesJson = prefs.getStringList(_kMessagesKey);
    if (messagesJson != null) {
      messages = messagesJson.map((jsonString) {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        final Doctor recipientDoctor = doctors.firstWhere(
          (doc) => doc.id == map['recipientId'],
          orElse: () => doctors.first, // Fallback in case doctor not found
        );
        return Message(
          id: map['id'],
          recipient: recipientDoctor,
          sender: MessageSender.values[map['sender']], // Deserialize enum
          content: map['content'],
          timestamp: DateTime.parse(map['timestamp']),
        );
      }).toList();
    } else {
      // Provide some initial dummy messages if none are saved
      messages = [
        Message(
          id: 'msg1',
          recipient: doctors[0],
          sender: MessageSender.doctor,
          content: 'Hello ${currentUser.name}, how are you feeling today?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Message(
          id: 'msg2',
          recipient: doctors[0],
          sender: MessageSender.user,
          content: 'Hi Dr. Johnson, I\'m doing well, thank you!',
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 30),
          ),
        ),
        Message(
          id: 'msg3',
          recipient: doctors[1],
          sender: MessageSender.doctor,
          content: 'Your test results are ready, please check the portal.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
    }
  }

  // Modified methods to use AppointmentService
  static Future<void> addAppointment(Appointment newAppointment) async {
    if (currentUser.id.isEmpty) {
      print('Cannot add appointment: Current user ID is empty.');
      return;
    }
    try {
      final createdAppointment = await AppointmentService.createAppointment(
        newAppointment,
        currentUser.id,
      );
      _cachedAppointments.add(createdAppointment);
      // Sort to maintain order if necessary
      _cachedAppointments.sort((a, b) => a.date.compareTo(b.date));
      // No need to call _saveData() here as appointments are now backend managed.
      // However, if there was a local cache of appointments we would update that.
    } catch (e) {
      print('Error adding appointment to backend: $e');
      rethrow;
    }
  }

  static Future<void> cancelAppointment(String appointmentId) async {
    try {
      // Find the appointment in the cache to get its current data, then update status
      final appointmentToUpdate = _cachedAppointments.firstWhere(
        (app) => app.id == appointmentId,
      );
      final updatedAppointment = appointmentToUpdate.copyWith(
        status: 'Cancelled',
      );

      await AppointmentService.updateAppointment(
        updatedAppointment,
        currentUser.id,
      );
      final index = _cachedAppointments.indexWhere(
        (app) => app.id == appointmentId,
      );
      if (index != -1) {
        _cachedAppointments[index] = updatedAppointment; // Update local cache
      }
      // No need to call _saveData() here.
    } catch (e) {
      print('Error canceling appointment on backend: $e');
      rethrow;
    }
  }

  static Future<void> updateAppointment(Appointment updatedAppointment) async {
    try {
      await AppointmentService.updateAppointment(
        updatedAppointment,
        currentUser.id,
      );
      final index = _cachedAppointments.indexWhere(
        (app) => app.id == updatedAppointment.id,
      );
      if (index != -1) {
        _cachedAppointments[index] = updatedAppointment; // Update local cache
      }
      // No need to call _saveData() here.
    } catch (e) {
      print('Error updating appointment on backend: $e');
      rethrow;
    }
  }

  static void toggleFavorite(String doctorId) {
    if (_favoriteDoctorIds.contains(doctorId)) {
      _favoriteDoctorIds.remove(doctorId);
    } else {
      _favoriteDoctorIds.add(doctorId);
    }
    _saveData();
  }

  static bool isDoctorFavorite(String doctorId) {
    return _favoriteDoctorIds.contains(doctorId);
  }

  static List<Doctor> getFavoriteDoctors() {
    return doctors
        .where((doctor) => _favoriteDoctorIds.contains(doctor.id))
        .toList();
  }

  static User getCurrentUser() {
    return currentUser;
  }

  static void updateCurrentUser(User updatedUser) {
    currentUser = updatedUser;
    _saveData();
  }

  // New: Method to add a message
  static void addMessage(Message newMessage) {
    messages.add(newMessage);
    messages.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    ); // Sort by most recent first
    _saveData(); // Save messages to SharedPreferences
  }
}
