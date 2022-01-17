import 'dart:convert';

import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/models/common/attributes/shortCodeAttribute.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/components/transaction/paymentRequestInstructions.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/requestPaymentScreen.dart';

import './../../../../../screens/dashboard/orders/cartICancelledtemLinesScreen.dart';
import './../../../../../components/custom_button.dart';
import './../../../../../models/transactions.dart';
import './../../../../../providers/orders.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './transaction.dart';
import 'transaction.dart';

class CartTransactions extends StatelessWidget {

  final Function()? afterPaymentRequestCallback;

  CartTransactions({ this.afterPaymentRequestCallback });

  List<Widget> buildTransactionCards(Order order){

    final transactions = order.embedded.transactions;

    return transactions.map((transaction){
      return TransactionWidget(
        transaction: transaction, 
        afterPaymentRequestCallback: afterPaymentRequestCallback
      );
    }).toList();

  }

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    final hasTransactions = order.embedded.transactions.length > 0 ? true : false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 10),
              Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              
              Divider(),
              SizedBox(height: 20),

              //  Transactions
              if(hasTransactions) ...buildTransactionCards(order),

              //  No Transactions
              if(!hasTransactions) Row(
                children: [
                  SvgPicture.asset('assets/icons/ecommerce_pack_1/coin.svg', width: 16, color: Colors.grey),
                  SizedBox(width: 10),
                  Text('No transactions found', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]
              ),

              SizedBox(height: 20),

              //  Request Payment Button
              RequestPaymentButton(afterPaymentRequestCallback: afterPaymentRequestCallback),
              
              SizedBox(height: 20),

            ],
          ),
        ),
      )
    );
  }
}

class RequestPaymentButton extends StatelessWidget {

  final Function()? afterPaymentRequestCallback;

  RequestPaymentButton({ required this.afterPaymentRequestCallback });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CustomButton(
        width: 200,
        size: 'small',
        text: 'Request Payment',
        margin: EdgeInsets.only(top: 20),
        onSubmit: () async {

          final response = await Get.to(() => RequestPaymentScreen());

          if( response == false ){
            return;
          }

          afterPaymentRequestCallback!();

        },
      ),
    );
  }
}