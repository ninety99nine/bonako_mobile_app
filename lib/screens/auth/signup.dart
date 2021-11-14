import 'package:bonako_mobile_app/screens/auth/components/auth_alternative_link.dart';
import 'package:bonako_mobile_app/screens/auth/components/auth_divider.dart';
import 'package:bonako_mobile_app/screens/auth/components/mobile_verification.dart';

import './../../screens/dashboard/stores/list/stores_screen.dart';
import './../../components/previous_step_button.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import './../../components/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
    'email': '',
    'password': '',
    'last_name': '',
    'first_name': '',
    'mobile_number': '',
    'verification_code': '',
    'password_confirmation': '',
  };

  Map registerServerErrors = {};

  var hidePassword = true;
  var isSubmitting = false;

  Map userAccount = {};
  bool requiresPassword = false;
  bool requiresMobileNumberVerification = false;
  
  final GlobalKey<FormState> _formKey = GlobalKey();
  
  RegisterStage currRegistrationStage = RegisterStage.enterAccountDetails;

  AuthProvider get authProvider {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  bool get isEnteringAccountDetails {
    return (currRegistrationStage == RegisterStage.enterAccountDetails);
  }

  bool get isEnteringVerificationCode {
    return (currRegistrationStage == RegisterStage.enterVerificationCode);
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
    
    final arguments = Get.arguments;

    //  Get arguments that may have been passed from login screen
    if( arguments != null ){

      //  Merge the form fields
      registerForm = {
        ...registerForm,
        ...arguments
      };

    }
    
    super.initState();

  }

  void _onRegister(){

    //  Reset server errors
    _resetRegisterServerErrors();

    if( currRegistrationStage == RegisterStage.enterVerificationCode ){

      _attemptCreateUserAccount();

    //  Validate the form
    }else if( _formKey.currentState!.validate() == true ){

      //  Save inputs
      _formKey.currentState!.save();

      //  If we are still checking account details
      if(currRegistrationStage == RegisterStage.enterAccountDetails){

        startRegisterLoader();

        //  Check if any user account exists using the same mobile number or email
        authProvider.checkIfMobileOrEmailAccountExists(
          mobileNumber: registerForm['mobile_number'],
          email: registerForm['email'],
          context: context
        ).then((response){

          _handleOnRegisterResponse(response);

            final Map responseBody = jsonDecode(response.body);

          if( response.statusCode == 200 ){

            final bool mobileAccountExists = (responseBody.containsKey('mobile_account_exists')) ? responseBody['mobile_account_exists'] : false;
            final bool emailAccountExists = (responseBody.containsKey('email_account_exists')) ? responseBody['email_account_exists'] : false;

            //  Handle non-existing account
            if(mobileAccountExists == false && emailAccountExists == false){

              //  Confirm mobile number ownership
              _handleVerificationCodeRequirement();
              
            //  Handle existing account
            }else{
        
              userAccount = responseBody['user'];
              requiresPassword = userAccount['requires_password'];
              requiresMobileNumberVerification = userAccount['requires_mobile_number_verification'];

              print('requiresPassword: '+ requiresPassword.toString());
              print('requiresMobileNumberVerification: '+ requiresMobileNumberVerification.toString());

              _showDialog(
                title: 'Account Exists',
                message: (mobileAccountExists == true)
                  ? _accountExistsDialogMessage('mobile_number', requiresPassword, requiresMobileNumberVerification)
                  : _accountExistsDialogMessage('email', requiresPassword, requiresMobileNumberVerification),
                buttonText: (requiresMobileNumberVerification || requiresPassword) ? 'Ok' : 'Login',
                onPressed: (requiresMobileNumberVerification || requiresPassword) ? null : () => { 
                  Get.off(() => LoginScreen(), arguments: {
                      'email': registerForm['email'],
                      'mobile_number': registerForm['mobile_number'],
                    }) 
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

      authProvider.showSnackbarMessage(msg: 'Registration failed', type: SnackbarType.error, context: context);

    }

  }

  void _resetRegisterServerErrors(){
    registerServerErrors = {};
  }

  void _handleOnRegisterResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      authProvider.showSnackbarMessage(msg: 'Registration failed', type: SnackbarType.error, context: context);

      _handleValidationErrors(response);
      
    }

  }

  void _handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];

    print('validationErrors');
    print(validationErrors);

    /**
     *  validationErrors = {
     *    mobile_number: [Enter a valid mobile number containing only digits e.g 26771234567]
     *  }
     */
    validationErrors.forEach((key, value){
      registerServerErrors[key] = value[0];
    });
    
    // Run form validation
   _formKey.currentState!.validate();
    
  }

  void _handleVerificationCodeRequirement(){
    setState(() {
      //  Request that we enter the verification code to confirm ownership
      currRegistrationStage = RegisterStage.enterVerificationCode;
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

  Widget _accountExistsDialogMessage(type, requiresPassword, requiresMobileNumberVerification){
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
        children: <TextSpan>[
          TextSpan(text: 'An account using the '+(type == 'mobile_number' ? 'mobile number ' : 'email')),
          TextSpan(
            text: (type == 'mobile_number' ? registerForm['mobile_number'] : registerForm['email']), 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          if(!requiresPassword && !requiresMobileNumberVerification) TextSpan(
            text: ' already exists. Please login to continue', 
            style: TextStyle(fontSize: 12)
          ),
          if((requiresMobileNumberVerification && requiresPassword) || requiresMobileNumberVerification && !requiresPassword) TextSpan(
            text: ' already exists'+(requiresMobileNumberVerification ? '. This account must be verified to continue.' : '. Please login to continue'), 
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
      email: registerForm['email'],
      context: context
    ).then((response){

      _handleOnRegisterResponse(response);

      if( response.statusCode == 200 ){

        authProvider.showSnackbarMessage(msg: 'Account created successfully', context: context);

        Get.off(() => StoresScreen());

      }

    }).whenComplete((){

      stopRegisterLoader();

    });

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
        
        if(isEnteringAccountDetails) _entryField("First Name"),
        
        if(isEnteringAccountDetails) _entryField("Last Name"),
        
        if(isEnteringAccountDetails) _entryField("Mobile"),
          
        if(isEnteringAccountDetails) _entryField("Email", optional: true),

        if(isEnteringAccountDetails) _entryField("Password"),

        if(isEnteringAccountDetails) _entryField("Confirm Password"),

        if(isEnteringVerificationCode) _verificationCodeField()

      ],
    );
  }



  Widget _entryField(String title, {bool optional = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              if(optional)
                Text(
                  ' (Optional)',
                  style: TextStyle(fontSize: 15),
                ),
            ],
          ),
          SizedBox(
            height: 10,
          ),

          //  If an first name text field
          if(title == 'First Name')
            TextFormField(
              initialValue: registerForm['first_name'],
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Katlego',
                border: InputBorder.none,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your first name';
                }else if(registerServerErrors['first_name'] != ''){
                  return registerServerErrors['first_name'];
                }
              },
              onChanged: (value){
                registerForm['first_name'] = value.trim();
              },
              onSaved: (value){
                registerForm['first_name'] = value!.trim();
              }
            ),

          //  If an last name text field
          if(title == 'Last Name')
            TextFormField(
              initialValue: registerForm['last_name'],
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                hintText: 'Warona',
                border: InputBorder.none,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your last name';
                }else if(registerServerErrors['last_name'] != ''){
                  return registerServerErrors['last_name'];
                }
              },
              onChanged: (value){
                registerForm['last_name'] = value.trim();
              },
              onSaved: (value){
                registerForm['last_name'] = value!.trim();
              }
            ),

          //  If an email text field
          if(title == 'Email')
            TextFormField(
              initialValue: registerForm['email'],
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                hintText: 'example@gmail.com',
                border: InputBorder.none,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              validator: (value){
                if(registerServerErrors['email'] != ''){
                  return registerServerErrors['email'];
                }
              },
              onChanged: (value){
                registerForm['email'] = value.trim();
              },
              onSaved: (value){
                registerForm['email'] = value!.trim();
              }
            ),

          //  If a mobile text field
          if(title == 'Mobile')
            TextFormField(
              initialValue: registerForm['mobile_number'],
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                hintText: 'e.g 72000123',
                border: InputBorder.none,
                fillColor: Colors.black.withOpacity(0.05),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your mobile number';
                }else if(value.length != 8){
                  return 'Please enter a valid 8 digit mobile number e.g 72000123';
                }else if(value.startsWith('7') == false){
                  return 'Please enter a valid mobile number e.g 72000123';
                }else if(registerServerErrors['mobile_number'] != ''){
                  return registerServerErrors['mobile_number'];
                }
              },
              onChanged: (value){
                registerForm['mobile_number'] = value.trim();
              },
              onSaved: (value){
                registerForm['mobile_number'] = value!.trim();
              }
            ),

          //  If a password text field
          if(title == 'Password')
            TextFormField(
              initialValue: registerForm['password'],
              keyboardType: TextInputType.text,
              obscureText: hidePassword,
              decoration: InputDecoration(
                  fillColor: Colors.black.withOpacity(0.05),
                border: InputBorder.none,
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on hidePassword state choose the icon
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    //  Update the state i.e. toggle the state of hidePassword variable
                    setState(() {
                        hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your password';
                }else if(registerServerErrors['password'] != ''){
                  return registerServerErrors['password'];
                }
              },
              onChanged: (value){
                registerForm['password'] = value;
              },
              onSaved: (value){
                registerForm['password'] = value;
              }
            ),

          //  If a password text field
          if(title == 'Confirm Password')
            TextFormField(
              initialValue: registerForm['password_confirmation'],
              keyboardType: TextInputType.text,
              obscureText: hidePassword,
              decoration: InputDecoration(
                  fillColor: Colors.black.withOpacity(0.05),
                border: InputBorder.none,
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on hidePassword state choose the icon
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () {
                    //  Update the state i.e. toggle the state of hidePassword variable
                    setState(() {
                        hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please confirm your password';
                }else if(registerServerErrors['password_confirmation'] != ''){
                  return registerServerErrors['password_confirmation'];
                }
              },
              onChanged: (value){
                registerForm['password_confirmation'] = value;
              },
              onSaved: (value){
                registerForm['password_confirmation'] = value;
              }
            ),

        ],
      ),
    );
  }

  Widget _verificationCodeField() {
    return MobileVerification(
      isProcessingSuccess: isSubmitting,
      mobileNumber: registerForm['mobile_number'],
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
        });
      },
      
    );
  }

  Widget _loginLabel() {
    return AuthAlternativeLink(
      linkText: 'Login',
      messageText: 'Have an account ?',
      onTap: () {
        Get.off(() => LoginScreen(), arguments: {
            'email': registerForm['email'],
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
                        
                      _formFields(),
                      
                      if(isEnteringAccountDetails) SizedBox(height: 20),
                        
                      if(isEnteringAccountDetails) _nextWithBackButton(),
                      if(isEnteringAccountDetails) SizedBox(height: 20),

                      if(isEnteringAccountDetails) AuthDivider(),
                      
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