import 'package:shared_preferences/shared_preferences.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class ApiProvider with ChangeNotifier{

  final String homeUrl = 'http://165.232.179.255/api';  //  'http://127.0.0.1:9000/api'; //  'http://bonakoonline.co.bw/api';  //   

  String _loginUrl = '';
  String _logoutUrl = '';
  String _registerUrl = ''; 
  String _bearerToken = '';
  String _mainShortcode = '';
  String _resetPasswordUrl = '';
  String _accountExistsUrl = '';
  String _paymentMethodsUrl = '';
  Map<String, dynamic> _apiHome = {};
  String _verifyUserAccountShortcode = '';
  String _verifyMobileVerificationCodeUrl = '';
  String _generateMobileVerificationCodeUrl = '';
  String _searchUserByMobileNumberUrl = '';

  Future<http.Response> setupApiConnection ({ required BuildContext context }) async {
    
    //  Establish a connection to Firebase
    await connectToFirebase();
    
    //  Establish a connection to Application Home API
    return await setApiEndpoints(context: context);

  }

  Future<void> connectToFirebase () async {

    print('Connecting To Firebase');
    
    //  Establish a connection to Firebase
    await Firebase.initializeApp();

  }

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

            //  Update the generate mobile verification code url
            _generateMobileVerificationCodeUrl = responseBody['_links']['bos:generate_mobile_verification_code']['href'];

            //  Update the verify mobile verification code url
            _verifyMobileVerificationCodeUrl = responseBody['_links']['bos:verify_mobile_verification_code']['href'];

            //  Update the logout url
            _logoutUrl = responseBody['_links']['bos:logout']['href'];

            //  Update the account exists url
            _accountExistsUrl = responseBody['_links']['bos:account_exists']['href'];

            //  Update the reset password url
            _resetPasswordUrl = responseBody['_links']['bos:reset_password']['href'];

            //  Update the search user by mobile number url
            _searchUserByMobileNumberUrl = responseBody['_links']['bos:search_user_by_mobile_number']['href'];

            //  Update the payment methods url
            _paymentMethodsUrl = responseBody['_links']['bos:payment_methods']['href'];

            //  Update Main USSD shortcode
            _mainShortcode = responseBody['_embedded']['main_shortcode'];

            //  Update shortcode to verify user account after registration
            _verifyUserAccountShortcode = responseBody['_embedded']['verify_user_account_shortcode'];

          }

          return response;

        });

    });

  }
  
  Future<http.Response> fetchPaymentMethods({ required BuildContext context }){

    return get(url: getPaymentMethodsUrl, context: context);
    
  }

  Future<http.Response> get({ required String url, required BuildContext context }){
    
    print('get url: '+ url);

    return http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_bearerToken'
      }
    ).then((response){

      handleApiResponseFail(response: response, context: context);

      return response;
      
    }).catchError((error){

      print('error.toString()');
      print(error.toString());

        handleApiFail(error, context);

        throw(error);
      
    });
  }

  Future<http.Response> post({ required String url, body: const {}, required BuildContext context }) {
    
    print('post url: '+ url);

    print('post body');
    print(body);

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
    
    print('put url: '+ url);

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
    
    print('patch url: '+ url);

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
    
    print('delete url: '+ url);

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

      var devContent = responseBody['message'];
      var title = responseBody['error'];
      var showingDevContent = false;

      //  If this is a validation error
      if( response.statusCode == 422 ){
        
        showingDevContent = true;
        devContent = _getServerValidationErrorsAsWidget(response);

      }

      showAlertDialog(
        context: context,
        title: title,
        devContent: devContent,
        showingDevContent: showingDevContent,
        content: 'Sorry, something went wrong on our side',
      );

    }

  }
    
    Widget _getServerValidationErrorsAsWidget(http.Response response){

      final serverErrors = {};

      final responseBody = jsonDecode(response.body);

      final Map validationErrors = responseBody['errors'];
      
      validationErrors.forEach((key, value){
        serverErrors[key] = value[0];
      });

      return Column(
        children: [
          SizedBox(height: 10,),
          ...serverErrors.values.map((value){
            return Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline_sharp, color: Colors.red, size: 12,),
                    SizedBox(width: 5),
                    Flexible(child: Text(value, style: TextStyle(fontSize: 12, color: Colors.red),))
                  ],
                ),
                SizedBox(height: 10,),
              ],
            );
          }).toList()
        ]
      );
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

  void showAlertDialog({ required String title, required String? content, required devContent, bool showingDevContent = false, required BuildContext context }){

    showDialog(context: context, builder: (ctx){

        return StatefulBuilder(
          builder: (context, setState) {

            return AlertDialog(
              title: Text(title, style: TextStyle(fontSize: 14),),
              content: Wrap(
                children: [
                  Divider(height: 10),
                  if(showingDevContent == true && devContent != null) (devContent is String ? Text(devContent, style: TextStyle(fontSize: 12)) : devContent),
                  if(showingDevContent == false && content != null) Text(content, style: TextStyle(fontSize: 12)),
                  Divider(height: 10),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: (){
                    setState((){
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
  
  String get getResetPasswordUrl{
    return _resetPasswordUrl;
  }
  
  String get getSearchUserByMobileNumberUrl{
    return _searchUserByMobileNumberUrl;
  }
  
  String get getPaymentMethodsUrl{
    return _paymentMethodsUrl;
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

  void showSnackbarMessage({ required String msg, required BuildContext context, SnackbarType type = SnackbarType.info }){

    Color color = Colors.blue;

    if(type == SnackbarType.warning){
      color = Colors.orange;
    }else if(type == SnackbarType.error){
      color = Colors.red;
    }

    //  Set snackbar content
    final snackBar = SnackBar(
      backgroundColor: color,
      content: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: Text(msg, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
      )
    );

    //  Hide existing snackbar
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    //  Show snackbar  
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }
  
}