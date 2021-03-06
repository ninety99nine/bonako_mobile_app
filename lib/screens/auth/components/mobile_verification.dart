import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/components/previous_step_button.dart';
import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/components/custom_divider.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_heading.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_mobile_number_instruction.dart';
import 'package:bonako_mobile_app/screens/auth/components/mobile_verification_pin_code_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import './../../../enum/enum.dart';
import 'dart:convert';

class MobileVerification extends StatefulWidget {

  final MobileNumberInstructionType mobileNumberInstructionType;
  final Function()? onGenerateMobileVerificationCode;
  final bool autoGenerateVerificationCode;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final bool showPreviousStepButton;
  final bool isProcessingSuccess;
  final Function()? onSuccess;
  final Function()? onGoBack;
  final bool hideHeadingText;
  final String mobileNumber;
  final bool hideBackButton;
  final String headingText;
  final String verifyText;
  final Map metadata;

  MobileVerification({ this.metadata = const {}, this.hideBackButton = false, this.verifyText = 'Verify', required this.mobileNumberInstructionType, required this.mobileNumber, this.autoGenerateVerificationCode = true, this.onCompleted, this.onChanged , this.showPreviousStepButton = true, this.onGoBack, this.onSuccess, this.isProcessingSuccess = true, this.hideHeadingText = false, this.headingText = 'Verify Mobile', this.onGenerateMobileVerificationCode });

  @override
  _MobileVerificationState createState() => _MobileVerificationState();
  
}

class _MobileVerificationState extends State<MobileVerification> {

  Map serverErrors = {};
  var isVerifyingCode = false;
  String verificationCode = '';
  bool hasGeneratedCode = false;
  var isGeneratingVerificationCode = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {

    if(widget.autoGenerateVerificationCode == true){

      _generateMobileVerification();

    }
    
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

  ApiProvider get apiProvider {
    return Provider.of<ApiProvider>(context, listen: false);
  }

  AuthProvider get authProvider {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  MobileVerificationType get mobileVerificationType {
    if( widget.mobileNumberInstructionType == MobileNumberInstructionType.mobile_verification_order_delivery_confirmation ){
      return MobileVerificationType.order_delivery_confirmation;

    }else if(widget.mobileNumberInstructionType == MobileNumberInstructionType.mobile_verification_change_password ){
      return MobileVerificationType.password_reset;

    }else {
      return MobileVerificationType.account_ownership;

    }
  }

  void _generateMobileVerification() async {

    startLoader();

    await authProvider.generateMobileVerification(
      type: mobileVerificationType,
      mobileNumber: widget.mobileNumber,
      metadata: widget.metadata,
      context: context
    ).then((response){

      if(response.statusCode == 200){

        setState(() {

          //  Indicate that the code was generated
          hasGeneratedCode = true;
          
        });
        
      }

      _handleResponse(response);

    }).whenComplete((){

      stoptLoader();

    });

    if( widget.onGenerateMobileVerificationCode != null){
      
      widget.onGenerateMobileVerificationCode!();

    }

  }

  void _verifyMobileVerificationCode(){

    startVerifyVerificationCodeLoader();

    authProvider.verifyMobileVerificationCode(
      type: mobileVerificationType,
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

          apiProvider.showSnackbarMessage(msg: 'Incorrect verification code', type: SnackbarType.error, context: context);
          
        }

      }

    }).whenComplete((){

      stopVerifyVerificationCodeLoader();

    });

  }

  void _handleResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      apiProvider.showSnackbarMessage(msg: 'Verification code failed', context: context);

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
    return AuthHeading(text: widget.headingText, fontSize: 32,);
  }

  Widget _instructionText(){
    return AuthMobileNumberInstruction(
      type: widget.mobileNumberInstructionType, 
      mobileNumber: widget.mobileNumber,
      hasGeneratedCode: hasGeneratedCode
    );
  }

  Widget _verificationInput(){
    return MobileVerificationPinCodeInput(
      length: 6,
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
    );
  }

  Widget _instructionTextAndVerificationInput(){
    return Column(
      children: [
        if(isGeneratingVerificationCode == true) CustomLoader(text: 'Generating verification code'),
        if(isGeneratingVerificationCode == false) _instructionText(),
        if(hasGeneratedCode) _verificationInput(),
      ],
    );
  }

  Widget _verifyButton() {
    return CustomButton(
      text: widget.verifyText,
      disabled: (isGeneratingVerificationCode || isVerifyingCode || verificationCode.length < 6 ),
      isLoading: isVerifyingCode,
      onSubmit: () {
        _verifyMobileVerificationCode();
      },
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
          Flexible(flex: 4, child: _verifyButton()),
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

  Widget _sendVerificationCode() {

    final onPressed = (){
      _generateMobileVerification();
    };

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Icon(Icons.speaker_phone, color: hasGeneratedCode ? Colors.green : Colors.white,),
        SizedBox(width: 10),
        Text(
          (hasGeneratedCode ? 'Resend' : 'Send') + ' verification code',
          style: TextStyle(color: hasGeneratedCode ? Colors.green : Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.only(top: hasGeneratedCode ? 20 : 0),
      child: hasGeneratedCode 
        ? TextButton(
            onPressed: onPressed,
            child: child,
          )
        : ElevatedButton(
            onPressed: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: child,
            ),
          )
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
      
          if(widget.hideHeadingText == false) SizedBox(height: height * 0.1),
    
          if(widget.hideHeadingText == false) _headingText(),
          if(widget.hideHeadingText == false) SizedBox(height: 20),
            
          if(!widget.isProcessingSuccess) _instructionTextAndVerificationInput(),
          if(!widget.isProcessingSuccess) SizedBox(height: 20),
            
          if(!widget.isProcessingSuccess && widget.hideBackButton && hasGeneratedCode) _verifyButton(),
          if(!widget.isProcessingSuccess && !widget.hideBackButton) _verifyWithBackButton(),
          if(widget.isProcessingSuccess) _processing(),
          if(!widget.isProcessingSuccess && hasGeneratedCode) SizedBox(height: 20),
    
          if(!widget.isProcessingSuccess && hasGeneratedCode) CustomDivider(text: Text('or') ),
      
          if(!widget.isProcessingSuccess && !isGeneratingVerificationCode) _sendVerificationCode(),
            
        ],
      ),
    );
  }
}
