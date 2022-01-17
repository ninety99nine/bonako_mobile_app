import 'package:flutter/material.dart';
import './login.dart';
import './signup.dart';

class WelcomePage extends StatefulWidget {

  static const routeName = '/welcome';

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  Widget _headingText() {
    return Text(
      'Bonako',
      style: TextStyle(
        fontSize: 50, 
        fontWeight: FontWeight.bold, 
        color: Colors.white,
        shadows: [
          Shadow(color: Colors.black.withOpacity(0.3), offset: Offset(0, 2), blurRadius: 10)
        ]
      ),
    );
  }

  Widget _asteriskSymbol(){
    return Text(
        ' * ',
        style: TextStyle(
          fontSize: 40, 
          height: 1.8,
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 5)
          ]
      )
    );
  }

  Widget _hashSymbol(){
    return Text(
        ' # ',
        style: TextStyle(
          fontSize: 30, 
          height: 1.5,
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 5)
          ]
      )
    );
  }

  Widget _dialerText(text){
    return Text(
        text,
        style: TextStyle(
          fontSize: 16, 
          height: 1.5,
          fontWeight: FontWeight.bold, 
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black.withOpacity(0.2), offset: Offset(0, 2), blurRadius: 5)
          ]
      )
    );
  }

  Widget _subHeadingText() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _asteriskSymbol(),
          _dialerText('Dial'),

          _asteriskSymbol(),
          _dialerText('Order'),

          _asteriskSymbol(),
          _dialerText('Deliver'),

          _hashSymbol()
        ],
      ),
    );
  }

  Widget _loginButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(context, LoginScreen.routeName);
          },
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Login',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signUpButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.orange.shade500, Colors.orange.shade700]
        )
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(context, SignUpScreen.routeName);
          },
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Register now',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _copyrightsText() {
    return Container(
      child: Text(
          '© Bonako Dial2Buy . All Rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12, 
            color: Colors.white
        )
      ),
    );
  }

  Widget _backgroundImage() {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/logo-white-2x.png'),
          colorFilter: new ColorFilter.mode(Colors.blue.withOpacity(0.2), BlendMode.dstATop),
        )
      ),
    );
  }

  Widget _backgroundGradient() {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade600, Colors.blue.shade900]
        )
      )
    );
  }

  Widget _content() {

    final height = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              
              SizedBox(height: height * 0.3),

              _headingText(),
              _subHeadingText(),

              Divider(color: Colors.white, height: 50,),

              _loginButton(),
              SizedBox(height: 20),

              _signUpButton(),
              Divider(color: Colors.white, height: 50,),

              _copyrightsText(),
              
              SizedBox(height: height * 0.1),
              
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          _backgroundGradient(),

          _backgroundImage(),

          _content(),

        ],
      ),
    );
  }
}
