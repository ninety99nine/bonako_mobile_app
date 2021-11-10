import 'dart:convert';

import 'package:bonako_app_3/components/custom_floating_action_button.dart';
import 'package:bonako_app_3/components/custom_rounded_refresh_button.dart';
import 'package:bonako_app_3/models/stores.dart';
import 'package:bonako_app_3/screens/dashboard/stores/show/store_screen.dart';

import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import '../../../../../providers/stores.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: CustomFloatingActionButton(),
      appBar: CustomAppBar(title: 'Settings'),
      drawer: StoreDrawer(),
      body: Content(),
    );
  }
}

class Content extends StatefulWidget {
  
  @override
  _ContentState createState() => _ContentState();
  
}

class _ContentState extends State<Content> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  Map storeServerErrors = {};
  bool isSubmitting = false;
  Map storeForm = {};

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

  @override
  void initState() {

    _setStoreForm();
    super.initState();
  
  }

  void _setStoreForm(){

    Store store = storesProvider.getStore;

    print('store');
    print(store.online);

    setState(() {

      storeForm = {
        'name': store.name,
        'online': store.online.status,
      };
      
    });

  }

  void _updateStore(){

    //  Reset server errors
    _resetStoreServerErrors();
    
    //  If local validation passed
    if( _formKey.currentState!.validate() == true ){

      //  Save inputs
      _formKey.currentState!.save();

      startLoader();

      Provider.of<StoresProvider>(context, listen: false).updateStore(
        body: storeForm,
        context: context
      ).then((response){

        _handleOnSubmitResponse(response);

      }).whenComplete((){

        stopLoader();

      });
    
    //  If validation failed
    }else{

      storesProvider.showSnackbarMessage(msg: 'Validation failed', context: context);

    }

  }

  void _resetStoreServerErrors(){
    storeServerErrors = {};
  }

  void _handleOnSubmitResponse(http.Response response){

    print('stage 1');
    
    //  If this is a validation error
    if(response.statusCode == 422){

      storesProvider.showSnackbarMessage(msg: 'Validation failed', context: context);

    print('stage 2');

      _handleValidationErrors(response);
    
    //  If updated successfully
    }else if(response.statusCode == 200){

      final store = jsonDecode(response.body);

      storesProvider.setStore(Store.fromJson(store));

      storesProvider.showSnackbarMessage(msg: 'Store updated successfully', context: context);

    }

  }

  void _handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];

    print('validationErrors');
    print(validationErrors);

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

  StoresProvider get storesProvider {
    return Provider.of<StoresProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.off(() => ShowStoreScreen());
              }),
            ],
          ),
          Divider(height: 0),

          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[

                          TextFormField(
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
                              }else if(storeServerErrors['name'] != ''){
                                return storeServerErrors['name'];
                              }
                            },
                            onSaved: (value){
                              storeForm['name'] = value;
                            }
                          ),

                          Divider(height: 20),

                          CustomButton(
                            text: 'Save',
                            isLoading: isSubmitting,
                            onSubmit: (isSubmitting) ? null : _updateStore,
                          ),

                          SizedBox(height: 50),
                        ],
                      ),
                    )
                  ],
                ),
              )
            )
          )
        ]
      )
    );
    
  }
}