import 'package:flutter/material.dart';

class PaymentAmount extends StatelessWidget {

  final String paymentAmountText;

  PaymentAmount({ required this.paymentAmountText });
  
  @override
  Widget build(BuildContext context) {

    //  Payment amount
    return Row(
      children: [
        Text('Payment Amount:'),
        SizedBox(width: 5,),
        Text(paymentAmountText, style: TextStyle(fontWeight: FontWeight.bold))
      ]
    );

  }
}