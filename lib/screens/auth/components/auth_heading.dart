import 'package:flutter/material.dart';
import './../../../components/custom_divider.dart';

class AuthHeading extends StatelessWidget {
  
  final String text;
  final double fontSize;
  final double bottomMargin;

  AuthHeading({ required this.text, this.fontSize = 50, this.bottomMargin = 0.0 });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: CustomDivider(
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
