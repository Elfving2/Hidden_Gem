import 'package:flutter/material.dart';

/*
  Textfield used to display users display name and change the name
*/
Widget textInput(String label, TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: 'Enter $label'),
    ),
  );
}
