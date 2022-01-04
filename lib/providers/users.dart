import 'dart:convert';

import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/invite/invite_users_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/show/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../providers/locations.dart';
import './../providers/stores.dart';
import './../models/locations.dart';
import './../models/users.dart';
import './../providers/auth.dart';
import './../providers/api.dart';
import 'package:get/get.dart';

class UsersProvider with ChangeNotifier{

  var _user;
  LocationsProvider locationsProvider;

  UsersProvider({ required this.locationsProvider });
  
  Future<http.Response> fetchUsers({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = usersUrl+'?page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('userFilters') ?? '{}');

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
              'inactive': 'Inactive'
            };

            return urlFilters[filterKey];

        }).join(',');

      }

    });

    return apiProvider.get(url: url, context: context);
    
  }
  
  Future<http.Response> fetchUser({ required BuildContext context }){

    return apiProvider.get(url: userUrl, context: context);
    
  }
  
  Future<http.Response> updateUser({ required Map body, required BuildContext context }){

    return apiProvider.put(url: userUrl, body: body, context: context);
    
  }
  
  Future<http.Response> deleteUser({ required BuildContext context }){

    return apiProvider.delete(url: userUrl, context: context).then((response){

        if( response.statusCode == 200 ){

          locationsProvider.fetchLocationTotals(context: context);

        }

        return response;

      });
    
  }

  handleDeleteUser({ required User user, required BuildContext context }) async {
    
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

              this.setUser(user);

              return this.deleteUser(
                context: context
              ).then((response){

                if( response.statusCode == 200 ){
                  
                  apiProvider.showSnackbarMessage(msg: 'Account deleted successfully', context: context, type: SnackbarType.info);

                }else{

                  apiProvider.showSnackbarMessage(msg: 'Delete Failed', context: context, type: SnackbarType.error);

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
              content: Row(
                children: [
                  if(isDeleting) Container(height:20, width:20, margin: EdgeInsets.only(right: 10), child: CircularProgressIndicator(strokeWidth: 3,)),
                  if(isDeleting) Text("Deleting account..."),
                  if(!isDeleting) Flexible(child: Text("Are you sure you want to this account?")),
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

  Future navigateToInviteUsers() async {

    this.unsetUser();
    
    return await Get.to(() => InviteUsersScreen());
    
  }

  String get usersUrl {
    return locationsProvider.getLocation.links.bosUsers.href!;
  }

  String get userUrl {
    return (_user as User).links.self.href!;
  }

  String get createUserUrl {
    return apiProvider.apiHome['_links']['bos:users']['href'];
  }

  void setUser(User user){
    this._user = user;
  }

  void unsetUser(){
    this._user = null;
  }

  User get getUser {
    return _user;
  }

  bool get hasUser {
    return _user == null ? false : true;
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