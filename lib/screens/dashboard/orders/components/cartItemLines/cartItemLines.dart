import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/models/itemLines.dart';
import 'package:bonako_mobile_app/providers/orders.dart';
import 'package:bonako_mobile_app/models/orders.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/cartICancelledtemLinesScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './cartItemLine.dart';

class CartItemLines extends StatelessWidget {

  List<Widget> buildItemCards(Order order){

    final itemLines = getItemLines(order: order, cancelled: false);

    return itemLines.map((itemLine){
      return CartItemLine(itemLine: itemLine);
    }).toList();
  }

  List<ItemLine> getItemLines({ required Order order, bool cancelled = false }){

    return order.embedded.activeCart.embedded.itemLines.where((itemLine){
      return itemLine.isCancelled.status == cancelled;
    }).toList();
  }

  Widget cancelledItemLinesButton(totalCancelledItems){
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
              Text(totalCancelledItems.toString() + ' cancelled ' + (totalCancelledItems == 1 ? 'item' : 'items'), style: TextStyle(fontSize: 12, color: Colors.white)),
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
    final hasItems = getItemLines(order: order, cancelled: false).length > 0 ? true : false;
    final totalCancelledItems = getItemLines(order: order, cancelled: true).length;
    final hasCancelledItems = totalCancelledItems > 0 ? true : false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('Cart Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 20),

              //  Items
              if(hasItems) ...buildItemCards(order),

              //  No Items
              if(!hasItems) Row(
                children: [
                  SvgPicture.asset('assets/icons/ecommerce_pack_1/shopping-bag-5.svg', width: 16, color: Colors.grey),
                  SizedBox(width: 10),
                  Text('No items found', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]
              ),
              
              if(!hasItems) SizedBox(height: 20),
              if(!hasItems) Divider(),
              SizedBox(height: 10),
              
              //  Cancelled items button
              if(hasCancelledItems) cancelledItemLinesButton(totalCancelledItems),
              if(hasCancelledItems) SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),

              //  Sub Total
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Sub total:'),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.subTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),

              //  Coupon Discount
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Coupon Discount:'),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.couponTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),

              //  Sale Discount
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Sale Discount:'),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.saleDiscountTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),

              //  Delivery Fee
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Delivery Fee:'),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.deliveryFee.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(width: 10),
                ],
              ),
              Divider(),
              SizedBox(height: 10),

              //  Grand Total
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Grand Total: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.grandTotal.currencyMoney, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      )
    );
  }
}