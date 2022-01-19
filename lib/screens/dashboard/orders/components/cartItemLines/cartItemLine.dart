import 'package:bonako_mobile_app/models/itemLines.dart';
import 'package:flutter/material.dart';
import '../../cartItemLineScreen.dart';
import 'package:get/get.dart';

class CartItemLine extends StatelessWidget {

  final ItemLine itemLine;

  const CartItemLine({ required this.itemLine });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () async {
          
          await Get.to(() => CartItemLineScreen(
            itemLine: itemLine,
          ));

        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, height: 1.5),
                  children: <TextSpan>[
                    TextSpan(text: itemLine.quantity.toString()),
                    TextSpan(text: ' x '),
                    TextSpan(text: itemLine.name)
                  ]
                )
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(itemLine.isFree.status == true) Text('FREE', style: TextStyle(color: Colors.green),),
                  if(itemLine.isFree.status == false) Text(itemLine.grandTotal.currencyMoney),
                  SizedBox(width: 5),       
                  //  Forward Arrow 
                  Icon(Icons.arrow_forward, color: Colors.grey, size: 12,),
                ],
              )
            ),
          ],
        ),
      )
    );
  }
}