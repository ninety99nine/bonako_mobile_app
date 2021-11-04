
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {

  final arguments;
  final Function? fallback;

  CustomBackButton({ this.fallback, this.arguments });

  @override
  Widget build(BuildContext context) {
    return 
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () {
            
            //  If we can go back to the previous screen
            if( Navigator.canPop(context) ){

              //  If we have any arguments, then return the arguments when popping the screen
              Get.back(result: arguments);

            }else{

              if(fallback != null){
              
                fallback!();

              }

            }
          }, 
          child: Row(
            children: [
              Icon(Icons.arrow_back, color: Colors.black,),
              SizedBox(width: 10),
              Text(
                'Back',
                style: Theme.of(context).textTheme.headline6,  
              ),
            ],
          )
        )
      );
  }
}