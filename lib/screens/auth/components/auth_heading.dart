import 'package:flutter/material.dart';
import './auth_divider.dart';

class AuthHeading extends StatelessWidget {
  
  final String text;
  final double fontSize;
  final double bottomMargin;

  AuthHeading({ required this.text, this.fontSize = 50, this.bottomMargin = 0.0 });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: AuthDivider(
        text: Text(
          text,
          style: TextStyle(
            fontSize: fontSize, 
            color: Colors.blue,
            fontWeight: FontWeight.bold, 
          ),
        )
      ),
    );
  }
}
