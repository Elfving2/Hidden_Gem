import 'package:flutter/material.dart';

Widget buildDescriptionField(
  String labelText,
  TextEditingController controller,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 30),
    child: TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.all(10),
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: labelText,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
