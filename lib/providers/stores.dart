import 'dart:convert';
import 'dart:math';

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
  
  Future<http.Response> fetchCreatedStores({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = createdStoresUrl+'&page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);

    print('url');
    print(url);

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

    return apiProvider.put(url: storeUrl, body: body, context: context);
    
  }
  
  Future<http.Response> deleteStore({ required Store store, required BuildContext context }){
    

    final storeUrl = store.links.self.href;

    authProvider.showLoadingDialog(context: context, loadingMsg: 'Deleting store...');

    return apiProvider.delete(url: storeUrl, context: context)
    .then((response){

      if( response.statusCode == 200 ){
      
        showSnackbarMessage(context: context, msg: 'Store deleted successfully');

      }

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

              return this.deleteStore(store: store, context: context)
                .then((response){

                  if( response.statusCode == 200 ){

                    showSnackbarMessage( msg: 'Store deleted successfully', context: context,);

                  }else{

                    showSnackbarMessage(msg: 'Delete Failed', context: context,);

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

    final generatePaymentShortcodeUrl = store.links.bosGeneratePaymentShortcode.href;

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

  void launchPaymentShortcode ({ required Store store, required BuildContext context }) async {

    //  Run API call to generate a payment shortcode
    await generatePaymentShortcode(store: store, context: context)
      .then((response) async {
          
        //  If generated successfully
        if(response.statusCode == 200){

          final responseBody = jsonDecode(response.body);
          final String dialingCode = responseBody['dialing_code'];
            
          authProvider.launchShortcode (dialingCode: dialingCode, loadingMsg: 'Preparing store subscription', context: context);

        }else{

          showSnackbarMessage(context: context, msg: 'Failed to generate payment shortcode');

        }

        return response;
        
      }).whenComplete((){

        //  Remove the loading dialog
        Navigator.of(context).pop();

      });

  }

  void showSnackbarMessage({ required BuildContext context, required String msg }){

    //  Set snackbar content
    final snackBar = SnackBar(content: Text(msg, textAlign: TextAlign.center));

    //  Hide existing snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

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

  String get storeUrl {
    return (store as Store).links.self.href;
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