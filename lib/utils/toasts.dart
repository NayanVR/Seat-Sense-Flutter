import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

Future<void> showErrorToast(
  BuildContext context, {
  String message = 'An unexpected error occurred',
}) => Future.delayed(Duration.zero, () {
  ShadToaster.of(context).show(ShadToast.destructive(title: Text(message)));
});

Future<void> showDioErrorToast(
  BuildContext context,
  DioException e,
  String fallbackMessage,
) => showErrorToast(
  context,
  message: e.response?.data['detail'] ?? fallbackMessage,
);

Future<void> showSuccessToast(
  BuildContext context, {
  String message = 'Operation successful',
}) => Future.delayed(Duration.zero, () {
  ShadToaster.of(context).show(ShadToast(title: Text(message)));
});
