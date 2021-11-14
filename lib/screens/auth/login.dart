import 'package:bonako_mobile_app/components/custom_back_button.dart';
import 'package:bonako_mobile_app/components/previous_step_button.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/screens/auth/components/mobile_verification.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:get/get.dart';
import './../dashboard/stores/list/stores_screen.dart';
import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './forgot_password.dart';
import 'dart:convert';
import 'signup.dart';

enum LoginTypes {
  Mobile,
  Email
}

enum LoginStage {
  enterMobileOrEmail,
  enterPassword,
  setNewPassword,
  enterVerificationCode
}

class LoginScreen extends StatefulWidget {

  static const routeName = '/login';
  
  @override
  _LoginScreenState createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen> {
  
  //  Set the form key
  final GlobalKey<FormState> _formKey = GlobalKey();

  //  By default we should login using the mobile type of authentication
  LoginTypes selectedLoginType = LoginTypes.Mobile;

  //  By default we start on step 1
  LoginStage currLoginStage = LoginStage.enterMobileOrEmail;
  
  Map loginData = {
    'password_confirmation': '',
    'verification_code': '',
    'mobile_number': '',
    'password': '',
    'email': '',
  };

  Map loginServerErrors = {};

  Map userAccount = {};
  bool requiresPassword = false;
  bool requiresMobileNumberVerification = false;

  //  By default the password is not visible for viewing
  var hidePassword = true;

  //  By default the loader is not loading
  var isLoading = false;

  AuthProvider get authProvider {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  Widget _noAccountExistsDialogMessage(){
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
        children: <TextSpan>[
          TextSpan(text: 'Could not find any account matching the ' + (selectedLoginType == LoginTypes.Mobile ? 'mobile number ' : 'email ')),
          TextSpan(
            text: (selectedLoginType == LoginTypes.Mobile ? loginData['mobile_number'] : loginData['email']), 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(
            text: '. Make sure you entered a correct '+(selectedLoginType == LoginTypes.Mobile ? 'mobile number' : 'email '), 
            style: TextStyle(fontSize: 12)
          ),
        ],
      )
    );
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

  @override
  void initState() {
    
    final arguments = Get.arguments;

    //  Get arguments that may have been passed from login screen
    if( arguments != null ){

      //  Merge the form fields
      loginData = {
        ...loginData,
        ...arguments
      };

    }
    
    super.initState();
  }

  void _resetloginServerErrors(){
    loginServerErrors = {};
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
      loginServerErrors[key] = value[0];
    });

    setState(() {

      final emailError = validationErrors.containsKey('email');
      final passwordError = validationErrors.containsKey('password');
      final mobileNumberError = validationErrors.containsKey('mobile_number');
      final verificationCodeError = validationErrors.containsKey('verification_code');

      //  If we have errors related to the mobile number or  email
      if(emailError || mobileNumberError){
        currLoginStage = LoginStage.enterMobileOrEmail;

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
      if( emailError || mobileNumberError || passwordError ){

        Future.delayed(const Duration(milliseconds: 500), () {

            // Run form validation
          _formKey.currentState!.validate();

        });

      }

    });
    
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
  
  void _onLogin(){

    print('_onLogin()');
    print('_formKey');
    print(_formKey);
    print('_formKey.currentState');
    print(_formKey.currentState);

    //  Reset server errors
    _resetloginServerErrors();

    if( currLoginStage == LoginStage.enterVerificationCode ){

      _handleAttemptLogin();

    //  Validate the form
    }else if( _formKey.currentState!.validate() == true ){

      //  Save inputs
      _formKey.currentState!.save();

      //  If local validation passed for the user account mobile number / email
      if( (currLoginStage == LoginStage.enterMobileOrEmail) ){

        _handleMobileOrEmailAccount();

      //  If local validation passed for the user account password
      }else if (currLoginStage == LoginStage.enterPassword){

          //  If the user account requires verification
          if( requiresMobileNumberVerification == true ){
          
            setState(() {
              currLoginStage = LoginStage.enterVerificationCode;
            });

          }else{

            _handleAttemptLogin();

          }

      //  If local validation passed for the user account password
      }else if (currLoginStage == LoginStage.setNewPassword){

        _handleSetNewPassword();

      }
    
    //  If validation failed
    }else{

      authProvider.showSnackbarMessage(msg: 'Login failed', type: SnackbarType.error, context: context);

    }

  }

  void _handleMobileOrEmailAccount(){

    print('_handleMobileOrEmailAccount()');

    startLoader();
  
    //  If we want to login via mobile number
    if(selectedLoginType == LoginTypes.Mobile ){

      Provider.of<AuthProvider>(context, listen: false).checkIfMobileAccountExists(
        mobileNumber: loginData['mobile_number'],
        context: context
      ).then((response){

        _handleOnCheckAccountExistsResponse(response);

      }).whenComplete((){

        stopLoader();

      });

    }

    //  If we want to login via email
    if(selectedLoginType == LoginTypes.Email ){

      Provider.of<AuthProvider>(context, listen: false).checkIfEmailAccountExists(
        email: loginData['email'],
        context: context
      ).then((response){

        _handleOnCheckAccountExistsResponse(response);

      }).whenComplete((){
        
        stopLoader();

      });

    }

  }

  void _handleAttemptLogin(){

    print('_handleAttemptLogin()');

    startLoader();
  
    //  If we want to login via mobile
    if(selectedLoginType == LoginTypes.Mobile ){

      Provider.of<AuthProvider>(context, listen: false).loginWithMobile(
        passwordConfirmation: loginData['password_confirmation'],
        verificationCode: loginData['verification_code'],
        mobileNumber: loginData['mobile_number'],
        password: loginData['password'],
        context: context
      ).then((response){

        print('jsonDecode(response.body)');
        print(jsonDecode(response.body));

        _handleOnLoginResponse(response);

      }).whenComplete((){

        stopLoader();

      });

    }

    //  If we want to login via email
    if(selectedLoginType == LoginTypes.Email ){

      Provider.of<AuthProvider>(context, listen: false).loginWithEmail(
        passwordConfirmation: loginData['password_confirmation'],
        verificationCode: loginData['verification_code'],
        password: loginData['password'],
        email: loginData['email'],
        context: context
      ).then((response){

        _handleOnLoginResponse(response);

      }).whenComplete((){
        
        stopLoader();

      });

    }
  }

  _handleSetNewPassword(){

    print('_handleSetNewPassword()');
    setState(() {
      currLoginStage = LoginStage.enterVerificationCode; 
    });

  }

  void _handleOnCheckAccountExistsResponse(http.Response response){

    final Map responseBody = jsonDecode(response.body);

        print('responseBody');
        print(responseBody);
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 ){

      final bool sccountExists = (responseBody.containsKey('account_exists')) ? responseBody['account_exists'] : false;

      //  If we have a matching account
      if(sccountExists){
        
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
          
        });

      //  If we don't have a matching account
      }else{

        _showDialog(
          title: 'Account does not exist', 
          message: _noAccountExistsDialogMessage(),
          buttonText: 'Register',
          onPressed: () => { 
            Get.off(() => SignUpScreen(), arguments: {
              'email': loginData['email'],
              'mobile_number': loginData['mobile_number'],
            }) 
          }
        );

      }
    }
  }

  void _handleOnLoginResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 ){
      
      authProvider.showSnackbarMessage(msg: 'Welcome back, '+userAccount['first_name']+'!', context: context);

      //  Navigate to the stores
      Navigator.pushReplacementNamed(context, StoresScreen.routeName);

    }

  }

  Widget _headingText({ double bottomMargin = 50 }) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      child: _divider(
        Text(
          'Login',
          style: TextStyle(
            fontSize: 50, 
            color: Colors.blue,
            fontWeight: FontWeight.bold
          ),
        )
      ),
    );
  }

  Widget _entryField(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),

          //  If an email text field
          if(title == 'Email')
            TextFormField(
              key: Key('email'),
              initialValue: loginData['email'],
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'example@gmail.com',
                border: InputBorder.none,
                fillColor: Colors.black.withOpacity(0.05),
                filled: true
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your email';
                }else if(loginServerErrors['email'] != ''){
                  return loginServerErrors['email'];
                }
              },
              onChanged: (value){
                loginData['email'] = value;
              },
              onSaved: (value){
                loginData['email'] = value;
              }
            ),

          //  If a mobile text field
          if(title == 'Mobile')
            TextFormField(
              key: Key('mobile_number'),
              initialValue: loginData['mobile_number'],
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'e.g 72000123',
                border: InputBorder.none,
                  fillColor: Colors.black.withOpacity(0.05),
                filled: true
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter your mobile number';
                }else if(value.length != 8 && value.length != 11){
                  return 'Please enter a valid 8 digit mobile number e.g 72000123';
                }else if(value.toString().startsWith('7') == false && value.toString().startsWith('267') == false){
                  return 'Please enter a valid mobile number e.g 72000123';
                }else if(loginServerErrors['mobile_number'] != ''){
                  return loginServerErrors['mobile_number'];
                }
              },
              onChanged: (value){
                loginData['mobile_number'] = value;
              },
              onSaved: (value){
                loginData['mobile_number'] = value;
              },
            ),

          //  If a password text field
          if(title == 'Password')
            TextFormField(
              initialValue: loginData['password'],
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
                }else if(loginServerErrors['password'] != ''){
                  return loginServerErrors['password'];
                }
              },
              onChanged: (value){
                loginData['password'] = value;
              },
              onSaved: (value){
                loginData['password'] = value;
              }
            ),

          //  If a password text field
          if(title == 'Confirm Password')
            TextFormField(
              initialValue: loginData['password_confirmation'],
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
                }else if(loginServerErrors['password_confirmation'] != ''){
                  return loginServerErrors['password_confirmation'];
                }
              },
              onChanged: (value){
                loginData['password_confirmation'] = value;
              },
              onSaved: (value){
                loginData['password_confirmation'] = value;
              }
            ),

        ],
      ),
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
      child: Container(
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
              child: isLoading 
                ? Container(height:20, width:20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3, ))
                : Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
          ),
        ),
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
            child: isLoading 
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
            currLoginStage = LoginStage.enterMobileOrEmail;
          });
        }
      )
    );
  }

  Widget _divider(text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          text,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Get.off(() => SignUpScreen(), arguments: {
          'email': loginData['email'],
          'mobile_number': loginData['mobile_number'],
        }) ;
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginFormWidget() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
      
            //  Conditionally show mobile field
            if( currLoginStage == LoginStage.enterMobileOrEmail && selectedLoginType == LoginTypes.Mobile )
              _entryField("Mobile"),
      
            //  Conditionally show email field
            if(currLoginStage == LoginStage.enterMobileOrEmail && selectedLoginType == LoginTypes.Email )
              _entryField("Email"),
      
            if(currLoginStage == LoginStage.enterPassword || currLoginStage == LoginStage.setNewPassword)
            _entryField("Password"),
      
            if(currLoginStage == LoginStage.setNewPassword)
            _entryField("Confirm Password"),
      
          ],
        ),
      ),
    );
  }

  Widget _loginTypeSwitch() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30)
      ),
      child: DefaultTabController(
        length: 2,
        child: TabBar(
          unselectedLabelColor: Colors.grey,
          indicator: BubbleTabIndicator(
            indicatorHeight: 40.0,
            indicatorColor: Colors.blue,
          ),
          onTap: (value){
            setState(() {
              if(value == 0){
                selectedLoginType = LoginTypes.Mobile;
              }else{
                selectedLoginType = LoginTypes.Email;
              }
            });
          },
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_android),
                  SizedBox(width: 10),
                  Text('Mobile')
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.email),
                  SizedBox(width: 10),
                  Text('Email')
                ],
              ),
            ),
          ],
        ),
      ),
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
          Navigator.pushNamed(context, ForgotPasswordPage.routeName);
        },
      )
      
      ,
    );
  }

  Widget _userAccountInfo(){
      
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(20),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white)
        ),
        title: Column(
          children: [
            Row(
              children: [
                Text(userAccount['first_name']),
                SizedBox(width: 5),
                Text(userAccount['last_name'])
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(requiresMobileNumberVerification ? Icons.not_interested_outlined : Icons.check_circle_outlined, color: requiresMobileNumberVerification ? Colors.orange : Colors.green, size: 12),
                SizedBox(width: 5),
                Text(requiresMobileNumberVerification ? 'Not verified' : 'Verified', style: TextStyle(color: requiresMobileNumberVerification ? Colors.orange : Colors.green, fontSize: 12))
              ],
            )
          ],
        ),
      ),
    );

  }


  Widget _verificationCode() {
    return MobileVerification(
      isProcessingSuccess: isLoading,
      mobileNumber: loginData['mobile_number'],
      onCompleted: (value){
        setState(() {
          loginData['verification_code'] = value;
        });
      },
      onChanged: (value){
        setState(() {
          loginData['verification_code'] = value;
        });
      },
      onSuccess: (){
        _onLogin();
      },
      onGoBack: (){
        setState(() {
          currLoginStage = LoginStage.enterMobileOrEmail;
        });
      },
      
    );
  }

  List<Widget> _loginStageContent(){
    
    if( currLoginStage == LoginStage.enterMobileOrEmail ){

      return [

        _headingText(),
        
        _loginTypeSwitch(),

        _loginFormWidget(),

        _nextStepButton(),

        _forgotPassword(),

        _divider( Text('or') ),
      
        _createAccountLabel(),

      ];

    }else if( currLoginStage == LoginStage.setNewPassword ){
      
      return [

        _headingText(),

        _loginFormWidget(),

        _loginWithBackButton(),

        _forgotPassword(),

        _divider( Text('or') ),
      
        _createAccountLabel(),

      ];

    }else if( currLoginStage == LoginStage.enterVerificationCode ){

      return [
        
        _verificationCode()

      ];
    
    }else{
      
      return [

        _headingText(bottomMargin: 20),

        _userAccountInfo(),

        _loginFormWidget(),

        _loginWithBackButton(),

        _forgotPassword(),

        _divider( Text('or') ),
      
        _createAccountLabel(),

      ];

    }
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
