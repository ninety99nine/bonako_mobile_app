import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {

  final bool value;
  final String text;
  final String link;
  final String linkText;
  final Function(bool?)? onChanged;

  CustomCheckbox({ this.text = '', this.linkText = '', this.link = '', required this.value, required this.onChanged });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        if(text.isEmpty == false) Text(text),
        InkWell(
          child: Row(
            children: [
              if(text.isEmpty == false) SizedBox(width: 5,),
              Text(linkText, style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
            ],
          ),
          onTap: () => link.isEmpty ? null : launch(link)
        ),
      ],
    );

  }

}