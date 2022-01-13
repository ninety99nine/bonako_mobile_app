import 'package:bonako_mobile_app/components/custom_countup.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/components/cartCouponLines/couponLines.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/components/transaction/transaction.dart';

import './../../../../screens/dashboard/orders/components/cartItemLines/cartItemLines.dart';
import './../../../../screens/dashboard/orders/components/customerSummaryCard.dart';
import './../../../../screens/dashboard/orders/components/orderStatusSummary.dart';
import './../../../../screens/dashboard/orders/list/orders_screen.dart';
import './../../../../screens/auth/components/mobile_verification.dart';
import './../../../../components/custom_multi_widget_separator.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_button.dart';
import './../../../../components/custom_divider.dart';
import './../../../../components/custom_loader.dart';
import '../../../../components/store_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../providers/orders.dart';
import './../../../../providers/auth.dart';
import './../../../../providers/api.dart';
import './../../../../models/orders.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './../../../../enum/enum.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:convert';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  String? orderNumber;

  OrdersProvider get ordersProvider {
    return Provider.of<OrdersProvider>(context, listen: false);
  }

  @override
  void initState() {
    
    //  Get the order set on the ordersProvider
    final Order order = Provider.of<OrdersProvider>(context, listen: false).getOrder;

    //  Set the App Bar Order #
    setOrderNumber(order.number);

    super.initState();

  }

  void setOrderNumber(String orderNumber){
    setState(() {
      this.orderNumber = orderNumber;
    });
  }
    
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: CustomAppBar(title: orderNumber == null ? '######' : 'Order #' + orderNumber!),
      drawer: StoreDrawer(),
      body: Content(
        setOrderNumber: setOrderNumber
      ),
    );
  }
}

class Content extends StatefulWidget {

  final void Function(String) setOrderNumber;

  Content({ required this.setOrderNumber });

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {

  late Order order;
  var isLoading = false;
  ScrollController _scrollController = ScrollController();

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

  OrdersProvider get ordersProvider {
    return Provider.of<OrdersProvider>(context, listen: false);
  }

  @override
  void initState() {

    fetchOrder();

    super.initState();

  }

  fetchOrder() {

      //  Start loader
      startLoader();
        
      //  Fetch the order
      ordersProvider.fetchOrder(context: context).then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          final order = Order.fromJson(responseBody as Map<String, dynamic>);

          //  Set the order on the ordersProvider
          ordersProvider.setOrder(order);

          //  Set the App Bar Order #
          widget.setOrderNumber(order.number);
        
        }

      }).whenComplete((){

        //  Start loader
        stopLoader();
      
      });

  }

  void scrollToBottom() {

    /**
     *  Since executing currLoginStage = LoginStage.enterVerificationCode
     *  will force the form to change the input fields, we need to give the
     *  application a chance to change the inputs before we can validate,
     *  we buy ourselves this time by delaying the execution of the form
     *  validation
     */
    Future.delayed(const Duration(milliseconds: 100), () {

      /**
       * Scroll maximum end, if you want you can give hardcoded values 
       * also in place of _scrollController.position.maxScrollExtent
       */
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease
      );

    });

  }

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
              CustomRoundedRefreshButton(onPressed: (){
                fetchOrder();
              }),
            ],
          ),
          Divider(),
          SizedBox(height: 20),

          //  show loader if loading
          if(isLoading == true) CustomLoader(),

          //  Show order if not loading
          if(isLoading == false) Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text('Order #'+order.number, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                    ],
                  ),
          
                  SizedBox(height: 20),
          
                  CustomerSummaryCard(
                    order: order,
                    onReturn: fetchOrder
                  ),
                  SizedBox(height: 20),
          
                  CartItemLines(),
                  SizedBox(height: 20),
          
                  CartCouponLines(),
                  SizedBox(height: 20),
          
                  CartTransaction(),
                  SizedBox(height: 20),

                  DeliveryConfirmationStaus(
                    hasDeliveryConfirmationCode: hasDeliveryConfirmationCode
                  ),

                  if(hasDeliveryConfirmationCode == true && order.deliveryVerified == false) ConfirmDeliveryByDeliveryCode(
                    scrollToBottom: scrollToBottom
                  ),

                  if(hasDeliveryConfirmationCode == false && order.deliveryVerified == false) ConfirmDeliveryByMobileVerification(
                    order: order,
                    scrollToBottom: scrollToBottom
                  ),

                  SizedBox(height: 100),

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
class DeliveryConfirmationStaus extends StatefulWidget {

