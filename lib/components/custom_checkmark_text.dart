import 'package:flutter/material.dart';

class CustomCheckmarkText extends StatelessWidget {

  final String text;

  CustomCheckmarkText({ this.text = '' });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_outlined, color: Colors.green, size: 12),
          SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 12),)
        ],
      ),
    );
  }

}