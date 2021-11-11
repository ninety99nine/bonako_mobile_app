import 'package:flutter/material.dart';
import './login.dart';

class ResetPasswordPage extends StatefulWidget {

  static const routeName = '/reset-password';

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();

}

class _ResetPasswordPageState extends State<ResetPasswordPage> {

  //  By default the password is not visible for viewing
  var hidePassword = true;
  
  final _userPasswordController = TextEditingController();
  final _userConfirmPasswordController = TextEditingController();

  Widget _headingText() {
    return _divider(
      Text(
        'Reset Password',
        style: TextStyle(
          fontSize: 28, 
          fontWeight: FontWeight.bold, 
          color: Colors.blue
        ),
      )
    );
  }

  Widget _instructionText() {
    return Text('Enter your new password and reset');
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

          //  If a password text field
          if(title == 'Password')
            TextFormField(
              keyboardType: TextInputType.text,
              controller: _userPasswordController,
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
            ),

          //  If a password text field
          if(title == 'Confirm Password')
            TextFormField(
              keyboardType: TextInputType.text,
              controller: _userConfirmPasswordController,
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
            )

        ],
      ),
    );
  }

  Widget _resetPasswordButton() {
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
            Navigator.pushReplacementNamed(context, LoginPage.routeName);

            final snackBar = SnackBar(
              duration: Duration(seconds: 30),
              content: Text(
                'Reset successfully, Please login',
                textAlign: TextAlign.center,
              )
            );
            
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Reset Password',
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
        Navigator.pushReplacementNamed(context, LoginPage.routeName);
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
              'Have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
              style: TextStyle(color: Color(0xfff79c4f), fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[

        _entryField("Password"),

        _entryField("Confirm Password")

      ],
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

                    _headingText(),
                    SizedBox(height: 20),

                    _instructionText(),
                    SizedBox(height: 20),
        
                    _emailPasswordWidget(),
                    SizedBox(height: 20),
        
                    _resetPasswordButton(),
                    SizedBox(height: 20),

                    _divider( Text('or') ),
                    
                    _loginLabel(),
        
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
