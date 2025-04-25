import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;

  const PasswordInput({
    super.key,
    required this.controller,
    this.placeholder = 'Password',
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return ShadInput(
      controller: widget.controller,
      placeholder: Text(widget.placeholder),
      obscureText: obscure,
      padding: const EdgeInsets.only(left: 12),
      trailing: SizedBox(
        width: 36, // Adjust width as needed
        height: 36, // Adjust height as needed
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(obscure ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
          color: Colors.black, // Optional: Set icon color
          onPressed: () {
            setState(() => obscure = !obscure);
          },
        ),
      ),
    );
  }
}
