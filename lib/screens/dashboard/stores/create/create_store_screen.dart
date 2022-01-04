import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/list/stores_screen.dart';
import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_button.dart';
import './../../../../components/store_drawer.dart';
import './../../../../providers/stores.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class CreateStoresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        drawer: StoreDrawer(),
        appBar: CustomAppBar(),
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
  var isLoading = false;
  bool showForm = true;
  bool acceptedGoldenRules = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  
  Map storeForm = {
    'name': '',
    'online': true,
    'hex_color': '2D8CF0',
    'location': {
        'online': true,
        'call_to_action': '',
    },
    'allow_sending_merchant_sms': true,
    'offline_message': 'Sorry, we are currently offline',
  };

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

  void _onSubmit(){

    //  Reset server errors
    _resetServerErrors();
    
    //  Validate the form
    validateForm().then((success){

      if( success ){

        if( acceptedGoldenRules == true ){

          //  Save inputs
          _formKey.currentState!.save();

          startLoader();

          Provider.of<StoresProvider>(context, listen: false).createStore(
            body: storeForm,
            context: context
          ).then((response){

            _handleOnSubmitResponse(response);

          }).whenComplete((){

            stopLoader();

          });

        //  If validation failed
        }else{

          final snackBar = SnackBar(content: Text('Check for mistakes', textAlign: TextAlign.center));

          //  Show snackbar  
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }

      }

    });

  }

  Future<bool> validateForm() async {
    
    return await Future.delayed(const Duration(milliseconds: 100), () {

      // Run form validation
      return _formKey.currentState!.validate() == true;

    });
    
  }

  void _handleOnSubmitResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if(response.statusCode == 201){

      final snackBar = SnackBar(content: Text('Store created successfully', textAlign: TextAlign.center));

      //  Show snackbar  
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      //  Navigate to the stores
      Get.offAll(() => StoresScreen());

    }

  }

  void _resetServerErrors(){
    serverErrors = {};
  }

  void _handleValidationErrors(http.Response response){

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

    /**
     *  Since the form is hidden while we are loading, we need to give the
     *  application a chance to set the text input value before we can
     *  validate, we buy ourselves this time by delaying the execution 
     *  of the form validation.
     */
    Future.delayed(const Duration(milliseconds: 100), () {

        // Run form validation
      _formKey.currentState!.validate();

    });
    
  }  

  void toggleShowForm(bool value){
    setState(() {
      showForm = value;
    });
  }

  void toggleAcceptanceOfGoldenRules(bool value){
    setState(() {
      acceptedGoldenRules = value;
    });
  }

  Widget goldenRuleTitle(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          left: BorderSide(color: Colors.orange.shade100, width: 2),
          right: BorderSide(color: Colors.orange.shade100, width: 2)
        )
      ),
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Text(
            '10 Golden Rules',
            style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          Text(
            'Accept these rules to continue',
            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.orange),
          )
        ],
      ),
    );
  }

  Widget goldenRule(number, rule) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, right: 20),
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text(number, style: TextStyle(color: Colors.orange.shade100, fontSize: 40, fontWeight: FontWeight.bold,),),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: EdgeInsets.only(right: 10),
          ),
          Flexible(child: Text(rule, textAlign: TextAlign.justify, style: TextStyle(),))
        ],
      ),
    );
  }

  List<Widget> goldenRuleList() {

    const List<String> rules = [
      'I will not advertise falsely on an any media platforms. All products I advertise to be bought on Bonako Dial2buy will be try and of the highest quality',
      'I will deliver all products and services I sell on Bonako to customers on the agreed upon time I communicate via Bonako.',

      'I will not advertise falsely on an any media platforms. All products I advertise to be bought on Bonako Dial2buy will be try and of the highest quality',
      'I will deliver all products and services I sell on Bonako to customers on the agreed upon time I communicate via Bonako.',

      'I will not advertise falsely on an any media platforms. All products I advertise to be bought on Bonako Dial2buy will be try and of the highest quality',
      'I will deliver all products and services I sell on Bonako to customers on the agreed upon time I communicate via Bonako.',

      'I will not advertise falsely on an any media platforms. All products I advertise to be bought on Bonako Dial2buy will be try and of the highest quality',
      'I will deliver all products and services I sell on Bonako to customers on the agreed upon time I communicate via Bonako.',

      'I will not advertise falsely on an any media platforms. All products I advertise to be bought on Bonako Dial2buy will be try and of the highest quality',
      'I will deliver all products and services I sell on Bonako to customers on the agreed upon time I communicate via Bonako.',
    ];

    final ruleWidgets = rules.mapIndexed((index, rule){
      
      final number = (index + 1).toString();
      
      return goldenRule(number, rule);

    }).toList();

    return ruleWidgets;

  }

  Widget checkboxToAccept(){
    return CustomCheckbox(
      text: 'I Accept to follow these',
      linkText: '10 Golden Rules',
      value: acceptedGoldenRules, 
      link: 'https://github.com/ninety99nine/bonako-mobile-app-privacy-policy/blob/main/privacy-policy',
      onChanged: (value) {
        if(value != null){
          toggleAcceptanceOfGoldenRules(value);
        }
      },
    );
  }

  Widget goldenRuleContent(){
    return Container(
      child: Column(
        children: [
          goldenRuleTitle(),
          SizedBox(height: 20),
          ...goldenRuleList(),
          checkboxToAccept(),
          Divider(),
          CustomButton(
            text: 'Create Store',
            ripple: (acceptedGoldenRules == true),
            disabled: (acceptedGoldenRules == false),
            onSubmit: (){
              toggleShowForm(true);
              _onSubmit();
            },
          ),
          SizedBox(height: 100)
        ],
      ),
    );
  }

  Widget createStoreTitle(){
    return Text(
      'Create Store',
      style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget createStoreDesctiption(){
    return Text(
      'Start selling on Bonako',
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  Widget createStoreForm(){
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            if(isLoading == false) TextFormField(
              autofocus: false,
              initialValue: storeForm['name'],
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Store name",
                hintText: 'E.g Heavenly Fruits',
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
                  return 'Please enter store name';
                }else if(serverErrors.containsKey('name')){
                  return serverErrors['name'];
                }
              },
              onChanged: (value){
                storeForm['name'] = value;
              },
              onSaved: (value){
                storeForm['name'] = value;
              }
            ),
            if(isLoading == false) SizedBox(height: 20,),
            if(isLoading == false) TextFormField(
              autofocus: false,
              initialValue: storeForm['location']['call_to_action'],
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Call to action",
                hintText: 'E.g Buy Fruits',
                helperText: 'Examples: Order Food / Purchase Tickets / Buy Gifts',
                labelStyle: TextStyle(
                  fontSize: 20
                ),
                border:OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter call to action e.g Order food';
                }else if(serverErrors.containsKey('call_to_action')){
                  return serverErrors['call_to_action'];
                }
              },
              onChanged: (value){
                storeForm['location']['call_to_action'] = value;
              },
              onSaved: (value){
                storeForm['location']['call_to_action'] = value;
              }
            ),
            if(isLoading == true) CustomLoader(
              text: 'Creating store...',
              bottomMargin: 20,
            ),

            SizedBox(height: 40,),
    
            //  Create Store
            CustomButton(
              text: acceptedGoldenRules ? 'Create Store' : 'Next',
              disabled: isLoading,
              onSubmit: () {
                if(acceptedGoldenRules == false){
                  toggleShowForm(false);
                }else{
                  _onSubmit();
                }
              }
            )
          ]
        ),
      ),
    );
  }

  Widget createStoreContent(){
    return Column(
      children: [
        SizedBox(height: 20),
        createStoreTitle(),
        createStoreDesctiption(),
        SizedBox(height: 20),
        createStoreForm()
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          CustomBackButton(fallback: (){
            Get.offAll(() => StoresScreen());
          }),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: (showForm == true) ? createStoreContent() : goldenRuleContent()
            ),
          )
        ],
      ),
    );
  }
}