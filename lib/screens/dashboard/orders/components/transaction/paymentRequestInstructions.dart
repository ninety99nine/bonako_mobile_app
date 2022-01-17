import './../../../../../models/common/attributes/shortCodeAttribute.dart';
import 'package:bonako_mobile_app/models/transactions.dart';
import './../../../../../components/custom_countup.dart';
import './../../../../../providers/transactions.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class PaymentRequestInstructions extends StatelessWidget {

  final Transaction transaction;

  PaymentRequestInstructions({ required this.transaction });

  @override
  Widget build(BuildContext context) {

    final transactionProvider = Provider.of<TransactionsProvider>(context, listen: false);

    ShortCodeAttribute? paymentShortCode = transaction.attributes.paymentShortCode;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text('Inform the customer to dial ', style: TextStyle(fontSize: 12)),
        SizedBox(height: 5),

        RichText(
          text: TextSpan(
            text: paymentShortCode!.dialingCode, 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 20),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                transactionProvider.launchPaymentShortcode(context: context);
          })
        ),
        SizedBox(height: 5),

        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
            children: [
              TextSpan(text: ' to pay for this order using '),
              TextSpan(
                text: 'Orange Money', 
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
            ],
          )
        ),

        Divider(height: 40),

        Container(
          child: CustomCountupSinceDateToNow(
            fontSize: 12,
            startDate: paymentShortCode.updatedAt,
            prefixText: 'Payment has not been approved for',
            suffixText: '. Request customer to pay as soon as possible.',
          ),
        ),

      ]
    );
  }
}