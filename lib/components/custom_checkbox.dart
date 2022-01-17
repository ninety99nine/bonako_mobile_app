import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {

  final text;
  final bool value;
  final String link;
  final String linkText;
  final Function(bool?)? onChanged;
  final MainAxisAlignment mainAxisAlignment;

  CustomCheckbox({ this.text = '', this.linkText = '', this.link = '', required this.value, required this.onChanged, this.mainAxisAlignment = MainAxisAlignment.start });

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        (text is Widget) ? text : Text(text),
        InkWell(
          child: Row(
            children: [
              if(text is Widget || (text is String && text.isEmpty == false)) SizedBox(width: 5,),
              Text(linkText, style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline))
            ],
          ),
          onTap: () => link.isEmpty ? null : launch(link)
        ),
      ],
    );

  }

}