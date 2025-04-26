import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:seat_sense_flutter/services/api_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EventService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> fetchEvents(BuildContext context) async {
    try {
      final response = await _apiService.post('/event/list');

      if (response.statusCode == 200 && response.data['events'] != null) {
        return List<Map<String, dynamic>>.from(response.data['events']);
      } else {
        ShadToaster.of(context).show(
          ShadToast(
            title: Text('Server returned: ${response.statusCode}'),
          ),
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['detail'] ?? 'Could not load events.';
      ShadToaster.of(context).show(
        ShadToast(title: Text(errorMessage)),
      );
    } catch (e) {
      ShadToaster.of(context).show(
        const ShadToast(title: Text('Unexpected error occurred')),
      );
    }
    return [];
  }

  Future<Map<String, dynamic>?> viewEvent(BuildContext context, String eventId) async {
    try {
      final response = await _apiService.post('/event/get', data: {'event_id': eventId});
      return response.data;
    } catch (e) {
      ShadToaster.of(context).show(
        const ShadToast(title: Text('Failed to fetch event details')),
      );
      return null;
    }
  }

  Future<bool> createEvent(BuildContext context, Map<String, dynamic> data) async {
    try {
      await _apiService.post('/event/create', data: data);
      ShadToaster.of(context).show(const ShadToast(title: Text('Event created successfully')));
      return true;
    } catch (e) {
      ShadToaster.of(context).show(const ShadToast(title: Text('Failed to create event')));
      return false;
    }
  }

  Future<bool> editEvent(BuildContext context, Map<String, dynamic> data) async {
    try {
      await _apiService.post('/event/update', data: data);
      ShadToaster.of(context).show(const ShadToast(title: Text('Event updated successfully')));
      return true;
    } catch (e) {
      ShadToaster.of(context).show(const ShadToast(title: Text('Failed to update event')));
      return false;
    }
  }

  Future<bool> deleteEvent(BuildContext context, String eventId) async {
    try {
      await _apiService.post('/event/delete', data: {'event_id': eventId});
      ShadToaster.of(context).show(const ShadToast(title: Text('Event deleted successfully')));
      return true;
    } catch (e) {
      ShadToaster.of(context).show(const ShadToast(title: Text('Failed to delete event')));
      return false;
    }
  }
}
