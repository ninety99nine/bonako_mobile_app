import './../../../../../models/customers.dart';
import 'package:flutter/material.dart';

class CustomerSummary extends StatelessWidget {
  
  final Customer customer;

  const CustomerSummary({ required this.customer });

  Widget showSummaryCard({ required String title, required IconData icon, required List<Widget> statWidgets }){
    return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Icon(icon, size: 16,),
                foregroundColor: Colors.blue,
                backgroundColor: Colors.blue.shade50,
              ),
              title: Text(title),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                children: statWidgets,
              ),
            )
          ]
        )
      );
  }

  Widget getSpendingHistoryStats(){

    final List<Map> generalStats = [
      {
        'name': 'Sub Total',
        'value': customer.checkoutSubTotal.currencyMoney
      },
      {
        'name': 'Sale Discount Total',
        'value': customer.checkoutSaleDiscountTotal.currencyMoney
      },
      {
        'name': 'Coupon Discount Total',
        'value': customer.checkoutCouponsTotal.currencyMoney
      },
      {
        'name': 'Grand total',
        'value': customer.checkoutGrandTotal.currencyMoney
      },
    ];

    final statWidgets = generalStats.map((stat){

      return Container(
        margin: EdgeInsets.only(bottom: (stat['name'] == 'Coupon Discount Total') ? 0 : 10),
        child: Column(
          children: [
            if(stat['name'] == 'Grand total') Divider(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(stat['name'], style: TextStyle(fontWeight: (stat['name'] == 'Grand total') ? FontWeight.bold : FontWeight.normal)),
                Text(stat['value'], style: TextStyle(fontWeight: (stat['name'] == 'Grand total') ? FontWeight.bold : FontWeight.normal)),
              ],
            )
          ],
        ),
      );

    }).toList();

    return showSummaryCard(
      icon: Icons.attach_money_rounded,
      title: 'Spending History', 
      statWidgets: statWidgets
    );

  }

  Widget getShoppingHistoryStats(){

    final List<Map> stats = [
      {
        'name': 'Orders placed',
        'value': customer.totalOrdersPlacedByCustomer
      },
      {
        'name': 'Items selected',
        'value': customer.checkoutTotalItems
      },
      {
        'name': 'Free delivery claimed',
        'value': customer.totalFreeDeliveryOnCheckout
      },
      {
        'name': 'Adverts used',
        'value': customer.totalAdvertsUsedOnCheckout
      },
      {
        'name': 'Instant carts used',
        'value': customer.totalInstantCartsUsedOnCheckout
      }
    ];

    final statWidgets = stats.map((stat){

      return Container(
        margin: EdgeInsets.only(bottom: (stat['name'] == 'Free delivery claimed') ? 0 : 10),
        child: Column(
          children: [
            if(stat['name'] == 'Adverts used') Divider(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(stat['name']),
                Text(stat['value'].toString()),
              ],
            ),
          ],
        ),
      );

    }).toList();

    return showSummaryCard(
      icon: Icons.shopping_cart_outlined,
      title: 'Shopping History', 
      statWidgets: statWidgets
    );

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Column(
        children: [
          getSpendingHistoryStats(),
          SizedBox(height: 10,),
          getShoppingHistoryStats(),
        ]
      ),
    );
  }
}