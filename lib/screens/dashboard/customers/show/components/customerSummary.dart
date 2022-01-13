import 'package:bonako_mobile_app/components/custom_card.dart';

import './../../../../../models/customers.dart';
import 'package:flutter/material.dart';

class CustomerSummary extends StatelessWidget {
  
  final Customer customer;

  const CustomerSummary({ required this.customer });

  Widget getCheckoutHistoryStats(){

    final List<Map> generalStats = [
      {
        'name': 'Sub Total',
        'value': customer.subTotalOnCheckout.currencyMoney
      },
      {
        'name': 'Sale Discount Total',
        'value': customer.saleDiscountTotalOnCheckout.currencyMoney
      },
      {
        'name': 'Coupon Discount Total',
        'value': customer.couponTotalOnCheckout.currencyMoney
      },
      {
        'name': 'Grand total',
        'value': customer.grandTotalOnCheckout.currencyMoney
      },
    ];

    final statWidgets = generalStats.map((stat){

      final index = generalStats.indexOf(stat);
      final isFirstItem = (index == 0);
      final requiresSeparation =  ['Grand total'].contains(stat['name']);

      return Container(
        margin: EdgeInsets.only(top: (isFirstItem || requiresSeparation) ? 0 : 10),
        child: Column(
          children: [
            if(requiresSeparation) Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(stat['name'], style: TextStyle(fontWeight: (stat['name'] == 'Grand total') ? FontWeight.bold : FontWeight.normal)),
                Text(stat['value'], style: TextStyle(fontWeight: (stat['name'] == 'Grand total') ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ],
        ),
      );

    }).toList();

    return CustomCard(
      title: 'Checkout Total', 
      description: statWidgets,
      icon: Icons.account_balance_wallet_outlined,
    );

  }

  Widget getConversionHistoryStats(){

    final List<Map> generalStats = [
      {
        'name': 'Sub Total',
        'value': customer.subTotalOnConversion.currencyMoney
      },
      {
        'name': 'Sale Discount Total',
        'value': customer.saleDiscountTotalOnConversion.currencyMoney
      },
      {
        'name': 'Coupon Discount Total',
        'value': customer.couponTotalOnConversion.currencyMoney
      },
      {
        'name': 'Grand total',
        'value': customer.grandTotalOnConversion.currencyMoney
      },
    ];

    final statWidgets = generalStats.map((stat){

      final index = generalStats.indexOf(stat);
      final isFirstItem = (index == 0);
      final requiresSeparation =  ['Grand total'].contains(stat['name']);

      return Container(
        margin: EdgeInsets.only(top: (isFirstItem || requiresSeparation) ? 0 : 10),
        child: Column(
          children: [
            if(requiresSeparation) Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(stat['name'], style: TextStyle(fontWeight: (stat['name'] == 'Grand total') ? FontWeight.bold : FontWeight.normal)),
                Text(stat['value'], style: TextStyle(fontWeight: (stat['name'] == 'Grand total') ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ],
        ),
      );

    }).toList();

    return CustomCard(
      title: 'Conversion Total', 
      description: statWidgets,
      icon: Icons.attach_money_rounded,
    );

  }

  Widget getShoppingHistoryStats(){

    final List<Map> stats = [
      {
        'name': 'Orders placed',
        'value': customer.totalOrdersPlacedByCustomerOnCheckout
      },
      {
        'name': 'Orders delivered',
        'value': customer.totalOrdersPlacedByCustomerOnCheckout
      },
      {
        'name': 'Orders cancelled',
        'value': customer.totalOrdersPlacedByCustomerOnCheckout
      },
      {
        'name': 'Items selected',
        'value': customer.totalItemsOnCheckout
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

      final index = stats.indexOf(stat);
      final isFirstItem = (index == 0);
      final requiresSeparation =  ['Items selected', 'Adverts used'].contains(stat['name']);

      return Container(
        margin: EdgeInsets.only(top: (isFirstItem || requiresSeparation) ? 0 : 10),
        child: Column(
          children: [
            if(requiresSeparation) Divider(height: 30),
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

    return CustomCard(
      title: 'Shopping History', 
      description: statWidgets,
      icon: Icons.shopping_cart_outlined,
    );

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Column(
        children: [
          getCheckoutHistoryStats(),
          SizedBox(height: 10,),
          getConversionHistoryStats(),
          SizedBox(height: 10,),
          getShoppingHistoryStats(),
        ]
      ),
    );
  }
}