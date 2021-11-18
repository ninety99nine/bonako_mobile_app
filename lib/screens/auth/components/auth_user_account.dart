import 'package:flutter/material.dart';

class AuthUserAccount extends StatelessWidget {
  
  final Map userAccount;
  final double topMargin;
  final double bottomMargin;
  final bool requiresMobileNumberVerification;

  AuthUserAccount({ required this.userAccount, this.topMargin = 0.0, this.bottomMargin = 0.0, required this.requiresMobileNumberVerification });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: topMargin, bottom: bottomMargin),
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
    );;
  }
}
