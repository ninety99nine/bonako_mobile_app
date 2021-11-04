import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {

  final double size;
  final String? text;
  final double topMargin;
  final double bottomMargin;
  final double strokeWidth;

  CustomLoader({ this.size = 20, this.text, this.topMargin = 20, this.bottomMargin = 0, this.strokeWidth = 4.0 });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size,
            height: size,
            alignment: (text == null) ? Alignment.center : Alignment.centerLeft,
            child: CircularProgressIndicator(color: Colors.blue, strokeWidth: strokeWidth,),
          ),
          if(text != null) SizedBox(width: 15),
          if(text != null) Text(text!, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),)
        ],
      ),
    );
  }
}