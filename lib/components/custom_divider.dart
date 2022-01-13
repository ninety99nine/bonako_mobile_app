import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  
  final text;
  final double topMargin;
  final double leftMargin;
  final double rightMargin;
  final double bottomMargin;
  final bool showLeftDivider;
  final bool showRightDivider;
  final CrossAxisAlignment alignment;

  CustomDivider({ 
    this.topMargin = 10.0, 
    this.leftMargin = 20.0, 
    this.rightMargin = 20.0, 
    this.bottomMargin = 10.0, 
    this.showLeftDivider = true,
    this.showRightDivider = true,  
    this.text = const Text('or'),
    this.alignment = CrossAxisAlignment.end
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin, left: leftMargin, right: rightMargin),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if(showLeftDivider) Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          (text is Widget) ? text : Text(text),
          if(showRightDivider) Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
