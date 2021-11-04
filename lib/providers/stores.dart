import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
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
  
  Future<http.Response> fetchCreatedStores({ required BuildContext context }){

    return apiProvider.get(url: createdStoresUrl, context: context);
    
  }
  
  Future<http.Response> fetchSharedStores({ required BuildContext context }){

    return apiProvider.get(url: sharedStoresUrl, context: context);
    
  }
  
  Future<http.Response> createStore({ required Map body, required BuildContext context }){

    return apiProvider.post(url: createStoreUrl, body: body, context: context);
    
  }
  
  Future<http.Response> deleteStore({ required Store store, required BuildContext context }){
    

    final storeUrl = store.links.self.href;

    showLoadingDialog(context: context, loadingMsg: 'Deleting store...');

    return apiProvider.delete(url: storeUrl, context: context)
    .then((response){
      
      showSnackbarMessage(context: context, msg: 'Store deleted successfully');

      return response;

    })
    .onError((error, stackTrace){
      
      showSnackbarMessage(context: context, msg: 'Failed to delete store');

      throw(stackTrace);
      
    })
    .whenComplete((){

      //  Remove the alert dialog
      Navigator.of(context).pop();

    });
    
  }
  
  Future<http.Response> generatePaymentShortcode({ required Store store, required BuildContext context }){

    final generatePaymentShortcodeUrl = store.links.bosGeneratePaymentShortcode.href;

    return apiProvider.post(url: generatePaymentShortcodeUrl, context: context);
    
  }

  void launchVisitShortcode ({ required Store store, required BuildContext context }) async {

    showLoadingDialog(context: context, loadingMsg: 'Preparing store visitation');

    final hasVisitShortCode = store.attributes.hasVisitShortCode;

    if( hasVisitShortCode ){

      final visitShortCode = store.attributes.visitShortCode!;
      
      final dialingCode = visitShortCode.dialingCode;

      final ussdString = "tel:" + Uri.encodeComponent(dialingCode);

      if(await canLaunch(ussdString)){

        await launch(ussdString);

        Navigator.of(context).pop();

      }

    }

  }

  void launchPaymentShortcode ({ required Store store, required BuildContext context }) async {

    showLoadingDialog(context: context, loadingMsg: 'Preparing store subscription');

    //  Run API call to generate a payment shortcode
    await generatePaymentShortcode(store: store, context: context)
      .then((response) async {
          
        //  If generated successfully
        if(response.statusCode == 200){

          final responseBody = jsonDecode(response.body);
          final String dialingCode = responseBody['dialing_code'];

          final ussdString = "tel:" + Uri.encodeComponent(dialingCode);

          if(await canLaunch(ussdString)){

            await launch(ussdString);

          }

        }else{

          showSnackbarMessage(context: context, msg: 'Failed to generate payment shortcode');

        }
        
      }).whenComplete((){

        //  Remove the loading dialog
        Navigator.of(context).pop();

      });

  }

  void showLoadingDialog({ required BuildContext context, String loadingMsg = 'loading...' }){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              Container(height:20, width:20, margin: EdgeInsets.only(right: 10), child: CircularProgressIndicator(strokeWidth: 3,)),
              Text(loadingMsg),
            ],
          )
        );
      }
    );
  }

  void showSnackbarMessage({ required BuildContext context, required String msg }){

    //  Set snackbar content
    final snackBar = SnackBar(content: Text(msg, textAlign: TextAlign.center));

    //  Show snackbar  
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }

  String get storesUrl {
    return apiProvider.apiHome['_links']['bos:stores']['href'];
  }

  String get createdStoresUrl {
    return authProvider.getAuthUser.links.bosCreatedStores.href;
  }

  String get sharedStoresUrl {
    return authProvider.getAuthUser.links.bosSharedStores.href;
  }

  String get createStoreUrl {
    return apiProvider.apiHome['_links']['bos:stores']['href'];
  }

  void setStore(Store store){
    this.store = store;
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