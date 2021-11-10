
import 'package:flutter/material.dart';


class CustomAppBar extends StatelessWidget with PreferredSizeWidget{

  final dynamic title;

  CustomAppBar({ this.title = '' });

  @override
  Widget build(BuildContext context) {
    return AppBar( 
      title: (title is Widget) ? title : Text(title),
     );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}