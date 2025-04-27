import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/screens/home_screen.dart';
import 'package:seat_sense_flutter/screens/signup_screen.dart';
import 'package:seat_sense_flutter/services/auth_service.dart';
import 'package:seat_sense_flutter/widgets/circular_button_loading.dart';
import 'package:seat_sense_flutter/widgets/password_input.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
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
                  Hero(
                    tag: 'auth-input',
                    child: ShadInput(
                      controller: _emailController,
                      placeholder: Text('Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  PasswordInput(controller: _passwordController),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ShadButton.link(
                      padding: EdgeInsets.all(0),
                      child: const Text('Forgot Password?'),
                      onPressed: () {
                        // TODO: Handle forgot password logic
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Hero(
                      tag: 'auth-button',
                      child: ShadButton(
                        onPressed: _isLoading ? null : () => _login(context),
                        child:
                            _isLoading
                                ? CircularButtonLoading()
                                : const Text('Login'),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ShadButton.link(
                    child: const Text("Don't have an account? Sign up"),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        // Use ShadToaster for error message
        ShadToaster.of(
          context,
        ).show(const ShadToast(title: Text('Please enter email and password')));
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Pass BuildContext to login method
    bool success = await _authService.login(context, email, password);

    if (success) {
      // Get stored profile
      final user = await _authService.getStoredProfile();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
          );
        } else {
          // Use ShadToaster for error message
          ShadToaster.of(
            context,
          ).show(const ShadToast(title: Text('Failed to fetch user profile')));
        }
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
