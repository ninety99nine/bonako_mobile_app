import 'dart:convert';
import 'dart:math';

import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/providers/locations.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/list/stores_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './../providers/api.dart';
import './../models/stores.dart';
import './auth.dart';

class StoresProvider with ChangeNotifier{

  var store;
  AuthProvider authProvider;

  StoresProvider({ required this.authProvider });
  
  Future<http.Response> fetchStores({ required BuildContext context }){

    return apiProvider.get(url: storesUrl, context: context);
    
  }
  
  Future<http.Response> fetchCreatedStores({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = createdStoresUrl+'&page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);

    return apiProvider.get(url: url, context: context);
    
  }
  
  Future<http.Response> fetchSharedStores({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = sharedStoresUrl+'&page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);

    return apiProvider.get(url: url, context: context);
    
  }
  
  Future<http.Response> createStore({ required Map body, required BuildContext context }){

    return apiProvider.post(url: createStoreUrl, body: body, context: context);
    
  }
  
  Future<http.Response> fetchStore({ required BuildContext context }){

    return apiProvider.get(url: storeUrl, context: context);
    
  }
  
  Future<http.Response> updateStore({ required Map body, required BuildContext context }){

    return apiProvider.put(url: storeUrl, body: body, context: context)
    .then((response){

      if( response.statusCode == 200 ){
      
        apiProvider.showSnackbarMessage(msg: 'Store updated successfully', context: context, type: SnackbarType.info);

      }else{

        apiProvider.showSnackbarMessage(msg: 'Failed to update store', context: context, type: SnackbarType.error);

      }

      return response;

    })
    .onError((error, stackTrace){
      
      apiProvider.showSnackbarMessage(msg: 'Failed to update store', context: context, type: SnackbarType.error);

      throw(stackTrace);
      
    });
  }
  
  Future<http.Response> deleteStore({ required Store store, required BuildContext context }){
    

    final storeUrl = store.links.self.href;

    authProvider.showLoadingDialog(context: context, loadingMsg: 'Deleting store...');

    return apiProvider.delete(url: storeUrl, context: context)
    .then((response){

      if( response.statusCode == 200 ){
      
        apiProvider.showSnackbarMessage(msg: 'Store deleted successfully', context: context, type: SnackbarType.info);

      }else{

        apiProvider.showSnackbarMessage(msg: 'Failed to delete store', context: context, type: SnackbarType.error);

      }

      return response;

    })
    .onError((error, stackTrace){
      
        apiProvider.showSnackbarMessage(msg: 'Failed to delete store', context: context, type: SnackbarType.error);

      throw(stackTrace);
      
    })
    .whenComplete((){

      //  Remove the alert dialog
      Navigator.of(context).pop();

    });
    
  }

  handleDeleteStore({ required Store store, required BuildContext context }) async {
    
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        
        //  Generate random 6 digit number
        int randomConfirmationCode = (new Random()).nextInt(999999 - 100000);
        final GlobalKey<FormState> _formKey = GlobalKey();
        String userConfirmationCode = '';
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {

            void startLoader(){
              setState((){
                isDeleting = true;
              });
            }

            void stopLoader(){
              setState((){
                isDeleting = false;
              });
            }

            Future<http.Response> onDelete(){
              
              startLoader();

              return deleteStore(store: store, context: context)
                .then((response){

                  if( response.statusCode == 200 ){

                    switchStore(context: context);

                  }

                  return response;

                }).whenComplete((){

                  stopLoader();
                  
                  //  Remove the alert dialog and return True as final value
                  Navigator.of(context).pop(true);

                });

            }

            return AlertDialog(
              title: Text('Confirmation'),
              content: Wrap(
                children: [
                  if(isDeleting) Container(height:20, width:20, margin: EdgeInsets.only(right: 10), child: CircularProgressIndicator(strokeWidth: 3,)),
                  if(isDeleting) Text("Deleting store..."),
                  if(!isDeleting) RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                      children: <TextSpan>[
                        TextSpan(text: 'Are you sure you want to delete ${store.name}? Enter the confirmation code '),
                        TextSpan(
                          text: randomConfirmationCode.toString(), 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        TextSpan(text: ' to delete this store"', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  if(!isDeleting) Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        autofocus: false,
                        initialValue: userConfirmationCode,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Enter confirmation code",
                          hintText: 'E.g 123456',
                          border:OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return 'Please enter the confirmation code to delete';
                          }else if( (userConfirmationCode.trim() != randomConfirmationCode.toString().trim()) ){
                            return 'Confirmation code does not match';
                          }
                        },
                        onChanged: (value){
                          setState(() {
                            userConfirmationCode = value;
                          });
                        }
                      ),
                    ),
                  )
                  
                ],
              ),
              actions: [

                //  Cancel Button
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () { 
                    //  Remove the alert dialog and return False as final value
                    Navigator.of(context).pop(false);
                  }
                ),

                //  Delete Button
                if(!isDeleting) TextButton(
                  child: Text('Delete', style: TextStyle(color: ((userConfirmationCode == randomConfirmationCode.toString())) ? Colors.red : Colors.grey)),
                  onPressed: (){
                    if( _formKey.currentState!.validate() == true ){
                      onDelete();
                    }
                  }
                ),
                
              ],
              
            );
          }
        );
      },
    );

  }
  
  Future<http.Response> generatePaymentShortcode({ required Store store, required BuildContext context }){

    final generatePaymentShortcodeUrl = store.links.bosGeneratePaymentShortcode.href!;

    return apiProvider.post(url: generatePaymentShortcodeUrl, context: context);
    
  }

  void launchVisitShortcode ({ required Store store, required BuildContext context }) async {

    final hasVisitShortCode = store.attributes.hasVisitShortCode;

    if( hasVisitShortCode ){

      final visitShortCode = store.attributes.visitShortCode!;
      
      final dialingCode = visitShortCode.dialingCode;
      
      authProvider.launchShortcode (dialingCode: dialingCode, loadingMsg: 'Preparing store visitation', context: context);

    }

  }

  Future<http.Response> launchPaymentShortcode ({ required Store store, required BuildContext context }) async {

    authProvider.showLoadingDialog(context: context, loadingMsg: 'Creating payment shortcode');

    //  Run API call to generate a payment shortcode
    return await generatePaymentShortcode(store: store, context: context)
      .then((response) {

        //  Hide the current alert dialog
        Navigator.of(context, rootNavigator: true).pop('dialog');
          
        //  If generated successfully
        if(response.statusCode == 200){

          final responseBody = jsonDecode(response.body);
          final String dialingCode = responseBody['dialing_code'];
            
          authProvider.launchShortcode(dialingCode: dialingCode, loadingMsg: 'Preparing store subscription', context: context);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to generate payment shortcode', context: context, type: SnackbarType.error);

        }

        return response;
        
      });

  }

  String get storesUrl {
    return apiProvider.apiHome['_links']['bos:stores']['href'];
  }

  String get createdStoresUrl {
    return authProvider.getAuthUser.links.bosCreatedStores!.href!;
  }

  String get sharedStoresUrl {
    return authProvider.getAuthUser.links.bosSharedStores!.href!;
  }

  String get createStoreUrl {
    return apiProvider.apiHome['_links']['bos:stores']['href'];
  }

  String get storeUrl {
    return (store as Store).links.self.href!;
  }

  void switchStore({ required BuildContext context }){
    this.unsetStore(context: context);
    Get.offAll(() => StoresScreen());
  }

  void setStore(Store store){
    this.store = store;
  }

  void unsetStore({ required context }){

    if( this.store != null ){

      this.store = null;

      //  Get the location provider
      final LocationsProvider? locationProvider = Provider.of<LocationsProvider>(context, listen: false);

      //  If the location provider is available
      if( locationProvider != null ){

        //  Unset the current location
        locationProvider.unsetLocation();

        //  Unset the current location totals
        locationProvider.unsetLocationTotals();

        //  Unset the current location permissions
        locationProvider.unsetLocationPermissions();

      }

    }

  }

  bool get hasStore {
    return store == null ? false : true;
  }

  Store get getStore {
    return store;
  }

  get getStoreVisitShortCode {
    return hasStore ? store.attributes.visitShortCode : null;
  }

  bool get getHasStoreVisitShortCode {
    return hasStore ? store.attributes.hasVisitShortCode : false;
  }

  get getStoreVisitShortCodeDialingCode {
    return getHasStoreVisitShortCode ? store.attributes.visitShortCode.dialingCode : null;
  }

  ApiProvider get apiProvider {
    return authProvider.apiProvider;
  }

}