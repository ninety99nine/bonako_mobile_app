import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../providers/locations.dart';
import './../providers/stores.dart';
import './../providers/auth.dart';
import './../providers/api.dart';
import './../models/orders.dart';

class OrdersProvider with ChangeNotifier{

  var order;
  LocationsProvider locationsProvider;

  OrdersProvider({ required this.locationsProvider });
  
  Future<http.Response> fetchOrders({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = ordersUrl+'?page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('orderFilters') ?? '{}');

      final activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

      //  If we have any active filters
      if( activeFilters.length > 0){

        //  Add filters to Url string
        url = url + '&status=' + activeFilters.keys.map((filterKey) {

            /**
             * filterKey: onSale / notOnSale / outOfStock / limitedStock / unlimitedStock
             */
            final Map<String, String> urlFilters = {
              'onSale': 'On sale',
              'notOnSale': 'Not on sale',
              'outOfStock': 'Out Of Stock',
              'limitedStock': 'Limited stock',
              'unlimitedStock': 'Unlimited stock',
            };

            return urlFilters[filterKey];

        }).join(',');

      }

    });

    return apiProvider.get(url: url, context: context);
    
  }

  Future<http.Response> verifyOrderDeliveryConfirmationCode({ String deliveryConfirmationCode: '', required BuildContext context }) async {

    final data = {
      'delivery_confirmation_code': deliveryConfirmationCode
    };

    return apiProvider.post(url: verifyOrderDeliveryConfirmationCodeUrl, body: data, context: context);
    
  }

  Future<http.Response> acceptOrderAsDelivered({ String? deliveryConfirmationCode, String? verificationCode, String? mobileNumber, required BuildContext context }) async {

    Map data = {};

    if(deliveryConfirmationCode != null){
      data['delivery_confirmation_code'] = deliveryConfirmationCode;
    }

    if(verificationCode != null){
      data['verification_code'] = verificationCode;
    }

    if(mobileNumber != null){
      data['mobile_number'] = mobileNumber;
    }

    return apiProvider.put(url: orderDeliverUrl, body: data, context: context);
    
  }

  String get verifyOrderDeliveryConfirmationCodeUrl {
    return apiProvider.apiHome['_links']['bos:order_verify_delivery_confirmation_code']['href'];
  }

  String get ordersUrl {
    return locationsProvider.getLocation.links.bosOrders.href;
  }

  String get orderDeliverUrl {
    return (order as Order).links.bosDeliver.href;
  }

  void setOrder(Order order){
    this.order = order;
  }

  Order get getOrder {
    return order;
  }

  bool get hasOrder {
    return order == null ? false : true;
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