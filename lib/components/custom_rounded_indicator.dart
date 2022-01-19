
import 'package:flutter/material.dart';

class CustomRoundedIndicator extends StatelessWidget {

  final mark;
  final markColor;
  final markBgColor;

  CustomRoundedIndicator({ this.mark, this.markBgColor, this.markColor = Colors.black });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: (markBgColor == null) ? Colors.blue.shade100 : markBgColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white)

      ),
      //  Display icon if the mark is IconData
      //  Display text if the mark is String
      //  Display widget if the mark Widget
      child: (mark is IconData) ? Center(child: Icon(mark, color: markColor, )) : ((mark is String) ? Center(child: Text(mark, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: markColor),)) : mark)
    );
     
  }
}