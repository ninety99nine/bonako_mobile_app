import 'dart:convert';

import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:bonako_mobile_app/screens/auth/components/mobile_verification.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:http/http.dart' as http;
import './../../../../screens/dashboard/orders/list/orders_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_app_bar.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/orders.dart';
import './../../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){

    final order = Provider.of<OrdersProvider>(context, listen: true).getOrder;

    return Scaffold(
      appBar:CustomAppBar(title: 'Order #' + order.number),
      drawer: StoreDrawer(),
      body: Content(),
    );
  }
}

class Content extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {

    final Order order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    final bool hasDeliveryConfirmationCode = Get.arguments == null ? false : (Get.arguments as Map).containsKey('delivery_confirmation_code');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.offAll(() => OrdersScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){}),
            ],
          ),
          Divider(),
          SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text('Order #'+order.number, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                    ],
                  ),
          
                  SizedBox(height: 20),
          
                  OrderCard(),
                  SizedBox(height: 20),
          
                  OrderItemsCard(),
                  SizedBox(height: 20),
          
                  OrderCouponsCard(),
                  SizedBox(height: 20),

                  if(hasDeliveryConfirmationCode == true) ConfirmDeliveryByDeliveryCode(),

                  if(hasDeliveryConfirmationCode == false) ConfirmDeliveryByMobileVerification(order: order)

                  /*
                  ReceivedLocationCard(),
                  SizedBox(height: 20),
          
                  TransactionsCard()
                  */
          
                ],
              ),
            ),
          )
        
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //  Customer name
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(order.embedded.customer.embedded.user.attributes.name)
                  ]
                ),
                //  Customer Number
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.phone, color: Colors.grey, size: 14,),
                    SizedBox(width: 5),
                    Text(order.embedded.customer.embedded.user.mobileNumber.number)
                  ]
                ),
              ],
            ),
            SizedBox(height: 10),
            //  Date
            if(order.createdAt != null) Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.watch_later_outlined, color: Colors.grey, size: 14,),
                SizedBox(width: 5),
                Text(DateFormat("MMM d y @ HH:mm").format(order.createdAt!), style: TextStyle(fontSize: 14),),
              ]
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(order.embedded.paymentStatus.name, style: TextStyle(fontSize: 14, color: (order.embedded.paymentStatus.name == 'Paid' ? Colors.green: Colors.grey))),
                SizedBox(width: 10),
                Text(order.embedded.deliveryStatus.name, style: TextStyle(fontSize: 14, color: (order.embedded.deliveryStatus.name == 'Delivered' ? Colors.green: Colors.grey))),
                //  Total Items
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: 5),
                      Text('|', style: TextStyle(fontSize: 14, color: Colors.grey),),
                      SizedBox(width: 5),
                      Text(order.embedded.activeCart.totalItems.toString(), style: TextStyle(fontSize: 14, color: Colors.grey),),
                      Text(order.embedded.activeCart.totalItems.toString() == '1' ? ' item' : ' items', style: TextStyle(fontSize: 14, color: Colors.grey),),
                    ]
                  ),
                ),
              ]
            ),
          ],
        ),
      )
    );
  }
}

class OrderItemsCard extends StatelessWidget {

  List<Widget> buildItemCards(Order order){
    return order.embedded.activeCart.embedded.itemLines.map((itemLine){
      return Container(
        margin: EdgeInsets.only(right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(itemLine.quantity.toString()),
                Text(' x '),
                Text(itemLine.name)
              ],
            ),
            Text(itemLine.grandTotal.currencyMoney)
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    final hasItems = order.embedded.activeCart.embedded.itemLines.length > 0 ? true : false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('Cart Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              if(hasItems) ...buildItemCards(order),
              if(!hasItems) Text('No items found', style: TextStyle(fontSize: 12, color: Colors.grey)),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Sub total: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.subTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Coupon Discount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.couponTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Sale Discount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.saleDiscountTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Delivery Fee:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.deliveryFee.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(width: 10),
                ],
              ),
              Divider(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Grand Total: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Text(order.embedded.activeCart.grandTotal.currencyMoney, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}

class OrderCouponsCard extends StatelessWidget {

  List<Widget> buildCouponLines(Order order){
    return order.embedded.activeCart.embedded.couponLines.map((couponLine){
      return ListTile(
        contentPadding: EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 10),
        title: Text(couponLine.name),
        subtitle: Text(couponLine.description ?? ''),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final order = Provider.of<OrdersProvider>(context, listen: false).getOrder;
    final hasCoupons = order.embedded.activeCart.embedded.couponLines.length > 0 ? true : false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('Coupons Applied', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              if(hasCoupons) ...buildCouponLines(order),
              if(!hasCoupons) Text('No coupons found', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      )
    );
  }
}

class ReceivedLocationCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Received Location: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(width: 20),
            Text('Some location'),
          ],
        ),
      )
    );
  }
}

