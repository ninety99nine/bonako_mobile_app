import 'package:bonako_app_3/screens/dashboard/stores/list/stores_screen.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_button.dart';
import './../../../../components/store_drawer.dart';
import './../../../../providers/stores.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class CreateStoresScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      drawer: StoreDrawer(),
      appBar: CustomAppBar(),
      body: StoreFormCard(),
    );
  }
}

class StoreFormCard extends StatefulWidget {

  @override
  _StoreFormCardState createState() => _StoreFormCardState();

}

class _StoreFormCardState extends State<StoreFormCard> {
  
  //  Set the form key
  final GlobalKey<FormState> _formKey = GlobalKey();
  
  Map storeForm = {
    'name': '',
    'online': true,
    'allow_sending_merchant_sms': true,
    'offline_message': 'Sorry, we are currently offline',
    'hex_color': '2D8CF0',
    'location': {
        'online': true,
        'call_to_action': '',
    }
  };

  Map storeServerErrors = {
    'name': '',
    'call_to_action': '',
  };

  //  By default the loader is not loading
  var isLoading = false;

  void _resetStoreServerErrors(){
    storeServerErrors = {
      'name': '',
      'call_to_action': '',
    };
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
      if( storeServerErrors.containsKey(key) ){
        storeServerErrors[key] = value[0];
      }
    });
    
    // Run form validation
   _formKey.currentState!.validate();
    
  }

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
    _resetStoreServerErrors();
    
    //  If local validation passed
    if( _formKey.currentState!.validate() == true ){

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

      final snackBar = SnackBar(content: Text('Store creation failed', textAlign: TextAlign.center));

      //  Show snackbar  
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

    }

  }

  void _handleOnSubmitResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if(response.statusCode == 200){

      //  Navigate to the stores
      Get.off(() => StoresScreen());

    }

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          CustomBackButton(fallback: (){
            Get.off(() => StoresScreen());
          }),
          Divider(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Create Store',
                    style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Start selling on Bonako',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          TextFormField(
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: "Store name",
                              hintText: 'E.g Heavenly Fruits',
                              labelStyle: TextStyle(
                                fontSize: 20
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (value){
                              if(value == null){
                                return 'Please enter store name';
                              }else if(storeServerErrors['name'] != ''){
                                return storeServerErrors['name'];
                              }
                            },
                            onSaved: (value){
                              storeForm['name'] = value;
                            }
                          ),
                          SizedBox(height: 20,),
                          TextFormField(
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
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            validator: (value){
                              if(value == null){
                                return 'Please enter call to action e.g Order food';
                              }else if(storeServerErrors['call_to_action'] != ''){
                                return storeServerErrors['call_to_action'];
                              }
                            },
                            onSaved: (value){
                              storeForm['location']['call_to_action'] = value;
                            }
                          ),

                          SizedBox(height: 40,),
                  
                          //  Create Store
                          CustomButton(
                            text: 'Create Store',
                            isLoading: isLoading,
                            onSubmit: () => _onSubmit()
                          )
                        ]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateStoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {}, 
      child: Text(
        'Create Store',
        style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),  
      ),
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 100, vertical: 20))
      ),
    );
  }
}