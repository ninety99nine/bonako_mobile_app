import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ApiProvider with ChangeNotifier{

  final String homeUrl = 'http://165.232.179.255/api';

  String _loginUrl = '';
  String _logoutUrl = '';
  String _accountExistsUrl = '';
  Map<String, dynamic> _apiHome = {};

  String _bearerToken = '';

  Future<http.Response> setApiEndpoints({ required BuildContext context }) async {
    
    /**
     *  Get the bearer token stored on the device. This usually takes some time, which is
     *  why this method returns a Future / Promise, so that we can wait for the process
     *  to resolve before we can continue. As soon as we have set the stored bearer
     *  token, we can use it to make a get request to the API Home endpoint.
     * 
     */
    return await setStoredBearerToken().then((_) async {

      /** Make an API Call to the API Home endpoint. This endpoint will provide us with the essential 
       *  routes to execute Login, Registation and Logout calls. Since we also set the bearer token 
       *  using the setStoredBearerToken() method, we can also derive if the user is still logged 
       *  in since this is provided by the payload: response->body->_embedded->authenticated.
       */

      return await get(url: homeUrl, context: context)
        .then((response){

          final responseBody = jsonDecode(response.body);
        
          //  Update the login url
          _apiHome = responseBody;
        
          //  Update the login url
          _loginUrl = responseBody['_links']['bos:login']['href'];

          //  Update the logout url
          _logoutUrl = responseBody['_links']['bos:logout']['href'];

          //  Update the account exists url
          _accountExistsUrl = responseBody['_links']['bos:account_exists']['href'];

          return response;

        });

    });

  }

  Future<http.Response> get({ required String url, required BuildContext context }){

    return http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_bearerToken'
      }
    ).then((response){

      return response;
      
    }).catchError((error){

        handleApiFail(error, context);

        throw(error);
      
    });
  }

  Future<http.Response> post({ required String url, body: const {}, required BuildContext context }) {

    return http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((response){

      return response;
      
    }).catchError((error){

        handleApiFail(error, context);

        throw(error);
      
    });
    
  }

  Future<http.Response> put({ url, body: const {}, required BuildContext context }) {

    return http.put(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((response){

      return response;
      
    }).catchError((error){

        handleApiFail(error, context);

        throw(error);
      
    });
  }

  Future<http.Response> patch({ url, body: const {}, required BuildContext context }) {
    return http.patch(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((response){

      return response;
      
    }).catchError((error){

        handleApiFail(error, context);

        throw(error);
      
    });
  }

  Future<http.Response> delete({ url, body: const {}, required BuildContext context }) {
    return http.delete(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((response){

      return response;
      
    }).catchError((error){

        handleApiFail(error, context);

        throw(error);
      
    });
  }

  void handleApiSuccess(http.Response response){

  }

  void handleApiFail(Object error, BuildContext context){

    showDialog(context: context, builder: (ctx){
        return AlertDialog(
          title: Text('Try Again'),
          content: Text(error.toString()),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: Text('Ok')
            )
          ],
        );
      });
  }

  String get getLoginUrl {
    return _loginUrl;
  }

  String get getLogoutUrl {
    return _logoutUrl;
  }
  
  String get getAccountExistsUrl {
    return _accountExistsUrl;
  }

  Map<String, dynamic> get apiHome {
    return _apiHome;
  }

  Future storeBearerTokenLocallyAndOnDevice(String token) async {
    
    //  Store bearer token locally
    _bearerToken = token;
    
    return await SharedPreferences.getInstance().then((prefs){

      //  Store bearer token to the device
      prefs.setString('bearerToken', token);

    });

  }

  Future setStoredBearerToken() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      //  Set the bearer token stored on the device
      _bearerToken = prefs.getString('bearerToken') ?? '';

    });

  }

  void unsetStoredBearerToken(){
    _bearerToken = '';
  }

  bool get hasBearerToken{
    return _bearerToken.isNotEmpty;
  }
  
}