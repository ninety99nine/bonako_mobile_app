import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomAvatarButton extends StatelessWidget {

  final String text;
  final EdgeInsets margin;
  final Function()? onSubmit;

  CustomAvatarButton({ this.text: '+ Add', this.margin: EdgeInsets.zero, this.onSubmit });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 200,
      height: 200,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            offset: Offset(0, 10),
            blurRadius: 5
          )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.2),
          onTap: onSubmit,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/ecommerce_pack_1/shopping-bag-6.svg', width: 32, color: Colors.white),
              SizedBox(height: 20),
              Text(text, style: TextStyle(color: Colors.white)),
            ]
          ),
        ),
      ),
    );
  }
}