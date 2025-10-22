import 'package:flutter/material.dart';

/*
  Used in profile_screen 
  takes in a label and a callback method
*/
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PrimaryButton({Key? key, required this.label, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
