import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool ocultar;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
  final bool enabled;
  final void Function(String)? onChanged;

  const CampoTexto({
    super.key,
    required this.label,
    required this.controller,
    this.ocultar = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: ocultar,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary) : null,
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }
}
