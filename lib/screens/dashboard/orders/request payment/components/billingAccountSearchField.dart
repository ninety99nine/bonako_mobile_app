import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/providers/users.dart';
import 'package:bonako_mobile_app/models/users.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class BillingAccountSearchField extends StatefulWidget {

  final bool foundDifferentAccountUser;
  final void Function(String)? onChanged;
  final dynamic Function(User)? onSuccess;
  final String customerAccountMobileNumber;
  final String differentAccountMobileNumber;
  final TransactionBillingAccountType selectedBillingAccount;

  BillingAccountSearchField({ 
    required this.onSuccess, required this.selectedBillingAccount, 
    required this.foundDifferentAccountUser, required this.onChanged, 
    required this.customerAccountMobileNumber,
    required this.differentAccountMobileNumber
  });

  @override
  _PaymentPlanExplainerState createState() => _PaymentPlanExplainerState();
  
}

class _PaymentPlanExplainerState extends State<BillingAccountSearchField> {

  Map serverErrors = {};
  bool isSearchingUser = false;
  late bool foundDifferentAccountUser;
  late String differentAccountMobileNumber;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {

    setState(() {

      foundDifferentAccountUser = widget.foundDifferentAccountUser;
      differentAccountMobileNumber = widget.differentAccountMobileNumber;

    });

    super.initState();

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

      if( widget.onSuccess != null ){

        widget.onSuccess!(user);

      }

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
    
    // Run form validation
   _formKey.currentState!.validate();
    
  }

  void resetServerErrors(){
    serverErrors = {};
  }

  Future<bool> validateForm() async {
    
    return await Future.delayed(const Duration(milliseconds: 100), () {

      // Run form validation
      return _formKey.currentState!.validate() == true;

    });
    
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        if(widget.selectedBillingAccount == TransactionBillingAccountType.differentAccount && widget.foundDifferentAccountUser == false) Container(
          margin: EdgeInsets.only(top: 20),
          child: Text('Enter the mobile number of the account to be billed', style: TextStyle(fontSize: 12))
        ),

        if(widget.selectedBillingAccount == TransactionBillingAccountType.differentAccount) Container(
          margin: EdgeInsets.only(top: 20),
          child: Row(
            children: [
              Form(
                key: _formKey,
                child: Flexible(
                  child: TextFormField(
                    key: ValueKey('mobile_number'),
                    autofocus: false,
                    initialValue: widget.differentAccountMobileNumber,
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
                      }else if(serverErrors.containsKey('payer_mobile_number')){
                        return serverErrors['payer_mobile_number'];
                      }
                    },
                    onChanged: (value){
                      setState(() {
                        differentAccountMobileNumber = value;
                        foundDifferentAccountUser = false;
                    
                        if( widget.onChanged != null ){
                          
                          widget.onChanged!(value);
              
                        }
              
                      });
                    }
                  ),
                ),
              ),

              if(widget.foundDifferentAccountUser == false && (differentAccountMobileNumber != widget.customerAccountMobileNumber)) CustomButton(
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

      ],
    );

  }
}