import 'package:flutter/material.dart';

class CustomScaffoldDialog extends StatelessWidget {

  final Widget child;

  CustomScaffoldDialog({ required this.child });

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blue.withOpacity(0.5),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          margin: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)
          ),
          child: child
        ),
      )
    );
  }
}