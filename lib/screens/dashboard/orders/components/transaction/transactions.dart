import 'dart:convert';

import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/models/common/attributes/shortCodeAttribute.dart';
import 'package:bonako_mobile_app/providers/transactions.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/components/transaction/paymentRequestInstructions.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/request%20payment/requestPaymentScreen.dart';

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
    final bool isPaid = order.embedded.paymentStatus.name == 'Paid' ? true : false;
    final bool hasTransactions = order.embedded.transactions.length > 0 ? true : false;

    //  Balance pending percentage
    final percentageBalancePending = order.attributes.paymentProgress.percentageBalancePending;

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

              if(hasTransactions) TransactionSummary(),

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

              if(isPaid == false) SizedBox(height: 20),

              if(isPaid == false && percentageBalancePending.withoutSign < 100) Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /**
                   *  Request Payment Button
                   * 
                   *  show this button if we have not paid for the order entirely and we do not
                   *  have transactions with pending amounts that sum up to 100% the entire
                   *  order amount. 
                   */
                  MarkAsPaidButton(afterPaymentRequestCallback: afterPaymentRequestCallback),
                  RequestPaymentButton(afterPaymentRequestCallback: afterPaymentRequestCallback),

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

class MarkAsPaidButton extends StatelessWidget {

  final Function()? afterPaymentRequestCallback;

  MarkAsPaidButton({ required this.afterPaymentRequestCallback });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CustomButton(
        width: 120,
        size: 'small',
        text: 'Mark As Paid',
        color: Colors.green,
        margin: EdgeInsets.only(top: 20),
        onSubmit: () async {

          final transactionProvider = Provider.of<TransactionsProvider>(context, listen: false);

          transactionProvider.unsetTransaction();

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

class RequestPaymentButton extends StatelessWidget {

  final Function()? afterPaymentRequestCallback;

  RequestPaymentButton({ required this.afterPaymentRequestCallback });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: CustomButton(
        width: 180,
        size: 'small',
        text: 'Request Payment',
        margin: EdgeInsets.only(top: 20),
        onSubmit: () async {

          final transactionProvider = Provider.of<TransactionsProvider>(context, listen: false);

          transactionProvider.unsetTransaction();

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

class TransactionSummary extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final OrdersProvider orderProvider = Provider.of<OrdersProvider>(context, listen: false);
    final Order order = orderProvider.getOrder;

    //  Paid balance
    final balancePaid = order.attributes.paymentProgress.balancePaid;
    final percentageBalancePaid = order.attributes.paymentProgress.percentageBalancePaid;

    //  Pending balance
    final balancePending = order.attributes.paymentProgress.balancePending;
    final percentageBalancePending = order.attributes.paymentProgress.percentageBalancePending;

    //  Outstanding balance
    final balanceOutstanding = order.attributes.paymentProgress.balanceOutstanding;
    final percentageBalanceOutstanding = order.attributes.paymentProgress.percentageBalanceOutstanding;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 15),
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          //  Amount paid
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Balance Paid: ', style: TextStyle(fontSize: 12)),
              Text(balancePaid.currencyMoney, style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
            ]
          ),

          //  Amount paid
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Balance Unpaid: ', style: TextStyle(fontSize: 12)),
              Text(balanceOutstanding.currencyMoney, style: TextStyle(fontSize: 12, color: Colors.yellow.shade900, fontWeight: FontWeight.bold)),
            ]
          )

        ],
      ),
    );
  }
}