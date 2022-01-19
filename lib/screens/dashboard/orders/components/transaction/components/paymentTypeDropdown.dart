import 'package:flutter/material.dart';
import 'package:bonako_mobile_app/enum/enum.dart';

class PaymentTypeDropdown extends StatefulWidget {

  final TransactionPaymentType initialPaymentType;
  final void Function(TransactionPaymentType)? onChanged;
  final List<TransactionPaymentType> rejectedPaymentTypes;
  
  PaymentTypeDropdown({ this.initialPaymentType = TransactionPaymentType.fullPayment, this.onChanged, this.rejectedPaymentTypes = const [] });

  @override
  _PaymentTypeDropdownState createState() => _PaymentTypeDropdownState();
}

class _PaymentTypeDropdownState extends State<PaymentTypeDropdown> {

  int? selectedPaymentType;

  final List<TransactionPaymentType> paymentTypes = TransactionPaymentType.values;

  String getPaymentTypeName(TransactionPaymentType paymentType) {

    if(paymentType == TransactionPaymentType.fullPayment){
      
      return 'Full Payment';

    }else if(paymentType == TransactionPaymentType.partialPayment){
      
      return 'Partial Payment';

    }else{

      return 'Unknown Payment';

    }

  }

  @override
  void initState() {

    selectedPaymentType = widget.initialPaymentType.index;

    // TODO: implement initState
    super.initState();

  }

  List<TransactionPaymentType> get acceptedPaymentTypes {
    
    return paymentTypes.where((paymentType) => widget.rejectedPaymentTypes.contains(paymentType) == false ).toList();

  }

  @override
  Widget build(BuildContext context) {

    //  Payment type dropdown
    return Row(
      children: [

        Text('Payment Type:'),
        SizedBox(width: 5,), 
        
        DropdownButton(

          // Initial Value
          value: selectedPaymentType,
            
          // Down Arrow Icon
          icon: const Icon(Icons.keyboard_arrow_down),    
            
          // Array list of acceptedPaymentTypes
          items: acceptedPaymentTypes.map((TransactionPaymentType paymentType) {
            return DropdownMenuItem(
              value: paymentType.index,
              child: Text(getPaymentTypeName(paymentType), style: TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),

          // After selecting the desired option,it will
          // change button value to selected value
          onChanged: (paymentTypeIndex){

            if( paymentTypeIndex != null ){

              if( widget.onChanged != null ){

                widget.onChanged!( (paymentTypes[(paymentTypeIndex as int)]) );

              }

              setState(() {

                selectedPaymentType = (paymentTypeIndex as int);
                
              });

            }

          },

        ),

      ],
    );

  }
}