
import 'package:flutter/material.dart';

class CustomInstructionMessage extends StatelessWidget {

  final String text;

  CustomInstructionMessage({ required this.text });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Icon(Icons.info_outline, color: Colors.blue, size: 12,),
          ),
          SizedBox(width: 5),
          Flexible(
            child: Text(text, style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.4),),
          )
        ],
      ),
    );
  }
  
}