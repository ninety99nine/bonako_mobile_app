import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  final String text;
  final String size;
  final bool ripple;
  final double width;
  final Widget? widget;
  final bool isLoading;
  final bool solidColor;
  final EdgeInsets margin;
  final Function()? onSubmit;
  final MaterialColor color;
  final bool disabled;

  CustomButton({ this.text: 'Button', this.ripple = false, this.widget, this.solidColor = false, this.color: Colors.blue, this.isLoading: false, this.onSubmit, this.margin: EdgeInsets.zero, this.width = double.infinity, this.size = 'large', this.disabled = false });

  Widget materialWidget(){

    final containerPadding = size == 'large' ? 15.00 : (size == 'medium' ? 10.00 : 5.00);
    final loaderSize = size == 'large' ? 20.00 : (size == 'medium' ? 16.00 : 14.00);
    final fontSize = size == 'large' ? 18.00 : (size == 'medium' ? 16.00 : 14.00);
    final height = size == 'large' ? 50.00 : (size == 'medium' ? 40.00 : 30.00);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (disabled == true) ? null : onSubmit,
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: containerPadding),
          child: isLoading 
            ? Container(height: loaderSize, width: loaderSize, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3, ))
            : widget != null ? widget :
              Text(text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white))
          ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final rippleRadius = size == 'large' ? 50.0 : (size == 'medium' ? 35.0 : 25.0);

    return Container(
      margin: margin,
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
            colors: disabled ? [Colors.grey.shade400, Colors.grey.shade400] : [solidColor ? color : color.shade500, solidColor ? color : color.shade700]
        )
      ),
      child: ripple ? RippleAnimation(
        color: color,
        repeat: true,
        ripplesCount: 2,
        minRadius: rippleRadius,
        child: materialWidget(),
      ): materialWidget()
    );
  }
}