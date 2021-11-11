import 'package:flutter/material.dart';
import './login.dart';

class SignUpPage extends StatefulWidget {

  static const routeName = '/signup';

  @override
  _SignUpPageState createState() => _SignUpPageState();

}

class _SignUpPageState extends State<SignUpPage> {

  //  By default the password is not visible for viewing
  var hidePassword = true;
  
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _userPasswordController = TextEditingController();
  final _userConfirmPasswordController = TextEditingController();

  Widget _headingText() {
    return _divider(
      Text(
        'Register',
        style: TextStyle(
          fontSize: 50, 
          fontWeight: FontWeight.bold, 
          color: Colors.blue
        ),
      )
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

  Widget _signUpButton() {
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
          onTap: () {},
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Sign Up',
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
        
        _entryField("Mobile"),
          
        _entryField("Email", optional: true),

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
        
                    _emailPasswordWidget(),
                    SizedBox(height: 20),
        
                    _signUpButton(),
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
