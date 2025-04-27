import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CircularButtonLoading extends StatelessWidget {
  const CircularButtonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20.0,
      height: 20.0,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: ShadTheme.of(context).colorScheme.primaryForeground,
      ),
    );
  }
}
