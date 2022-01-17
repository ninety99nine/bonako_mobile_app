import 'dart:convert';

import 'package:bonako_mobile_app/enum/enum.dart';
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
  
  Future<http.Response> fetchOrders({ String? alternativeUrl, String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = (alternativeUrl == null ? ordersUrl : alternativeUrl)+'?page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);
    
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

  
  Future<http.Response> fetchOrder({ required BuildContext context }){

    return apiProvider.get(url: orderUrl, context: context);
    
  }

  Future<http.Response> verifyOrderDeliveryConfirmationCode({ String deliveryConfirmationCode: '', required BuildContext context }) async {

    final data = {
      'delivery_confirmation_code': deliveryConfirmationCode,
      'location_id': locationsProvider.getLocation.id
    };

    return apiProvider.post(url: verifyOrderDeliveryConfirmationCodeUrl, body: data, context: context)
      .then((response){

          if( response.statusCode == 200){
    
            final responseBody = jsonDecode(response.body);
            final bool isValid = responseBody['is_valid'];
            final Map<String, dynamic> jsonOrder = responseBody['order'] ?? {};

            if( isValid && jsonOrder.isNotEmpty ){

              apiProvider.showSnackbarMessage(msg: 'Valid delivery code', context: context);

            }else{

              apiProvider.showSnackbarMessage(msg: 'Invalid delivery code', context: context, type: SnackbarType.error);

            }

          }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to verify delivery code', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
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

    data['location_id'] = locationsProvider.getLocation.id;

    return apiProvider.put(url: orderDeliverUrl, body: data, context: context);
    
  }

  Future<http.Response> requestPayment({ int? transactionId, String? payerMobileNumber, double percentageRate = 0, bool sendCustomerSms = false, required BuildContext context }) async {

    Map data = {
      'percentage_rate': percentageRate,
      'send_customer_sms': sendCustomerSms,
    };

    if( payerMobileNumber != null ){
      data['payer_mobile_number'] = payerMobileNumber;
    }

    if( transactionId != null ){
      data['transaction_id'] = transactionId;
    }

    return apiProvider.post(url: orderPaymentRequestUrl, body: data, context: context)
      .then((response){

        if( response.statusCode == 200 ){
        
          apiProvider.showSnackbarMessage(msg: 'Payment requested successfully', context: context, type: SnackbarType.info);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to request payment', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to request payment', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }

  String get verifyOrderDeliveryConfirmationCodeUrl {
    return apiProvider.apiHome['_links']['bos:order_verify_delivery_confirmation_code']['href'];
  }

  String get ordersUrl {
    return locationsProvider.getLocation.links.bosOrders.href!;
  }

  String get orderUrl {
    return (order as Order).links.self.href!;
  }

  String get orderDeliverUrl {
    return (order as Order).links.bosDeliver.href!;
  }

  String get orderPaymentRequestUrl {
    return (order as Order).links.bosPaymentRequest.href!;
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