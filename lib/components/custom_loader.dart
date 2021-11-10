import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {

  final double size;
  final Color color;
  final String? text;
  final double topMargin;
  final double leftMargin;
  final double bottomMargin;
  final double rightPadding;
  final double strokeWidth;

  CustomLoader({ this.size = 20, this.color = Colors.blue, this.text, this.topMargin = 20, this.leftMargin = 0, this.bottomMargin = 0, this.rightPadding = 0, this.strokeWidth = 4.0 });

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.only(right: rightPadding), 
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin, left: leftMargin), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size,
            height: size,
            alignment: (text == null) ? Alignment.center : Alignment.centerLeft,
            child: CircularProgressIndicator(color: color, strokeWidth: strokeWidth,),
          ),
          if(text != null) SizedBox(width: 15),
          if(text != null) Text(text!, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),)
        ],
      ),
    );
  }
}