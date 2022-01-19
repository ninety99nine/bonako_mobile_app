import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/models/transactions.dart';
import 'package:bonako_mobile_app/providers/transactions.dart';
import 'package:bonako_mobile_app/models/common/money.dart';
import 'package:bonako_mobile_app/providers/orders.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class RequestPaymentAndCancelButton extends StatefulWidget {

  final String cancelText;
  final bool isFullPayment;
  final bool sendCustomerSms;
  final int validPercentageRate;
  final Transaction? transaction;
  final bool hasValidPercentageRate;
  final bool isBillingCustomerAccount;
  final void Function(Response)? onSuccess;
  final String differentAccountMobileNumber;

  RequestPaymentAndCancelButton({ 
    required this.isFullPayment, required this.sendCustomerSms, required this.validPercentageRate, 
    required this.transaction, required this.onSuccess, required this.hasValidPercentageRate, 
    required this.isBillingCustomerAccount, required this.differentAccountMobileNumber, 
    this.cancelText = 'Cancel'
  });

  @override
  _PaymentPlanExplainerState createState() => _PaymentPlanExplainerState();
  
}

class _PaymentPlanExplainerState extends State<RequestPaymentAndCancelButton> {

  bool isSending = false;

  OrdersProvider get ordersProvider {
    return Provider.of<OrdersProvider>(context, listen: false);
  }

  void startSendingLoader(){
    setState(() {
      isSending = true;
    });
  }

  void stopSendingLoader(){
    setState(() {
      isSending = false;
    });
  }

  @override
  void initState() {

    setState(() {


    });

    super.initState();

  }

  requestPayment(){

    startSendingLoader();

    final transactionId = (widget.transaction == null) ? null : widget.transaction!.id;
    final currPercentageRate = widget.isFullPayment == true ? 100 : widget.validPercentageRate;
    final payerMobileNumber = widget.isBillingCustomerAccount == true ? null : widget.differentAccountMobileNumber;
    
    ordersProvider.requestPayment(transactionId: transactionId, payerMobileNumber: payerMobileNumber, percentageRate: currPercentageRate, sendCustomerSms: widget.sendCustomerSms, context: context)
      .then((response){

        if( response.statusCode == 200 ){

          if( widget.onSuccess != null ){

            widget.onSuccess!(response);

          }

        }
        
      }).whenComplete((){
        
        stopSendingLoader();

      });
  }
  
  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        //  Ok / Cancel Button
        TextButton(
          child: Text(widget.cancelText),
          onPressed: isSending ? null : () { 
            //  Remove the alert dialog and return False as final value
            Navigator.of(context).pop();
          }
        ),

        //  Request Payment
        CustomButton(
          width: 200,
          size: 'small',
          isLoading: isSending,
          disabled: (isSending || (widget.isFullPayment == false && widget.hasValidPercentageRate == false)),
          text: 'Request Payment',
          onSubmit: (){

            requestPayment();

          },
        ),
      ],
    );

  }
}