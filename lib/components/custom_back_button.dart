
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {

  final text;
  final arguments;
  final Function? fallback;
  final Function? onOveride;

  CustomBackButton({ this.text = 'Back', this.onOveride, this.fallback, this.arguments });

  @override
  Widget build(BuildContext context) {
    return 
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () {

            //  If we don't want to overide the default function
            if( onOveride == null ){
            
              //  If we can go back to the previous screen
              if( Navigator.canPop(context) ){

                print('Can go back');

                //  If we have any arguments, then return the arguments when popping the screen
                Get.back(result: arguments);


              //  If we cannot fo back to the previous screen
              }else{

                print('Cannot go back');

                //  If we have a fallback function
                if(fallback != null){
                
                  //  Execute the fallback function
                  fallback!();

                }

              }

            //  If we want to overide the default function
            }else{
              
              //  Execute the overide function
              onOveride!();

            }
          }, 
          child: Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.black,),
              SizedBox(width: 10),
              Text(
                text,
                style: Theme.of(context).textTheme.headline6,  
              ),
            ],
          )
        )
      );
  }
}