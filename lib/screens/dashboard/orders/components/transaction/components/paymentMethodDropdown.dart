import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/models/paymentMethods.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class PaymentMethodDropdown extends StatefulWidget {

  final int? selectPaymentMethodId;
  final void Function(int)? onChanged;
  
  PaymentMethodDropdown({ this.selectPaymentMethodId, this.onChanged });

  @override
  _PaymentMethodDropdownState createState() => _PaymentMethodDropdownState();
}

class _PaymentMethodDropdownState extends State<PaymentMethodDropdown> {

  var isLoading = false;
  late int paymentMethodId;
  late List<PaymentMethod> paymentMethods;
  late PaginatedPaymentMethods paginatedPaymentMethods;

  void startLoader(){
    setState(() {
      isLoading = true;
    });
  }

  void stopLoader(){
    setState(() {
      isLoading = false;
    });
  }

  ApiProvider get apiProvider {
    return Provider.of<ApiProvider>(context, listen: false);
  }

  @override
  void initState() {

    fetchPaymentMethods();

    super.initState();

  }

  fetchPaymentMethods() {

      //  Start loader
      startLoader();
        
      //  Fetch the payment methods
      apiProvider.fetchPaymentMethods(context: context).then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          paginatedPaymentMethods = PaginatedPaymentMethods.fromJson(responseBody);

          paymentMethods = paginatedPaymentMethods.embedded.paymentMethods;

          if( widget.selectPaymentMethodId == null ){

            paymentMethodId = paymentMethods.first.id;

          }
        
        }

      }).whenComplete((){

        //  Start loader
        stopLoader();
      
      });

  }

  @override
  Widget build(BuildContext context) {

    //  Payment type dropdown
    return Row(
      children: [

        Text('Payment Method:'),
        SizedBox(width: 5,), 

        if(isLoading == true) CustomLoader(
          size: 10,
          topMargin: 0,
          leftMargin: 5,
          strokeWidth: 2,
        ),
        
        if(isLoading == false) DropdownButton(

          // Initial Value
          value: paymentMethodId,
            
          // Down Arrow Icon
          icon: const Icon(Icons.keyboard_arrow_down),    
            
          // Array list of paymentMethods
          items: paymentMethods.map((PaymentMethod paymentMethod) {
            return DropdownMenuItem(
              value: paymentMethod.id,
              child: Text(paymentMethod.name, style: TextStyle(fontWeight: FontWeight.bold)),
            );
          }).toList(),

          // After selecting the desired option,it will
          // change button value to selected value
          onChanged: (currPaymentMethodId){

            if( currPaymentMethodId != null ){

              if( widget.onChanged != null ){

                widget.onChanged!( (currPaymentMethodId as int) );

              }

              setState(() {

                paymentMethodId = (currPaymentMethodId as int);
                
              });

            }

          },

        ),

      ],
    );

  }
}