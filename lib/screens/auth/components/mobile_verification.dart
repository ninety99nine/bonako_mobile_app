import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/components/previous_step_button.dart';
import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_divider.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_heading.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './../../../enum/enum.dart';
import 'dart:convert';

class MobileVerification extends StatefulWidget {

  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final bool showPreviousStepButton;
  final bool isProcessingSuccess;
  final Function()? onSuccess;
  final Function()? onGoBack;
  final String mobileNumber;

  MobileVerification({ required this.mobileNumber, this.onCompleted, this.onChanged , this.showPreviousStepButton = true, this.onGoBack, this.onSuccess, this.isProcessingSuccess = true });

  @override
  _MobileVerificationState createState() => _MobileVerificationState();
  
}

class _MobileVerificationState extends State<MobileVerification> {

  Map serverErrors = {};
  var isVerifyingCode = false;
  String verificationCode = '';
  var isGeneratingVerificationCode = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    _generateMobileVerification();
    
    super.initState();
  }

  void startLoader(){
    setState(() {
      isGeneratingVerificationCode = true;
    });
  }

  void stoptLoader(){
    setState(() {
      isGeneratingVerificationCode = false;
    });
  }

  void startVerifyVerificationCodeLoader(){
    setState(() {
      isVerifyingCode = true;
    });
  }

  void stopVerifyVerificationCodeLoader(){
    setState(() {
      isVerifyingCode = false;
    });
  }

  AuthProvider get authProvider {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  void _generateMobileVerification(){

    print('_generateMobileVerification()');

    startLoader();

    authProvider.generateMobileVerification(
      type: MobileVerificationType.account_registration,
      mobileNumber: widget.mobileNumber,
      context: context
    ).then((response){

      _handleResponse(response);

      if( response.statusCode == 200){
        
        authProvider.showSnackbarMessage(msg: 'Verification code created', context: context);

      }else{

        authProvider.showSnackbarMessage(msg: 'Verification code failed', context: context);

      }

    }).whenComplete((){

      stoptLoader();

    });

  }

  void _verifyMobileVerificationCode(){

    print('_verifyMobileVerificationCode()');

    startVerifyVerificationCodeLoader();

    authProvider.verifyMobileVerificationCode(
      type: MobileVerificationType.account_registration,
      mobileNumber: widget.mobileNumber,
      code: verificationCode,
      context: context
    ).then((response){

      _handleResponse(response);

      if( response.statusCode == 200){

        final responseBody = jsonDecode(response.body);
        final bool isValid = responseBody['is_valid'];

        if( isValid ){

          if( widget.onSuccess != null ){
            widget.onSuccess!();
          }

          //  createUserAccount();

        }else{

          authProvider.showSnackbarMessage(msg: 'Incorrect verification code', type: SnackbarType.error, context: context);
          
        }

      }

    }).whenComplete((){

      stopVerifyVerificationCodeLoader();

    });

  }

  void _handleResponse(http.Response response){

    print('response.statusCode');
    print(response.statusCode);

    print('jsonDecode(response.body)');
    print(jsonDecode(response.body));
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }

  }

  void _handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];
    
    validationErrors.forEach((key, value){
      serverErrors[key] = value[0];
    });
    
    // Run form validation
   _formKey.currentState!.validate();
    
  }

  Widget _headingText() {
    return AuthHeading(text: 'Verify Mobile', fontSize: 32,);
  }

  Widget _verificationInput(){
    return Column(
      children: [
        if(isGeneratingVerificationCode == true) Text('Generating verification code...'),
        if(isGeneratingVerificationCode == false) RichText(
          textAlign: TextAlign.justify,
          text: TextSpan(
            style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
            children: <TextSpan>[
              TextSpan(text: 'Dial '),
              TextSpan(
                text: authProvider.apiProvider.getVerifyUserAccountShortcode, 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, decoration: TextDecoration.underline), 
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    //  storesProvider.launchVisitShortcode(store: store, context: context);
                  }),
              TextSpan(text: ' on '),
              TextSpan(
                text: widget.mobileNumber, 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              TextSpan(text: ' to verify that the mobile number belongs to you. Enter the '),
              TextSpan(
                text: '6 digit verification code', 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              TextSpan(text: ' below'),
            ],
          ),
        ),
        SizedBox(height: 20),
        PinCodeTextField(
          length: 6,
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
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Colors.white,
            */
          ),
          animationDuration: Duration(milliseconds: 300),
          //  backgroundColor: Colors.blue.shade50,
          enableActiveFill: true,
          //  errorAnimationController: errorController,
          //  controller: textEditingController,

          onCompleted: (value){
            verificationCode = value;

            if(widget.onCompleted != null){
              widget.onCompleted!(value);
            }
          },
          onChanged: (value){
            verificationCode = value;

            if(widget.onChanged != null){
              widget.onChanged!(value);
            }
          },
          beforeTextPaste: (text) {
            print("Allowing to paste $text");
            //  If you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
            //  but you can show anything you want here, like your pop up saying wrong paste format or etc
            return true;
          },
        ),
      ],
    );
  }

  Widget _verifyButton() {
    return Flexible(
      flex: 4,
      child: CustomButton(
        text: 'Verify',
        disabled: (isGeneratingVerificationCode || isVerifyingCode || verificationCode.length < 6 ),
        isLoading: isVerifyingCode,
        onSubmit: () {
          _verifyMobileVerificationCode();
        },
      ),
    );
  }

  Widget _previousStepButton() {
    return Flexible(
      child: PreviousStepButton(
        onTap: () {
          if( widget.onGoBack != null ){
            widget.onGoBack!();
          }
        }
      )
    );
  }
  
  Widget _verifyWithBackButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(widget.showPreviousStepButton) _previousStepButton(),
          _verifyButton(),
        ],
      ),
    );
  }

  Widget _processing() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          CustomLoader(text: 'One moment ...'),
           Divider(height: 100)
        ],
      ),
    );
  }

  Widget _resendVerificationCode() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: TextButton(
        onPressed: (){
          _generateMobileVerification();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Icon(Icons.sms_outlined, color: Colors.green,),
            SizedBox(width: 10),
            Text(
              'Resend verification code',
              style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
      
          SizedBox(height: height * 0.1),
    
          _headingText(),
          SizedBox(height: 20),
            
          if(!widget.isProcessingSuccess) _verificationInput(),
          if(!widget.isProcessingSuccess) SizedBox(height: 20),
            
          if(!widget.isProcessingSuccess) _verifyWithBackButton(),
          if(widget.isProcessingSuccess) _processing(),
          if(!widget.isProcessingSuccess) SizedBox(height: 20),
    
          if(!widget.isProcessingSuccess) AuthDivider(text: Text('or') ),
      
          if(!widget.isProcessingSuccess && !isGeneratingVerificationCode) _resendVerificationCode(),
            
        ],
      ),
    );
  }
}
