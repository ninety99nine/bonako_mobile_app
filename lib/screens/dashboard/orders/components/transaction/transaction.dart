import 'dart:convert';

import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/components/custom_countup.dart';
import 'package:bonako_mobile_app/models/common/attributes/shortCodeAttribute.dart';
import 'package:bonako_mobile_app/models/paymentMethods.dart';
import 'package:bonako_mobile_app/models/transactions.dart';
import 'package:bonako_mobile_app/providers/transactions.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/components/transaction/paymentRequestInstructions.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/requestPaymentScreen.dart';
import 'package:flutter/gestures.dart';

import './../../../../../screens/dashboard/orders/cartICancelledtemLinesScreen.dart';
import './../../../../../components/custom_button.dart';
import './../../../../../models/couponLines.dart';
import './../../../../../providers/orders.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionWidget extends StatelessWidget {

  final Transaction transaction;

  final Function()? afterPaymentRequestCallback;

  TransactionWidget({ required this.transaction, required this.afterPaymentRequestCallback });

  @override
  Widget build(BuildContext context) {

    final bool hasPaymentMethod = transaction.embedded.paymentMethod == null ? false : true;
    final PaymentMethod? paymentMethod = transaction.embedded.paymentMethod;
    final transactionStatusName = (transaction.embedded.status.name);

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.only(right: 10, bottom: 10),
      child: ListTile(
        onTap: () async {

          final transactionProvider = Provider.of<TransactionsProvider>(context, listen: false);

          transactionProvider.setTransaction(transaction);

          final response = await Get.to(() => RequestPaymentScreen());

          transactionProvider.unsetTransaction();

          if( response == false ){
            return;
          }

          afterPaymentRequestCallback!();

        },
        title: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transaction #' + transaction.number),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(text: 'Status ', style: TextStyle(color: Colors.grey)),
                            TextSpan(
                              text: transactionStatusName, 
                              style: TextStyle(color: (transactionStatusName == 'Paid') ? Colors.green : (transactionStatusName == 'Pending' ? Colors.yellow.shade900 : Colors.black) )
                            ),
                          ],
                        )
                      ),
                      SizedBox(width: 20),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(text: 'Amount ', style: TextStyle(color: Colors.grey)),
                            TextSpan(
                              text: transaction.amount.currencyMoney
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                  if(hasPaymentMethod) SizedBox(height: 10),
                  if(hasPaymentMethod) Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(text: 'Payment Method ', style: TextStyle(color: Colors.grey)),
                            TextSpan(
                              text: paymentMethod!.name
                            ),
                          ],
                        )
                      ),
                      SizedBox(width: 20),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(text: 'Amount ', style: TextStyle(color: Colors.grey)),
                            TextSpan(
                              text: transaction.amount.currencyMoney
                            ),
                          ],
                        )
                      )
                    ],
                  )
                ],
              ),
              Icon(Icons.arrow_forward, color: Colors.grey, size: 12,),  //  Forward Arrow 
            ],
          ),
        ),
      )
    );
  }
}