// user_profile.dart

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String role;
  final DateTime dob;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.role,
    required this.dob,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      role: json['role'],
      dob: DateTime.parse(json['dob']), // Parsing date from ISO 8601 format
    );
  }

  static List<UserProfile> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserProfile.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role,
      'dob': dob.toIso8601String(), // Converting DateTime to ISO 8601 format
    };
  }
}
