import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import './../components/custom_loader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../models/users.dart';
import 'package:get/get.dart';
import './../enum/enum.dart';
import 'dart:convert';
import './api.dart';

class AuthProvider with ChangeNotifier{

  String _token = '';
  String _refreshToken = '';
  String _tokenExpiryDate = '';
  bool _hasViewedIntro = false;
  bool _isAuthenticated = false;
  Map<String, dynamic> _user = {};
  Map<String, dynamic> _loginData = {};
  Map<String, dynamic> _registrationData = {};
  Map<String, dynamic> _passwordResetData = {};
  
  ApiProvider apiProvider;

  AuthProvider({ required this.apiProvider });

  Future<http.Response> acceptTermsAndConditions({ required BuildContext context}){

    return apiProvider.post(url: getAcceptTermsAndConditionsUrl, context: context);
    
  }

  Future<http.Response> checkIfMobileAccountExists({ required String mobileNumber, required BuildContext context}){
    
    final accountData = {
      'mobile_number': mobileNumber
    };

    return apiProvider.post(url: apiProvider.getAccountExistsUrl, body: accountData, context: context);
    
  }
  
  Future<http.Response> generateMobileVerification({ required String mobileNumber, required MobileVerificationType type, Map metadata = const {}, required BuildContext context}){
    
    final Map<String, dynamic> data = {
      'mobile_number': mobileNumber,
      'type': extractEnumValue(type),
    };

    if( metadata.isNotEmpty ){
      data['metadata'] = metadata;
    }
  
    print('generateMobileVerification()');
    print('data');
    print(data);

    return apiProvider.post(url: apiProvider.getGenerateMobileVerificationCodeUrl, body: data, context: context);
    
  }
  
  Future<http.Response> verifyMobileVerificationCode({ required String mobileNumber, required MobileVerificationType type, required String code, required BuildContext context}){
    
    final data = {
      'code': code,
      'mobile_number': mobileNumber,
      'type': extractEnumValue(type),
    };

    return apiProvider.post(url: apiProvider.getVerifyMobileVerificationCodeUrl, body: data, context: context);
    
  }

  Future<http.Response> loginWithMobile({ required String mobileNumber, required String password, String? passwordConfirmation, String? verificationCode, required BuildContext context}){
    
    final loginData = {
      'mobile_number': mobileNumber,
      'password': password,
    };

    if(passwordConfirmation != null){
      loginData['password_confirmation'] = passwordConfirmation;
    }

    if(verificationCode != null){
      loginData['verification_code'] = verificationCode;
    }

    return login(loginData: loginData, context: context);
    
  }

  Future<http.Response> registerUserAccount({ required String firstName, required String lastName, required String mobileNumber, required String password, required String passwordConfirmation, required String verificationCode, required BuildContext context}){
    
    final registerData = {
      'password': password,
      'last_name': lastName,
      'first_name': firstName,
      'mobile_number': mobileNumber,
      'verification_code': verificationCode,
      'password_confirmation': passwordConfirmation,
    };

    print('registerData');
    print(registerData);

    return apiProvider.post(url: apiProvider.getRegisterUrl, body: registerData, context: context)
      .then((response) async {

        await setUserAndAuthTokenFromResponse(response);

        return response;

      });
    
  }

  Future<http.Response> login({ required Map loginData, required BuildContext context}){

    return apiProvider.post(url: apiProvider.getLoginUrl, body: loginData, context: context)
      .then((response) async {

        await setUserAndAuthTokenFromResponse(response);

        return response;

      });
    
  }

  Future<http.Response> resetUserAccountPassword({ required String mobileNumber, required String password, required String passwordConfirmation, required String verificationCode, required BuildContext context}){
    
    final passwordResetData = {
      'password': password,
      'mobile_number': mobileNumber,
      'verification_code': verificationCode,
      'password_confirmation': passwordConfirmation,
    };

    return apiProvider.post(url: apiProvider.getResetPasswordUrl, body: passwordResetData, context: context)
      .then((response) async {

        await setUserAndAuthTokenFromResponse(response);

        return response;

      });
    
  }

