import 'package:flutter/material.dart';

Widget textInput(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: 'Enter $label'),
    ),
  );
}
