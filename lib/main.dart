import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/models/user_model.dart';
import 'package:seat_sense_flutter/screens/home_screen.dart';
import 'package:seat_sense_flutter/screens/login_screen.dart';
import 'package:seat_sense_flutter/services/auth_service.dart';
import 'package:seat_sense_flutter/utils/secure_storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _defaultHome = Scaffold(
    // Display loading indicator initially
    body: Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
    ),
  );
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    String? accessToken = await SecureStorage.getAccessToken();
    if (accessToken != null) {
      // Fetch user profile
      User? user = await _authService.getStoredProfile();
      if (user != null) {
        setState(() {
          _defaultHome = HomeScreen(user: user);
        });
      } else {
        await SecureStorage.deleteAccessToken();
        setState(() {
          _defaultHome = const LoginScreen();
        });
      }
    } else {
      setState(() {
        _defaultHome = const LoginScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp.material(
      title: 'My App',
      // scaffoldMessengerKey: AppConfig.messengerKey, // Removed invalid parameter
      materialThemeBuilder: (context, theme) {
        return theme.copyWith(
          appBarTheme: const AppBarTheme(
            toolbarHeight: 52,
            color: Color(0xff2563eb),
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            iconTheme: IconThemeData(color: Colors.white),
            actionsIconTheme: IconThemeData(color: Colors.white),
            centerTitle: true,
            elevation: 0,
          ),
        );
      },
      theme: ShadThemeData(
        colorScheme: ShadBlueColorScheme.light(ring: Colors.transparent),
        brightness: Brightness.light,
      ),
      home: _defaultHome, // Show loading initially
    );
  }
}
