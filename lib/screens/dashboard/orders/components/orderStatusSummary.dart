import './../../../../components/custom_multi_widget_separator.dart';
import './../../../../models/orders.dart';
import 'package:flutter/material.dart';

class OrderStatusSummary extends StatelessWidget {

  final Order order;

  const OrderStatusSummary({ required this.order });

  @override
  Widget build(BuildContext context) {
    return

      //  Payment status | Delivery status | Total items | Total coupons
      CustomMultiWidgetSeparator(
        texts: [

          //  Payment status
          {
            'widget': Text(order.embedded.paymentStatus.name, style: TextStyle(fontSize: 12, color: (order.embedded.paymentStatus.name == 'Paid' ? Colors.green: Colors.yellow.shade700))),
            'value': order.embedded.paymentStatus.name
          },

          //  Delivery status
          {
            'widget': Text(order.embedded.deliveryStatus.name, style: TextStyle(fontSize: 12, color: (order.embedded.deliveryStatus.name == 'Delivered' ? Colors.green: Colors.yellow.shade700))),
            'value': order.embedded.deliveryStatus.name
          },

          //  Total items
          {
            'widget': Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(order.embedded.activeCart.totalItems.toString() + (order.embedded.activeCart.totalItems.toString() == '1' ? ' item' : ' items'), style: TextStyle(fontSize: 12, color: Colors.grey),),
              ]
            ),
            'value': order.embedded.activeCart.totalItems.toString()
          },

          //  Total coupons
          {
            'widget': Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(order.embedded.activeCart.totalCoupons.toString() + (order.embedded.activeCart.totalCoupons.toString() == '1' ? ' coupon' : ' coupons'), style: TextStyle(fontSize: 12, color: Colors.grey),),
              ]
            ),
            'value': order.embedded.activeCart.totalCoupons.toString()
          },

        ]
      );
  }
}