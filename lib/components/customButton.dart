import 'package:flutter/material.dart';

Widget customButton(String buttonText, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      minimumSize: const Size(120, 40),
    ),
    child: Text(buttonText),
  );
}
