import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_alternative_link.dart';
import 'package:bonako_mobile_app/components/custom_divider.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_input_field.dart';
import 'package:bonako_mobile_app/screens/auth/components/mobile_verification.dart';
import 'package:bonako_mobile_app/screens/auth/terms_and_conditions.dart';
import './../../screens/dashboard/stores/list/stores_screen.dart';
import './../../components/previous_step_button.dart';
import './../../components/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../../providers/auth.dart';
import './../../enum/enum.dart';
import 'package:get/get.dart';
import './login.dart';
import 'dart:convert';

import 'components/auth_heading.dart';

class SignUpScreen extends StatefulWidget {

  static const routeName = '/signup';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();

}

class _SignUpScreenState extends State<SignUpScreen> {

  Map registerForm = {
    'password': '',
    'last_name': '',
    'first_name': '',
    'mobile_number': '',
    'verification_code': '',
    'password_confirmation': '',
  };

  Map registerServerErrors = {};

  var isLoading = false;
  var hidePassword = true;
  var isSubmitting = false;
  var autoGenerateVerificationCode = true;

  Map userAccount = {};
  bool requiresPassword = false;
  bool mobileAccountExists = false;
  bool requiresMobileNumberVerification = false;
  
  final GlobalKey<FormState> _formKey = GlobalKey();
  
  RegisterStage currRegistrationStage = RegisterStage.enterAccountDetails;

  ApiProvider get apiProvider {
    return Provider.of<ApiProvider>(context, listen: false);
  }

