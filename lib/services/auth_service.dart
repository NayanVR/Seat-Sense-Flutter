import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/models/signup_model.dart';
import 'package:seat_sense_flutter/models/user_model.dart';
import 'package:seat_sense_flutter/services/api_service.dart';
import 'package:seat_sense_flutter/utils/secure_storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart'; // Import Shadcn UI
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static const String _userProfileKey = 'user_profile';

  Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    // Pass BuildContext
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        await SecureStorage.setAccessToken(accessToken);

        // Fetch user profile after successful login
        final user = await getProfile(); // Call getProfile
        if (user != null) {
          await _saveUserProfile(user);
          return true;
        } else {
          // Use ShadToaster for error message
          ShadToaster.of(context).show(
            ShadToast(
              title: const Text(
                'Failed to get and store profile',
              ), // Use destructive for errors
            ),
          );
          return false;
        }
      } else {
        // Use ShadToaster for error message
        ShadToaster.of(
          context,
        ).show(ShadToast(title: Text('Login failed: ${response.statusCode}')));
        return false;
      }
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['detail'] ?? errorMessage;
      }
      // Use ShadToaster for error message
      ShadToaster.of(context).show(ShadToast(title: Text(errorMessage)));
      return false;
    } catch (e) {
      // Use ShadToaster for error message
      ShadToaster.of(
        context,
      ).show(ShadToast(title: Text('An unexpected error occurred')));
      return false;
    }
  }

  Future<bool> signup(BuildContext context, SignupRequest req) async {
    // Pass BuildContext
    try {
      final response = await _apiService.post(
        '/auth/signup',
        data: req.toJson(),
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        await SecureStorage.setAccessToken(accessToken);
        return true;
      } else {
        // Use ShadToaster for error message
        ShadToaster.of(
          context,
        ).show(ShadToast(title: Text('Signup failed: ${response.statusCode}')));
        return false;
      }
    } on DioException catch (e) {
      String errorMessage = 'Signup failed';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['detail'] ?? errorMessage;
      }
      // Use ShadToaster for error message
      ShadToaster.of(context).show(ShadToast(title: Text(errorMessage)));
      return false;
    } catch (e) {
      // Use ShadToaster for error message
      ShadToaster.of(
        context,
      ).show(const ShadToast(title: Text('An unexpected error occurred')));
      return false;
    }
  }

  Future<bool> registerFace(BuildContext context, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: 'face.jpg'),
      });

      final response = await _apiService.post('/register-face', data: formData);

      if (response.statusCode == 200) {
        return true;
      } else {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text('Face registration failed: ${response.statusCode}'),
          ),
        );
        return false;
      }
    } on DioException catch (e) {
      String errorMessage = 'Face registration failed';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['detail'] ?? errorMessage;
      }
      ShadToaster.of(context).show(ShadToast(title: Text(errorMessage)));
      return false;
    } catch (e) {
      ShadToaster.of(context).show(
        const ShadToast(
          title: Text('An unexpected error occurred during face registration'),
        ),
      );
      return false;
    }
  }

  Future<User?> getProfile() async {
    try {
      final response = await _apiService.post('/auth/profile');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteAccessToken();
    await _deleteUserProfile();
  }

  Future<void> _saveUserProfile(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(user.toJson()));
  }

  Future<User?> getStoredProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userProfileKey);
    if (userJson != null) {
      final decodedJson = jsonDecode(userJson);
      return User.fromJson(decodedJson);
    }
    return null;
  }

  Future<void> _deleteUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
  }
}
