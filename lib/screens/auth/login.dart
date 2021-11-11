import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import './../dashboard/stores/list/stores_screen.dart';
import 'package:bonako_app_3/providers/auth.dart';
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
  setNewPassword
}

class LoginPage extends StatefulWidget {

  static const routeName = '/login';
  
  @override
  _LoginPageState createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {
  
  //  Set the form key
  final GlobalKey<FormState> _formKey = GlobalKey();

  //  By default we should login using the mobile type of authentication
  LoginTypes selectedLoginType = LoginTypes.Mobile;

  //  By default we start on step 1
  LoginStage currLoginStage = LoginStage.enterMobileOrEmail;
  
  Map loginData = {
    'password': '',
    'mobile_number': '',
    'email': '',
  };

  Map loginServerErrors = {
    'password': '',
    'mobile_number': '',
    'email': '',
  };

  Map userAccount = {};

  //  By default the password is not visible for viewing
  var hidePassword = true;

  //  By default the loader is not loading
  var isLoading = false;

  void _showDialog({ required String title, required String message }){
    showDialog(context: context, builder: (ctx){
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: Text('Ok')
          )
        ],
      );
    });
  }

  void _resetloginServerErrors(){
    loginServerErrors = {
      'password': '',
      'mobile_number': '',
      'email': '',
    };
  }

  void _resetUserAccount(){
    userAccount = {};
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
      if( loginServerErrors.containsKey(key) ){
        loginServerErrors[key] = value[0];
      }
    });
    
    // Run form validation
   _formKey.currentState!.validate();
    
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

  void _onCheckAccountExists(){

    //  Reset user account
    _resetUserAccount();

    //  Reset server errors
    _resetloginServerErrors();
    
    //  If local validation passed
    if( _formKey.currentState!.validate() == true ){

      //  Save inputs
      _formKey.currentState!.save();

      startLoader();
    
      //  If we provided a mobile number
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
    
    //  If validation failed
    }else{

      //  Set snackbar content
      final snackBar = SnackBar(content: Text('Login failed', textAlign: TextAlign.center));

      //  Show snackbar  
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }

  }

  void _handleOnCheckAccountExistsResponse(http.Response response){

    final responseBody = jsonDecode(response.body);
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 ){

      final accountExistsStatus = responseBody['exists'];
        
      //  If we have a matching account
      if(accountExistsStatus){
        
        setState(() {
        
          userAccount = responseBody['user'];

          //  If the user account requires a password
          if(userAccount['requires_password']){
            currLoginStage = LoginStage.setNewPassword;
          }else{
            currLoginStage = LoginStage.enterPassword;
          }
          
        });

      //  If we don't have a matching account
      }else{

        _showDialog(
          title: 'Account does not exist', 
          message: 'Could not find any account matching the mobile number ${loginData['mobile_number']}. Make sure you entered a correct mobile number.'
        );

      }
    }
  }

  void _onLogin(){

    //  Reset server errors
    _resetloginServerErrors();
    
    //  If local validation passed
    if( _formKey.currentState!.validate() == true ){

      //  Save inputs
      _formKey.currentState!.save();

      startLoader();
    
      //  If we want to login via mobile
      if(selectedLoginType == LoginTypes.Mobile ){

        Provider.of<AuthProvider>(context, listen: false).loginWithMobile(
          mobileNumber: loginData['mobile_number'],
          password: loginData['password'],
          context: context
        ).then((response){

          _handleOnLoginResponse(response);

        }).whenComplete((){

          stopLoader();

        });

      }

      //  If we want to login via email
      if(selectedLoginType == LoginTypes.Email ){

        Provider.of<AuthProvider>(context, listen: false).loginWithEmail(
          email: loginData['email'],
          password: loginData['password'],
          context: context
        ).then((response){

          _handleOnLoginResponse(response);

        }).whenComplete((){
          
          stopLoader();

        });

      }
    
    //  If validation failed
    }else{

      final snackBar = SnackBar(content: Text('Login failed', textAlign: TextAlign.center));

      //  Show snackbar  
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }

  }

  void _handleOnLoginResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 ){

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
              onSaved: (value){
                loginData['password'] = value;
              },
            )

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
            _onCheckAccountExists();
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
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2
            )
          ],
          color: Colors.grey.shade400
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                currLoginStage = LoginStage.enterMobileOrEmail;
              });
            },
            splashColor: Colors.blue,
            child: Container(
              alignment: Alignment.center,
              width: 55,
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Icon(Icons.arrow_back, color: Colors.white,),
            ),
          ),
        ),
      ),
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
        Navigator.pushReplacementNamed(context, SignUpPage.routeName);
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
      
            if(currLoginStage == LoginStage.enterPassword)
            //  Always show password field
            _entryField("Password"),
      
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
        title: Row(
          children: [
            Text(userAccount['first_name']),
            SizedBox(width: 5),
            Text(userAccount['last_name'])
          ],
        ),
      ),
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
