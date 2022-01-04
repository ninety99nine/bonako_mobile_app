import 'dart:convert';

import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../screens/dashboard/coupons/create/create.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../providers/locations.dart';
import './../providers/stores.dart';
import './../models/locations.dart';
import './../models/coupons.dart';
import './../providers/auth.dart';
import './../providers/api.dart';
import 'package:get/get.dart';

class CouponsProvider with ChangeNotifier{

  var _coupon;
  LocationsProvider locationsProvider;

  CouponsProvider({ required this.locationsProvider });
  
  Future<http.Response> fetchCoupons({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = couponsUrl+'?page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('couponFilters') ?? '{}');

      final activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

      //  If we have any active filters
      if( activeFilters.length > 0){

        //  Add filters to Url string
        url = url + '&status=' + activeFilters.keys.map((filterKey) {

            /**
             * filterKey: Active / Inactive / outOfStock / Free delivery
             */
            final Map<String, String> urlFilters = {
              'active': 'Active',
              'inactive': 'Inactive',
              'free delivery': 'Free delivery'
            };

            return urlFilters[filterKey];

        }).join(',');

      }

    });

    return apiProvider.get(url: url, context: context);
    
  }
  
  Future<http.Response> fetchCoupon({ required BuildContext context }){

    return apiProvider.get(url: couponUrl, context: context);
    
  }
  
  Future<http.Response> createCoupon({ required Map body, required BuildContext context }){

    final data = toJsonBodyFormat(body);

    return apiProvider.post(url: createCouponUrl, body: data, context: context)
      .then((response){

        if( response.statusCode == 200 || response.statusCode == 201 ){
        
          apiProvider.showSnackbarMessage(msg: 'Coupon created successfully', context: context, type: SnackbarType.info);

          locationsProvider.fetchLocationTotals(context: context);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to create coupon', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to create coupon', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }
  
  Future<http.Response> updateCoupon({ required Map body, required BuildContext context }){

    final data = toJsonBodyFormat(body);

    return apiProvider.put(url: couponUrl, body: data, context: context)
      .then((response){

        if( response.statusCode == 200 ){
        
          apiProvider.showSnackbarMessage(msg: 'Coupon updated successfully', context: context, type: SnackbarType.info);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to update coupon', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to update coupon', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }

  Map toJsonBodyFormat(Map data){

    final editableData = new Map.from(data);

    final keysRelatedToDates = [
      'discount_on_start_datetime', 'discount_on_end_datetime'
    ];

    //  Convert any DateTime to string
    for (var i = 0; i < keysRelatedToDates.length; i++) {
      if(editableData.containsKey(keysRelatedToDates[i])){
        if(editableData[keysRelatedToDates[i]] != null){
          editableData[keysRelatedToDates[i]] = (editableData[keysRelatedToDates[i]] as DateTime).toIso8601String();
        }
      }
    }

    return editableData;
  }
  
  Future<http.Response> deleteCoupon({ required BuildContext context }){

    return apiProvider.delete(url: couponUrl, context: context)
      .then((response){

        if( response.statusCode == 200 ){
        
          apiProvider.showSnackbarMessage(msg: 'Coupon deleted successfully', context: context, type: SnackbarType.info);

          locationsProvider.fetchLocationTotals(context: context);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to delete coupon', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to delete coupon', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }

  handleDeleteCoupon({ required Coupon coupon, required BuildContext context }) async {
    
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

              this.setCoupon(coupon);

              return this.deleteCoupon(
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
                  if(isDeleting) Text("Deleting coupon..."),
                  if(!isDeleting) Flexible(child: Text("Are you sure you want to delete ${coupon.name}?")),
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

  Future navigateToAddCoupon() async {

    this.unsetCoupon();
    
    return await Get.to(() => CreateCouponScreen());
    
  }

  String get couponsUrl {
    return locationsProvider.getLocation.links.bosCoupons.href!;
  }

  String get couponUrl {
    return (_coupon as Coupon).links.self.href!;
  }

  String get createCouponUrl {
    return apiProvider.apiHome['_links']['bos:coupons']['href'];
  }

  void setCoupon(Coupon coupon){
    this._coupon = coupon;
  }

  void unsetCoupon(){
    this._coupon = null;
  }

  Coupon get getCoupon {
    return _coupon;
  }

  bool get hasCoupon {
    return _coupon == null ? false : true;
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