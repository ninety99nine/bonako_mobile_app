import 'package:flutter/material.dart';
import 'package:bonako_mobile_app/enum/enum.dart';

class BillingAccountTypeDropdown extends StatefulWidget {

  final TransactionBillingAccountType initialBillingAccountType;
  final void Function(TransactionBillingAccountType)? onChanged;
  
  BillingAccountTypeDropdown({ this.initialBillingAccountType = TransactionBillingAccountType.customerAccount, this.onChanged });

  @override
  _BillingAccountTypeDropdownState createState() => _BillingAccountTypeDropdownState();
}

class _BillingAccountTypeDropdownState extends State<BillingAccountTypeDropdown> {

  int? selectedBillingAccountType;

  final List<TransactionBillingAccountType> billingAccountTypes = TransactionBillingAccountType.values;

  String getBillingAccountTypeName(TransactionBillingAccountType billingAccountType) {

    if(billingAccountType == TransactionBillingAccountType.customerAccount){
      
      return 'Customer Account';

    }else if(billingAccountType == TransactionBillingAccountType.differentAccount){
      
      return 'Different Account';

    }else{

      return 'Unknown Account';

    }

  }

  @override
  void initState() {

    selectedBillingAccountType = widget.initialBillingAccountType.index;

    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {

    //  Billing account dropdown
    return Row(
      children: [

        Text('Bill To:'),
        SizedBox(width: 5,), 
        
        DropdownButton(

          // Initial Value
          value: selectedBillingAccountType,
            
          // Down Arrow Icon
          icon: const Icon(Icons.keyboard_arrow_down),    
            
          // Array list of billingAccountTypes
          items: billingAccountTypes.map((TransactionBillingAccountType billingAccountType) {
            return DropdownMenuItem(
              value: billingAccountType.index,
              child: Text(getBillingAccountTypeName(billingAccountType), style: TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),

          // After selecting the desired option,it will
          // change button value to selected value
          onChanged: (billingAccountTypeIndex){

            if( billingAccountTypeIndex != null ){

              if( widget.onChanged != null ){

                widget.onChanged!( (billingAccountTypes[(billingAccountTypeIndex as int)]) );

              }

              setState(() {

                selectedBillingAccountType = (billingAccountTypeIndex as int);
                
              });

            }

          },

        ),

      ],
    );

  }
}