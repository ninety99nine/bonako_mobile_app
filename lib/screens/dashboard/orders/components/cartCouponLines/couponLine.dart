import './../../../../../models/couponLines.dart';
import '../../cartCouponLineScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CouponLineWidget extends StatelessWidget {

  final CouponLine couponLine;

  const CouponLineWidget({ required this.couponLine });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.only(right: 10, bottom: 10),
      child: ListTile(
        onTap: () async {
          
          await Get.to(() => CartCouponLineScreen(
            couponLine: couponLine,
          ));

        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(couponLine.name)
            ),
            Icon(Icons.arrow_forward, color: Colors.grey, size: 12,),  //  Forward Arrow 
          ],
        ),
      )
    );
  }
}