  Future<http.Response> setUserAndAuthTokenFromResponse(http.Response response) async {

    //  if we authenticated successfully
    if( response.statusCode == 200 ){

      print('setUserAndAuthTokenFromResponse()');
      print('response.body');
      print(response.body);

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

  }

  void setAuthenticatedStatus(bool status){

    _isAuthenticated = status;

  }

  Future logout({ required BuildContext context }){

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
    return apiProvider.post(url: apiProvider.getLogoutUrl, context: context);
  }

  Future logoutClientSide() {

    //  Store an empty bearer token on the device
    return apiProvider.storeBearerTokenLocallyAndOnDevice('').whenComplete((){
      
      //  Reset the login form
      storeLoginDataLocallyAndOnDevice();
      
      //  Reset the registration form
      storeRegistrationDataLocallyAndOnDevice();

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

      //  Set the user stored on the device
      _user = jsonDecode( prefs.getString('user') ?? '{}' );

    });

  }

  Future storeLoginDataLocallyAndOnDevice({ Map<String, dynamic> loginData = const {} }) async {
    
    return await SharedPreferences.getInstance().then((prefs){
      
      if(loginData.isNotEmpty){

        //  Set to expire after 1 hour
        loginData['expires_at'] = (new DateTime.now()).add(new Duration(hours: 1)).toIso8601String();

      }

      //  Store login data to the device
      prefs.setString('login_data', jsonEncode(loginData));

    });

  }

  Future setLoginDataFromDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      //  Set the login data stored on the device
      _loginData = jsonDecode( prefs.getString('login_data') ?? '{}' );

    });

  }

  Future storePasswordResetDataLocallyAndOnDevice({ Map<String, dynamic> passwordResetData = const {} }) async {
    
    return await SharedPreferences.getInstance().then((prefs){
      
      if(passwordResetData.isNotEmpty){

        //  Set to expire after 1 hour
        passwordResetData['expires_at'] = (new DateTime.now()).add(new Duration(hours: 1)).toIso8601String();

      }

      //  Store password reset data to the device
      prefs.setString('password_reset_data', jsonEncode(passwordResetData));

    });

  }

  Future setPasswordResetDataFromDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      //  Set the password reset data stored on the device
      _passwordResetData = jsonDecode( prefs.getString('password_reset_data') ?? '{}' );

    });

  }

  Future storeRegistrationDataLocallyAndOnDevice({ Map<String, dynamic> registrationData = const {} }) async {
    
    return await SharedPreferences.getInstance().then((prefs){
      
      if(registrationData.isNotEmpty){

        //  Set to expire after 1 hour
        registrationData['expires_at'] = (new DateTime.now()).add(new Duration(hours: 1)).toIso8601String();

      }

      //  Store registration data to the device
      prefs.setString('registration_data', jsonEncode(registrationData));

    });

  }

  Future setRegistrationDataFromDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      //  Set the registration data stored on the device
      _registrationData = jsonDecode( prefs.getString('registration_data') ?? '{}' );

    });

  }
  
  void storeHasViewedIntroOnDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      _hasViewedIntro = true;

      prefs.setString('hasViewedIntro', jsonEncode(_hasViewedIntro));

    }).whenComplete((){

      notifyListeners();

    });
  }
  
  void storeHasNotViewedIntroOnDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      _hasViewedIntro = false;

      prefs.setString('hasViewedIntro', jsonEncode(_hasViewedIntro));

    }).whenComplete((){

      notifyListeners();

    });
  }

  Future setHasViewedIntroFromDevice() async {
    
    return await SharedPreferences.getInstance().then((prefs){

      print( 'prefs.getString(\'hasViewedIntro\')' );
      print( prefs.getString('hasViewedIntro') );

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
    return (_user.isNotEmpty);
  }
  
  bool get hasAcceptedTermsAndConditions {
    return (hasAuthUser == true) ? getAuthUser.acceptedTermsAndConditions.status : false;
  }
  
  Map get getLoginData {
    return _loginData;
    
  }
  
  bool get hasLoginData {
    final now = DateTime.now();
    //  Check if the data exists and has not expired (Expires after 1 hour)
    return _loginData.isNotEmpty && _loginData.containsKey('expires_at') && DateTime.parse(_loginData['expires_at']).isAfter(now);
  }
  
  Map get getRegistrationData {
    return _registrationData;
    
  }
  
  bool get hasRegistrationData {
    final now = DateTime.now();
    //  Check if the data exists and has not expired (Expires after 1 hour)
    return _registrationData.isNotEmpty && _registrationData.containsKey('expires_at') && DateTime.parse(_registrationData['expires_at']).isAfter(now);
  }

  Map get getPasswordResetData {
    return _passwordResetData;
    
  }
  
  bool get hasPasswordResetData {
    final now = DateTime.now();
    //  Check if the data exists and has not expired (Expires after 1 hour)
    return _passwordResetData.isNotEmpty && _passwordResetData.containsKey('expires_at') && DateTime.parse(_passwordResetData['expires_at']).isAfter(now);
  }

  bool get isAuthenticated {
    return _isAuthenticated;
  }
  
  String get getAcceptTermsAndConditionsUrl {
    return getAuthUser.links.bosAcceptTermsAndConditions.href;
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
        padding: const EdgeInsets.only(top: 15),
        child: Text(msg, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
      )
    );

    //  Hide existing snackbar
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    //  Show snackbar  
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }

  void launchShortcode ({ required String dialingCode, String loadingMsg = 'Loading...', required BuildContext context }) async {

    showLoadingDialog(context: context, loadingMsg: loadingMsg);

    final ussdString = "tel:" + Uri.encodeComponent(dialingCode);

    if(await canLaunch(ussdString)){

      await launch(ussdString);

      Navigator.of(context).pop();

    }

  }

  void showLoadingDialog({ required BuildContext context, String loadingMsg = 'Loading...' }){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              Container(height:20, width:20, margin: EdgeInsets.only(right: 10), child: CircularProgressIndicator(strokeWidth: 3,)),
              Text(loadingMsg),
            ],
          )
        );
      }
    );
  }

}