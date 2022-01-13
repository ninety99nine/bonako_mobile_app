import './../../../../../screens/dashboard/orders/cartICancelledtemLinesScreen.dart';
import './../../../../../components/custom_button.dart';
import './../../../../../models/couponLines.dart';
import './../../../../../providers/orders.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './couponLine.dart';
import 'couponLine.dart';

class CartCouponLines extends StatelessWidget {

  List<Widget> buildCouponCards(Order order){

    final couponLines = getCouponLines(order: order, cancelled: false);

    return couponLines.map((couponLine){
      return CouponLineWidget(couponLine: couponLine);
    }).toList();
  }

  List<CouponLine> getCouponLines({ required Order order, bool cancelled = false }){

    return order.embedded.activeCart.embedded.couponLines.where((couponLine){
      return couponLine.isCancelled.status == cancelled;
    }).toList();
  }

  Widget cancelledCouponLinesButton(totalCancelledCoupons){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          width: 200,
          size: 'small',
          onSubmit: (){
            Get.to(() => CartICancelledtemLinesScreen());
          },
          margin: EdgeInsets.only(right: 10),
          widget: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(totalCancelledCoupons.toString() + ' cancelled ' + (totalCancelledCoupons == 1 ? 'coupon' : 'coupons'), style: TextStyle(fontSize: 12, color: Colors.white)),
              SizedBox(width: 5),       
              //  Forward Arrow 
              Icon(Icons.arrow_forward, color: Colors.white, size: 12,),
            ],
          ),
      
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    final hasCoupons = getCouponLines(order: order, cancelled: false).length > 0 ? true : false;
    final totalCancelledCoupons = getCouponLines(order: order, cancelled: true).length;
    final hasCancelledCoupons = totalCancelledCoupons > 0 ? true : false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('Cart Coupons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 20),

              //  Coupons
              if(hasCoupons) ...buildCouponCards(order),

              //  No Coupons
              if(!hasCoupons) Row(
                children: [
                  SvgPicture.asset('assets/icons/ecommerce_pack_1/discount-coupon.svg', width: 16, color: Colors.grey),
                  SizedBox(width: 10),
                  Text('No coupons found', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]
              ),
              
              SizedBox(height: 20),
              if(hasCoupons && hasCancelledCoupons) Divider(),
              if(hasCoupons && hasCancelledCoupons) SizedBox(height: 10),
              
              //  Cancelled coupons button
              if(hasCancelledCoupons) cancelledCouponLinesButton(totalCancelledCoupons),
              if(hasCancelledCoupons) SizedBox(height: 10),
            ],
          ),
        ),
      )
    );
  }
}