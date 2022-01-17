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

class RequestPaymentScreen extends StatelessWidget {
  
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

  Map serverErrors = {};
  bool isSending = false;
  Transaction? transaction;
  User? differentAccountUser;
  bool hasTransaction = false;
  bool isSearchingUser = false;
  bool sendCustomerSms = false;
  String percentageRate = '50';
  ShortCodeAttribute? paymentShortCode;
  bool foundDifferentAccountUser = false;
  String differentAccountMobileNumber = '';
  final GlobalKey<FormState> _formKey = GlobalKey();
    
  // Payment type
  String selectedPaymentType = 'Full Payment';   
  
  // List of paymentTypes in our dropdown menu
  var paymentTypes = [    
    'Full Payment',
    'Partial Payment',
  ];
    
  // Payment type
  String selectedBillingAccount = 'Customer Amount'; 
  
  // List of billTypes in our dropdown menu
  var billingAccounts = [    
    'Customer Amount',
    'Different Account',
  ];

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

  void startSearchingLoader(){
    setState(() {
      isSearchingUser = true;
    });
  }

  void stopSearchingLoader(){
    setState(() {
      isSearchingUser = false;
    });
  }

  OrdersProvider get ordersProvider {
    return Provider.of<OrdersProvider>(context, listen: false);
  }

  TransactionsProvider get transactionsProvider {
    return Provider.of<TransactionsProvider>(context, listen: false);
  }

  Money get grandTotal {
    return ordersProvider.getOrder.embedded.activeCart.grandTotal;
  }

  String get symbol {
    return ordersProvider.getOrder.embedded.activeCart.currency.symbol;
  }

  bool get isFullPayment {
    return (hasTransaction == false && selectedPaymentType == 'Full Payment') || (hasTransaction == true && percentageRate == '100');
  }

  bool get isBillingCustomerAccount {
    
    final order = ordersProvider.getOrder;

    return (hasTransaction == false && selectedBillingAccount == 'Customer Amount') || (hasTransaction == true  && order.embedded.customer.embedded.user.id == transaction!.payerId);
  
  }

  bool get hasValidPercentageRate {
    return double.tryParse(percentageRate) != null;
  }

  String get validPercentageRate {

    if( hasValidPercentageRate == true ){

      final rate = double.parse(percentageRate);

      //  If the rate is greater than 100% e.g 200%
      if(rate > 100){

        //  Set the limit to 100%
        return '100';
        
      }else{
        
        //  Return the valid percentage rate
        return percentageRate;

      }

    }

    //  Return '0' for invalid parses
    return '0';

  }

  String get paymentAmountText {

    if( isFullPayment ){

      return grandTotal.currencyMoney;

    }else{

      if( hasValidPercentageRate == true ){
      
        return symbol + (double.parse(grandTotal.amount) * double.parse(validPercentageRate) / 100).toStringAsFixed(2);

      }else{

        return 'Invalid Amount';

      }

    }

  }

  String get paymentRemainingAmountText {

    if( isFullPayment ){

      return symbol + '0.00';

    }else{

      if( hasValidPercentageRate == true ){
      
        return symbol + (double.parse(grandTotal.amount) * ((100 - double.parse(validPercentageRate)) / 100)).toStringAsFixed(2);

      }else{

        return 'Invalid Amount';

      }

    }

  }

  @override
  void initState() {

    setState(() {

      final order = ordersProvider.getOrder;
      final customerAccountUser = order.embedded.customer.embedded.user;

      hasTransaction = transactionsProvider.hasTransaction;

      if( hasTransaction ){

        setState(() {

          transaction = transactionsProvider.getTransaction;

          percentageRate = (transaction!.percentageRate == null) ? '100' : transaction!.percentageRate.toString();

          print('*************     percentageRate    ************');
          print(percentageRate);

          //  If the order customer user account is not the same as the transaction user account
          if(customerAccountUser.id != transaction!.payerId){

            differentAccountMobileNumber = transaction!.embedded.payer!.mobileNumber.number;

            differentAccountUser = transaction!.embedded.payer!;

            foundDifferentAccountUser = true;

          }

        });

      }

    });

    super.initState();

  }

