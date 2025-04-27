class SendOTPRequest {
  final String email;

  SendOTPRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class VerifyOTPRequest {
  final String email;
  final int otp;

  VerifyOTPRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }
}
