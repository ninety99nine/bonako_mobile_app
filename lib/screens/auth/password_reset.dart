import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_input_field.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_mobile_number_instruction.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_user_account.dart';
import 'package:bonako_mobile_app/screens/auth/terms_and_conditions.dart';
import './../../screens/auth/components/auth_alternative_link.dart';
import './../../screens/auth/components/mobile_verification.dart';
import './../../components/custom_divider.dart';
import './../../screens/auth/components/auth_heading.dart';
import './../dashboard/stores/list/stores_screen.dart';
import './../../components/previous_step_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../../providers/auth.dart';
import './../../enum/enum.dart';
import 'package:get/get.dart';
import './login.dart';
import 'dart:convert';
import 'signup.dart';

class PasswordResetScreen extends StatefulWidget {

  static const routeName = '/password-reset';
  
  @override
  _PasswordResetScreenState createState() => _PasswordResetScreenState();

}

class _PasswordResetScreenState extends State<PasswordResetScreen> {

  Map passwordResetForm = {
    'password_confirmation': '',
    'verification_code': '',
    'mobile_number': '',
    'password': '',
  };

  Map passwordResetServerErrors = {};

  var isLoading = false;
  var hidePassword = true;
  var isSubmitting = false;
  var autoGenerateVerificationCode = true;

  Map userAccount = {};
  bool requiresPassword = false;
  bool requiresMobileNumberVerification = false;
  
  final GlobalKey<FormState> _formKey = GlobalKey();

  PasswordResetStage currPasswordResetStage = PasswordResetStage.enterMobile;

  ApiProvider get apiProvider {
    return Provider.of<ApiProvider>(context, listen: false);
  }

