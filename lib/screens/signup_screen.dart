import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/models/signup_model.dart';
import 'package:seat_sense_flutter/screens/face_registration_screen.dart';
import 'package:seat_sense_flutter/screens/login_screen.dart';
import 'package:seat_sense_flutter/services/auth_service.dart';
import 'package:seat_sense_flutter/widgets/password_input.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

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
              ShadInput(
                controller: _emailController,
                placeholder: const Text('Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              PasswordInput(controller: _passwordController),
              PasswordInput(
                controller: _confirmPasswordController,
                placeholder: 'Confirm Password',
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  onPressed: _isLoading ? null : () => _signup(context),
                  child:
                      _isLoading
                          ? SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  ShadTheme.of(
                                    context,
                                  ).colorScheme.primaryForeground,
                            ),
                          )
                          : const Text('Sign Up'),
                ),
              ),
              SizedBox(height: 16.0),
              ShadButton.link(
                child: const Text('Already have an account? Log in'),
                onPressed: () {
                  // go back
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

  Future<void> _signup(BuildContext context) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(const ShadToast(title: Text('Please fill in all fields')));
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password != confirmPassword) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(const ShadToast(title: Text('Passwords do not match')));
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final signupRequest = SignupRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    final success = await _authService.signup(context, signupRequest);

    if (success) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const FaceRegistrationScreen(),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
