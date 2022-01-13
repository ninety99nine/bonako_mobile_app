
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {

  final title;
  final subtitle;
  final description;
  final IconData icon;

  CustomCard({ this.title = 'Title', this.subtitle, this.description = 'Description', this.icon = Icons.info_rounded });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Icon(icon, size: 16,),
                foregroundColor: Colors.blue,
                backgroundColor: Colors.blue.shade50,
              ),
              title: (title is String) ? Text(title) : title,
              subtitle: subtitle,
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                //  If list of Widgets
                children: (description is List<Widget>) ? description : [
                  //  If String / Widget
                  (description is String) ? Text(description) : description
                ],
              ),
            )
          ]
        ),
      )
    );
     
  }
}