import 'dart:convert';

import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/components/custom_countup.dart';
import 'package:bonako_mobile_app/components/custom_rounded_indicator.dart';
import 'package:bonako_mobile_app/models/common/attributes/shortCodeAttribute.dart';
import 'package:bonako_mobile_app/models/paymentMethods.dart';
import 'package:bonako_mobile_app/models/transactions.dart';
import 'package:bonako_mobile_app/providers/transactions.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/components/transaction/paymentRequestInstructions.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/request%20payment/requestPaymentScreen.dart';
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
    final bool hasTransactionPayer = (transaction.embedded.payer == null) ? false : true;
    final PaymentMethod? paymentMethod = transaction.embedded.paymentMethod;
    final transactionStatusName = (transaction.embedded.status.name);
    final transactionPercentage = (transaction.percentageRate);
    final transactionPayer = (transaction.embedded.payer);

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.blue.withOpacity(0.1))
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          Positioned(
            top: 15.0,
            left: 10.0,
            child: Wrap(
              children: [
                if(transactionStatusName == 'Paid') CustomRoundedIndicator(
                  mark: Icons.check_circle,
                  markBgColor: Colors.white,
                  markColor: Colors.green,
                ),

                if(transactionStatusName == 'Pending') CustomRoundedIndicator(
                  mark: Icons.watch_later,
                  markBgColor: Colors.white,
                  markColor: Colors.yellow.shade900,
                ),

                if(transactionStatusName == 'Failed') CustomRoundedIndicator(
                  mark: Icons.error,
                  markBgColor: Colors.white,
                  markColor: Colors.red.shade900,
                ),
              ],
            )
          ),

          ListTile(
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
              margin: EdgeInsets.only(top: 10, bottom: 10, left: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction #' + transaction.number),
                      SizedBox(height: 8),
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
                          SizedBox(width: 15),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                              children: <TextSpan>[
                                TextSpan(text: 'Amount ', style: TextStyle(color: Colors.grey)),
                                TextSpan(
                                  text: transaction.amount.currencyMoney
                                ),
                                if(transactionPercentage != null) TextSpan(
                                  text: '   '+transactionPercentage.toString()+'%', style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            )
                          )
                        ],
                      ),
                      if(hasPaymentMethod || hasTransactionPayer) SizedBox(height: 8),
                      if(hasPaymentMethod || hasTransactionPayer) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if(hasTransactionPayer) RichText(
                            text: TextSpan(
                              style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                              children: <TextSpan>[
                                TextSpan(text: 'Account ', style: TextStyle(color: Colors.grey)),
                                TextSpan(
                                  text: transactionPayer!.attributes.name
                                ),
                              ],
                            )
                          ),
                          SizedBox(width: 15),
                          if(hasPaymentMethod) RichText(
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
                        ],
                      )
                    ],
                  ),
                  Icon(Icons.arrow_forward, color: Colors.grey, size: 12,),  //  Forward Arrow 
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}