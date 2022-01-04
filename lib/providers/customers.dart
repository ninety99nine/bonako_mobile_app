
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../providers/locations.dart';
import './../providers/stores.dart';
import './../models/locations.dart';
import './../models/customers.dart';
import './../providers/auth.dart';
import './../providers/api.dart';
import 'package:get/get.dart';
import 'dart:convert';

class CustomersProvider with ChangeNotifier{

  var _customer;
  LocationsProvider locationsProvider;

  CustomersProvider({ required this.locationsProvider });
  
  Future<http.Response> fetchCustomers({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = customersUrl+'?page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('customerFilters') ?? '{}');

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
  
  Future<http.Response> fetchCustomer({ required BuildContext context }){

    return apiProvider.get(url: customerUrl, context: context);
    
  }

  String get customersUrl {
    return locationsProvider.getLocation.links.bosCustomers.href!;
  }

  String get customerUrl {
    return (_customer as Customer).links.self.href!;
  }

  void setCustomer(Customer customer){
    this._customer = customer;
  }

  void unsetCustomer(){
    this._customer = null;
  }

  Customer get getCustomer {
    return _customer;
  }

  bool get hasCustomer {
    return _customer == null ? false : true;
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