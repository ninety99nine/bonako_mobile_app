import 'dart:convert';

import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/models/users.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/locationTotals.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../models/locations.dart';
import './stores.dart';

class LocationsProvider with ChangeNotifier{

  var location;
  var locationTotals;
  var temporaryLocation;
  StoresProvider storesProvider;
  bool isLoadingLocation = false;
  bool isLoadingLocationTotals = false;
  List<String> locationPermissions = [];
  bool isLoadingLocationPermissions = false;

  LocationsProvider({ required this.storesProvider });
  
  Future<http.Response> fetchLocations({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = selectedStoreLocationsUrl+'?page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);
    
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
  
  Future<http.Response> fetchLocation({ String? locationUrl, required BuildContext context }){

    var url;
    
    //  If we did not provide location url
    if(locationUrl == null){

      //  Set the selected store location url
      url = selectedStoreLocationUrl;

      //  Start the loader only if we are loading the selected store location
      isLoadingLocation = true;

    }else{

      //  Set the given location url
      url = locationUrl;

    }

    return apiProvider.get(url: url, context: context).whenComplete((){
    
      //  If we did not provide location url
      if(locationUrl == null){

        //  Stop the loader only if we are loading the selected store location
        isLoadingLocation = false;

        //  Notify any listening providers
        notifyListeners();

      }

    });
    
  }
  
  Future<http.Response> createLocation({ required Map body, required BuildContext context }){

    return apiProvider.post(url: createLocationUrl, body: body, context: context)
      .then((response){

        if( response.statusCode == 200 || response.statusCode == 201 ){
        
          apiProvider.showSnackbarMessage(msg: 'Location created successfully', context: context, type: SnackbarType.info);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to create location', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to create location', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }

  Future<http.Response> updateLocation({ String? locationUrl, required Map body, required BuildContext context }){

    var url;
    
    //  If we did not provide location url
    if(locationUrl == null){

      //  Set the selected store location url
      url = selectedStoreLocationUrl;

      //  Start the loader only if we are loading the selected store location
      isLoadingLocation = true;

    }else{

      //  Set the given location url
      url = locationUrl;

    }

    print('url');
    print(url);

    return apiProvider.put(url: url, body: body, context: context)
      .then((response){

        if( response.statusCode == 200 ){
        
          apiProvider.showSnackbarMessage(msg: 'Location updated successfully', context: context, type: SnackbarType.info);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to update location', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to update location', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
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
  
  Future<http.Response> fetchLocationUsers({ required BuildContext context }){

    return apiProvider.get(url: locationUsersUrl, context: context);
    
  }
    
  Future<http.Response> fetchAvailablePermissions({ required BuildContext context }){

    return apiProvider.get(url: locationAvailablePermissionsUrl, context: context);
  
  }

  Future<http.Response> fetchMyLocationPermissions({ required BuildContext context }){

    isLoadingLocationPermissions = true;

    return apiProvider.get(url: myLocationPermissionsUrl, context: context)
      .then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          //  Get the location permissions
          final locationPermissions = new List<String>.from(responseBody['permissions']);

          //  Set the location as the default location totals
          this.setLocationPermissions(locationPermissions);

        }

        return response;

      }).whenComplete((){

        isLoadingLocationPermissions = false;
        notifyListeners();
        
      });
    
  }

  Future<http.Response> fetchUserLocationPermissions({ required int userId, required BuildContext context }){

    final body = {
      'user_id': userId
    };

    return apiProvider.post(url: locationUserPermissionsUrl, body: body, context: context);
    
  }
  
  Future<http.Response> inviteUsers({ required Map body, required BuildContext context }){

    return apiProvider.post(url: locationUsersUrl, body: body, context: context)
      .then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          final bool hasInvitedUsers = responseBody['has_invited_users'];

          if(hasInvitedUsers){
          
            apiProvider.showSnackbarMessage(msg: 'Team invited successfully', context: context, type: SnackbarType.info);

          }else{
          
            apiProvider.showSnackbarMessage(msg: 'No members found to invite', context: context, type: SnackbarType.error);

          }
        
        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to invite team', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }
  
  Future<http.Response> removeUsers({ required List<int> userIds, required BuildContext context }){

    final body = { 
      'user_ids': userIds
    };

    return apiProvider.delete(url: locationUsersUrl, body: body, context: context)
      .then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);
          final successStatus = responseBody['success_status'];

          if( response.statusCode == 200 ){

            if( successStatus ){

              apiProvider.showSnackbarMessage(msg: 'Removed '+( userIds.length == 1 ? 'member': userIds.length.toString() + ' members')+' successfully', context: context);

            }else{

              apiProvider.showSnackbarMessage(msg: 'Couldn\'t remove '+( userIds.length == 1 ? 'member': 'members'), context: context, type: SnackbarType.error);

            }

          }else{

            apiProvider.showSnackbarMessage(msg: 'Couldn\'t remove '+( userIds.length == 1 ? 'member': 'members'), context: context, type: SnackbarType.error);

          }
        
        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to remove team members', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }
  
  Future<http.Response> updateUserPermissions({ required int userId, required List<String> permissions, required BuildContext context }){

    final body = {
      'user_id': userId,
      'permissions': permissions,
    };

    return apiProvider.post(url: updateLocationUserPermissionsUrl, body: body, context: context)
      .then((response){

        if( response.statusCode == 201 ){
        
          apiProvider.showSnackbarMessage(msg: 'Permissions updated successfully', context: context, type: SnackbarType.info);

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to update permissions', context: context, type: SnackbarType.error);

        }

        return response;

      })
      .onError((error, stackTrace){
        
        apiProvider.showSnackbarMessage(msg: 'Failed to update permissions', context: context, type: SnackbarType.error);

        throw(stackTrace);
        
      });
    
  }



  handleRemoveUsers({ required List<User> users, required BuildContext context }) async {
    
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

            Future<http.Response> onRemove(){
              
              startLoader();

              final userIds = new List<int>.from(users.map((user) => user.id));

              return this.removeUsers(
                userIds: userIds,
                context: context
              ).then((response){

                final responseBody = jsonDecode(response.body);
                final successStatus = responseBody['success_status'];

                Navigator.of(context).pop(successStatus);

                return response;

              }).whenComplete((){

                stopLoader();

              });

            }

            return AlertDialog(
              title: Text('Confirmation'),
              content: Row(
                children: [
                  if(isDeleting) Container(height:20, width:20, margin: EdgeInsets.only(right: 10), child: CircularProgressIndicator(strokeWidth: 3,)),
                  if(isDeleting) Text('Removing '+( users.length == 1 ? 'user': 'users')+'...'),
                  if(!isDeleting) Flexible(
                    child: users.length == 1
                      ? Text("Are you sure you want to remove ${users[0].attributes.name}?")
                      : Text("Are you sure you want to remove these ${users.length} members?")
                  ),
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

                //  Remove Button
                if(!isDeleting) TextButton(
                  child: Text('Remove', style: TextStyle(color: Colors.red)),
                  onPressed: (){
                    onRemove();
                  }
                ),
              ],
              
            );
          }
        );
      },
    );

  }

  String get selectedStoreLocationsUrl {
    return storesProvider.store.links.bosLocations.href;
  }

  String get selectedStoreLocationUrl {
    return storesProvider.store.links.bosMyStoreLocation.href;
  }

  String get locationTotalsUrl {
    return location.links.bosTotals.href;
  }

  String get myLocationPermissionsUrl {
    return location.links.bosMyPermissions.href;
  }

  String get locationUserPermissionsUrl {
    return location.links.bosUserPermissions.href;
  }

  String get locationAvailablePermissionsUrl {
    return location.links.bosAvailablePermissions.href;
  }

  String get updateLocationUserPermissionsUrl {
    return location.links.bosUpdateUserPermissions.href;
  }

  String get createLocationUrl {
    return apiProvider.apiHome['_links']['bos:locations']['href'];
  }

  String get locationOrdersUrl {
    return (location as Location).links.bosOrders.href!;
  }

  String get locationUsersUrl {
    return (location as Location).links.bosUsers.href!;
  }

  void setLocation(Location location){
    this.location = location;
  }

  void unsetLocation(){
    this.location = null;
  }

  void setTemporaryLocation(Location temporaryLocation){
    this.temporaryLocation = temporaryLocation;
  }

  void unsetTemporaryLocation(){
    this.temporaryLocation = null;
  }

  void setLocationTotals(LocationTotals locationTotals){
    this.locationTotals = locationTotals;
  }

  void unsetLocationTotals(){
    this.locationTotals = null;
  }

  void setLocationPermissions(List<String> locationPermissions){
    this.locationPermissions = locationPermissions;
  }

  void unsetLocationPermissions(){
    this.locationPermissions = [];
  }

  LocationTotals get getLocationTotals {
    return locationTotals;
  }

  List<String> get getLocationPermissions {
    return locationPermissions;
  }

  bool get hasLocationTotals {
    return locationTotals == null ? false : true;
  }

  int get totalLocationProducts {
    return hasLocationTotals ? ((locationTotals as LocationTotals).productTotals.total) : 0;
  }

  Location get getLocation {
    return location;
  }

  Location get getTemporaryLocation {
    return temporaryLocation;
  }

  String get getLocationCurrencySymbol {
    return (location as Location).currency.symbol;
  }

  String get getTemporaryLocationCurrencySymbol {
    return (temporaryLocation as Location).currency.symbol;
  }

  bool get hasLocation {
    return location == null ? false : true;
  }

  bool get hasTemporaryLocation {
    return temporaryLocation == null ? false : true;
  }

  AuthProvider get authProvider {
    return storesProvider.authProvider;
  }

  ApiProvider get apiProvider {
    return storesProvider.authProvider.apiProvider;
  }

}