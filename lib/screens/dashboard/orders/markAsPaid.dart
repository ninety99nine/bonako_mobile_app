import 'dart:convert';
import 'package:bonako_mobile_app/models/users.dart';
import 'package:bonako_mobile_app/providers/transactions.dart';
import 'package:bonako_mobile_app/providers/users.dart';
import 'package:http/http.dart' as http;

import 'package:bonako_mobile_app/components/custom_app_bar.dart';
import 'package:bonako_mobile_app/components/custom_back_button.dart';
import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/components/custom_countup.dart';
import 'package:bonako_mobile_app/components/custom_explainer.dart';
import 'package:bonako_mobile_app/components/store_drawer.dart';
import 'package:bonako_mobile_app/models/common/attributes/shortCodeAttribute.dart';
import 'package:bonako_mobile_app/models/common/money.dart';
import 'package:bonako_mobile_app/models/transactions.dart';
import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/show/order_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/show/components/userProfileSummary.dart';
import 'package:flutter/gestures.dart';

import './../../../../../screens/dashboard/orders/cartICancelledtemLinesScreen.dart';
import './../../../../../components/custom_button.dart';
import './../../../../../models/couponLines.dart';
import './../../../../../providers/orders.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'components/transaction/paymentRequestInstructions.dart';

class MarkAsPaidScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    final Order order = Provider.of<OrdersProvider>(context, listen: false).getOrder;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Order #' + order.number),
        drawer: StoreDrawer(),
        body: Content(),
      )
    );
  }
}

class Content extends StatefulWidget {

  @override
  _ContentState createState() => _ContentState();

}

class _ContentState extends State<Content> {
    
  //  Payment type
  String selectedPaymentType = 'Full Payment';   
  
  //  List of paymentTypes in our dropdown menu
  var paymentTypes = [    
    'Full Payment',
    'Partial Payment',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey();
  ScrollController _scrollController = ScrollController();

  List<Widget> widgetsBeforeRequest (){

    return [
      
      //  Payment type dropdown
      Row(
        children: [

          Text('Payment Type:'),
          SizedBox(width: 5,), 
          
          DropdownButton(

            // Initial Value
            value: selectedPaymentType,
              
            // Down Arrow Icon
            icon: const Icon(Icons.keyboard_arrow_down),    
              
            // Array list of paymentTypes
            items: paymentTypes.map((String paymentType) {
              return DropdownMenuItem(
                value: paymentType,
                child: Text(paymentType, style: TextStyle(fontWeight: FontWeight.bold)),
              );
            }).toList(),

            // After selecting the desired option,it will
            // change button value to selected value
            onChanged: (String? newValue) { 
              setState(() {
                selectedPaymentType = newValue!;
              });
            },

          ),

        ],
      ),
      SizedBox(height: 10,), 

    ];

  }

  List<Widget> widgetsAfterRequest (){

    return [];

  }
  
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.offAll(() => OrderScreen());
              })
            ],
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      SizedBox(height: 20),
                
                      //  Heading & Sub-heading
                      Text('Mark As Paid', style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold),),
                      SizedBox(height: 5),
                      Text('', style: Theme.of(context).textTheme.bodyText1),
                      
                      SizedBox(height: 20),
                      Divider(height: 20),
                      
                      //  Instructions (Before marking as paid)
                      ...widgetsBeforeRequest(),
                
                      //  Instructions (After marking as paid)
                      ...widgetsAfterRequest(),
                
                      SizedBox(height: 100)
                    ],
                  ),
                ),
              )
            ),
          )

        ],
      ),
    );
  }
}