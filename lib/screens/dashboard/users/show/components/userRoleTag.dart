import '../../../../../components/custom_tag.dart';
import '../../../../../models/users.dart';
import 'package:flutter/material.dart';

class UserRoleTag extends StatelessWidget {
  
  final User user;

  const UserRoleTag({ required this.user });

  @override
  Widget build(BuildContext context) {
    return 
      //  User role
      CustomTag(
        boldedText: user.attributes.userLocation!.type, 
        color: user.attributes.userLocation!.type == 'Owner' ? Colors.orange : Colors.green
      );
  }
}