import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import './../dashboard/stores/list/stores_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './../../providers/auth.dart';
import './../../enum/enum.dart';
import 'package:get/get.dart';
import 'dart:convert';

class TermsAndConditionsScreen extends StatefulWidget {

  static const routeName = '/terms-and-conditions';
  
  @override
  _TermsAndConditionsScreenState createState() => _TermsAndConditionsScreenState();

}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {

  bool isLoading = false;
  bool isSubmitting = false;
  bool acceptedPrivacyPolicy = false;
  bool acceptedTermsOfService = false;

  void startLoader(){
    setState(() {
      isLoading = true;
    });
  }

  void stopLoader(){
    setState(() {
      isLoading = false;
    });
  }

  void startSubmittionLoader(){
    setState(() {
      isSubmitting = true;
    });
  }

  void stopSubmittionLoader(){
    setState(() {
      isSubmitting = false;
    });
  }

  @override
  void initState() {
    
    super.initState();

  }

  ApiProvider get apiProvider {
    return Provider.of<ApiProvider>(context, listen: false);
  }
  
  AuthProvider get authProvider {
    return Provider.of<AuthProvider>(context, listen: false);
  }

  bool get hasAcceptedTermsAndConditions {
    return (acceptedPrivacyPolicy && acceptedTermsOfService);
  }
  
  acceptTermsAndConditions(){

    startLoader();

    return authProvider.acceptTermsAndConditions(context: context)
      .then((response) async {

        final Map responseBody = jsonDecode(response.body);

        //  If this is a successful request
        if( response.statusCode == 200 && responseBody['accepted'] == true){
          
          final user = responseBody['user'];
          
          await authProvider.storeUserLocallyAndOnDevice(user);

          apiProvider.showSnackbarMessage(msg: 'Terms & Conditions accepted!', context: context);

          Get.offAll(() => StoresScreen());

        }else{

          apiProvider.showSnackbarMessage(msg: 'Failed to accept Terms & Conditions', context: context, type: SnackbarType.error);

        }

      }).whenComplete((){

        stopLoader();
      
      });
    
  }

  List<Widget> termsAndCondtions(){
    return [
      termsAndCondtionsHeader(),
      termsAndCondtionsContent(),
    ];
  }

  Widget termsAndCondtionsHeader(){
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Terms & Conditions', style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget termsAndCondtionsContent(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
              children: <TextSpan>[
                TextSpan(text: 'Accept the following terms and conditions to continue using '),
                TextSpan(
                  text: 'Bonako Dial2Buy', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                )
              ],
            ),
          ),
          Divider(height: 50),
          checkboxToAccept(
            link: 'https://github.com/ninety99nine/bonako-mobile-app-privacy-policy/blob/main/privacy-policy',
            name: 'Privacy Policy', 
          ),
          checkboxToAccept(
            link: 'https://github.com/ninety99nine/bonako-mobile-app-privacy-policy/blob/main/privacy-policy',
            name: 'Terms Of Service', 
          ),
          Divider(height: 50),
          CustomButton(
            text: 'Accept & Continue',
            size: 'medium',
            ripple: hasAcceptedTermsAndConditions == true,
            disabled: hasAcceptedTermsAndConditions == false,
            onSubmit: (){
              if( hasAcceptedTermsAndConditions == true ){
                acceptTermsAndConditions();
              }
            },
          )
        ],
      ),
    );
  }

  Widget checkboxToAccept({ required String name, required String link }){
    return CustomCheckbox(
      text: 'Accept',
      linkText: name,
      value: name == 'Privacy Policy' ? acceptedPrivacyPolicy : acceptedTermsOfService, 
      onChanged: (value) {
        if(value != null){
          setState(() {
            if(name == 'Privacy Policy'){
              acceptedPrivacyPolicy = value;
            }else if(name == 'Terms Of Service'){
              acceptedTermsOfService = value;
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40),
              constraints: BoxConstraints(maxWidth: 800),
              height: height * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  
                  if(isLoading == true) CustomLoader(),
                  if(isLoading == false) ...termsAndCondtions()

                ],
              ),
            ), 
          ),
        )
      )
    );
  }
}