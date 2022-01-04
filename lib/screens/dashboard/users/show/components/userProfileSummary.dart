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
              subtitle: Text(
                user.mobileNumber.number,
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
            )
          ]
        )
      ),
    );
  }
}