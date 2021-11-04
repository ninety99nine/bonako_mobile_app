import 'package:flutter/material.dart';

class CustomRoundedRefreshButton extends StatelessWidget {

  final Function onPressed;

  CustomRoundedRefreshButton({ required this.onPressed });

  @override
  Widget build(BuildContext context) {

    return 
      //  Rounded Refresh Button
      OutlinedButton(
        onPressed: () => onPressed(), 
        child: Row(
          children: [
            Icon(Icons.refresh),
            SizedBox(width: 10),
            Text('Refresh'),
          ],
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            )
          )
        ),
      );
  }
}