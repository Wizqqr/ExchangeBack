import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType; // ← добавили это

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    this.onChanged,
    this.inputFormatters,
    this.keyboardType, // ← добавили это
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black87, 
          fontSize: 16,
        ),
        readOnly: readOnly,
        keyboardType: keyboardType ?? TextInputType.text, // ← используем здесь
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white, // Светлый фон
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
