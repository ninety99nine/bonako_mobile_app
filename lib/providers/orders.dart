import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../providers/locations.dart';
import './../providers/stores.dart';
import './../providers/auth.dart';
import './../providers/api.dart';
import './../models/orders.dart';

class OrdersProvider with ChangeNotifier{

  var order;
  LocationsProvider locationsProvider;

  OrdersProvider({ required this.locationsProvider });
  
  Future<http.Response> fetchOrders({ required BuildContext context }){

    return apiProvider.get(url: ordersUrl, context: context);
    
  }

  String get ordersUrl {
    return locationsProvider.getLocation.links.bosOrders.href;
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