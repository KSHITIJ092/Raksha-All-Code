import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 15, horizontal: 100)),
      ),
      child: Text(text),
    );
  }
}
