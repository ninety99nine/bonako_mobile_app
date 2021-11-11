import 'package:flutter/material.dart';

class CustomCheckmarkText extends StatelessWidget {

  final String text;
  final String state;

  CustomCheckmarkText({ this.text = '', this.state = 'success' });

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
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 12),
          SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 12),)
        ],
      ),
    );
  }

}