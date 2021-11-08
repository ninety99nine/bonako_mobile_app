import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../components/custom_loader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../models/users.dart';
import 'dart:convert';
import './api.dart';

class AuthProvider with ChangeNotifier{

  Map<String, dynamic> _user = {};
  String _token = '';
  String _refreshToken = '';
  String _tokenExpiryDate = '';
  bool _isAuthenticated = false;
  bool _hasViewedIntro = false;
  
  ApiProvider apiProvider;

  AuthProvider({ required this.apiProvider });
  
  Future<http.Response> checkIfMobileAccountExists({ required String mobileNumber, required BuildContext context}){
    
    final accountData = {
      'mobile_number': mobileNumber
    };

    return apiProvider.post(url: apiProvider.getAccountExistsUrl, body: accountData, context: context);
    
  }
  
  Future<http.Response> checkIfEmailAccountExists({ required String email, required BuildContext context}){
    
    final accountData = {
      'email': email
    };

    return apiProvider.post(url: apiProvider.getAccountExistsUrl, body: accountData, context: context);
    
  }

  Future<http.Response> loginWithMobile({ required String mobileNumber, required String password, required BuildContext context}){
    
    final loginData = {
      'mobile_number': mobileNumber,
      'password': password,
    };

    return login(loginData: loginData, context: context);
    
  }

  Future<http.Response> loginWithEmail({ required String email, required String password, required BuildContext context}){
    
    final loginData = {
      'email': email,
      'password': password,
    };

    return login(loginData: loginData, context: context);
    
  }

  Future<http.Response> login({ required Map loginData, required BuildContext context}){

    return apiProvider.post(url: apiProvider.getLoginUrl, body: loginData, context: context)
      .then((response) async {

        //  if we authenticated successfully
        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);
        
          final user = responseBody['user'] ?? '';
        
          final token = responseBody['access_token']['accessToken'] ?? '';

          //  Store the bearer token locally and to the device
          await apiProvider.storeBearerTokenLocallyAndOnDevice(token);

          //  Store the user locally and to the device
          await storeUserLocallyAndOnDevice(user);

          //  Set the _isAuthenticated status
          setAuthenticatedStatus(true);

          notifyListeners();

        }

        return response;

      });
    
  }

  void setAuthenticatedStatus(bool status){

    _isAuthenticated = status;

  }

  Future logout({ required BuildContext context }){

    print('logout()');

    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomLoader(topMargin: 0, text: 'Logging out')
          ],
        )
      )
    );
    
    return logoutServerSide(context: context).then((response) async {

      if( response.statusCode == 200 ){
      
        await logoutClientSide();
        
        Navigator.of(Get.overlayContext!).pop();

      }
      
      return response;

    });
  }

  Future logoutServerSide({ required BuildContext context }){

    print('logoutServerSide()');
    return apiProvider.post(url: apiProvider.getLogoutUrl, context: context);
  }

  Future logoutClientSide() {

    print('logoutClientSide()');

    //  Store an empty bearer token on the device
    return apiProvider.storeBearerTokenLocallyAndOnDevice('').whenComplete((){

      //  Set the user as unauthenticated
      setAuthenticatedStatus(false);

      notifyListeners();

    });
    
  }

  Future storeUserLocallyAndOnDevice(Map<String, dynamic> user) async {

    //  Store user locally
    _user = user;
    
    return await SharedPreferences.getInstance().then((prefs){

      //  Store user to the device
      prefs.setString('user', jsonEncode(user));

    });

  }

  Future setUserFromDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      if( prefs.getString('user') != null ){

        //  Set the user stored on the device
        _user = jsonDecode( prefs.getString('user') ?? '{}' );    //  jsonDecode( prefs.getString('user') ?? '{}' );

      }

    });

  }
  
  void storeHasViewedIntroOnDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      _hasViewedIntro = true;
      
      prefs.setString('hasViewedIntro', 'true');

    }).whenComplete((){

      notifyListeners();

    });
  }
  
  void storeHasNotViewedIntroOnDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      _hasViewedIntro = false;
      
      prefs.setString('hasViewedIntro', 'false');

    }).whenComplete((){

      notifyListeners();

    });
  }

  Future setHasViewedIntroFromDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      _hasViewedIntro = prefs.getString('hasViewedIntro') == 'true';

    });

  }

  bool get hasViewedIntro {
    return _hasViewedIntro;
  }
  
  User get getAuthUser {
    return User.fromJson(_user);
    
  }
  
  bool get hasAuthUser {
    return _user.isNotEmpty;
  }

  bool get isAuthenticated {
    return _isAuthenticated;
  }

}