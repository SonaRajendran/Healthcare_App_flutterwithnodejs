// lib/models/user.dart
class User {
  final String id;
  String name;
  String email;
  String? imageUrl; // Optional
  String? phoneNumber; // Optional

  User({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    this.phoneNumber,
  });

  // Factory constructor to create a User from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imageUrl:
          json['image_url'] as String?, // Matches backend 'image_url' field
      phoneNumber:
          json['phone_number']
              as String?, // Matches backend 'phone_number' field
    );
  }

  // Method to convert a User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image_url': imageUrl, // Matches backend 'image_url' field
      'phone_number': phoneNumber, // Matches backend 'phone_number' field
    };
  }

  // Method to create a copy with updated fields
  User copyWith({
    String? name,
    String? email,
    String? imageUrl,
    String? phoneNumber,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