  AuthProvider get authProvider {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  bool get isEnteringAccountDetails {
    return (currRegistrationStage == RegisterStage.enterAccountDetails);
  }

  bool get isEnteringVerificationCode {
    return (currRegistrationStage == RegisterStage.enterVerificationCode);
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

  void startRegisterLoader(){
    setState(() {
      isSubmitting = true;
    });
  }

  void stopRegisterLoader(){
    setState(() {
      isSubmitting = false;
    });
  }

  @override
  void initState() {
    
    setRegistrationDataFromDevice();

    super.initState();

  }

  void setRegistrationDataFromDevice() async {
    
    startLoader();

    //  Set the registration data stored on the device
    await authProvider.setRegistrationDataFromDevice().then((value){

      setState(() {
    
        //  If we have the registration data
        if( authProvider.hasRegistrationData ){

          final registrationData = authProvider.getRegistrationData;

          userAccount = registrationData['userAccount'];
          registerForm = registrationData['registerForm'];
          requiresPassword = registrationData['requiresPassword'];
          mobileAccountExists = registrationData['mobileAccountExists'];
          currRegistrationStage = RegisterStage.values[registrationData['currRegistrationStage']];
          requiresMobileNumberVerification = registrationData['requiresMobileNumberVerification'];

          //  If we should enter the verification code
          if(currRegistrationStage == RegisterStage.enterVerificationCode){

            //  Disable automatic generation of verification code
            autoGenerateVerificationCode = false;

          }

        }

        final arguments = Get.arguments;

        //  Get arguments that may have been passed from login screen
        if( arguments != null ){

          //  Merge the form fields
          registerForm = {
            ...registerForm,
            ...arguments
          };

        }
        
      });

    }).whenComplete((){
      
      stopLoader();
      
    });

  }

  void storeRegistrationDataOnDevice({ bool reset = false }){

    Map<String, dynamic> registrationData = {
      'userAccount': userAccount,
      'registerForm': registerForm,
      'requiresPassword': requiresPassword,
      'mobileAccountExists': mobileAccountExists,
      'currRegistrationStage': currRegistrationStage.index,
      'requiresMobileNumberVerification': requiresMobileNumberVerification,
    };

    //  If we must reset
    if(reset == true){

      //  Reset the registration data on the device
      authProvider.storeRegistrationDataLocallyAndOnDevice();

    }else{

      //  Store the registration data on the device
      authProvider.storeRegistrationDataLocallyAndOnDevice(registrationData: registrationData);

    }
    
  }

  void _onRegister(){

    //  Reset server errors
    _resetRegisterServerErrors();

    if( currRegistrationStage == RegisterStage.enterVerificationCode ){

      _attemptCreateUserAccount();

    }else{

      //  Validate the form
      validateForm().then((success){

        if( success ){

          //  Save inputs
          _formKey.currentState!.save();

          //  If we are still checking account details
          if(currRegistrationStage == RegisterStage.enterAccountDetails){

            startRegisterLoader();

            //  Check if any user account exists using the same mobile number
            authProvider.checkIfMobileAccountExists(
              mobileNumber: registerForm['mobile_number'],
              context: context
            ).then((response){

              _handleOnRegisterResponse(response);

              final Map responseBody = jsonDecode(response.body);

              if( response.statusCode == 200 ){

                mobileAccountExists = (responseBody.containsKey('account_exists')) ? responseBody['account_exists'] : false;

                //  Handle non-existing account
                if(mobileAccountExists == false){

                  //  Confirm mobile number ownership
                  _handleVerificationCodeRequirement();
                  
                //  Handle existing account
                }else{
            
                  userAccount = responseBody['user'];
                  requiresPassword = userAccount['requires_password'];
                  requiresMobileNumberVerification = userAccount['requires_mobile_number_verification'];

                  _showDialog(
                    title: 'Account Exists',
                    message: _accountExistsDialogMessage(requiresPassword, requiresMobileNumberVerification),
                    buttonText: (requiresMobileNumberVerification || requiresPassword) ? 'Ok' : 'Login',
                    onPressed: (requiresMobileNumberVerification || requiresPassword) ? null : () { 

                      //  Reset the registration data stored on the device
                      storeRegistrationDataOnDevice(reset: true);

                      Get.offAll(() => LoginScreen(), arguments: {
                        'mobile_number': registerForm['mobile_number'],
                      });

                    }

                  );

                  if( requiresPassword || requiresMobileNumberVerification ){

                    //  Confirm mobile number ownership
                    _handleVerificationCodeRequirement();

                  }

                }
              }

            }).whenComplete((){

              stopRegisterLoader();

            });
            
          }
    
        //  If validation failed
        }else{

          apiProvider.showSnackbarMessage(msg: 'Check for mistakes', type: SnackbarType.error, context: context);

          storeRegistrationDataOnDevice();

        }

      });

    }

  }

  Future<bool> validateForm() async {

    /**
     * When running the _resetRegisterServerErrors(), we actually reset the registerServerErrors = {}, 
     * however the AuthInputField() must render to pick up these changes. These changes will 
     * clear any previous server errors. Since the re-build of AuthInputField() may take
     * sometime, we don't want to validate the form too soon since we may use the old 
     * registerServerErrors within AuthInputField() causing the form to fail even if 
     * the user input correct information.
     */
    return await Future.delayed(const Duration(milliseconds: 100), () {

      // Run form validation
      return _formKey.currentState!.validate() == true;

    });
    
  }

  void _resetRegisterServerErrors(){
    setState(() {
      registerServerErrors = {};
    });
  }

  void _attemptCreateUserAccount(){

    startRegisterLoader();

    //  Register the user account
    authProvider.registerUserAccount(
      passwordConfirmation: registerForm['password_confirmation'],
      verificationCode: registerForm['verification_code'],
      mobileNumber: registerForm['mobile_number'],
      password: registerForm['password'],
      firstName: registerForm['first_name'],
      lastName: registerForm['last_name'],
      context: context
    ).then((response){

      _handleOnRegisterResponse(response);

    final responseBody = jsonDecode(response.body);
      print('responseBody');
      print(responseBody);

      if( response.statusCode == 200 ){

        storeRegistrationDataOnDevice(reset: true);

        if( authProvider.hasAcceptedTermsAndConditions ){

          apiProvider.showSnackbarMessage(msg: 'Account created successfully', context: context);

          Get.offAll(() => StoresScreen());

        }else{

          Get.offAll(() => TermsAndConditionsScreen());

        }

      }

    }).whenComplete((){

      stopRegisterLoader();

    });

  }

  void _handleOnRegisterResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      apiProvider.showSnackbarMessage(msg: 'Registration failed', type: SnackbarType.error, context: context);

      _handleValidationErrors(response);
      
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
      registerServerErrors[key] = value[0];
    });

