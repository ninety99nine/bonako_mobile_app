import 'package:flutter/material.dart';

class CustomCheckmarkText extends StatelessWidget {

  final String text;
  final String state;
  final EdgeInsets margin;

  CustomCheckmarkText({ this.text = '', this.state = 'success', this.margin = const EdgeInsets.only(bottom: 5) });

  IconData get icon {
    if(state == 'warning'){
      return Icons.error_outline;
    }else{
      return Icons.check_circle_outline_outlined;
    }
  }

  Color get iconColor {
    if(state == 'warning'){
      return Colors.orange;
    }else{
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 12),
          SizedBox(width: 5),
          Flexible(child: Text(text, style: TextStyle(fontSize: 12),))
        ],
      ),
    );
  }

}