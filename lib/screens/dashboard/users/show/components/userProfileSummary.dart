import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../models/users.dart';
import 'package:flutter/material.dart';

class UserProfileSummary extends StatelessWidget {
  
  final User user;
  final EdgeInsetsGeometry margin;

  const UserProfileSummary({ required this.user, this.margin = const EdgeInsets.symmetric(vertical: 10) });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person, size: 20,),
                foregroundColor: Colors.blue,
                backgroundColor: Colors.blue.shade50,
              ),
              title: Text(user.attributes.name),
              subtitle: Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Text('Tap to call'),
                    SizedBox(width: 5),
                    Icon(Icons.phone, color: Colors.grey, size: 14,),
                    SizedBox(width: 5),
                    Text(
                      user.mobileNumber.number, 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              onTap: (){
                  
                final dialingCode = user.mobileNumber.number;
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                
                authProvider.launchShortcode(dialingCode: dialingCode, loadingMsg: 'Preparing to call ' + user.firstName, context: context);

              },
            ),
          ]
        )
      ),
    );
  }
}