  requestPayment(){

    startSendingLoader();

    final percentageRate = double.parse(validPercentageRate);
    final transactionId = (transaction == null) ? null : transaction!.id;
    final payerMobileNumber = isBillingCustomerAccount == true ? null : differentAccountMobileNumber;
    
    ordersProvider.requestPayment(transactionId: transactionId, payerMobileNumber: payerMobileNumber, percentageRate: percentageRate, sendCustomerSms: sendCustomerSms, context: context)
      .then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          setState(() {

            //  Set has transaction
            hasTransaction = true;

            //  Set transaction
            transaction = Transaction.fromJson(responseBody);

            //  Set transaction on Transactions Provider
            transactionsProvider.setTransaction(transaction!);

          });

        }
        
      }).whenComplete((){
        
        stopSendingLoader();

      });
  }


  void searchUsers(){

    //  Reset server errors
    resetServerErrors();

    //  Validate the form
    validateForm().then((success){

      if( success ){

        startSearchingLoader();
      
        Provider.of<UsersProvider>(context, listen: false).searchUserByMobileNumber(
          mobileNumber: differentAccountMobileNumber,
          context: context
        ).then((response){

          handleOnSearchUserResponse(response);

        }).whenComplete((){

          stopSearchingLoader();

        });

      }

    });

  }

  void handleOnSearchUserResponse(http.Response response){

    //  If this is a validation error
    if(response.statusCode == 422){

      handleValidationErrors(response);
      
    }else if( response.statusCode == 200 ){

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      final User user = User.fromJson(responseBody);
        
      setState(() {
      
        differentAccountUser = user;
        foundDifferentAccountUser = true;
        
      });

    }
  }

  void handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];

    /**
     *  validationErrors = {
     *    mobile_number: [Enter a valid mobile number containing only digits e.g 26771234567]
     *  }
     */
    validationErrors.forEach((key, value){
      serverErrors[key] = value[0];
    });
    
  }

  Future<bool> validateForm() async {

    /**
     * When running the _resetloginServerErrors(), we actually reset the loginServerErrors = {}, 
     * however the AuthInputField() must render to pick up these changes. These changes will 
     * clear any previous server errors. Since the re-build of AuthInputField() may take
     * sometime, we don't want to validate the form too soon since we may use the old 
     * loginServerErrors within AuthInputField() causing the form to fail even if the 
     * user input correct information.
     */
    return await Future.delayed(const Duration(milliseconds: 100), () {

      // Run form validation
      return _formKey.currentState!.validate() == true;

    });
    
  }

  void resetServerErrors(){
    serverErrors = {};
  }

  List<Widget> widgetsBeforeRequest (){

    final order = ordersProvider.getOrder;
    final customerAccountUser = order.embedded.customer.embedded.user;
    final customerAccountMobileNumber = customerAccountUser.mobileNumber.number;

    return [
                
      //  Instructions (Before creating payment shortcode)
      RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
          children: [
            TextSpan(text: 'Create a '),
            TextSpan(
              text: 'Payment Shortcode', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            TextSpan(text: ' to share with the customer. This payment shortcode can be dialed by the customer and used to pay for this order using '),
            TextSpan(
              text: 'Orange Money', 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            TextSpan(text: '. Remember that the customer must have an Orange Money Account'),
          ],
        )
      ),

      Divider(height: 40),
      
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

      //  Payment amount
      Row(
        children: [
          Text('Payment Amount:'),
          SizedBox(width: 5,), 
          Text(paymentAmountText, style: TextStyle(fontWeight: FontWeight.bold)),
        ]
      ),

      if(selectedPaymentType == 'Partial Payment') SizedBox(height: 20,), 

      if(selectedPaymentType == 'Partial Payment') TextFormField(
        autofocus: false,
        initialValue: percentageRate,
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
          }else if(double.tryParse(value) == null){
            return 'Enter valid percentage amount';
          }else if(serverErrors.containsKey('percentage')){
            return serverErrors['percentage'];
          }
        },
        onChanged: (value){
          setState(() {

            /**
             *  Set the percentage rate even if the rate is incorrectly formatted
             *  e.g correct value (12, 12.3, 12.34) or incorrect value (12.., 12.1.2.3, e.t.c)
             * 
             *  We will use the validPercentageRate getter to get the properly formatted value 
             */ 
            percentageRate = value;
            
          });
        }
      ),

      SizedBox(height: 20),

      PaymentPlanExplainer(
        grandTotal: grandTotal, 
        isFullPayment: isFullPayment, 
        paymentAmountText: paymentAmountText, 
        validPercentageRate: validPercentageRate, 
        hasValidPercentageRate: hasValidPercentageRate, 
        paymentRemainingAmountText: paymentRemainingAmountText
      ),

      SizedBox(height: 20),

      //  Billing account dropdown
      Row(
        children: [
          Text('Bill To:'),
          SizedBox(width: 5,), 
          
          DropdownButton(

            // Initial Value
            value: selectedBillingAccount,
              
            // Down Arrow Icon
            icon: const Icon(Icons.keyboard_arrow_down),
              
            // Array list of billingAccounts
            items: billingAccounts.map((String billingAccount) {
              return DropdownMenuItem(
                value: billingAccount,
                child: Text(billingAccount, style: TextStyle(fontWeight: FontWeight.bold)),
              );
            }).toList(),

            // After selecting the desired option,it will
            // change button value to selected value
            onChanged: (String? newValue) { 
              setState(() {
                selectedBillingAccount = newValue!;
              });
            },

          ),

        ],
      ),

      if(isBillingCustomerAccount == false && foundDifferentAccountUser == false) Container(
        margin: EdgeInsets.only(top: 20),
        child: Text('Enter the mobile number of the account to be billed', style: TextStyle(fontSize: 12))
      ),

      if(isBillingCustomerAccount == false) Container(
        margin: EdgeInsets.only(top: 20),
        child: Row(
          children: [
            Flexible(
              child: TextFormField(
                key: ValueKey('mobile_number'),
                autofocus: false,
                initialValue: differentAccountMobileNumber,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g 72000123',
                  border: InputBorder.none,
                    fillColor: Colors.black.withOpacity(0.05),
                  filled: true
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Please enter account mobile number';
                  }
                },
                onChanged: (value){
                  setState(() {
                    differentAccountMobileNumber = value;
                    foundDifferentAccountUser = false;
                  });
                }
              ),
            ),
            if(foundDifferentAccountUser == false) CustomButton(
              width: 100,
              text: 'Search',
              isLoading: isSearchingUser,
              margin: EdgeInsets.only(left: 10),
              onSubmit: (){
                searchUsers();
              },
            )
          ],
        ),
      ),

      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) SizedBox(height: 20),

      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) 
        BillingAccountExplainer(
          customerAccountUser: customerAccountUser, 
          differentAccountUser: differentAccountUser,
          isBillingCustomerAccount: isBillingCustomerAccount, 
          foundDifferentAccountUser: foundDifferentAccountUser, 
          customerAccountMobileNumber: customerAccountMobileNumber, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
        ),

      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) SizedBox(height: 20),
      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) Divider(height: 20),
      
      //  Send sms to customer checkbox
      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) CustomCheckbox(  
        value: sendCustomerSms,
        text: Expanded(
          child: Text('Send customer the payment shortcode via SMS (Sms will be charged on your account)', style: TextStyle(fontSize: 12))
        ),
        onChanged: (value) {
          if(value != null){
            setState(() {
              sendCustomerSms = value;
            });
          }
        }
      ),
      
      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) Divider(height: 40),

      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //  Ok / Cancel Button
          TextButton(
            child: Text('Cancel'),
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
            disabled: (isSending || (isFullPayment == false && hasValidPercentageRate == false)),
            text: 'Request Payment',
            onSubmit: (){

              requestPayment();

            },
          ),
        ],
      ),

    ];

  }

  List<Widget> widgetsAfterRequest (){

    final List<Widget> widgets = [];

    final order = ordersProvider.getOrder;
    final customerAccountUser = order.embedded.customer.embedded.user;
    final customerAccountMobileNumber = customerAccountUser.mobileNumber.number;

    final bool hasPaymentShortCode = transaction!.attributes.hasPaymentShortCode;

    //  If the given transaction has a payment shortcode
    if( hasPaymentShortCode && transaction!.embedded.status.name != 'Paid'){
        
      widgets.addAll([

        PaymentRequestInstructions(transaction: transaction!),

        Divider(height: 40),

        PaymentPlanExplainer(
          grandTotal: grandTotal, 
          isFullPayment: isFullPayment, 
          paymentAmountText: paymentAmountText, 
          validPercentageRate: validPercentageRate, 
          hasValidPercentageRate: hasValidPercentageRate, 
          paymentRemainingAmountText: paymentRemainingAmountText
        ),

        SizedBox(height: 20),
        
        BillingAccountExplainer(
          customerAccountUser: customerAccountUser, 
          differentAccountUser: differentAccountUser,
          isBillingCustomerAccount: isBillingCustomerAccount, 
          foundDifferentAccountUser: foundDifferentAccountUser, 
          customerAccountMobileNumber: customerAccountMobileNumber, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
        ),
        
        Divider(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            //  Back Button
            CustomButton(
              text: 'Ok',
              width: 100,
              size: 'small',
              onSubmit: (){ 

                //  Remove the alert dialog and return False as final value
                Navigator.of(context).pop();

              }
            ),

          ],
        ),

      ]);

    //  Check if the transaction has a status of Paid (Explaining why we don't have a payment shortcode)
    }else if(transaction!.embedded.status.name == 'Paid'){
      
      widgets.addAll([

        SizedBox(height: 10),
        
        CustomExplainer(
          mark: Icons.check_circle,
          markBgColor: Colors.white,
          markColor: Colors.green,
          title: 'Paid',
          description: 'This transaction was successfully processed',
        ),

        SizedBox(height: 20),

        PaymentPlanExplainer(
          grandTotal: grandTotal, 
          isFullPayment: isFullPayment, 
          paymentAmountText: paymentAmountText, 
          validPercentageRate: validPercentageRate, 
          hasValidPercentageRate: hasValidPercentageRate, 
          paymentRemainingAmountText: paymentRemainingAmountText,
          hasBeenPaid: true
        ),

        SizedBox(height: 20),
        
        BillingAccountExplainer(
          customerAccountUser: customerAccountUser, 
          differentAccountUser: differentAccountUser,
          isBillingCustomerAccount: isBillingCustomerAccount, 
          foundDifferentAccountUser: foundDifferentAccountUser, 
          customerAccountMobileNumber: customerAccountMobileNumber, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
          hasBeenPaid: true
        ),
        
        Divider(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            //  Back Button
            CustomButton(
              text: 'Ok',
              width: 100,
              size: 'small',
              onSubmit: (){ 

                //  Remove the alert dialog and return False as final value
                Navigator.of(context).pop();

              }
            ),

          ],
        ),

      ]);

    //  Otherwise the payment shortcode expired
    }else{
        
      //  If the given transaction does not have a payment shortcode (Probably expired)
      widgets.addAll([
        
        CustomExplainer(
          mark: Icons.info_sharp,
          markBgColor: Colors.white,
          markColor: Colors.yellow.shade700,
          title: 'Expired',
          description: 'The payment shortcode expired. Request a new payment to allow the customer to pay for this order',
        ),

        SizedBox(height: 20),

        PaymentPlanExplainer(
          grandTotal: grandTotal, 
          isFullPayment: isFullPayment, 
          paymentAmountText: paymentAmountText, 
          validPercentageRate: validPercentageRate, 
          hasValidPercentageRate: hasValidPercentageRate, 
          paymentRemainingAmountText: paymentRemainingAmountText,
        ),

        SizedBox(height: 20),
        
        BillingAccountExplainer(
          customerAccountUser: customerAccountUser, 
          differentAccountUser: differentAccountUser,
          isBillingCustomerAccount: isBillingCustomerAccount, 
          foundDifferentAccountUser: foundDifferentAccountUser, 
          customerAccountMobileNumber: customerAccountMobileNumber, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
        ),

        Divider(height: 40),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            //  Ok / Cancel Button
            TextButton(
              child: Text('Back'),
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
              disabled: isSending,
              text: 'Request Payment',
              onSubmit: (){
                requestPayment();
              },
            ),

          ],
        ),

      ]);

    }

    return widgets;

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
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      SizedBox(height: 20),
                
                      //  Heading & Sub-heading
                      Text('Request Payment', style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold),),
                      SizedBox(height: 5),
                      Text('Get customers paying for their orders', style: Theme.of(context).textTheme.bodyText1),
                      
                      SizedBox(height: 20),
                      Divider(height: 20),
                      
                      //  Instructions (Before creating payment shortcode)
                      if(hasTransaction == false) ...widgetsBeforeRequest(),
                
                      //  Instructions (After creating payment shortcode)
                      if(hasTransaction == true) ...widgetsAfterRequest(),
                
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

