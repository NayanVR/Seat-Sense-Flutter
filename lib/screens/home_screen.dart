import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/models/user_model.dart';
import 'package:seat_sense_flutter/screens/login_screen.dart';
import 'package:seat_sense_flutter/services/auth_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                // Check if the widget is still in the tree
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          widget.user.role == 'admin' ? 'Admin' : 'Student',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
