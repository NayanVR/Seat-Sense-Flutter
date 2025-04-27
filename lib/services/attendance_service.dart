import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:seat_sense_flutter/services/api_service.dart';
import 'package:seat_sense_flutter/utils/toasts.dart';

class AttendanceService {
  final ApiService _apiService = ApiService();
  final Logger _logger = Logger();

  Future<bool> markAttendance({
    required BuildContext context,
    required String eventId,
    required double latitude,
    required double longitude,
    required String imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'event_id': eventId,
        'latitude': latitude,
        'longitude': longitude,
        'image': await MultipartFile.fromFile(imagePath, filename: 'face.jpg'),
      });

      final response = await _apiService.post(
        '/attendance/mark-from-image',
        data: formData,
      );

      if (response.statusCode == 200) {
        showSuccessToast(context, message: 'Attendance marked successfully');
        return true;
      } else {
        showErrorToast(
          context,
          message: 'Server returned: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Failed to mark attendance.');
    } catch (e) {
      _logger.e('Unexpected Error: ${e.toString()}');
      showErrorToast(context);
    }

    return false;
  }

  Future<bool> manualMarkAttendance({
    required BuildContext context,
    required String email,
    required String eventId,
  }) async {
    try {
      final response = await _apiService.post(
        '/attendance/mark',
        data: {'email': email, 'event_id': eventId},
      );

      if (response.statusCode == 200) {
        showSuccessToast(context, message: 'Attendance marked manually');
        return true;
      } else {
        showErrorToast(
          context,
          message: 'Server returned: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Failed to manually mark attendance.');
    } catch (e) {
      _logger.e('Unexpected Error: ${e.toString()}');
      showErrorToast(context);
    }

    return false;
  }

  Future<bool> deleteAttendance({
    required BuildContext context,
    required String attendanceId,
  }) async {
    try {
      final response = await _apiService.post(
        '/attendance/delete',
        data: {'attendance_id': attendanceId},
      );

      if (response.statusCode == 200) {
        showSuccessToast(context, message: 'Attendance deleted successfully');
        return true;
      } else {
        showErrorToast(
          context,
          message: 'Server returned: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Failed to delete attendance.');
    } catch (e) {
      _logger.e('Unexpected Error: ${e.toString()}');
      showErrorToast(context);
    }

    return false;
  }

  Future<List<Map<String, dynamic>>> fetchAttendanceByEvent({
    required BuildContext context,
    required String eventId,
  }) async {
    try {
      final response = await _apiService.post(
        '/attendance/by-event',
        data: {'event_id': eventId},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return List<Map<String, dynamic>>.from(data);
      } else {
        showErrorToast(
          context,
          message: 'Server returned: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Failed to fetch attendance.');
    } catch (e) {
      _logger.e('Unexpected Error: ${e.toString()}');
      showErrorToast(context);
    }

    return [];
  }
}