class BillingAccountExplainer extends StatelessWidget {

  final bool isBillingCustomerAccount;
  final String customerAccountMobileNumber;
  final String differentAccountMobileNumber;
  final bool foundDifferentAccountUser;
  final User customerAccountUser;
  final User? differentAccountUser;
  final bool hasBeenPaid;

  const BillingAccountExplainer({
    required this.isBillingCustomerAccount,
    required this.customerAccountMobileNumber,
    required this.differentAccountMobileNumber,
    required this.foundDifferentAccountUser,
    required this.customerAccountUser,
    required this.differentAccountUser,
    this.hasBeenPaid = false
  });

  @override
  Widget build(BuildContext context) {
    return CustomExplainer(
      mark: Icons.info_sharp,
      markBgColor: Colors.white,
      markColor: Colors.blue,
      title: 'Billing Account',
      description:  
        Wrap(
          children: [
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                children: <TextSpan>[
                  if(isBillingCustomerAccount == true) TextSpan(text: 'The customer'),
                  if(isBillingCustomerAccount == false) TextSpan(text: 'A different'),
                  TextSpan(text: ' account using the mobile number '),
                  TextSpan(
                    text: isBillingCustomerAccount ? customerAccountMobileNumber : differentAccountMobileNumber, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(text: hasBeenPaid ? ' was billed successfully' : ' will be billed', style: TextStyle(fontSize: 12)),
                ],
              )
            ),
            
            SizedBox(height: 20),

          ],
        ),
      
      footer: (isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) 
        ? UserProfileSummary(
            user: (isBillingCustomerAccount == true) ? customerAccountUser :  differentAccountUser!
          )
        : null
    );
  }
}

