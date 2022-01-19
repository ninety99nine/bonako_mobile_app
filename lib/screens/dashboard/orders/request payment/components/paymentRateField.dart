import 'package:bonako_mobile_app/providers/transactions.dart';
import 'package:bonako_mobile_app/models/common/money.dart';
import 'package:bonako_mobile_app/providers/orders.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class PaymentRateField extends StatefulWidget {

  final int percentageRate;
  final bool hasValidPercentageRate;
  final int maximumPercentageRateLimit;
  final void Function()? onInValidChange;
  final void Function(int)? onValidChange;
  final TransactionPaymentType selectedPaymentType;

  PaymentRateField({ 
    required this.percentageRate, required this.hasValidPercentageRate, required this.maximumPercentageRateLimit, 
    required this.onInValidChange, required this.onValidChange, required this.selectedPaymentType,
  });

  @override
  _PaymentPlanExplainerState createState() => _PaymentPlanExplainerState();
  
}

class _PaymentPlanExplainerState extends State<PaymentRateField> {

  late bool hasTransaction;
  late int percentageRate;

  @override
  void initState() {

    setState(() {

      percentageRate = widget.percentageRate;
      hasTransaction = transactionsProvider.hasTransaction;

    });

    super.initState();

  }
  
  OrdersProvider get ordersProvider {
    return Provider.of<OrdersProvider>(context, listen: false);
  }

  TransactionsProvider get transactionsProvider {
    return Provider.of<TransactionsProvider>(context, listen: false);
  }

  String get symbol {
    return ordersProvider.getOrder.embedded.activeCart.currency.symbol;
  }

  Money get grandTotal {
    return ordersProvider.getOrder.embedded.activeCart.grandTotal;
  }

  bool get isFullPayment {
    return (hasTransaction == true && widget.percentageRate == 100) ||
           (hasTransaction == false && widget.selectedPaymentType == TransactionPaymentType.fullPayment) || 
           (hasTransaction == false && widget.selectedPaymentType == TransactionPaymentType.partialPayment && widget.hasValidPercentageRate && widget.percentageRate == 100 && widget.percentageRate <= widget.maximumPercentageRateLimit );
  }

  bool get hasValidMaximumPercentageRateLimit {
    return int.tryParse(widget.maximumPercentageRateLimit.toString()) != null;
  }

  String get maximumPaymentAmountText {

    if( isFullPayment ){

      return grandTotal.currencyMoney;

    }else{

      if( hasValidMaximumPercentageRateLimit == true ){
      
        return symbol + (double.parse(grandTotal.amount) * widget.maximumPercentageRateLimit / 100).toStringAsFixed(2);

      }else{

        return 'Invalid Amount';

      }

    }

  }
  
  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        
        TextFormField(
            autofocus: false,
            initialValue: percentageRate.toString(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Percentage amount",
              suffixIcon: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text('%', style: TextStyle(fontSize: 16)),
              ),
              hintText: 'E.g 50',
              border:OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            validator: (value){
              
              if(value == null || value.isEmpty){
                return 'Enter percentage amount';
              }else if(int.tryParse(value) == null){
                return 'Enter valid percentage amount';
              }
            },
            onChanged: (value){
              setState(() {

                //  Set the percentage rate only if valid
                if( int.tryParse(value.toString()) != null && int.parse(value) > 0 ){

                  percentageRate = int.parse(value);

                  if( widget.onValidChange != null ){

                    widget.onValidChange!(percentageRate);

                  }

                }else{

                  if( widget.onInValidChange != null ){

                    widget.onInValidChange!();

                  }

                }
                
              });
            }
        ),

        if(widget.maximumPercentageRateLimit < 100) Container(
          margin: EdgeInsets.only(top: 20),
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
              children: <TextSpan>[
                TextSpan(text: 'NOTE: ', style: TextStyle(fontWeight: FontWeight.bold, color: (widget.hasValidPercentageRate && percentageRate > widget.maximumPercentageRateLimit) ? Colors.red.shade900 : Colors.black)),
                TextSpan(text: 'You cannot request more than '),
                TextSpan(text: widget.maximumPercentageRateLimit.toString()+'%', style: TextStyle(fontWeight: FontWeight.bold, color: (widget.hasValidPercentageRate && percentageRate > widget.maximumPercentageRateLimit) ? Colors.red.shade900 : Colors.blue)),
                TextSpan(text: ' of '+grandTotal.currencyMoney+' You are strictly limited to request '+maximumPaymentAmountText+' or less since other transactions are still pending payments.'),
              ],
            )
          ),
        ),

      ],
    );

  }
}