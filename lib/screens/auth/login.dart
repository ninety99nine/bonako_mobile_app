import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_input_field.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_mobile_number_instruction.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_user_account.dart';
import 'package:bonako_mobile_app/screens/auth/terms_and_conditions.dart';

import './../../screens/auth/components/auth_alternative_link.dart';
import './../../screens/auth/components/mobile_verification.dart';
import './../../screens/auth/components/auth_heading.dart';
import './../dashboard/stores/list/stores_screen.dart';
import './../../components/previous_step_button.dart';
import './../../components/custom_divider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../../providers/auth.dart';
import './../../enum/enum.dart';
import 'password_reset.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'signup.dart';

class LoginScreen extends StatefulWidget {

  static const routeName = '/login';
  
  @override
  _LoginScreenState createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {

  Map loginForm = {
    'password_confirmation': '',
    'verification_code': '',
    'mobile_number': '',
    'password': '',
  };

  Map loginServerErrors = {};

  var isLoading = false;
  var hidePassword = true;
  var isSubmitting = false;
  var autoGenerateVerificationCode = true;

  Map userAccount = {};
  bool requiresPassword = false;
  bool requiresMobileNumberVerification = false;
  
  final GlobalKey<FormState> _formKey = GlobalKey();

  LoginStage currLoginStage = LoginStage.enterMobile;

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
    
    setLoginDataFromDevice();
    
    super.initState();

  }

  void setLoginDataFromDevice() async {
    
    startLoader();

    //  Set the login data stored on the device
    await authProvider.setLoginDataFromDevice().then((value){

      setState(() {
    
        //  If we have the login data
        if( authProvider.hasLoginData ){

          final loginData = authProvider.getLoginData;

          loginForm = loginData['loginForm'];
          userAccount = loginData['userAccount'];
          requiresPassword = loginData['requiresPassword'];
          currLoginStage = LoginStage.values[loginData['currLoginStage']];
          requiresMobileNumberVerification = loginData['requiresMobileNumberVerification'];

          //  If we should enter the verification code
          if(currLoginStage == LoginStage.enterVerificationCode){

            //  Disable automatic generation of verification code
            autoGenerateVerificationCode = false;

          }

        }

        final arguments = Get.arguments;

        //  Get arguments that may have been passed from login screen
        if( arguments != null ){

          //  Merge the form fields
          loginForm = {
            ...loginForm,
            ...arguments
          };

        }
        
      });

    }).whenComplete((){
      
      stopLoader();
      
    });

  }

  void storeLoginDataOnDevice({ bool reset = false }){

    Map<String, dynamic> loginData = {
      'userAccount': userAccount,
      'loginForm': loginForm,
      'requiresPassword': requiresPassword,
      'currLoginStage': currLoginStage.index,
      'requiresMobileNumberVerification': requiresMobileNumberVerification,
    };

    //  If we must reset
    if(reset == true){

      //  Reset the login data on the device
      authProvider.storeLoginDataLocallyAndOnDevice();

    }else{

      //  Store the login data on the device
      authProvider.storeLoginDataLocallyAndOnDevice(loginData: loginData);

    }
    
  }
  
  void _onLogin(){

    //  Reset server errors
    _resetloginServerErrors();

    if( currLoginStage == LoginStage.enterVerificationCode ){

      _handleAttemptLogin();

    }else{

      //  Validate the form
      validateForm().then((success){

        if( success ){

          //  Save inputs
          _formKey.currentState!.save();

          //  If local validation passed for the user account mobile number
          if( (currLoginStage == LoginStage.enterMobile) ){

            _handleMobileAccount();

          //  If local validation passed for the user account password
          }else if (currLoginStage == LoginStage.enterPassword){
            
            _handleEnterExistingPassword();

          //  If local validation passed for the user account password
          }else if (currLoginStage == LoginStage.setNewPassword){

            _handleSetNewPassword();

          }
        
        //  If validation failed
        }else{

          apiProvider.showSnackbarMessage(msg: 'Check for mistakes', type: SnackbarType.error, context: context);

          storeLoginDataOnDevice();

        }

      });

    }

  }

  Future<bool> validateForm() async {

    /**
     * When running the _resetloginServerErrors(), we actually reset the loginServerErrors = {}, 
     * however the AuthInputField() must render to pick up these changes. These changes will 
     * clear any previous server errors. Since the re-build of AuthInputField() may take
     * sometime, we don't want to validate the form too soon since we may use the old 
     * loginServerErrors within AuthInputField() causing the form to fail even if the 
     * user input correct information.
     */
    return await Future.delayed(const Duration(milliseconds: 100), () {

      // Run form validation
      return _formKey.currentState!.validate() == true;

    });
    
  }

