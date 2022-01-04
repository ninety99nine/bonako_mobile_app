import 'package:bonako_mobile_app/enum/enum.dart';

import './../screens/dashboard/instant_carts/create/create.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/instantCarts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../providers/locations.dart';
import './../providers/stores.dart';
import './../providers/auth.dart';
import './../providers/api.dart';
import 'package:get/get.dart';
import 'dart:convert';

class InstantCartsProvider with ChangeNotifier{

  var _instantCart;
  LocationsProvider locationsProvider;

  InstantCartsProvider({ required this.locationsProvider });
  
  Future<http.Response> fetchInstantCarts({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = instantCartsUrl+'?page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('instantCartFilters') ?? '{}');

      final activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

      //  If we have any active filters
      if( activeFilters.length > 0){

        //  Add filters to Url string
        url = url + '&status=' + activeFilters.keys.map((filterKey) {

            /**
             * filterKey: Active / Inactive
             */
            final Map<String, String> urlFilters = {
              'active': 'Active',
              'inactive': 'Inactive',
            };

            return urlFilters[filterKey];

        }).join(',');

      }

    });

    return apiProvider.get(url: url, context: context);
    
  }
  
  Future<http.Response> fetchInstantCart({ required BuildContext context }){

    return apiProvider.get(url: instantCartUrl, context: context);
    
  }
  
  Future<http.Response> createInstantCart({ required Map body, required BuildContext context }){

    return apiProvider.post(url: createinstantCartUrl, body: body, context: context)
      .then((response){

        if( response.statusCode == 200 || response.statusCode == 201 ){
        
          apiProvider.showSnackbarMessage(msg: 'Instant cart created successfully', context: context, type: SnackbarType.info);

          locationsProvider.fetchLocationTotals(context: context);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to create instant cart', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to create instant cart', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }
  
  Future<http.Response> updateInstantCart({ required Map body, required BuildContext context }){

    return apiProvider.put(url: instantCartUrl, body: body, context: context)
      .then((response){

        if( response.statusCode == 200 ){
        
          apiProvider.showSnackbarMessage(msg: 'Instant cart updated successfully', context: context, type: SnackbarType.info);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to update instant cart', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to update instant cart', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }
  
  Future<http.Response> deleteInstantCart({ required BuildContext context }){

    return apiProvider.delete(url: instantCartUrl, context: context)
      .then((response){

        if( response.statusCode == 200 ){
        
          apiProvider.showSnackbarMessage(msg: 'Instant cart deleted successfully', context: context, type: SnackbarType.info);

          locationsProvider.fetchLocationTotals(context: context);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to delete instant cart', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to delete instant cart', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }

  handleDeleteInstantCart({ required InstantCart instantCart, required BuildContext context }) async {
    
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        
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

              this.setInstantCart(instantCart);

              return this.deleteInstantCart(
                context: context
              ).then((response){

                return response;

              }).whenComplete((){

                stopLoader();
                
                //  Remove the alert dialog and return True as final value
                Navigator.of(context).pop(true);

              });

            }

            return AlertDialog(
              title: Text('Confirmation'),
              content: Row(
                children: [
                  if(isDeleting) Container(height:20, width:20, margin: EdgeInsets.only(right: 10), child: CircularProgressIndicator(strokeWidth: 3,)),
                  if(isDeleting) Text("Deleting instant cart..."),
                  if(!isDeleting) Flexible(child: Text("Are you sure you want to delete ${instantCart.name}?")),
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
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: (){
                    onDelete();
                  }
                ),
              ],
              
            );
          }
        );
      },
    );

  }

  Future navigateToAddInstantCart() async {

    this.unsetInstantCart();
    
    return await Get.to(() => CreateInstantCartScreen());
    
  }

  String get instantCartsUrl {
    return locationsProvider.getLocation.links.bosInstantCarts.href!;
  }

  String get instantCartUrl {
    return (_instantCart as InstantCart).links.self.href!;
  }

  String get createinstantCartUrl {
    return apiProvider.apiHome['_links']['bos:instant_carts']['href'];
  }

  void setInstantCart(InstantCart instantCart){
    this._instantCart = instantCart;
  }

  void unsetInstantCart(){
    this._instantCart = null;
  }

  InstantCart get getInstantCart {
    return _instantCart;
  }

  bool get hasInstantCart {
    return _instantCart == null ? false : true;
  }
  
  Future<http.Response> generatePaymentShortcode({ required InstantCart instantCart, required BuildContext context }){

    final generatePaymentShortcodeUrl = instantCart.links.bosGeneratePaymentShortcode.href!;

    return apiProvider.post(url: generatePaymentShortcodeUrl, context: context);
    
  }

  void launchVisitShortcode ({ required InstantCart instantCart, required BuildContext context }) async {

    final hasVisitShortCode = instantCart.attributes.hasVisitShortCode;

    if( hasVisitShortCode ){

      final visitShortCode = instantCart.attributes.visitShortCode!;
      
      final dialingCode = visitShortCode.dialingCode;
      
      authProvider.launchShortcode (dialingCode: dialingCode, loadingMsg: 'Preparing visitation', context: context);

    }

  }

  Future<http.Response> launchPaymentShortcode ({ required InstantCart instantCart, required BuildContext context }) async {

    authProvider.showLoadingDialog(context: context, loadingMsg: 'Creating payment shortcode');

    //  Run API call to generate a payment shortcode
    return await generatePaymentShortcode(instantCart: instantCart, context: context)
      .then((response) async {

        print('Hide: Creating payment shortcode');

        //  Hide the current alert dialog
        Navigator.of(context, rootNavigator: true).pop('dialog');
          
        //  If generated successfully
        if(response.statusCode == 200){

          final responseBody = jsonDecode(response.body);
          final String dialingCode = responseBody['dialing_code'];
            
          authProvider.launchShortcode(dialingCode: dialingCode, loadingMsg: 'Preparing subscription', context: context);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to generate payment shortcode', context: context, type: SnackbarType.error);

        }

        return response;
        
      });

  }

  StoresProvider get storesProvider {
    return locationsProvider.storesProvider;
  }

  AuthProvider get authProvider {
    return storesProvider.authProvider;
  }

  ApiProvider get apiProvider {
    return authProvider.apiProvider;
  }

}