class PaymentPlanExplainer extends StatelessWidget {

  final bool isFullPayment;
  final bool hasValidPercentageRate;
  final String validPercentageRate;
  final Money grandTotal;
  final String paymentAmountText;
  final String paymentRemainingAmountText;
  final bool hasBeenPaid;

  const PaymentPlanExplainer({
    required this.isFullPayment,
    required this.hasValidPercentageRate,
    required this.validPercentageRate,
    required this.grandTotal,
    required this.paymentAmountText,
    required this.paymentRemainingAmountText,
    this.hasBeenPaid = false
  });

  @override
  Widget build(BuildContext context) {
    return CustomExplainer(
      mark: Icons.info_sharp,
      markBgColor: Colors.white,
      markColor: (isFullPayment == true) || (isFullPayment == false && hasValidPercentageRate == true) ? Colors.blue : Colors.yellow.shade700,
      title: 'Payment Plan',
      sideNote: isFullPayment ? '100%' : validPercentageRate+'%',
      description: (isFullPayment == true) || (isFullPayment == false && hasValidPercentageRate == true) 
        ? (isFullPayment ? 'The customer '+(hasBeenPaid ? 'successfully paid' : 'will be requested to pay')+' the full amount of ' + grandTotal.currencyMoney
                          : 'The customer '+(hasBeenPaid ? 'successfully paid' : 'will be requested to pay')+' a partial amount of ' + paymentAmountText + 
                            ' which is ' + validPercentageRate+'% of the order total ('+grandTotal.currencyMoney+'). A balance of '+paymentRemainingAmountText+' '+(hasBeenPaid ? 'was' : 'will be')+' reserved for future payment.')
        : 'The payment plan is not valid. Make sure your percentage amount is correct',
    );
  }
}