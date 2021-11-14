import 'dart:convert';

import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/providers/auth.dart';

import './../models/location_totals.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../models/locations.dart';
import './stores.dart';

class LocationsProvider with ChangeNotifier{

  var location;
  var locationTotals;
  bool isLoadingLocation = false;
  StoresProvider storesProvider;
  bool isLoadingLocationTotals = false;

  LocationsProvider({ required this.storesProvider });
  
  Future<http.Response> fetchLocations({ required BuildContext context }){

    return apiProvider.get(url: locationsUrl, context: context);
    
  }
  
  Future<http.Response> fetchLocation({ required BuildContext context }){

    isLoadingLocation = true;

    return apiProvider.get(url: locationUrl, context: context).whenComplete((){
      isLoadingLocation = false;
      notifyListeners();
    });
    
  }
  
  Future<http.Response> fetchLocationTotals({ required BuildContext context }){

    isLoadingLocationTotals = true;

    return apiProvider.get(url: locationTotalsUrl, context: context)
      .then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          //  Get the location totals
          final locationTotals = LocationTotals.fromJson(responseBody);

          //  Set the location as the default location totals
          this.setLocationTotals(locationTotals);

        }

        return response;

      }).whenComplete((){

        isLoadingLocationTotals = false;
        notifyListeners();
        
      });
    
  }
  
  Future<http.Response> fetchLocationOrders({ required BuildContext context }){

    return apiProvider.get(url: locationOrdersUrl, context: context);
    
  }

  String get locationsUrl {
    return storesProvider.store.links.bosLocations.href;
  }

  String get locationUrl {
    return storesProvider.store.links.bosMyStoreLocation.href;
  }

  String get locationTotalsUrl {
    return location.links.bosTotals.href;
  }

  String get locationOrdersUrl {
    return (location as Location).links.bosOrders.href;
  }

  void setLocationTotals(LocationTotals locationTotals){
    this.locationTotals = locationTotals;
  }

  void setLocation(Location location){
    this.location = location;
  }

  LocationTotals get getLocationTotals {
    return locationTotals;
  }

  bool get hasLocationTotals {
    return locationTotals == null ? false : true;
  }

  int get totalLocationProducts {
    return hasLocationTotals ? ((locationTotals as LocationTotals).products.total) : 0;
  }

  Location get getLocation {
    return location;
  }

  String get getLocationCurrencySymbol {
    return (location as Location).currency.symbol;
  }

  bool get hasLocation {
    return location == null ? false : true;
  }

  AuthProvider get authProvider {
    return storesProvider.authProvider;
  }

  ApiProvider get apiProvider {
    return storesProvider.authProvider.apiProvider;
  }

}