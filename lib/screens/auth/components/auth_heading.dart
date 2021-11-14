import 'package:flutter/material.dart';
import './auth_divider.dart';

class AuthHeading extends StatelessWidget {
  
  final String text;
  final double fontSize;

  AuthHeading({ required this.text, this.fontSize = 50 });

  @override
  Widget build(BuildContext context) {
    return AuthDivider(
      text: Text(
        text,
        style: TextStyle(
          fontSize: fontSize, 
          color: Colors.blue,
          fontWeight: FontWeight.bold, 
        ),
      )
    );
  }
}
