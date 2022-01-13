import 'package:bonako_mobile_app/models/transactions.dart';

import './../../../../../screens/dashboard/orders/cartICancelledtemLinesScreen.dart';
import './../../../../../components/custom_button.dart';
import './../../../../../models/couponLines.dart';
import './../../../../../providers/orders.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartTransaction extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    final hasTransaction = order.embedded.transaction == null ? false : true;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 20),

              //  Transaction
              if(hasTransaction) TransactionLine(),

              //  No Transaction
              if(!hasTransaction) Row(
                children: [
                  SvgPicture.asset('assets/icons/ecommerce_pack_1/coin.svg', width: 16, color: Colors.grey),
                  SizedBox(width: 10),
                  Text('No transaction recorded', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      )
    );
  }
}

class TransactionLine extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    final Transaction transaction = order.embedded.transaction!;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.only(right: 10, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        onTap: () async {
          
          /*
          await Get.to(() => CartCouponLineScreen(
            couponLine: couponLine,
          ));
          */

        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transaction #' + transaction.number),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: TextStyle(color: Colors.black, height: 1.5),
                            children: <TextSpan>[
                              TextSpan(text: 'Status: ', style: TextStyle(color: Colors.grey, fontSize: 12),),
                              TextSpan(text: transaction.embedded.status.name, style: TextStyle(color: Colors.black, fontSize: 12),),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: TextStyle(color: Colors.black, height: 1.5),
                            children: <TextSpan>[
                              TextSpan(text: 'Method: ', style: TextStyle(color: Colors.grey, fontSize: 12),),
                              TextSpan(text: transaction.embedded.paymentMethod.name, style: TextStyle(color: Colors.black, fontSize: 12),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: TextStyle(color: Colors.black, height: 1.5),
                            children: <TextSpan>[
                              TextSpan(text: 'Amount: ', style: TextStyle(color: Colors.grey, fontSize: 12),),
                              TextSpan(text: transaction.amount.currencyMoney, style: TextStyle(color: Colors.black, fontSize: 12),),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ),
            Icon(Icons.arrow_forward, color: Colors.grey, size: 12,),  //  Forward Arrow 
          ],
        ),
      )
    );
  }
}