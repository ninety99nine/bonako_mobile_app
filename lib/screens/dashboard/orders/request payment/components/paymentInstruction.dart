import 'package:flutter/material.dart';

class PaymentInstruction extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    //  Payment amount
    return RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
          children: [
            TextSpan(text: 'Create a '),
            TextSpan(
              text: 'Payment Shortcode', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            TextSpan(text: ' to share with the customer. This payment shortcode can be dialed by the customer and used to pay for this order using '),
            TextSpan(
              text: 'Orange Money', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            TextSpan(text: '. Remember that the customer must have an Orange Money Account'),
          ],
        )
      );

  }
}