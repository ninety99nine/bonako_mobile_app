import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/providers/transactions.dart';
import 'package:bonako_mobile_app/models/common/money.dart';
import 'package:bonako_mobile_app/providers/orders.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SendCustomerSmsCheckbox extends StatefulWidget {

  final bool sendCustomerSms;
  final void Function(bool)? onChanged;

  SendCustomerSmsCheckbox({ required this.sendCustomerSms, this.onChanged });

  @override
  _PaymentPlanExplainerState createState() => _PaymentPlanExplainerState();
  
}

class _PaymentPlanExplainerState extends State<SendCustomerSmsCheckbox> {

  late bool sendCustomerSms;

  @override
  void initState() {

    setState(() {

      sendCustomerSms = widget.sendCustomerSms;

    });

    super.initState();

  }
  
  @override
  Widget build(BuildContext context) {

    return CustomCheckbox(  
      value: sendCustomerSms,
      text: Expanded(
        child: Text('Send customer the payment shortcode via SMS (Sms will be charged on your account)', style: TextStyle(fontSize: 12))
      ),
      onChanged: (value) {
        if(value != null){
          setState(() {
            sendCustomerSms = value;

            if(widget.onChanged != null){
              widget.onChanged!(value);
            }

          });
        }
      }
    );

  }
}