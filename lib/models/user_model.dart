class User {
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String userId;
  final bool faceVerified;

  User({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.userId,
    required this.faceVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      role: json['role'],
      userId: json['user_id'],
      faceVerified: json['face_verified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'user_id': userId,
      'face_verified': faceVerified,
    };
  }
}
