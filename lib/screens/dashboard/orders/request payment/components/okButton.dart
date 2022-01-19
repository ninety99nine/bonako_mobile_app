import './../../../../../components/custom_button.dart';
import 'package:flutter/material.dart';

class OkButton extends StatelessWidget {

  const OkButton({ required this.context });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [

        //  Back Button
        CustomButton(
          text: 'Ok',
          width: 100,
          size: 'small',
          onSubmit: (){ 

            //  Remove the alert dialog and return False as final value
            Navigator.of(context).pop();

          }
        ),

      ],
    );
  }
}