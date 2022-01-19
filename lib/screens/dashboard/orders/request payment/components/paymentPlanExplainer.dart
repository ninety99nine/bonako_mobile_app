import './../../../../../components/custom_explainer.dart';
import './../../../../../models/common/money.dart';
import './../../../../../enum/enum.dart';
import 'package:flutter/material.dart';

class PaymentPlanExplainer extends StatelessWidget {

  final Money grandTotal;
  final bool isFullPayment;
  final int validPercentageRate;
  final String paymentAmountText;
  final bool hasValidPercentageRate;
  final bool transactionPaidStatus;
  final String paymentRemainingAmountText;

  PaymentPlanExplainer({ 
    required this.grandTotal, required this.isFullPayment, required this.validPercentageRate,
    required this.transactionPaidStatus, required this.paymentRemainingAmountText,
    required this.paymentAmountText, required this.hasValidPercentageRate,
  });
 
  @override
  Widget build(BuildContext context) {

    return CustomExplainer(
      mark: Icons.info_sharp,
      markBgColor: Colors.white,
      markColor: (isFullPayment == true) || (isFullPayment == false && hasValidPercentageRate == true) ? Colors.blue : Colors.yellow.shade700,
      title: 'Payment Plan',
      sideNote: isFullPayment ? '100%' : validPercentageRate.toString()+'%',
      description: (isFullPayment == true) || (isFullPayment == false && hasValidPercentageRate == true) 
        ? ((isFullPayment == true)
            ? 'The customer '+(transactionPaidStatus ? 'successfully paid' : 'will be requested to pay')+' the full amount of ' + grandTotal.currencyMoney
            : 'The customer '+(transactionPaidStatus ? 'successfully paid' : 'will be requested to pay')+' a partial amount of ' + paymentAmountText + 
              ' which is ' + validPercentageRate.toString()+'% of the order total ('+grandTotal.currencyMoney+'). A balance of '+
              paymentRemainingAmountText +' '+ (transactionPaidStatus ? 'was' : 'will be')+' reserved for other transactions.')
        : 'The payment plan is not valid. Make sure your percentage amount is correct',
    );

  }
}