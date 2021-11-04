import './../../../../screens/dashboard/orders/list/orders_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_app_bar.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/orders.dart';
import './../../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){

    final order = Provider.of<OrdersProvider>(context, listen: true).getOrder;

    return Scaffold(
      appBar:CustomAppBar(title: 'Order #' + order.number),
      drawer: StoreDrawer(),
      body: Content(),
    );
  }
}

class Content extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.off(() => OrdersScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){}),
            ],
          ),
          Divider(),
          SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text('Order #'+order.number, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                    ],
                  ),
          
                  SizedBox(height: 20),
          
                  OrderCard(),
                  SizedBox(height: 20),
          
                  OrderItemsCard(),
                  SizedBox(height: 20),
          
                  OrderCouponsCard(),
                  SizedBox(height: 20),
          
                  ReceivedLocationCard(),
                  SizedBox(height: 20),
          
                  TransactionsCard()
          
                ],
              ),
            ),
          )
        
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //  Customer name
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(order.embedded.customer.embedded.user.attributes.name)
                  ]
                ),
                //  Customer Number
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.phone, color: Colors.grey, size: 14,),
                    SizedBox(width: 5),
                    Text(order.embedded.customer.embedded.user.mobileNumber.number)
                  ]
                ),
              ],
            ),
            SizedBox(height: 10),
            //  Date
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.watch_later_outlined, color: Colors.grey, size: 14,),
                SizedBox(width: 5),
                Text(DateFormat("MMM d y @ HH:mm").format(order.createdAt), style: TextStyle(fontSize: 14),),
              ]
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(order.embedded.paymentStatus.name, style: TextStyle(fontSize: 14, color: (order.embedded.paymentStatus.name == 'Paid' ? Colors.green: Colors.grey))),
                SizedBox(width: 10),
                Text(order.embedded.deliveryStatus.name, style: TextStyle(fontSize: 14, color: (order.embedded.deliveryStatus.name == 'Delivered' ? Colors.green: Colors.grey))),
                //  Total Items
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: 5),
                      Text('|', style: TextStyle(fontSize: 14, color: Colors.grey),),
                      SizedBox(width: 5),
                      Text(order.embedded.activeCart.totalItems.toString(), style: TextStyle(fontSize: 14, color: Colors.grey),),
                      Text(order.embedded.activeCart.totalItems.toString() == '1' ? ' item' : ' items', style: TextStyle(fontSize: 14, color: Colors.grey),),
                    ]
                  ),
                ),
              ]
            ),
          ],
        ),
      )
    );
  }
}

class OrderItemsCard extends StatelessWidget {

  List<Widget> buildItemCards(Order order){
    return order.embedded.activeCart.embedded.itemLines.map((itemLine){
      return Container(
        margin: EdgeInsets.only(right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(itemLine.quantity.toString()),
                Text(' x '),
                Text(itemLine.name)
              ],
            ),
            Text(itemLine.grandTotal.currencyMoney)
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    final hasItems = order.embedded.activeCart.embedded.itemLines.length > 0 ? true : false;

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
              SizedBox(height: 20),
              if(hasItems) ...buildItemCards(order),
              if(!hasItems) Text('No items found', style: TextStyle(color: Colors.red)),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Sub total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.subTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Coupon Discount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.couponTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Sale Discount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.saleDiscountTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Delivery Fee:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.deliveryFee.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(width: 10),
                ],
              ),
              Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Grand Total: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.grandTotal.currencyMoney, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}

class OrderCouponsCard extends StatelessWidget {

  List<Widget> buildCouponLines(Order order){
    return order.embedded.activeCart.embedded.couponLines.map((couponLine){
      return ListTile(
        contentPadding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 10),
        title: Text(couponLine.name),
        subtitle: Text(couponLine.description),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    final hasCoupons = order.embedded.activeCart.embedded.couponLines.length > 0 ? true : false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('Coupons Applied', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              if(hasCoupons) ...buildCouponLines(order),
              if(!hasCoupons) Text('No coupons found', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      )
    );
  }
}

class ReceivedLocationCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Received Location: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(width: 20),
            Text('Some location'),
          ],
        ),
      )
    );
  }
}

class TransactionsCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('Some transaction'),
            ],
          ),
        ),
      )
    );
  }
}