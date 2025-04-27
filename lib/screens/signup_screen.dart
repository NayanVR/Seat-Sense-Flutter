import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/models/signup_model.dart';
import 'package:seat_sense_flutter/screens/face_registration_screen.dart';
import 'package:seat_sense_flutter/screens/login_screen.dart';
import 'package:seat_sense_flutter/services/auth_service.dart';
import 'package:seat_sense_flutter/widgets/circular_button_loading.dart';
import 'package:seat_sense_flutter/widgets/password_input.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'lib/assets/logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 32),
              if (!_isOtpSent || !_isOtpVerified) ...[
                Hero(
                  tag: 'auth-input',
                  child: ShadInput(
                    controller: _emailController,
                    placeholder: const Text('Email'),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isOtpSent,
                  ),
                ),
                if (_isOtpSent)
                  ShadInput(
                    controller: _otpController,
                    placeholder: const Text('Enter OTP'),
                    keyboardType: TextInputType.number,
                  ),
                if (_isOtpSent)
                  TextButton(
                    onPressed: _resetToEmailInput,
                    child: const Text('Change Email'),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: Hero(
                    tag: 'auth-button',
                    child: ShadButton(
                      onPressed:
                          _isLoading
                              ? null
                              : _isOtpSent
                              ? _verifyOtp
                              : _sendOtp,
                      child:
                          _isLoading
                              ? const CircularButtonLoading()
                              : Text(_isOtpSent ? 'Verify OTP' : 'Send OTP'),
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ShadInput(
                        controller: _firstNameController,
                        placeholder: const Text('First Name'),
                      ),
                    ),
                    Expanded(
                      child: ShadInput(
                        controller: _lastNameController,
                        placeholder: const Text('Last Name'),
                      ),
                    ),
                  ],
                ),
                PasswordInput(controller: _passwordController),
                PasswordInput(
                  controller: _confirmPasswordController,
                  placeholder: 'Confirm Password',
                ),
                SizedBox(
                  width: double.infinity,
                  child: ShadButton(
                    onPressed: _isLoading ? null : _signup,
                    child:
                        _isLoading
                            ? const CircularButtonLoading()
                            : const Text('Sign Up'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ShadButton.link(
                child: const Text('Already have an account? Login'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      ShadToaster.of(
        context,
      ).show(const ShadToast(title: Text('Please enter your email')));
      setState(() => _isLoading = false);
      return;
    }

    final success = await _authService.sendOtp(context, email);
    if (success) {
      setState(() {
        _isOtpSent = true;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    final email = _emailController.text.trim().toLowerCase();
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ShadToaster.of(
        context,
      ).show(const ShadToast(title: Text('Please enter the OTP')));
      setState(() => _isLoading = false);
      return;
    }

    final success = await _authService.verifyOtp(context, email, otp);
    if (success) {
      setState(() {
        _isOtpVerified = true;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ShadToaster.of(
        context,
      ).show(const ShadToast(title: Text('Please fill in all fields')));
      setState(() => _isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      ShadToaster.of(
        context,
      ).show(const ShadToast(title: Text('Passwords do not match')));
      setState(() => _isLoading = false);
      return;
    }

    final success = await _authService.signup(
      context,
      SignupRequest(
        otp: int.parse(_otpController.text.trim()),
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      ),
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const FaceRegistrationScreen()),
      );
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _resetToEmailInput() {
    setState(() {
      _isOtpSent = false;
      _isOtpVerified = false;
      _otpController.clear();
    });
  }
}
