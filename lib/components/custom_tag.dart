import 'package:flutter/material.dart';

class CustomTag extends StatelessWidget {
  
  final text;
  final String boldedText;
  final MaterialColor color;

  CustomTag({ this.text = '', this.boldedText = '', this.color = Colors.green });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade200)
      ),
      child: (text is Widget) ? text : RichText(
        text: TextSpan(
          style: TextStyle(color: color),
          children: <TextSpan>[
            if(text != '') TextSpan(text: text, style: TextStyle(fontSize: 12, color: color ),),
            if(boldedText != '') TextSpan(text: boldedText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      )
    );
  }
}
