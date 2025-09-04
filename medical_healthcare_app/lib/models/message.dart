// lib/models/message.dart
import 'package:medical_healthcare_app/models/doctor.dart'; // Import Doctor model

enum MessageSender { user, doctor } // Define who sent the message

class Message {
  final String id;
  final Doctor recipient; // The doctor this message is to/from
  final MessageSender sender;
  final String content;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.recipient,
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}
