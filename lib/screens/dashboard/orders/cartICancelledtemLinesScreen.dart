import 'package:bonako_mobile_app/components/custom_back_button.dart';
import 'package:bonako_mobile_app/components/custom_divider.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/cartItemLineScreen.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/show/order_screen.dart';
import 'package:get/get.dart';

import '../../../components/custom_app_bar.dart';
import '../../../components/store_drawer.dart';
import '../../../providers/orders.dart';
import '../../../models/itemLines.dart';
import '../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CartICancelledtemLinesScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    final Order order = Provider.of<OrdersProvider>(context, listen: false).getOrder;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Order #' + order.number),
        drawer: StoreDrawer(),
        body: Content(),
      )
    );
  }
}

class Content extends StatelessWidget {

  List<Widget> getCancelledItemLinesWithReasons({ required Order order }){
    
    return getItemLines(order: order, cancelled: true).map((itemLine){

      return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.only(right: 10, bottom: 10),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  flex: 9,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(itemLine.name, style: TextStyle(fontWeight: FontWeight.bold),),
                      SizedBox(height: 5,),
                      Text(itemLine.cancellationReason == null || itemLine.cancellationReason == '' ? 'No reason found' : itemLine.cancellationReason)
                    ],
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.arrow_forward, color: Colors.grey, size: 12,),
                  )
                ),
                
              ],
            )
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              child: Ink(
                height: 40,
                width: double.infinity
              ),
              onTap: () async {

                await Get.to(() => CartItemLineScreen(
                  itemLine: itemLine,
                ));

              }, 
            )
          )
        ]
      )
    );

    }).toList();

  }

  List<ItemLine> getItemLines({ required Order order, bool cancelled = false }){

    return order.embedded.activeCart.embedded.itemLines.where((itemLine){
      return itemLine.isCancelled.status == cancelled;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final Order order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.offAll(() => OrderScreen());
              })
            ],
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
                        child: Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              SizedBox(height: 10),
                              Text('Cancelled Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),

                              Divider(height: 20),
                              SizedBox(height: 20),

                              ...getCancelledItemLinesWithReasons(order: order)
                              
                            ],
                          ),
                        ),
                      )
                    ),

                    SizedBox(height: 100)
                  ],
                ),
              )
            ),
          )

        ],
      ),
    );
  }
}