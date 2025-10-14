import 'package:flutter/material.dart';

Widget buildTextField(String labelText, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.only(bottom: 5),
        hintText: labelText,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    ),
  );
}