    setState(() {
      
      final passwordError = validationErrors.containsKey('password');
      final lastNameError = validationErrors.containsKey('last_name');
      final firstNameError = validationErrors.containsKey('first_name');
      final mobileNumberError = validationErrors.containsKey('mobile_number');
      final verificationCodeError = validationErrors.containsKey('verification_code');

      //  If we have errors related to the name, mobile number or password
      if(firstNameError || lastNameError || mobileNumberError || passwordError){

        currRegistrationStage = RegisterStage.enterAccountDetails;

        /**
         *  Since executing currRegistrationStage = RegisterStage.enterAccountDetails
         *  will force the form to change the input fields, we need to give the
         *  application a chance to change the inputs before we can validate,
         *  we buy ourselves this time by delaying the execution of the form
         *  validation
         */
        Future.delayed(const Duration(milliseconds: 100), () {

            // Run form validation
          _formKey.currentState!.validate();

        });
      
      //  If we have errors related to the verification code
      }else if(verificationCodeError){
        
        currRegistrationStage = RegisterStage.enterVerificationCode;

      }

    });

    storeRegistrationDataOnDevice();
    
  }

  void _handleVerificationCodeRequirement(){
    setState(() {

      //  Request that we enter the verification code to confirm ownership
      currRegistrationStage = RegisterStage.enterVerificationCode;

      //  Store the registration form to the device
      storeRegistrationDataOnDevice();

    });
  }

  void _showDialog({ required dynamic title, required dynamic message, String buttonText = 'Ok', Function()? onPressed }){
    showDialog(context: context, builder: (ctx){
      return AlertDialog(
        title: (title is Widget) ? title : Text(title),
        content: (message is Widget) ? message : Text(message),
        actions: [
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

  Widget _accountExistsDialogMessage(requiresPassword, requiresMobileNumberVerification){
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
        children: <TextSpan>[
          TextSpan(text: 'An account using the mobile number '),
          TextSpan(
            text: registerForm['mobile_number'], 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          if(!requiresPassword && !requiresMobileNumberVerification) TextSpan(
            text: ' already exists. Please login to continue', 
            style: TextStyle(fontSize: 12)
          ),
          if((requiresMobileNumberVerification && requiresPassword) || requiresMobileNumberVerification && !requiresPassword) TextSpan(
            text: ' already exists'+(requiresMobileNumberVerification ? '. Verify that you own this mobile number to continue.' : '. Please login to continue'), 
            style: TextStyle(fontSize: 12)
          ),
          if(requiresPassword && !requiresMobileNumberVerification) TextSpan(
            text: ' already exists'+(requiresPassword ? '. This account does not have a password, therefore verify account to set the new password.' : '. Please login to continue'), 
            style: TextStyle(fontSize: 12)
          ),
        ],
      )
    );
  }

  Widget _headingText() {
    return AuthHeading(text: 'Register', fontSize: 50);
  }

  Widget _nextButton() {
    return Flexible(
      flex: 4,
      child: CustomButton(
        text: 'Next',
        disabled: (isSubmitting),
        isLoading: isSubmitting,
        onSubmit: () {
          _onRegister();
        },
      ),
    );
  }

  Widget _previousStepButton() {
    return Flexible(
      child: PreviousStepButton(
        onTap: () {
          setState(() {
            currRegistrationStage = RegisterStage.enterAccountDetails;
            storeRegistrationDataOnDevice();
          });
        }
      )
    );
  }
  
  Widget _nextWithBackButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(currRegistrationStage == RegisterStage.enterVerificationCode) _previousStepButton(),
          _nextButton(),
        ],
      ),
    );
  }

  Widget _formFields() {

    return Column(
      children: <Widget>[
        
        if(isEnteringAccountDetails) _entryFieldFirstName(),
        
        if(isEnteringAccountDetails) _entryFieldLastName(),
        
        if(isEnteringAccountDetails) _entryFieldMobile(),

        if(isEnteringAccountDetails) _entryFieldPassword(),

        if(isEnteringAccountDetails) _entryFieldConfirmPassword(),

        if(isEnteringVerificationCode) _verificationCodeField()

      ],
    );
  }

  Widget _entryFieldFirstName() {
    return AuthInputField(
      title: 'First Name', 
      initialValue: registerForm['first_name'], 
      serverErrors: registerServerErrors,
      onChanged: (value){
        registerForm['first_name'] = value.trim();
      },
      onSaved: (value){
        registerForm['first_name'] = value == null ? '' : value.trim();
      }
    );
  }

  Widget _entryFieldLastName() {
    return AuthInputField(
      title: 'Last Name', 
      initialValue: registerForm['last_name'], 
      serverErrors: registerServerErrors,
      onChanged: (value){
        registerForm['last_name'] = value.trim();
      },
      onSaved: (value){
        registerForm['last_name'] = value == null ? '' : value.trim();
      }
    );
  }

  Widget _entryFieldMobile() {
    return AuthInputField(
      title: 'Mobile', 
      initialValue: registerForm['mobile_number'], 
      serverErrors: registerServerErrors,
      onChanged: (value){
        registerForm['mobile_number'] = value;
      },
      onSaved: (value){
        registerForm['mobile_number'] = value;
      }
    );
  }

  Widget _entryFieldPassword() {
    return AuthInputField(
      title: 'Password', 
      initialValue: registerForm['password'],
      serverErrors: registerServerErrors,
      hidePassword: hidePassword,
      onChanged: (value){
        registerForm['password'] = value;
      },
      onSaved: (value){
        registerForm['password'] = value;
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
      initialValue: registerForm['password_confirmation'],
      serverErrors: registerServerErrors,
      hidePassword: hidePassword,
      onChanged: (value){
        registerForm['password_confirmation'] = value;
      },
      onSaved: (value){
        registerForm['password_confirmation'] = value;
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
      mobileNumber: registerForm['mobile_number'],
      autoGenerateVerificationCode: autoGenerateVerificationCode,
      mobileNumberInstructionType: 
        /**
         *  If we don't have any matching account, or we have a matching account
         *  but is not verified, then request an account ownership verification,
         *  otherwise request a password reset verification.
         */
        (mobileAccountExists == false || requiresMobileNumberVerification == true) 
          ? MobileNumberInstructionType.mobile_verification_ownership 
          : MobileNumberInstructionType.mobile_verification_change_password, 
      onCompleted: (value){
        setState(() {
          registerForm['verification_code'] = value;
        });
      },
      onChanged: (value){
        setState(() {
          registerForm['verification_code'] = value;
        });
      },
      onSuccess: (){
        _onRegister();
      },
      onGoBack: (){
        setState(() {
          currRegistrationStage = RegisterStage.enterAccountDetails;
          storeRegistrationDataOnDevice();
        });
      },
      
    );
  }

  Widget _loginLabel() {
    return AuthAlternativeLink(
      linkText: 'Login',
      messageText: 'Have an account ?',
      onTap: () {

        //  Reset the registration data stored on the device
        storeRegistrationDataOnDevice(reset: true);

        Get.offAll(() => LoginScreen(), arguments: {
          'mobile_number': registerForm['mobile_number'],
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      if(isEnteringAccountDetails) SizedBox(height: height * 0.1),
                
                      if(isEnteringAccountDetails) _headingText(),
                      if(isEnteringAccountDetails) SizedBox(height: 20),
                        
                      (isLoading) ? CustomLoader(height: 400) : _formFields(),
                      
                      if(isEnteringAccountDetails) SizedBox(height: 20),
                        
                      if(isEnteringAccountDetails) _nextWithBackButton(),
                      if(isEnteringAccountDetails) SizedBox(height: 20),

                      if(isEnteringAccountDetails) CustomDivider(),
                      
                      if(isEnteringAccountDetails) _loginLabel(),
                        
                    ],
                  ),
                ),
              ),
            ), 
          ),
        )
      )
    );
  }

}