import 'package:flutter/material.dart';
import 'dart:async';

class CustomCountupSinceDateToNow extends StatefulWidget {
  
  final DateTime? startDate;
  final bool showWatchIcon;
  final String prefixText;
  final String suffixText;
  final double fontSize;

  CustomCountupSinceDateToNow({ required this.startDate, this.showWatchIcon = true, this.fontSize = 14, this.prefixText = '', this.suffixText = '' });

  @override
  _CustomCountupSinceDateToNowState createState() => _CustomCountupSinceDateToNowState();
}

class _CustomCountupSinceDateToNowState extends State<CustomCountupSinceDateToNow> {
  
  Timer? _timer;
  String output = '';

  @override
  void initState() {

    startTimer();

    super.initState();

  }

  void startTimer() {

    if( widget.startDate != null ){

      _timer = new Timer.periodic(

        //  Set duration to execute callback every 1 second
        Duration(seconds: 1),

        //  Execute the following callback every 1 second
        (Timer timer) {

          final DateTime nowDate = DateTime.now();
          final DateTime startDate = widget.startDate!;
      
          final days = nowDate.difference(startDate).inDays;
          final hrs = nowDate.difference(startDate).inHours % 24;
          final min = nowDate.difference(startDate).inMinutes % 1440 - ((nowDate.difference(startDate).inMinutes % 1440)~/60 * 60);
          final sec = nowDate.difference(startDate).inSeconds % 86400 - ((nowDate.difference(startDate).inSeconds % 86400)~/60 * 60);
            
          String buildOutput = '';

          if(days > 0){
            buildOutput += days.toString() + (days == 1 ? ' day' : ' days');
          }

          if(hrs > 0){
            buildOutput += ' ' + hrs.toString() + (hrs == 1 ? ' hr' : ' hrs');
          }

          if(min > 0 && days == 0){
            buildOutput += ' ' + min.toString() + (min == 1 ? ' min' : ' mins');
          }

          if(days == 0 && hrs == 0){
            buildOutput += ' ' + sec.toString() + (sec == 1 ? ' sec' : ' secs');
          }

          setState(() {

            output = buildOutput;

          });

        },
      );

    }
  }

  @override
  void dispose() {
    if( _timer != null){
      _timer!.cancel();
    }
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Row(
      children: [
        if(widget.showWatchIcon && output.isNotEmpty) Icon(Icons.watch_later_outlined, size: 20,),
        if(widget.showWatchIcon && output.isNotEmpty) SizedBox(width: 10),
        if(output.isNotEmpty) Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.4, fontSize: widget.fontSize),
              children: <TextSpan>[
                if(widget.prefixText.isNotEmpty) TextSpan(text: widget.prefixText),
                TextSpan(text: "$output", style: TextStyle(color: Colors.blue)),
                if(widget.suffixText.isNotEmpty) TextSpan(text: widget.suffixText),
              ],
            ),
          ),
        )
      ],
    );
  }
}