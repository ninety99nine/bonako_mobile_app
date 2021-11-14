import 'package:flutter/material.dart';
import './reset_password.dart';
import './login.dart';

class OneTimePinPage extends StatefulWidget {

  static const routeName = '/one-time-pin';

  @override
  _OneTimePinPageState createState() => _OneTimePinPageState();

}

class _OneTimePinPageState extends State<OneTimePinPage> {
  
  final _oneTimePinController = TextEditingController();
  
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
            Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _headingText() {
    return _divider(
      Text(
        'One Time Pin',
        style: TextStyle(
          fontSize: 28, 
          fontWeight: FontWeight.bold, 
          color: Colors.blue
        ),
      )
    );
  }

  Widget _instructionText(BuildContext context) {

    final String accountIdentity = ModalRoute.of(context)!.settings.arguments as String;

    return RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          text: 'Enter the 6 digit pin sent to ',
          style: TextStyle(color: Colors.black),
          children: <TextSpan>[
            TextSpan(text: accountIdentity, style: TextStyle(fontWeight: FontWeight.bold),)
          ],
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
          
          TextField(
            keyboardType: TextInputType.number,
              controller: _oneTimePinController,
              decoration: InputDecoration(
                hintText: 'e.g 123456',
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
            Navigator.pushReplacementNamed(context, ResetPasswordPage.routeName);

            final snackBar = SnackBar(
              duration: Duration(seconds: 10),
              content: Text(
                'Verified successfully',
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
        Navigator.pushNamed(context, LoginScreen.routeName);
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

  Widget _oneTimePinField() {
    return Column(
      children: <Widget>[

          _entryField("Enter 6 Digit Pin"),

      ],
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

                  _instructionText(context),
                  SizedBox(height: 20),
      
                  _oneTimePinField(),
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
