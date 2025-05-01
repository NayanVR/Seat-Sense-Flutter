import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/services/auth_service.dart';
import 'package:seat_sense_flutter/widgets/password_input.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
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
                ShadInput(
                  controller: _emailController,
                  placeholder: const Text('Email'),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isOtpSent,
                ),
                if (_isOtpSent)
                  ShadInput(
                    controller: _otpController,
                    placeholder: const Text('Enter OTP'),
                    keyboardType: TextInputType.number,
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ShadButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _isOtpSent
                            ? _verifyOtp
                            : _sendOtp,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : Text(_isOtpSent ? 'Verify OTP' : 'Send OTP'),
                  ),
                ),
              ] else ...[
                PasswordInput(controller: _passwordController),
                PasswordInput(
                  controller: _confirmPasswordController,
                  placeholder: 'Confirm Password',
                ),
                SizedBox(
                  width: double.infinity,
                  child: ShadButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Reset Password'),
                  ),
                ),
              ],
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

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final email = _emailController.text.trim().toLowerCase();
    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
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

    final success = await _authService.resetPassword(
      context,
      email,
      otp,
      password,
    );
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _isLoading = false);
    }
  }
}