class TransactionsCard extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Text('Some transaction'),
            ],
          ),
        ),
      )
    );
  }
}

class ConfirmDeliveryByDeliveryCode extends StatefulWidget {
  const ConfirmDeliveryByDeliveryCode({ Key? key }) : super(key: key);

  @override
  _ConfirmDeliveryByDeliveryCodeState createState() => _ConfirmDeliveryByDeliveryCodeState();
}

class _ConfirmDeliveryByDeliveryCodeState extends State<ConfirmDeliveryByDeliveryCode> {

  Map serverErrors = {};
  bool isSubmitting = false;
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

  @override
  void initState() {
    
    deliveryConfirmationCode = Get.arguments['delivery_confirmation_code'];

    super.initState();

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

    return ordersProvider.acceptOrderAsDelivered(deliveryConfirmationCode: deliveryConfirmationCode, context: context)
      .then((response) async {

        //  If this is a successful request
        if( response.statusCode == 200){

            apiProvider.showSnackbarMessage(msg: 'Order accepted as delivered!', context: context);

            Get.back(result: 'accepted');

        }else if(response.statusCode == 422){

          apiProvider.showSnackbarMessage(msg: 'Could not accept as delivered', context: context, type: SnackbarType.error);

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
                TextSpan(text: 'Accept that this order has been successfully '),
                TextSpan(
                  text: 'paid', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'delivered', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                TextSpan(text: ' to the customer.'),
              ],
            )
          ),
        )
      ],
    );
  }

  Widget _acceptButton(){
    return
      CustomButton(
        text: 'Accept As Delivered',
        disabled: (isSubmitting),
        onSubmit: () {
          _onSubmit();
        },
      );
  }

  Widget _serverErrorText(){
    return Column(
      children: [
        SizedBox(height: 20,),
        ...serverErrors.values.map((value){
          return Row(
            children: [
              Icon(Icons.error_outline_sharp, color: Colors.red),
              SizedBox(width: 5),
              Text(value, style: TextStyle(fontSize: 12, color: Colors.red),)
            ],
          );
        }).toList()
      ]
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Form(
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
              child: SvgPicture.asset('assets/icons/ecommerce_pack_1/like.svg', width: 32, color: Colors.blue,),
            ),
            SizedBox(height: 30),
            if(isSubmitting == false) _instructionText(),
            if(isSubmitting == true) CustomLoader(text: 'Accepting delivery...',),
            _serverErrorText(),
            SizedBox(height: 30),
            _acceptButton(),
            SizedBox(height: 150),
              
          ],
        ),
      ),
    );

  }

}

class ConfirmDeliveryByMobileVerification extends StatefulWidget {
  final Order order;

  const ConfirmDeliveryByMobileVerification({ required this.order });

  @override
  _ConfirmDeliveryByMobileVerificationState createState() => _ConfirmDeliveryByMobileVerificationState();
}

class _ConfirmDeliveryByMobileVerificationState extends State<ConfirmDeliveryByMobileVerification> {

  Map serverErrors = {};
  bool isSubmitting = false;
  String verificationCode = '';

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

  String get _customerMobileNumber {
    return widget.order.embedded.customer.embedded.user.mobileNumber.number;
  }

  _resetServerErrors(){
    serverErrors = {};
  }

  _verifyOrderDeliveryCode(){

    startLoader();

    _resetServerErrors();

    return ordersProvider.acceptOrderAsDelivered(verificationCode: verificationCode, mobileNumber: _customerMobileNumber, context: context)
      .then((response) async {

        //  If this is a successful request
        if( response.statusCode == 200){

            apiProvider.showSnackbarMessage(msg: 'Order accepted as delivered!', context: context);

            Get.back(result: 'accepted');

        }else if(response.statusCode == 422){

          apiProvider.showSnackbarMessage(msg: 'Could not accept as delivered', context: context, type: SnackbarType.error);

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

  Widget _verificationCodeField() {
    return MobileVerification(
      metadata: {
        'order_id': widget.order.id
      },
      hideBackButton: true,
      hideHeadingText: true,
      verifyText: 'Accept As Delivered',
      isProcessingSuccess: isSubmitting,
      mobileNumber: _customerMobileNumber,
      autoGenerateVerificationCode: true,
      mobileNumberInstructionType: MobileNumberInstructionType.mobile_verification_order_delivery_confirmation,
      onCompleted: (value){
        setState(() {
          verificationCode = value;
        });
      },
      onChanged: (value){
        setState(() {
          verificationCode = value;
        });
      },
      onSuccess: (){
        _verifyOrderDeliveryCode();
      }
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.blue.shade100, width: 1),
            ),
            child: SvgPicture.asset('assets/icons/ecommerce_pack_1/like.svg', width: 32, color: Colors.blue,),
          ),
          SizedBox(height: 10),
          _verificationCodeField(),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}