import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';

class MobileVerificationPinCodeInput extends StatelessWidget {

  final int length;
  final Function(String)? onCompleted;
  final void Function(String) onChanged;
  final bool Function(String?)? beforeTextPaste;

  MobileVerificationPinCodeInput({ this.length = 6, this.onCompleted, required this.onChanged, this.beforeTextPaste });

  @override
  Widget build(BuildContext context) {

    return PinCodeTextField(
      length: length,
      obscureText: false,
      appContext: context,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.underline,

        activeColor: Colors.green,
        activeFillColor: Colors.green.withOpacity(0.05),

        selectedColor: Colors.green,
        selectedFillColor: Colors.transparent,

        inactiveColor: Colors.grey,
        inactiveFillColor: Colors.transparent,

        /*
        borderRadius: BorderRadius.circular(5),
        activeFillColor: Colors.white,
        fieldHeight: 50,
        fieldWidth: 40,
        */
      ),
      //  errorAnimationController: errorController,
      //  backgroundColor: Colors.blue.shade50,
      //  controller: textEditingController,
      animationDuration: Duration(milliseconds: 300),
      onCompleted: onCompleted,
      beforeTextPaste: beforeTextPaste,
      enableActiveFill: true,
      onChanged: onChanged,
    );

  }
}