  void _resetloginServerErrors(){
    setState(() {
      loginServerErrors = {};
    });
  }

  void _handleAttemptLogin(){

    startSubmittionLoader();

    Provider.of<AuthProvider>(context, listen: false).loginWithMobile(
      passwordConfirmation: loginForm['password_confirmation'],
      verificationCode: loginForm['verification_code'],
      mobileNumber: loginForm['mobile_number'],
      password: loginForm['password'],
      context: context
    ).then((response){

      _handleOnLoginResponse(response);

    }).whenComplete((){

      stopSubmittionLoader();

    });
    
  }

  _handleEnterExistingPassword(){

    //  If the user account requires verification
    if( requiresMobileNumberVerification == true ){
    
      setState(() {
        currLoginStage = LoginStage.enterVerificationCode;
        storeLoginDataOnDevice();
      });

    }else{

      _handleAttemptLogin();

    }
    
  }

  _handleSetNewPassword(){
    
    setState(() {
      currLoginStage = LoginStage.enterVerificationCode; 
      storeLoginDataOnDevice();
    });

  }

  void _handleOnLoginResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 ){

      storeLoginDataOnDevice(reset: true);

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
      loginServerErrors[key] = value[0];
    });

    setState(() {

      final passwordError = validationErrors.containsKey('password');
      final mobileNumberError = validationErrors.containsKey('mobile_number');
      final verificationCodeError = validationErrors.containsKey('verification_code');

      //  If we have errors related to the mobile number
      if(mobileNumberError){

        currLoginStage = LoginStage.enterMobile;

      //  If we have errors related to the password
      }else if(passwordError){

        if(requiresPassword){
          currLoginStage = LoginStage.setNewPassword;
        }else{
          currLoginStage = LoginStage.enterPassword;
        }
      
      //  If we have errors related to the verification code
      }else if(verificationCodeError){
        
        currLoginStage = LoginStage.enterVerificationCode;

      }

      //  Validate the form only on the following conditions
      if( mobileNumberError || passwordError ){

        /**
         *  Since executing currLoginStage = LoginStage.enterVerificationCode
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

      storeLoginDataOnDevice();

    });
    
  }

  void _handleMobileAccount(){

    startSubmittionLoader();
  
    Provider.of<AuthProvider>(context, listen: false).checkIfMobileAccountExists(
      mobileNumber: loginForm['mobile_number'],
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

          //  If the user account requires a new password
          if( requiresPassword ){
          
            currLoginStage = LoginStage.setNewPassword;

          }else{
          
            currLoginStage = LoginStage.enterPassword;

          }

          storeLoginDataOnDevice();
          
        });

      //  If we don't have a matching account
      }else{

        _showDialog(
          title: 'Account does not exist', 
          message: _noAccountExistsDialogMessage(),
          buttonText: 'Register',
          onPressed: () {
          
            storeLoginDataOnDevice(reset: true);

            Get.offAll(() => SignUpScreen(), arguments: {
              'mobile_number': loginForm['mobile_number'],
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
            text: loginForm['mobile_number'], 
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



  List<Widget> _loginStageContent(){
    
    if( currLoginStage == LoginStage.enterMobile ){

      return [

        _headingText(),
        
        AuthMobileNumberInstruction(),

        if(isLoading == false) _loginFormWidget(),

        if(isLoading == false) _nextStepButton(),

        if(isLoading == true) CustomLoader(bottomMargin: 40,),

        if(isLoading == false) _forgotPassword(),

        CustomDivider(),
      
        _createAccountLabel(),

      ];

    }else if( currLoginStage == LoginStage.setNewPassword ){
      
      return [

        _headingText(),
        
        if(isLoading == false) AuthMobileNumberInstruction(type: MobileNumberInstructionType.login_set_new_password,),

        if(isLoading == false) _loginFormWidget(),

        if(isLoading == false) _loginWithBackButton(),

        if(isLoading == true) CustomLoader(bottomMargin: 40,),

        if(isLoading == false) _forgotPassword(),

        CustomDivider(),
      
        _createAccountLabel(),

      ];

    }else if( currLoginStage == LoginStage.enterVerificationCode ){

      return [
        
        if(isLoading == false) _verificationCodeField(),

        if(isLoading == true) CustomLoader(),

      ];
    
    }else{
      
      return [

        _headingText(bottomMargin: 20.0),

        _userAccountInfo(),

        if(isLoading == false) _loginFormWidget(),

        if(isLoading == false) _loginWithBackButton(),

        if(isLoading == true) CustomLoader(bottomMargin: 40,),

        if(isLoading == false) _forgotPassword(),

        CustomDivider(),
      
        _createAccountLabel(),

      ];

    }
  }

  Widget _headingText({ bottomMargin = 0.0 }) {
    return AuthHeading(text: 'Login', fontSize: 50, bottomMargin: bottomMargin);
  }

  Widget _userAccountInfo(){
      
    return AuthUserAccount(userAccount: userAccount, requiresMobileNumberVerification: requiresMobileNumberVerification, bottomMargin: 20,);

  }

  Widget _loginFormWidget() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[

            if( currLoginStage == LoginStage.enterMobile )
              _entryFieldMobile(),
      
            if(currLoginStage == LoginStage.enterPassword || currLoginStage == LoginStage.setNewPassword)
              _entryFieldPassword(),
      
            if(currLoginStage == LoginStage.setNewPassword)
              _entryFieldConfirmPassword(),
      
          ],
        ),
      ),
    );
  }

  Widget _entryFieldMobile() {
    return AuthInputField(
      title: 'Mobile', 
      initialValue: loginForm['mobile_number'],
      serverErrors: loginServerErrors,
      onChanged: (value){
        loginForm['mobile_number'] = value;
      },
      onSaved: (value){
        loginForm['mobile_number'] = value;
      }
    );
  }

  Widget _entryFieldPassword() {
    return AuthInputField(
      title: 'Password', 
      initialValue: loginForm['password'],
      serverErrors: loginServerErrors,
      hidePassword: hidePassword,
      onChanged: (value){
        loginForm['password'] = value;
      },
      onSaved: (value){
        loginForm['password'] = value;
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
      initialValue: loginForm['password_confirmation'],
      serverErrors: loginServerErrors,
      hidePassword: hidePassword,
      onChanged: (value){
        loginForm['password_confirmation'] = value;
      },
      onSaved: (value){
        loginForm['password_confirmation'] = value;
      },
      onTogglePasswordVisibility: (){
        setState(() {
            hidePassword = !hidePassword;
        });
      }
    );
  }

  Widget _forgotPassword() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.centerRight,
      child: TextButton(
        child: Text('Forgot Password ?',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500
          )
        ),
        onPressed: (){

          //  Reset the login data stored on the device
          storeLoginDataOnDevice(reset: true);

          Get.offAll(() => PasswordResetScreen(), arguments: {
            'mobile_number': loginForm['mobile_number'],
          });

        },
      )
      
      ,
    );
  }

  Widget _verificationCodeField() {

    return MobileVerification(
      isProcessingSuccess: isSubmitting,
      mobileNumber: loginForm['mobile_number'],
      autoGenerateVerificationCode: autoGenerateVerificationCode,
      mobileNumberInstructionType: requiresMobileNumberVerification 
        ? MobileNumberInstructionType.mobile_verification_ownership 
        : MobileNumberInstructionType.mobile_verification_change_password,
      onCompleted: (value){
        setState(() {
          loginForm['verification_code'] = value;
        });
      },
      onChanged: (value){
        setState(() {
          loginForm['verification_code'] = value;
        });
      },
      onSuccess: (){
        _onLogin();
      },
      onGoBack: (){
        setState(() {
          currLoginStage = LoginStage.enterMobile;
          storeLoginDataOnDevice();
        });
      },
      
    );
  }
  
  Widget _loginWithBackButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _previousStepButton(),
          _loginButton(),
        ],
      ),
    );
  }

  Widget _loginButton() {
    return Flexible(
      flex: 4,
      child: CustomButton(
        text: currLoginStage == (LoginStage.enterPassword) ? 'Login' : 'Next',
        disabled: (isSubmitting),
        isLoading: isSubmitting,
        onSubmit: () {
          _onLogin();
        },
      ),
    );
  }

  Widget _nextStepButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.shade200,
              offset: Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2
          )
        ],
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.blue.shade500, Colors.blue.shade700]
        )
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _onLogin();
          },
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: isSubmitting 
              ? Container(height:20, width:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3, ))
              : Text('Next', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _previousStepButton() {
    return Flexible(
      child: PreviousStepButton(
        onTap: () {
          setState(() {
            currLoginStage = LoginStage.enterMobile;
            storeLoginDataOnDevice();
          });
        }
      )
    );
  }

  Widget _createAccountLabel() {
    return AuthAlternativeLink(
      linkText: 'Register',
      messageText: 'Don\'t have an account ?',
      onTap: () {

        //  Reset the login data stored on the device
        storeLoginDataOnDevice(reset: true);

        Get.offAll(() => SignUpScreen(), arguments: {
          'mobile_number': loginForm['mobile_number'],
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

                    ..._loginStageContent()

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