  AuthProvider get authProvider {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  void startLoader(){
    setState(() {
      isLoading = true;
    });
  }

  void stopLoader(){
    setState(() {
      isLoading = false;
    });
  }

  void startSubmittionLoader(){
    setState(() {
      isSubmitting = true;
    });
  }

  void stopSubmittionLoader(){
    setState(() {
      isSubmitting = false;
    });
  }

  @override
  void initState() {
    
    setPasswordResetDataFromDevice();
    
    super.initState();

  }

  void setPasswordResetDataFromDevice() async {
    
    startLoader();

    //  Set the forgot password data stored on the device
    await authProvider.setPasswordResetDataFromDevice().then((value){

      setState(() {
    
        //  If we have the forgot password data
        if( authProvider.hasPasswordResetData ){

          final passwordResetData = authProvider.getPasswordResetData;

          userAccount = passwordResetData['userAccount'];
          requiresPassword = passwordResetData['requiresPassword'];
          passwordResetForm = passwordResetData['passwordResetForm'];
          currPasswordResetStage = PasswordResetStage.values[passwordResetData['currPasswordResetStage']];
          requiresMobileNumberVerification = passwordResetData['requiresMobileNumberVerification'];

          //  If we should enter the verification code
          if(currPasswordResetStage == PasswordResetStage.enterVerificationCode){

            //  Disable automatic generation of verification code
            autoGenerateVerificationCode = false;

          }

        }

        final arguments = Get.arguments;

        //  Get arguments that may have been passed from login screen
        if( arguments != null ){

          //  Merge the form fields
          passwordResetForm = {
            ...passwordResetForm,
            ...arguments
          };

        }
        
      });

    }).whenComplete((){
      
      stopLoader();
      
    });

  }

  void storePasswordResetDataOnDevice({ bool reset = false }){

    Map<String, dynamic> passwordResetData = {
      'userAccount': userAccount,
      'requiresPassword': requiresPassword,
      'passwordResetForm': passwordResetForm,
      'currPasswordResetStage': currPasswordResetStage.index,
      'requiresMobileNumberVerification': requiresMobileNumberVerification,
    };

    //  If we must reset
    if(reset == true){

      //  Reset the forgot password data on the device
      authProvider.storePasswordResetDataLocallyAndOnDevice();

    }else{

      //  Store the forgot password data on the device
      authProvider.storePasswordResetDataLocallyAndOnDevice(passwordResetData: passwordResetData);

    }
    
  }
  
  void _onSubmit(){

    //  Reset server errors
    _resetPasswordResetServerErrors();

    if( currPasswordResetStage == PasswordResetStage.enterVerificationCode ){

      _handleResetPassword();

    }else{

      //  Validate the form
      validateForm().then((success){

        if( success ){

          //  Save inputs
          _formKey.currentState!.save();

          //  If local validation passed for the user account mobile number
          if( (currPasswordResetStage == PasswordResetStage.enterMobile) ){

            _handleMobileAccount();

          //  If local validation passed for the user account password
          }else if (currPasswordResetStage == PasswordResetStage.setNewPassword){

            _handleSetNewPassword();

          }
        
        //  If validation failed
        }else{

          apiProvider.showSnackbarMessage(msg: 'Check for mistakes', type: SnackbarType.error, context: context);

          storePasswordResetDataOnDevice();

        }

      });

    }

  }

  Future<bool> validateForm() async {

    /**
     * When running the _resetPasswordResetServerErrors(), we actually reset the passwordResetServerErrors = {}, 
     * however the AuthInputField() must render to pick up these changes. These changes will 
     * clear any previous server errors. Since the re-build of AuthInputField() may take
     * sometime, we don't want to validate the form too soon since we may use the old 
     * passwordResetServerErrors within AuthInputField() causing the form to fail
     * even if the user input correct information.
     */
    return await Future.delayed(const Duration(milliseconds: 100), () {

      // Run form validation
      return _formKey.currentState!.validate() == true;

    });
    
  }

  void _resetPasswordResetServerErrors(){
    setState(() {
      passwordResetServerErrors = {};
    });
  }

  void _handleResetPassword(){

    startSubmittionLoader();

    Provider.of<AuthProvider>(context, listen: false).resetUserAccountPassword(
      passwordConfirmation: passwordResetForm['password_confirmation'],
      verificationCode: passwordResetForm['verification_code'],
      mobileNumber: passwordResetForm['mobile_number'],
      password: passwordResetForm['password'],
      context: context
    ).then((response){

      _handleOnResetPasswordResponse(response);

    }).whenComplete((){

      stopSubmittionLoader();

    });
    
  }

  _handleSetNewPassword(){
    
    setState(() {
      currPasswordResetStage = PasswordResetStage.enterVerificationCode; 
      storePasswordResetDataOnDevice();
    });

  }

  void _handleOnResetPasswordResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 ){

      storePasswordResetDataOnDevice(reset: true);

      if( authProvider.hasAcceptedTermsAndConditions ){
      
        apiProvider.showSnackbarMessage(msg: 'Welcome back, '+userAccount['first_name']+'!', context: context);

        Get.offAll(() => StoresScreen());

      }else{

        Get.offAll(() => TermsAndConditionsScreen());

      }

    }

  }

  void _handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];

    /**
     *  validationErrors = {
     *    mobile_number: [Enter a valid mobile number containing only digits e.g 26771234567]
     *  }
     */
    validationErrors.forEach((key, value){
      passwordResetServerErrors[key] = value[0];
    });

    setState(() {

      final passwordError = validationErrors.containsKey('password');
      final mobileNumberError = validationErrors.containsKey('mobile_number');
      final verificationCodeError = validationErrors.containsKey('verification_code');

      //  If we have errors related to the mobile number
      if(mobileNumberError){

        currPasswordResetStage = PasswordResetStage.enterMobile;

      //  If we have errors related to the password
      }else if(passwordError){

        currPasswordResetStage = PasswordResetStage.setNewPassword;
      
      //  If we have errors related to the verification code
      }else if(verificationCodeError){
        
        currPasswordResetStage = PasswordResetStage.enterVerificationCode;

      }

      //  Validate the form only on the following conditions
      if( mobileNumberError || passwordError ){

        /**
         *  Since executing currPasswordResetStage = PasswordResetStage.enterVerificationCode
         *  will force the form to change the input fields, we need to give the
         *  application a chance to change the inputs before we can validate,
         *  we buy ourselves this time by delaying the execution of the form
         *  validation
         */
        Future.delayed(const Duration(milliseconds: 100), () {

            // Run form validation
          _formKey.currentState!.validate();

        });

      }
      
      storePasswordResetDataOnDevice();

    });
    
  }

  void _handleMobileAccount(){

    startSubmittionLoader();
  
    Provider.of<AuthProvider>(context, listen: false).checkIfMobileAccountExists(
      mobileNumber: passwordResetForm['mobile_number'],
      context: context
    ).then((response){

      _handleOnCheckAccountExistsResponse(response);

    }).whenComplete((){

      stopSubmittionLoader();

    });

  }

  void _handleOnCheckAccountExistsResponse(http.Response response){

    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 ){

      final Map responseBody = jsonDecode(response.body);

      final bool accountExists = (responseBody.containsKey('account_exists')) ? responseBody['account_exists'] : false;

      //  If we have a matching account
      if(accountExists){
        
        setState(() {
        
          userAccount = responseBody['user'];
          requiresPassword = userAccount['requires_password'];
          requiresMobileNumberVerification = userAccount['requires_mobile_number_verification'];
          
          currPasswordResetStage = PasswordResetStage.setNewPassword;

          storePasswordResetDataOnDevice();
          
        });

      //  If we don't have a matching account
      }else{

        _showDialog(
          title: 'Account does not exist', 
          message: _noAccountExistsDialogMessage(),
          buttonText: 'Register',
          onPressed: () {
          
            storePasswordResetDataOnDevice(reset: true);

            Get.offAll(() => SignUpScreen(), arguments: {
              'mobile_number': passwordResetForm['mobile_number'],
            });

          }
        );

      }
    }
  }

  void _showDialog({ required dynamic title, required dynamic message, String buttonText = 'Ok', Function()? onPressed, bool showCancelButton = true }){
    showDialog(context: context, builder: (ctx){
      return AlertDialog(
        title: (title is Widget) ? title : Text(title),
        content: (message is Widget) ? message : Text(message),
        actions: [
          if(showCancelButton) TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            }, 
            child: Text('Cancel')
          ),
          ElevatedButton(
            onPressed: (){
              if( onPressed == null ){
                Navigator.of(context).pop();
              }else{
                onPressed();
              }
            }, 
            child: Text(buttonText)
          )
        ],
      );
    });
  }

  Widget _noAccountExistsDialogMessage(){
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
        children: <TextSpan>[
          TextSpan(text: 'Could not find any account matching the mobile number '),
          TextSpan(
            text: passwordResetForm['mobile_number'], 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(
            text: '. Make sure you entered a correct mobile number', 
            style: TextStyle(fontSize: 12)
          ),
        ],
      )
    );
  }



  List<Widget> _passwordResetStageContent(){
    
    if( currPasswordResetStage == PasswordResetStage.enterMobile ){

      return [

        _headingText(),
        
        AuthMobileNumberInstruction(type: MobileNumberInstructionType.password_reset_enter_mobile,),

        if(isLoading == false) _passwordResetFormWidget(),

        if(isLoading == false) _submitButton(),

        if(isLoading == true) CustomLoader(bottomMargin: 40,),

        CustomDivider(),
      
        _loginLabel(),

      ];

    }else if( currPasswordResetStage == PasswordResetStage.setNewPassword ){
      
      return [

        _headingText(),

        _userAccountInfo(),
        
        if(isLoading == false) AuthMobileNumberInstruction(type: MobileNumberInstructionType.login_set_new_password,),

        if(isLoading == false) _passwordResetFormWidget(),

        if(isLoading == false) _submitWithBackButton(),

        if(isLoading == true) CustomLoader(bottomMargin: 40,),

        CustomDivider(),
      
        _loginLabel(),

      ];

    }else if( currPasswordResetStage == PasswordResetStage.enterVerificationCode ){

      return [
        
        if(isLoading == false) _verificationCodeField(),

        if(isLoading == true) CustomLoader(),

      ];
    
    }else{

      return [];

    }
  }

  Widget _headingText({ bottomMargin = 0.0 }) {
    return AuthHeading(text: 'Password Reset', fontSize: 32, bottomMargin: bottomMargin);
  }

  Widget _userAccountInfo(){
      
    return AuthUserAccount(userAccount: userAccount, requiresMobileNumberVerification: requiresMobileNumberVerification, topMargin: 20,);

  }

  Widget _passwordResetFormWidget() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[

            if( currPasswordResetStage == PasswordResetStage.enterMobile )
              _entryFieldMobile(),
      
            if(currPasswordResetStage == PasswordResetStage.setNewPassword)
              _entryFieldPassword(),
      
            if(currPasswordResetStage == PasswordResetStage.setNewPassword)
              _entryFieldConfirmPassword(),
      
          ],
        ),
      ),
    );
  }

  Widget _entryFieldMobile() {
    return AuthInputField(
      title: 'Mobile', 
      initialValue: passwordResetForm['mobile_number'], 
      serverErrors: passwordResetServerErrors,
      onChanged: (value){
        passwordResetForm['mobile_number'] = value;
      },
      onSaved: (value){
        passwordResetForm['mobile_number'] = value;
      }
    );
  }

  Widget _entryFieldPassword() {
    return AuthInputField(
      title: 'Password', 
      initialValue: passwordResetForm['password'],
      serverErrors: passwordResetServerErrors,
      hidePassword: hidePassword,
      onChanged: (value){
        passwordResetForm['password'] = value;
      },
      onSaved: (value){
        passwordResetForm['password'] = value;
      },
      onTogglePasswordVisibility: (){
        setState(() {
            hidePassword = !hidePassword;
        });
      }
    );
  }

  Widget _entryFieldConfirmPassword() {
    return AuthInputField(
      title: 'Confirm Password', 
      initialValue: passwordResetForm['password_confirmation'],
      serverErrors: passwordResetServerErrors,
      hidePassword: hidePassword,
      onChanged: (value){
        passwordResetForm['password_confirmation'] = value;
      },
      onSaved: (value){
        passwordResetForm['password_confirmation'] = value;
      },
      onTogglePasswordVisibility: (){
        setState(() {
            hidePassword = !hidePassword;
        });
      }
    );
  }

  Widget _verificationCodeField() {
    return MobileVerification(
      isProcessingSuccess: isSubmitting,
      mobileNumber: passwordResetForm['mobile_number'],
      autoGenerateVerificationCode: autoGenerateVerificationCode,
      mobileNumberInstructionType: MobileNumberInstructionType.mobile_verification_change_password,
      onCompleted: (value){
        setState(() {
          passwordResetForm['verification_code'] = value;
        });
      },
      onChanged: (value){
        setState(() {
          passwordResetForm['verification_code'] = value;
        });
      },
      onSuccess: (){
        _onSubmit();
      },
      onGoBack: (){
        setState(() {
          currPasswordResetStage = PasswordResetStage.enterMobile;
          storePasswordResetDataOnDevice();
        });
      },
      
    );
  }
  
  Widget _submitWithBackButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _previousStepButton(),
          _nextButton(),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return CustomButton(
      text: 'Submit',
      disabled: (isSubmitting),
      isLoading: isSubmitting,
      onSubmit: () {
        _onSubmit();
      },
    );
  }

  Widget _nextButton() {
    return Flexible(
      flex: 4,
      child: CustomButton(
        text: 'Next',
        disabled: (isSubmitting),
        isLoading: isSubmitting,
        onSubmit: () {
          _onSubmit();
        },
      ),
    );
  }

  Widget _previousStepButton() {
    return Flexible(
      child: PreviousStepButton(
        onTap: () {
          setState(() {
            currPasswordResetStage = PasswordResetStage.enterMobile;
            storePasswordResetDataOnDevice();
          });
        }
      )
    );
  }

  Widget _loginLabel() {
    return AuthAlternativeLink(
      linkText: 'Login',
      messageText: 'Have an account ?',
      onTap: () {

        //  Reset the registration data stored on the device
        storePasswordResetDataOnDevice(reset: true);

        Get.offAll(() => LoginScreen(), arguments: {
          'mobile_number': passwordResetForm['mobile_number'],
        });

      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    SizedBox(height: height * 0.1),

                    ..._passwordResetStageContent()

                  ],
                ),
              ),
            ), 
          ),
        )
      )
    );
  }

}