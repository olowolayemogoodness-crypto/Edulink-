import 'package:flutter/material.dart';
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label; final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  const AuthTextField({super.key, required this.controller, required this.label, required this.hint, this.obscureText = false, this.keyboardType = TextInputType.text, this.suffixIcon, this.validator});
  @override
  Widget build(BuildContext context) {
    return TextFormField(controller: controller, obscureText: obscureText, keyboardType: keyboardType, validator: validator,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(labelText: label, hintText: hint, suffixIcon: suffixIcon));
  }
}