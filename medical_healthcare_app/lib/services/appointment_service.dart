// lib/services/appointment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_healthcare_app/models/appointment.dart';
import 'package:medical_healthcare_app/models/doctor.dart'; // Needed to reconstruct Doctor objects

class AppointmentService {
  static const String _baseUrl =
      'http://localhost:3000/api/appointments'; // Use localhost for development

  // Fetch all appointments for a specific user
  static Future<List<Appointment>> fetchAppointments(String userId) async {
    final response = await http.get(Uri.parse('$_baseUrl/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load appointments: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Create a new appointment
  static Future<Appointment> createAppointment(
    Appointment appointment,
    String userId,
  ) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId, // Pass user ID
        'doctorId': appointment.doctor.id,
        'date': appointment.date.toIso8601String().split(
          'T',
        )[0], // Send only date part
        'time': appointment.time,
        'status': appointment.status,
      }),
    );

    if (response.statusCode == 201) {
      return Appointment.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to create appointment: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Update an existing appointment
  static Future<Appointment> updateAppointment(
    Appointment appointment,
    String userId,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${appointment.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId, // Pass user ID
        'doctorId': appointment.doctor.id,
        'date': appointment.date.toIso8601String().split(
          'T',
        )[0], // Send only date part
        'time': appointment.time,
        'status': appointment.status,
      }),
    );

    if (response.statusCode == 200) {
      return Appointment.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to update appointment: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Delete an appointment
  static Future<void> deleteAppointment(String appointmentId) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$appointmentId'));

    if (response.statusCode == 204) {
      return; // No content, successful deletion
    } else if (response.statusCode == 404) {
      throw Exception('Appointment not found for deletion: $appointmentId');
    } else {
      throw Exception(
        'Failed to delete appointment: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

// Extend Appointment model to include fromJson constructor
extension AppointmentExtension on Appointment {
  static Appointment fromJson(Map<String, dynamic> json) {
    // Assuming DummyData.doctors is already loaded and contains all doctors
    final doctorJson = json['doctor'] as Map<String, dynamic>?;
    if (doctorJson == null) {
      throw Exception('Doctor data is missing in the response');
    }
    final Doctor doctor = Doctor(
      id: doctorJson['id'] ?? '',
      name: doctorJson['name'] ?? '',
      specialty: doctorJson['specialty'] ?? '',
      imageUrl: doctorJson['imageUrl'],
      rating: (doctorJson['rating'] as num?)?.toDouble() ?? 0.0,
      experience: doctorJson['experience'],
      bio: doctorJson['bio'],
      availableTime: doctorJson['availableTime'],
    );

    return Appointment(
      id: json['id'] ?? '',
      doctor: doctor,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      time: json['time'] ?? '',
      status: json['status'] ?? 'Upcoming',
    );
  }
}
