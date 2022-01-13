import 'dart:convert';

import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:bonako_mobile_app/screens/auth/components/mobile_verification_pin_code_input.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/show/order_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/show/store_screen.dart';

import './../../../../screens/dashboard/orders/list/orders_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_app_bar.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/orders.dart';
import './../../../../models/orders.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class VerifyOrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar:CustomAppBar(title: 'Verify Orders'),
        drawer: StoreDrawer(),
        body: Content(),
      )
    );
  }
}

class Content extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.offAll(() => ShowStoreScreen());
              }),
            ],
          ),
          Divider(),
          SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  OrderVerificationInput()
          
                ],
              ),
            ),
          )
        
        ],
      ),
    );
  }
}

class OrderVerificationInput extends StatefulWidget {
  
  final Function(String)? onCompleted;
  final Function(String)? onChanged;

  const OrderVerificationInput({ this.onCompleted, this.onChanged });

  @override
  _OrderVerificationInputState createState() => _OrderVerificationInputState();
}

class _OrderVerificationInputState extends State<OrderVerificationInput> {

  Map serverErrors = {};
  bool isSubmitting = false;
  bool showNextOrderText = false;
  String deliveryConfirmationCode = '';
  final GlobalKey<FormState> _formKey = GlobalKey();

  void startLoader(){
    setState(() {
      isSubmitting = true;
    });
  }

  void stopLoader(){
    setState(() {
      isSubmitting = false;
    });
  }

  ApiProvider get apiProvider {
    return Provider.of<ApiProvider>(context, listen: false);
  }

  AuthProvider get authProvider {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  OrdersProvider get ordersProvider {
    return Provider.of<OrdersProvider>(context, listen: false);
  }

  _onSubmit(){
    
    _resetServerErrors();

    if( _formKey.currentState!.validate() == true ){

      _verifyOrderDeliveryCode();

    }else{

      apiProvider.showSnackbarMessage(msg: 'Invalid delivery code', context: context, type: SnackbarType.error);

    }

  }

  _resetServerErrors(){
    serverErrors = {};
  }

  _verifyOrderDeliveryCode(){

    startLoader();

    return ordersProvider.verifyOrderDeliveryConfirmationCode(deliveryConfirmationCode: deliveryConfirmationCode, context: context)
      .then((response) async {

        final Map responseBody = jsonDecode(response.body);

        //  If this is a successful request
        if( response.statusCode == 200){
    
          final bool isValid = responseBody['is_valid'];
          final Map<String, dynamic> jsonOrder = responseBody['order'] ?? {};

          if( isValid && jsonOrder.isNotEmpty ){

            Order order = Order.fromJson(jsonOrder);
            
            ordersProvider.setOrder(order);

            final result = await Get.to(() => OrderScreen(), arguments: {
              'delivery_confirmation_code': deliveryConfirmationCode,
            });

            if( result == 'accepted' ){

              setState(() {
                
                //  Show next order text
                showNextOrderText = true;

                deliveryConfirmationCode = '';

              });

              //  Stop showing next order text after 5 seconds
              Future.delayed(const Duration(milliseconds: 5000), () {
                
                setState(() {
                  showNextOrderText = false;
                });

              });

            }

          }

        }else if(response.statusCode == 422){

          _handleValidationErrors(response);
          
        }

      }).whenComplete((){

        stopLoader();
      
      });
    
  }

  void _handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];
    
    validationErrors.forEach((key, value){
      serverErrors[key] = value[0];
    });
    
  }

  Widget _instructionText(){
    return Row(
      children: [
        Flexible(
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
              children: <TextSpan>[
                TextSpan(text: 'Enter the 14 digit '),
                TextSpan(
                  text: 'order delivery confirmation code', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                TextSpan(
                  text: ' sent to the customer\'s mobile number via SMS. This is to verify that the order belongs to the customer and that the customer has received their order.', 
                  style: TextStyle(fontSize: 12)
                ),
              ],
            )
          ),
        )
      ],
    );
  }

  Widget _nextOrderText(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_sharp, color: Colors.blue),
          SizedBox(width: 10,),
          Text('Perfect verify the next order', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ]
      ),
    );
  }

  Widget _verificationInput(){
    return
      TextFormField(
        autofocus: false,
        initialValue: deliveryConfirmationCode,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Delivery confirmation code',
          hintText: '123456789',
          labelStyle: TextStyle(
            fontSize: 20
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Enter order delivery confirmation code';
          }if(value.length != 16){
            return 'Must be 16 digits long';
          }else if(serverErrors.containsKey('delivery_confirmation_code')){
            return serverErrors['delivery_confirmation_code'];
          }
        },
        onChanged: (value){
          deliveryConfirmationCode = value;
        },
        onSaved: (value){
          if( value != null ){
            deliveryConfirmationCode = value;
          }
        },
      );
  }

  Widget _verificationButton(){
    return
      CustomButton(
        text: 'Verify',
        disabled: (isSubmitting),
        onSubmit: () {
          _onSubmit();
        },
      );
  }

  @override
  Widget build(BuildContext context) {

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.blue.shade100, width: 1),
            ),
            child: Icon(Icons.safety_divider_sharp, size: 32, color: Colors.blue,)
          ),
          SizedBox(height: 20),
          if(isSubmitting == false && showNextOrderText == true) _nextOrderText(),
          if(isSubmitting == false && showNextOrderText == false) _instructionText(),
          if(isSubmitting == true) CustomLoader(text: 'Verifying code...',),
          SizedBox(height: 20),
          if(isSubmitting == false) _verificationInput(),
          SizedBox(height: 20),
          _verificationButton(),
            
        ],
      ),
    );

  }

}