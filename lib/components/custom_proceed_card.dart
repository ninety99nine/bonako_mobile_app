import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomProceedCard extends StatelessWidget {

  final title;
  final subtitle;
  final bool highlight;
  final String? svgIcon;
  final void Function()? onTap;

  const CustomProceedCard({ required this.title, this.subtitle, this.svgIcon, this.onTap, this.highlight = false });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: highlight ? Colors.blue.shade200 : Colors.white,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                child: ListTile(
                  leading: (svgIcon == null) ? null : CircleAvatar(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.blue.shade50,
                    child: SvgPicture.asset(svgIcon!, width: 16, color: Colors.blue,),
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  //  Check if the title is a Widget or a Text and render accordingly
                  title: (title is Widget) ? title! : Text(title!, style: TextStyle(fontSize: 16)),
                  subtitle: (subtitle == null) ? null : (
                    //  Check if the subtitle is a Widget or a Text and render accordingly
                    (subtitle is Widget) ? subtitle! : Text(subtitle!, style: TextStyle(fontSize: 12))
                  ),
                  onTap: onTap,
                ),
              ),
            )
          ]
        )
      )
    );
  }
}