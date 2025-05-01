import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/models/otp_model.dart';
import 'package:seat_sense_flutter/models/signup_model.dart';
import 'package:seat_sense_flutter/models/user_model.dart';
import 'package:seat_sense_flutter/services/api_service.dart';
import 'package:seat_sense_flutter/utils/secure_storage.dart';
import 'package:seat_sense_flutter/utils/toasts.dart';
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
          showErrorToast(context, message: 'Failed to get and store profile');
          return false;
        }
      } else {
        showErrorToast(
          context,
          message: 'Login failed: ${response.statusCode}',
        );
        return false;
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Login failed');
      return false;
    } catch (e) {
      showErrorToast(context);
      return false;
    }
  }

  Future<bool> sendOtp(BuildContext context, String email) async {
    try {
      final response = await _apiService.post(
        '/auth/send-otp',
        data: SendOTPRequest(email: email).toJson(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Failed to send OTP');
      return false;
    } catch (e) {
      showErrorToast(context);
      return false;
    }
  }

  Future<bool> verifyOtp(BuildContext context, String email, String otp) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-otp',
        data: VerifyOTPRequest(email: email, otp: int.parse(otp)).toJson(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'OTP verification failed');
      return false;
    } catch (e) {
      showErrorToast(context);
      return false;
    }
  }

  Future<bool> signup(BuildContext context, SignupRequest req) async {
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
        showErrorToast(
          context,
          message: 'Signup failed: ${response.statusCode}',
        );
        return false;
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Signup failed');
      return false;
    } catch (e) {
      showErrorToast(context);
      return false;
    }
  }

  Future<bool> registerFace(BuildContext context, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath, filename: 'face.jpg'),
      });

      final response = await _apiService.post(
        '/auth/register-face',
        data: formData,
      );

      if (response.statusCode == 200) {
        final user = await getProfile();
        if (user != null) {
          await _saveUserProfile(user);
          return true;
        } else {
          showErrorToast(context, message: 'Failed to get and store profile');
          return false;
        }
      } else {
        showErrorToast(
          context,
          message: 'Face registration failed: ${response.statusCode}',
        );
        return false;
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Face registration failed');
      return false;
    } catch (e) {
      showErrorToast(context);
      return false;
    }
  }

  Future<bool> resetPassword(
    BuildContext context,
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.post(
        '/auth/reset-password',
        data: {'email': email, 'otp': otp, 'password': newPassword},
      );

      if (response.statusCode == 200) {
        showSuccessToast(context, message: response.data['message']);
        return true;
      } else {
        showErrorToast(
          context,
          message: 'Password reset failed: ${response.statusCode}',
        );
        return false;
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Password reset failed');
      return false;
    } catch (e) {
      showErrorToast(context);
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
