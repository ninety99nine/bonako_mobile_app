import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter/material.dart';

class CustomCountdown extends StatelessWidget {

  final int endTime;
  final Function onEnd;
  final Widget endWidget;
  final bool showWatchIcon;
  final EdgeInsets margin;
  
  CustomCountdown({ 
    required this.onEnd,
    required this.endTime,
    required this.endWidget,
    this.showWatchIcon = true,
    this.margin = const EdgeInsets.only(top: 5)
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: margin,
      child: CountdownTimer(
        endTime: endTime,
        onEnd: (){
          onEnd();
        },
        widgetBuilder: (ctx, currentRemainingTime){

          final days = currentRemainingTime == null ? 0 : (currentRemainingTime.days ?? 0);
          final hrs = currentRemainingTime == null ? 0 : (currentRemainingTime.hours ?? 0);
          final min = currentRemainingTime == null ? 0 : (currentRemainingTime.min ?? 0);
          final sec = currentRemainingTime == null ? 0 : (currentRemainingTime.sec ?? 0);

          var countdown = '';

          if(days > 0){
            countdown += days.toString() + (days == 1 ? ' day' : ' days');
          }

          if(hrs > 0){
            countdown += ' ' + hrs.toString() + (hrs == 1 ? ' hr' : ' hrs');
          }

          if(min > 0 && days == 0){
            countdown += ' ' + min.toString() + (min == 1 ? ' min' : ' mins');
          }

          if(days == 0 && hrs == 0){
            countdown += ' ' + sec.toString() + (sec == 1 ? ' sec' : ' secs');
          }

          countdown += ' left';

          if(days == 0 && hrs == 0 && min == 0 && sec == 0){

            return endWidget;

          }else{

            return Row(
              children: [
                if(showWatchIcon) Icon(Icons.watch_later_outlined, color: Colors.grey, size: 14,),
                if(showWatchIcon) SizedBox(width: 5),
                Text(countdown.trim(), style: TextStyle(fontSize: 14,))
              ]
            );

          }

        },
      ),
    );
    
  }
}