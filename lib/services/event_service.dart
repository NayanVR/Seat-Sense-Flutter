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
        ShadToast(
          title: Text(errorMessage),
        ),
      );
    } catch (e) {
      ShadToaster.of(context).show(
        const ShadToast(title: Text('Unexpected error occurred')),
      );
    }

    return []; 
  }
}