  final bool hasDeliveryConfirmationCode;

  DeliveryConfirmationStaus({ required this.hasDeliveryConfirmationCode });

  @override
  _DeliveryConfirmationStausState createState() => _DeliveryConfirmationStausState();

}

class _DeliveryConfirmationStausState extends State<DeliveryConfirmationStaus> {

  OrdersProvider get ordersProvider {
    return Provider.of<OrdersProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    
    //  Get the order set on the ordersProvider
    final Order order = Provider.of<OrdersProvider>(context, listen: false).getOrder;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: order.deliveryVerified ? 20 : 0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: order.deliveryVerified ? 40 : 20, vertical: 20),
              decoration: BoxDecoration(
                  color: order.deliveryVerified ? Colors.blue.shade50 : Colors.orange.shade50, 
                borderRadius: BorderRadius.circular(order.deliveryVerified == true ? 100 : 10),
                border: Border.all(
                  color: order.deliveryVerified ? Colors.blue.shade100 : Colors.orange.shade100, 
                  width: 1
                ),
              ),
              child: Column(
                children: [
                  SvgPicture.asset(
                    order.deliveryVerified 
                      ?  'assets/icons/ecommerce_pack_1/like.svg' 
                      :  'assets/icons/ecommerce_pack_1/delivery.svg',
                    color: order.deliveryVerified ? Colors.blue : Colors.orange,
                    width: 32,
                  ),
                  SizedBox(height: 10),
                  Text(
                    order.deliveryVerified ? 'Order delivered' : 'Order not delivered',
                    style: TextStyle(color: order.deliveryVerified ? Colors.blue : Colors.orange,),
                  ),

                  if(order.deliveryVerified == false) Divider(height: 20),

                  if(order.deliveryVerified == false) Container(
                    child: CustomCountupSinceDateToNow(
                      fontSize: 12,
                      startDate: order.createdAt,
                      prefixText: 'Delivery has not been approved for',
                      suffixText: '. Confirm delivery as soon as possible.' +
                                  (widget.hasDeliveryConfirmationCode == true ? '' : ' Follow intructions below'),
                    ),
                  ),
                ],
              )
            ),
          ),

          if(order.deliveryVerified == true && order.deliveryVerifiedBy != null) SizedBox(height: 40),
          if(order.deliveryVerified == true && order.deliveryVerifiedBy != null) RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: 'Delivery verified by: ', style: TextStyle(color: Colors.black)),
                TextSpan(text: order.deliveryVerifiedBy, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),

          if(order.deliveryVerified == true && order.attributes.timeElapsedToDeliveryVerified != null) SizedBox(height: 10),
          if(order.deliveryVerified == true && order.attributes.timeElapsedToDeliveryVerified != null) RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: 'Time to delivery: ', style: TextStyle(color: Colors.black)),
                TextSpan(text: order.attributes.timeElapsedToDeliveryVerified!.twoEntries, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
            
        ],
      ),
    );

  }
}

class ConfirmDeliveryByDeliveryCode extends StatefulWidget {
  final Function() scrollToBottom;

  const ConfirmDeliveryByDeliveryCode({ required this.scrollToBottom });

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
          
          widget.scrollToBottom();
          
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
            SizedBox(height: 20),
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
  final Function() scrollToBottom;

  const ConfirmDeliveryByMobileVerification({ required this.order, required this.scrollToBottom });

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

          //  Make to scroll to the bottom of the screen
          widget.scrollToBottom();
          
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
      autoGenerateVerificationCode: false,
      mobileNumberInstructionType: MobileNumberInstructionType.mobile_verification_order_delivery_confirmation,
      onGenerateMobileVerificationCode: (){
        widget.scrollToBottom();
      },
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
          _verificationCodeField()
        ],
      ),
    );
  }
}