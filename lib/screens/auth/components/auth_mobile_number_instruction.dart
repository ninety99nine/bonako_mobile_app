import './../../../providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './../../../enum/enum.dart';

class AuthMobileNumberInstruction extends StatelessWidget {

  final String mobileNumber;
  final MobileNumberInstructionType type;

  AuthMobileNumberInstruction({ this.type = MobileNumberInstructionType.login_enter_mobile, this.mobileNumber = '###' });

  List<TextSpan> loginEnterMobile(){
    return [
      TextSpan(text: 'Enter your '),
      TextSpan(
        text: 'Orange', 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
      ),
      TextSpan(
        text: ' mobile number to login', 
        style: TextStyle(fontSize: 12)
      ),
    ];
  }

  List<TextSpan> loginSetPassword(){
    return [
      TextSpan(text: 'Set your '),
      TextSpan(
        text: 'new password', 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
      ),
      TextSpan(
        text: ' to login', 
        style: TextStyle(fontSize: 12)
      ),
    ];
  }

  List<TextSpan> mobileVerificationOwnership(BuildContext context){

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dialingCode = authProvider.apiProvider.getVerifyUserAccountShortcode;

    return [
      TextSpan(text: 'Dial '),
      TextSpan(
        text: authProvider.apiProvider.getVerifyUserAccountShortcode, 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, decoration: TextDecoration.underline), 
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            authProvider.launchShortcode (dialingCode: dialingCode, loadingMsg: 'Preparing verification', context: context);
          }),
      TextSpan(text: ' on '),
      TextSpan(
        text: mobileNumber, 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      TextSpan(text: ' to verify that the mobile number belongs to you. Enter the '),
      TextSpan(
        text: '6 digit verification code', 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      TextSpan(text: ' below'),
    ];
  }

  List<TextSpan> mobileVerificationChangePassword(BuildContext context){

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return [
      TextSpan(text: 'Dial '),
      TextSpan(
        text: authProvider.apiProvider.getVerifyUserAccountShortcode, 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, decoration: TextDecoration.underline), 
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            
            final dialingCode = authProvider.apiProvider.getVerifyUserAccountShortcode;
            
            if( dialingCode.isNotEmpty ){
              authProvider.launchShortcode(dialingCode: dialingCode, loadingMsg: 'Loading...', context: context);
            }

          }),
      TextSpan(text: ' on '),
      TextSpan(
        text: mobileNumber, 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      TextSpan(text: ' to confirm changes to your password. Enter the '),
      TextSpan(
        text: '6 digit verification code', 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      TextSpan(text: ' below'),
    ];
  }

  List<TextSpan> mobileVerificationOrderDeliveryConfirmation(BuildContext context){

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return [
      TextSpan(text: 'Inform your customer to dial '),
      TextSpan(
        text: authProvider.apiProvider.getVerifyUserAccountShortcode, 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, decoration: TextDecoration.underline), 
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            
            final dialingCode = authProvider.apiProvider.getVerifyUserAccountShortcode;
            
            if( dialingCode.isNotEmpty ){
              authProvider.launchShortcode(dialingCode: dialingCode, loadingMsg: 'Loading...', context: context);
            }

          }),
      TextSpan(text: ' on their mobile number '),
      TextSpan(
        text: mobileNumber, 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      TextSpan(text: ' to confirm that they have paid and received their order. Enter the '),
      TextSpan(
        text: '6 digit verification code', 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
      ),
      TextSpan(text: ' below'),
    ];
  }

  List<TextSpan> passwordResetEnterMobile(){
    return [
      TextSpan(text: 'Enter your '),
      TextSpan(
        text: 'Orange', 
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
      ),
      TextSpan(
        text: ' mobile number, then click the submit button to reset your password', 
        style: TextStyle(fontSize: 12)
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {

    List<TextSpan> textSpan = [];
    IconData icon = Icons.phone_android;

    if( type == MobileNumberInstructionType.login_enter_mobile ){

      textSpan = loginEnterMobile();

    }else if( type == MobileNumberInstructionType.login_set_new_password ){

      textSpan = loginSetPassword();
      icon = Icons.password_outlined;

    }else if( type == MobileNumberInstructionType.password_reset_enter_mobile ){

      textSpan = passwordResetEnterMobile();

    }else if( type == MobileNumberInstructionType.mobile_verification_ownership ){

      textSpan = mobileVerificationOwnership(context);
      icon = Icons.dialpad_rounded;

    }else if( type == MobileNumberInstructionType.mobile_verification_change_password ){

      textSpan = mobileVerificationChangePassword(context);
      icon = Icons.dialpad_rounded;

    }else if( type == MobileNumberInstructionType.mobile_verification_order_delivery_confirmation ){

      textSpan = mobileVerificationOrderDeliveryConfirmation(context);
      icon = Icons.dialpad_rounded;

    }

    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 10),
          Flexible(
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                children: textSpan,
              )
            ),
          )
        ],
      ),
    );
  }
}
