

import './../components/transaction/components/billingAccountTypeDropdown.dart';
import './../components/transaction/components/paymentTypeDropdown.dart';
import './../../../../screens/dashboard/orders/show/order_screen.dart';
import './../components/transaction/paymentRequestInstructions.dart';
import './../../../../components/custom_back_button.dart';
import './components/requestPaymentAndCancelButton.dart';
import './../../../../components/custom_explainer.dart';
import './../../../../components/custom_app_bar.dart';
import './components/billingAccountSearchField.dart';
import './../../../../components/store_drawer.dart';
import './components/sendCustomerSmsCheckbox.dart';
import './../../../../providers/transactions.dart';
import './components/billingAccountExplainer.dart';
import '../../../../../../providers/orders.dart';
import './../../../../models/common/money.dart';
import './components/paymentPlanExplainer.dart';
import './../../../../models/transactions.dart';
import '../../../../../../models/orders.dart';
import './components/paymentInstruction.dart';
import './components/paymentRateField.dart';
import './../../../../models/users.dart';
import './components/paymentAmount.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../../../../enum/enum.dart';
import './components/okButton.dart';
import 'package:get/get.dart';
import 'dart:convert';

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

  int percentageRate = 50;
  User? differentAccountUser;
  bool sendCustomerSms = false;
  bool hasValidPercentageRate = true;
  int maximumPercentageRateLimit = 100;
  bool foundDifferentAccountUser = false;
  String differentAccountMobileNumber = '';
  List<TransactionPaymentType> rejectedPaymentTypes = [];
  ScrollController _scrollController = ScrollController();
    
  // Payment type
  TransactionPaymentType selectedPaymentType = TransactionPaymentType.fullPayment;   
    
  // Billing account type
  TransactionBillingAccountType selectedBillingAccount = TransactionBillingAccountType.customerAccount; 

  OrdersProvider get ordersProvider {
    return Provider.of<OrdersProvider>(context, listen: false);
  }

  TransactionsProvider get transactionsProvider {
    return Provider.of<TransactionsProvider>(context, listen: false);
  }

  Order get order {
    return ordersProvider.getOrder;
  }

  User get customerAccountUser {
    return order.embedded.customer.embedded.user;
  }

  String get customerAccountMobileNumber {
    return customerAccountUser.mobileNumber.number;
  }

  Transaction? get transaction {
    return hasTransaction ? transactionsProvider.getTransaction: null;
  }

  bool get hasTransaction {
    return transactionsProvider.hasTransaction;
  }

  bool get hasPaymentShortCode {
    return transaction == null ? false : transaction!.attributes.hasPaymentShortCode;
  }

  String get transactionStatusName {
    return transaction == null ? '' : transaction!.embedded.status.name;
  }

  bool get transactionPaidStatus {
    return (transaction == null) ? false : transactionStatusName == 'Paid';
  }

  Money get grandTotal {
    return ordersProvider.getOrder.embedded.activeCart.grandTotal;
  }

  String get symbol {
    return ordersProvider.getOrder.embedded.activeCart.currency.symbol;
  }

  bool get isFullPayment {
    return (hasTransaction == true && percentageRate == 100) ||
           (hasTransaction == false && selectedPaymentType == TransactionPaymentType.fullPayment) || 
           (hasTransaction == false && selectedPaymentType == TransactionPaymentType.partialPayment && hasValidPercentageRate && percentageRate == 100 && percentageRate <= maximumPercentageRateLimit );
  }

  bool get isBillingCustomerAccount {
    final order = ordersProvider.getOrder;
    return (hasTransaction == true  && order.embedded.customer.embedded.user.id == transaction!.payerId) || 
           (hasTransaction == false && (selectedBillingAccount == TransactionBillingAccountType.customerAccount) || (selectedBillingAccount == TransactionBillingAccountType.differentAccount && differentAccountMobileNumber == customerAccountMobileNumber));
  }

  int get validPercentageRate {

    if( hasValidPercentageRate == true ){

      final rate = percentageRate;

      //  If the rate is greater than the maximumPercentageRateLimit
      if(rate > maximumPercentageRateLimit){

        //  Set the limit to the maximumPercentageRateLimit
        return maximumPercentageRateLimit;
        
      }else{
        
        //  Return the valid percentage rate
        return percentageRate;

      }

    }

    //  Return '0' for invalid parses
    return 0;

  }
  
  String get paymentAmountText {

    if( isFullPayment ){

      return grandTotal.currencyMoney;

    }else{

      if( hasValidPercentageRate == true ){
      
        return symbol + (double.parse(grandTotal.amount) * validPercentageRate / 100).toStringAsFixed(2);

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
      
        return symbol + (double.parse(grandTotal.amount) * ((100 - validPercentageRate) / 100)).toStringAsFixed(2);

      }else{

        return 'Invalid Amount';

      }

    }

  }

  @override
  void initState() {

    setState(() {

      setState(() {

        if( hasTransaction ){

          print('hasTransaction: YES');

          //  Update the percentage rate using the transaction
          updatePercentageRateFromTransaction();

          //  If the order customer user account is not the same as the transaction user account
          if(customerAccountUser.id != transaction!.payerId){

            //  Set the different account mobile number
            differentAccountMobileNumber = transaction!.embedded.payer!.mobileNumber.number;

            //  Set the different account user
            differentAccountUser = transaction!.embedded.payer!;

            //  Indicate that we found a user
            foundDifferentAccountUser = true;

          }

        }else{

          /**
           *  Set the maximum percentage limit that the user is allowed to set to be
           *  100% minus the percentage total reserved for pending transactions
           *  that still need to be paid. This prevents us from requesting
           *  excessive payments to the same order.
           */
          maximumPercentageRateLimit = (100 - order.attributes.paymentProgress.percentageBalancePending.withoutSign);

          //  If the limit is less than 100 then we cannot offer full payment
          if( maximumPercentageRateLimit < 100){
            
            //  Remove the full payment option
            rejectedPaymentTypes.add(TransactionPaymentType.fullPayment);

            //  Set the payment type to partial payment
            selectedPaymentType = TransactionPaymentType.partialPayment;

            //  Set the percentage rate to the maximum ercentage rate limit
            percentageRate = maximumPercentageRateLimit;

          }

        }

      });

    });

    super.initState();

  }


  @override
  void dispose() {

    _scrollController.dispose();  // dispose the controller

    super.dispose();
  
  }

  updatePercentageRateFromTransaction(){

    setState(() {

      //  Indicate invalid percentage rate
      if( int.tryParse(transaction!.percentageRate.toString()) == null ){

        print('IS VALID: NO');

        hasValidPercentageRate = false;

      //  Indicate valid percentage rate and set the transaction percentage rate
      }else{

        print('IS VALID: YES');

        hasValidPercentageRate = true;
        percentageRate = transaction!.percentageRate!;

      }

    });

  }

  handleOnRequestPaymentSuccess(http.Response response){

    final responseBody = jsonDecode(response.body);

    setState(() {

      final currTransaction = Transaction.fromJson(responseBody);

      //  Set transaction on Transactions Provider
      transactionsProvider.setTransaction(currTransaction);

      //  Update the percentage rate using the transaction
      updatePercentageRateFromTransaction();

      scrollToTop();

    });

  }

  void scrollToTop() {

    Future.delayed(const Duration(milliseconds: 100), () {

      _scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.linear);

    });

  }

  List<Widget> widgetsBeforeRequest (){

    final order = ordersProvider.getOrder;
    final customerAccountUser = order.embedded.customer.embedded.user;
    final customerAccountMobileNumber = customerAccountUser.mobileNumber.number;

    return [
                
      //  Payment Instructions (Before creating payment shortcode)
      PaymentInstruction(),

      Divider(height: 40),
      
      //  Payment Type Dropdown
      PaymentTypeDropdown(
        initialPaymentType: selectedPaymentType,
        rejectedPaymentTypes: rejectedPaymentTypes,
        onChanged: (updatedPaymentType){
          setState(() {
            selectedPaymentType = updatedPaymentType;
          });
        }
      ),
      
      SizedBox(height: 10,), 

      //  Payment Amount
      PaymentAmount(paymentAmountText: paymentAmountText),

      if(selectedPaymentType == TransactionPaymentType.partialPayment) SizedBox(height: 20,), 

      //  Payment Rate Field
      if(selectedPaymentType == TransactionPaymentType.partialPayment) PaymentRateField(
        percentageRate: percentageRate,
        selectedPaymentType: selectedPaymentType,
        hasValidPercentageRate: hasValidPercentageRate,
        maximumPercentageRateLimit: maximumPercentageRateLimit, 
        onValidChange: (validPercentageRate){
          setState(() {
            hasValidPercentageRate = true;
            percentageRate = validPercentageRate;
          });
        },
        onInValidChange: (){
          setState(() {
            hasValidPercentageRate = false;
          });
        }
      ),

      SizedBox(height: 20),

      //  Payment Plan Explainer
      PaymentPlanExplainer(
        grandTotal: grandTotal,  
        isFullPayment: isFullPayment, 
        paymentAmountText: paymentAmountText,
        validPercentageRate: validPercentageRate,
        transactionPaidStatus: transactionPaidStatus, 
        hasValidPercentageRate: hasValidPercentageRate, 
        paymentRemainingAmountText: paymentRemainingAmountText, 
      ),

      SizedBox(height: 20),
          
      //  Billing Account Dropdown
      BillingAccountTypeDropdown(
        initialBillingAccountType: selectedBillingAccount,
        onChanged: (updatedBillingAccount){
          setState(() {
            selectedBillingAccount = updatedBillingAccount;
          });
        }
      ),

      //  Billing Account Search Field
      BillingAccountSearchField(
        selectedBillingAccount: selectedBillingAccount,  
        foundDifferentAccountUser: foundDifferentAccountUser, 
        customerAccountMobileNumber: customerAccountMobileNumber,
        differentAccountMobileNumber: differentAccountMobileNumber,
        onChanged: (value){
          setState(() {
            differentAccountMobileNumber = value;
            foundDifferentAccountUser = false;
            differentAccountUser = null;
          });
        }, 
        onSuccess: (User user){
          setState(() {
            differentAccountUser = user;
            foundDifferentAccountUser = true;
          });
        }, 
      ),

      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) 
        SizedBox(height: 20),

      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) 
        //  Billing Account Explainer
        BillingAccountExplainer(
          customerAccountUser: customerAccountUser,
          differentAccountUser: differentAccountUser, 
          transactionPaidStatus: transactionPaidStatus, 
          isBillingCustomerAccount: isBillingCustomerAccount, 
          foundDifferentAccountUser: foundDifferentAccountUser, 
          customerAccountMobileNumber: customerAccountMobileNumber, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
        ),

      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) 
        SizedBox(height: 20),
      
      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) 
        Divider(height: 20),
      
      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) 
        //  Send SMS To Customer Checkbox
        SendCustomerSmsCheckbox(  
          sendCustomerSms: sendCustomerSms,
          onChanged: (value) {
            setState(() {
              sendCustomerSms = value;
            });
          }
        ),
      
      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true)) 
        Divider(height: 40),

      if(isBillingCustomerAccount == true || (isBillingCustomerAccount == false && foundDifferentAccountUser == true))  
        //  Request Payment And Cancel Button
        RequestPaymentAndCancelButton(
          cancelText: 'Cancel', 
          transaction: transaction, 
          isFullPayment: isFullPayment,
          sendCustomerSms: sendCustomerSms, 
          validPercentageRate: validPercentageRate, 
          hasValidPercentageRate: hasValidPercentageRate, 
          isBillingCustomerAccount: isBillingCustomerAccount, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
          onSuccess: (http.Response response) { 
            handleOnRequestPaymentSuccess(response);
           }, 
        ),

    ];

  }

  List<Widget> widgetsAfterRequest (){

    final List<Widget> widgets = [];

    //  If the given transaction has a payment shortcode and is not Paid
    if( hasPaymentShortCode && transactionStatusName != 'Paid'){
        
      widgets.addAll([

        PaymentRequestInstructions(transaction: transaction!),

        Divider(height: 40),

        //  Payment Plan Explainer
        PaymentPlanExplainer(
          grandTotal: grandTotal,  
          isFullPayment: isFullPayment, 
          paymentAmountText: paymentAmountText,
          validPercentageRate: validPercentageRate,
          transactionPaidStatus: transactionPaidStatus, 
          hasValidPercentageRate: hasValidPercentageRate, 
          paymentRemainingAmountText: paymentRemainingAmountText, 
        ),

        SizedBox(height: 20),
        
        //  Billing Account Explainer
        BillingAccountExplainer(
          transactionPaidStatus: transactionPaidStatus, 
          customerAccountUser: customerAccountUser,
          differentAccountUser: differentAccountUser, 
          isBillingCustomerAccount: isBillingCustomerAccount, 
          foundDifferentAccountUser: foundDifferentAccountUser, 
          customerAccountMobileNumber: customerAccountMobileNumber, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
        ),
        
        Divider(height: 40),

        OkButton(context: context),

      ]);

    //  Check if the transaction has a status of Paid (Explaining why we don't have a payment shortcode)
    }else if(transactionStatusName == 'Paid'){
      
      widgets.addAll([

        SizedBox(height: 10),
        
        //  Transaction Paid Explainer
        CustomExplainer(
          title: 'Paid',
          markColor: Colors.green,
          mark: Icons.check_circle,
          markBgColor: Colors.white,
          description: 'This transaction was successfully processed',
        ),

        SizedBox(height: 20),

        //  Payment Plan Explainer
        PaymentPlanExplainer(
          grandTotal: grandTotal,  
          isFullPayment: isFullPayment, 
          paymentAmountText: paymentAmountText,
          validPercentageRate: validPercentageRate,
          transactionPaidStatus: transactionPaidStatus, 
          hasValidPercentageRate: hasValidPercentageRate, 
          paymentRemainingAmountText: paymentRemainingAmountText, 
        ),

        SizedBox(height: 20),
        
        //  Billing Account Explainer
        BillingAccountExplainer(
          transactionPaidStatus: transactionPaidStatus, 
          customerAccountUser: customerAccountUser,
          differentAccountUser: differentAccountUser, 
          isBillingCustomerAccount: isBillingCustomerAccount, 
          foundDifferentAccountUser: foundDifferentAccountUser, 
          customerAccountMobileNumber: customerAccountMobileNumber, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
        ),
        
        Divider(height: 40),

        //  Ok Button
        OkButton(context: context),

      ]);

    //  Otherwise the payment shortcode expired
    }else{
        
      //  If the given transaction does not have a payment shortcode (Probably expired)
      widgets.addAll([
        
        //  Transaction Expired Explainer
        CustomExplainer(
          mark: Icons.info_sharp,
          markBgColor: Colors.white,
          markColor: Colors.yellow.shade700,
          title: 'Expired',
          description: 'The payment shortcode expired. Request a new payment to allow the customer to pay for this order',
        ),

        SizedBox(height: 20),

        //  Payment Plan Explainer
        PaymentPlanExplainer(
          grandTotal: grandTotal,  
          isFullPayment: isFullPayment, 
          paymentAmountText: paymentAmountText,
          validPercentageRate: validPercentageRate,
          transactionPaidStatus: transactionPaidStatus, 
          hasValidPercentageRate: hasValidPercentageRate, 
          paymentRemainingAmountText: paymentRemainingAmountText, 
        ),

        SizedBox(height: 20),
        
        //  Billing Account Explainer
        BillingAccountExplainer(
          transactionPaidStatus: transactionPaidStatus, 
          customerAccountUser: customerAccountUser,
          differentAccountUser: differentAccountUser, 
          isBillingCustomerAccount: isBillingCustomerAccount, 
          foundDifferentAccountUser: foundDifferentAccountUser, 
          customerAccountMobileNumber: customerAccountMobileNumber, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
        ),

        Divider(height: 40),
        
        //  Request Payment And Cancel Button
        RequestPaymentAndCancelButton(
          cancelText: 'Back', 
          transaction: transaction, 
          isFullPayment: isFullPayment,
          sendCustomerSms: sendCustomerSms, 
          validPercentageRate: validPercentageRate, 
          hasValidPercentageRate: hasValidPercentageRate, 
          isBillingCustomerAccount: isBillingCustomerAccount, 
          differentAccountMobileNumber: differentAccountMobileNumber, 
          onSuccess: (http.Response response) { 
            handleOnRequestPaymentSuccess(response);
           }, 
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
              controller: _scrollController,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
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
              )
            ),
          )

        ],
      ),
    );

  }

}