
import 'package:bonako_mobile_app/components/custom_rounded_indicator.dart';
import 'package:flutter/material.dart';

class CustomExplainer extends StatelessWidget {

  final mark;
  final title;
  final footer;
  final sideNote;
  final markColor;
  final markBgColor;
  final description;
  final EdgeInsetsGeometry? margin;

  CustomExplainer({ this.mark, this.title, this.description, this.sideNote, this.footer, this.markBgColor, this.markColor = Colors.black, this.margin });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10)
      ),
      margin: margin,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(mark != null) CustomRoundedIndicator(
                mark: mark,
                markColor: markColor,
                markBgColor: markBgColor
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //  Title
                        if(title != null) ((title is Widget) ? title : Text(title)),

                        //  Side Note
                        if(sideNote != null) ((sideNote is Widget) ? sideNote : Text(sideNote, style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                    //  Description
                    if(description != null) SizedBox(height: 10),
                    if(description != null) ((description is Widget) ? description : Text(description, textAlign: TextAlign.justify, style: TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            ],
          ),
          //  Footer
          if(footer != null) SizedBox(height: 10),
          if(footer != null) ((footer is Widget) ? footer : Text(footer, textAlign: TextAlign.justify, style: TextStyle(fontSize: 12))),
        ],
      ),
    );
     
  }
}