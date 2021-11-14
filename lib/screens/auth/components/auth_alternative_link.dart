import 'package:flutter/material.dart';
import './auth_divider.dart';

class AuthAlternativeLink extends StatelessWidget {
  
  final String linkText;
  final Function()? onTap;
  final String messageText;

  AuthAlternativeLink({ this.messageText = 'Click on this', this.linkText = 'link', this.onTap });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
}
