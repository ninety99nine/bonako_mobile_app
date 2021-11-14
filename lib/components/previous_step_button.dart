
import 'package:flutter/material.dart';

class PreviousStepButton extends StatelessWidget {

  final Function()? onTap;

  PreviousStepButton({ this.onTap });

  @override
  Widget build(BuildContext context) {
    return 
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2
            )
          ],
          color: Colors.grey.shade400
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.blue,
            child: Container(
              alignment: Alignment.center,
              width: 55,
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Icon(Icons.arrow_back, color: Colors.white,),
            ),
          ),
        ),
      );
  }
}