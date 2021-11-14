
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:flutter/material.dart';
import './one_time_pin.dart';
import './login.dart';

enum AccountTypes {
  Mobile,
  Email
}

class ForgotPasswordPage extends StatefulWidget {

  static const routeName = '/forgot-password';

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();

}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  //  By default we should reset using the mobile account
  AccountTypes selectedAccountType = AccountTypes.Mobile;
  
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  
  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _headingText() {
    return _divider(
      Text(
        'Forgot Password',
        style: TextStyle(
          fontSize: 28, 
          fontWeight: FontWeight.bold, 
          color: Colors.blue
        ),
      )
    );
  }

  Widget _instructionText() {
    return Text(
      (selectedAccountType == AccountTypes.Mobile)
      ? 'Enter your mobile number, then click the submit button. This will send a code to your mobile number to help you reset your password'
      : 'Enter your email address, then click the submit button. This will send a code to your email address to help you reset your password',
      textAlign: TextAlign.justify,
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
            TextField(
              keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'example@gmail.com',
                  border: InputBorder.none,
                  fillColor: Colors.black.withOpacity(0.05),
                  filled: true
              )
            ),

          //  If a mobile text field
          if(title == 'Mobile')
            TextField(
              keyboardType: TextInputType.phone,
              controller: _mobileController,
              decoration: InputDecoration(
                hintText: 'e.g 72000123',
                border: InputBorder.none,
                  fillColor: Colors.black.withOpacity(0.05),
                filled: true
              )
            ),

        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
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

            var accountIdentity = '';

            if(selectedAccountType == AccountTypes.Mobile){
              
              //  accountIdentity = 72123456
              accountIdentity = _mobileController.text;

            }else{

              //  accountIdentity = example@gmail.com
              accountIdentity = _emailController.text;

            }

            Navigator.pushNamed(context, OneTimePinPage.routeName, arguments: accountIdentity);

            final snackBar = SnackBar(
              duration: Duration(seconds: 20),
              content: Text(
                '6 digit pin sent to '+accountIdentity,
                textAlign: TextAlign.center,
              )
            );

            //  Hide existing snackbar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            
            ScaffoldMessenger.of(context).showSnackBar(snackBar);

          },
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Submit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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

  Widget _loginLabel() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
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
              'Want to login ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
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

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[

        //  Conditionally show mobile field
        if(selectedAccountType == AccountTypes.Mobile )
          _entryField("Mobile"),

        //  Conditionally show email field
        if(selectedAccountType == AccountTypes.Email )
          _entryField("Email"),

        //  Always show password field
        _entryField("Password"),

      ],
    );
  }

  Widget _accountTypeSwitch() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
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
                selectedAccountType = AccountTypes.Mobile;
              }else{
                selectedAccountType = AccountTypes.Email;
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

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;

    return Scaffold(
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

                  _backButton(),
              
                  SizedBox(height: height * 0.1),

                  _headingText(),
                  SizedBox(height: 20),

                  _instructionText(),
                  SizedBox(height: 20),
      
                  _accountTypeSwitch(),
                  SizedBox(height: 20),
      
                  _emailPasswordWidget(),
                  SizedBox(height: 20),
      
                  _submitButton(),
                  SizedBox(height: 20),
                  
                  _divider( Text('or') ),
                
                  _loginLabel(),
      
                ],
              ),
            ),
          ), 
        ),
      )
    );
  }
}
