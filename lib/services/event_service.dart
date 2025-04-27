import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/services/api_service.dart';
import 'package:seat_sense_flutter/utils/toasts.dart';

class EventService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> fetchEvents(BuildContext context) async {
    try {
      final response = await _apiService.post('/event/list');

      if (response.statusCode == 200 && response.data['events'] != null) {
        return List<Map<String, dynamic>>.from(response.data['events']);
      } else {
        showErrorToast(
          context,
          message: 'Server returned: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Could not load events');
    } catch (e) {
      showErrorToast(context);
    }
    return [];
  }

  Future<Map<String, dynamic>?> viewEvent(
    BuildContext context,
    String eventId,
  ) async {
    try {
      final response = await _apiService.post(
        '/event/get',
        data: {'event_id': eventId},
      );
      return response.data;
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Failed to fetch event details');
    } catch (e) {
      showErrorToast(context, message: 'Failed to fetch event details');
    }
    return null;
  }

  Future<bool> createEvent(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      await _apiService.post('/event/create', data: data);
      showSuccessToast(context, message: 'Event created successfully');
      return true;
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Failed to create event');
    } catch (e) {
      showErrorToast(context, message: 'Failed to create event');
    }
    return false;
  }

  Future<bool> editEvent(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      await _apiService.post('/event/update', data: data);
      showSuccessToast(context, message: 'Event updated successfully');
      return true;
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Failed to update event');
    } catch (e) {
      showErrorToast(context, message: 'Failed to update event');
    }
    return false;
  }

  Future<bool> deleteEvent(BuildContext context, String eventId) async {
    try {
      await _apiService.post('/event/delete', data: {'event_id': eventId});
      showSuccessToast(context, message: 'Event deleted successfully');
      return true;
    } on DioException catch (e) {
      showDioErrorToast(context, e, 'Failed to delete event');
    } catch (e) {
      showErrorToast(context, message: 'Failed to delete event');
    }
    return false;
  }
}
