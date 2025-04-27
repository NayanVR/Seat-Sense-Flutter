class SignupRequest {
  final int otp;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;

  SignupRequest({
    required this.otp,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.role = 'STUDENT',
  });

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
