import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ApiProvider with ChangeNotifier{

  final String homeUrl = 'http://127.0.0.1:9000/api'; //  'http://165.232.179.255/api';

  String _loginUrl = '';
  String _logoutUrl = '';
  String _registerUrl = '';
  String _bearerToken = '';
  String _mainShortcode = '';
  String _accountExistsUrl = '';
  String _registerValidationUrl = '';
  Map<String, dynamic> _apiHome = {};
  String _verifyUserAccountShortcode = '';
  String _verifyMobileVerificationCodeUrl = '';
  String _generateMobileVerificationCodeUrl = '';

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
          
          if( response.statusCode == 200 ){
              
            final responseBody = jsonDecode(response.body);
          
            //  Update the login url
            _apiHome = responseBody;
          
            //  Update the login url
            _loginUrl = responseBody['_links']['bos:login']['href'];
          
            //  Update the register url
            _registerUrl = responseBody['_links']['bos:register']['href'];

            //  Update the register validation url
            _registerValidationUrl = responseBody['_links']['bos:register_validation']['href'];

            //  Update the generate mobile verification code url
            _generateMobileVerificationCodeUrl = responseBody['_links']['bos:generate_mobile_verification_code']['href'];

            //  Update the verify mobile verification code url
            _verifyMobileVerificationCodeUrl = responseBody['_links']['bos:verify_mobile_verification_code']['href'];

            //  Update the logout url
            _logoutUrl = responseBody['_links']['bos:logout']['href'];

            //  Update the account exists url
            _accountExistsUrl = responseBody['_links']['bos:account_exists']['href'];

            //  Update Main USSD shortcode
            _mainShortcode = responseBody['_embedded']['main_shortcode'];

            //  Update shortcode to verify user account after registration
            _verifyUserAccountShortcode = responseBody['_embedded']['verify_user_account_shortcode'];


          }

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

      handleApiResponseFail(response: response, context: context);

      print(response.statusCode);

      return response;
      
    }).catchError((error){

        handleApiFail(error, context);

        throw(error);
      
    });
  }

  Future<http.Response> post({ required String url, body: const {}, required BuildContext context }) {
    print('post url');
    print(url);
    return http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {
        'Authorization': 'Bearer $_bearerToken',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).then((response){

      handleApiResponseFail(response: response, context: context);

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

      handleApiResponseFail(response: response, context: context);

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

      handleApiResponseFail(response: response, context: context);

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

      handleApiResponseFail(response: response, context: context);

      return response;
      
    }).catchError((error){

        handleApiFail(error, context);

        throw(error);
      
    });
  }

  void handleApiResponseFail({ required http.Response response, required BuildContext context}){

    //  Client or Server error
    if(response.statusCode >= 400){

      final responseBody = jsonDecode(response.body);

      var showingDevContent = false;

      //  If this is a validation error
      if( response.statusCode == 422 ){
        showingDevContent = true;
      }

      showAlertDialog(
        context: context,
        title: responseBody['error'],
        devContent: responseBody['message'],
        showingDevContent: showingDevContent,
        content: 'Sorry, something went wrong on our side',
      );

    }

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

  void showAlertDialog({ required String title, required String content, required String devContent, bool showingDevContent = false, required BuildContext context }){

    showDialog(context: context, builder: (ctx){

        return StatefulBuilder(
          builder: (context, setState) {

            return AlertDialog(
              title: Text(title, style: TextStyle(fontSize: 14),),
              content: Wrap(
                children: [
                  Divider(height: 10),
                  if(showingDevContent == true) Text(devContent, style: TextStyle(fontSize: 12)),
                  if(showingDevContent == false) Text(content, style: TextStyle(fontSize: 12)),
                  Divider(height: 10),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: (){
                    setState((){
                      print(showingDevContent);
                      showingDevContent = !showingDevContent;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey,
                  ),
                  child: Wrap(
                    direction: Axis.horizontal,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 14),
                      SizedBox(width: 5),
                      (showingDevContent == true) ? Text('Less') : Text('More')
                    ]
                  )
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(), 
                  child: Text('Ok')
                )
              ],
            );

          });
      });
  }

  String get getLoginUrl {
    return _loginUrl;
  }

  String get getRegisterUrl {
    return _registerUrl;
  }

  String get getRegisterValidationUrl {
    return _registerValidationUrl;
  }
  
  String get getGenerateMobileVerificationCodeUrl {
    return _generateMobileVerificationCodeUrl;
  }
  
  String get getVerifyMobileVerificationCodeUrl {
    return _verifyMobileVerificationCodeUrl;
  }

  String get getLogoutUrl {
    return _logoutUrl;
  }
  
  String get getAccountExistsUrl {
    return _accountExistsUrl;
  }
  
  String get getMainShortcode {
    return _mainShortcode;
  }
  
  String get getVerifyUserAccountShortcode {
    return _verifyUserAccountShortcode;
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