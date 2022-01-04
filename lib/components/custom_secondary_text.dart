import 'package:flutter/material.dart';

class CustomSecondaryText extends StatelessWidget {

  final String text;

  CustomSecondaryText({ this.text = '' });

  @override
  Widget build(BuildContext context) {

    return Text(
      text, 
      style: TextStyle(fontSize: 12, color: Colors.grey)
    );
  }
}