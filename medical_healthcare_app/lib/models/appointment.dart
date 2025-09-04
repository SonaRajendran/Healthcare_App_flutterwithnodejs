// lib/models/appointment.dart
import 'package:medical_healthcare_app/models/doctor.dart'; // Import Doctor model

class Appointment {
  final String id;
  final Doctor doctor; // The doctor associated with the appointment
  final DateTime date;
  final String
  time; // Storing as String for simplicity as TimeOfDay.format(context) is used
  final String status; // e.g., 'Upcoming', 'Completed', 'Cancelled'

  Appointment({
    required this.id,
    required this.doctor,
    required this.date,
    required this.time,
    required this.status,
  });

  // New: fromJson factory constructor for deserialization from API
  factory Appointment.fromJson(Map<String, dynamic> json) {
    // This factory will be used by AppointmentService to parse API responses.
    // The doctor object needs to be reconstructed from the nested JSON.
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

  // New: copyWith method for creating updated instances of Appointment
  Appointment copyWith({
    String? id,
    Doctor? doctor,
    DateTime? date,
    String? time,
    String? status,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
    );
  }
}
