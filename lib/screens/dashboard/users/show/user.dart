import 'package:bonako_mobile_app/components/custom_card.dart';
import 'package:bonako_mobile_app/components/custom_checkmark_text.dart';
import 'package:bonako_mobile_app/components/custom_divider.dart';
import 'package:bonako_mobile_app/components/custom_tag.dart';
import 'package:bonako_mobile_app/components/previous_step_button.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/models/users.dart';
import 'package:bonako_mobile_app/providers/locations.dart';
import 'package:bonako_mobile_app/providers/users.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/list/stores_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/show/store_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/list/users_screen.dart';
import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/show/components/userProfileSummary.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/show/components/userRoleTag.dart';
import 'package:flutter/foundation.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_button.dart';
import './../../../../components/store_drawer.dart';
import './../../../../providers/stores.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class ShowUserScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    final user = Provider.of<UsersProvider>(context, listen: false).getUser;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: user.attributes.name),
        drawer: StoreDrawer(),
        body: Content(),
      )
    );
  }
}

class Content extends StatefulWidget {

  @override
  _ContentState createState() => _ContentState();

}

class _ContentState extends State<Content> {

  bool isOwner = false;
  Map serverErrors = {};
  bool isSubmitting = false;
  List<Map> availablePermissions = [];
  bool isLoadingUserPermissions = false;
  bool isLoadingAvailablePermissions = false;
  List<String> originalSelectedPermissions = [];
  final GlobalKey<FormState> _formKey = GlobalKey();

  Map userForm = {
    'permissions': [] 
  };

  void startAvailablePermissionsLoader(){
    setState(() {
      isLoadingAvailablePermissions = true;
    });
  }

  void stopAvailablePermissionsLoader(){
    setState(() {
      isLoadingAvailablePermissions = false;
    });
  }

  void startUserPermissionsLoader(){
    setState(() {
      isLoadingUserPermissions = true;
    });
  }

  void stopUserPermissionsLoader(){
    setState(() {
      isLoadingUserPermissions = false;
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
    fetchAvailablePermissions();
    fetchUserLocationPermissions();
    
    super.initState();
  }

  Future<http.Response> fetchUserLocationPermissions(){

    startUserPermissionsLoader();

    final user = Provider.of<UsersProvider>(context, listen: false).getUser;

    return Provider.of<LocationsProvider>(context, listen: false).fetchUserLocationPermissions(userId: user.id, context: context)
      .then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          isOwner = responseBody['is_owner'];

          //  Sort alphabetically so that the listEquals can track changes properly
          userForm['permissions'] = new List<String>.from(sortAlphabetically(responseBody['permissions']));
          originalSelectedPermissions = new List<String>.from(sortAlphabetically(responseBody['permissions']));

        }

        return response;

      }).whenComplete((){

        stopUserPermissionsLoader();

      });

  }

  List sortAlphabetically(List data){

    data.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    return data;
  }

  Future<http.Response> fetchAvailablePermissions(){

    startAvailablePermissionsLoader();

    return Provider.of<LocationsProvider>(context, listen: false).fetchAvailablePermissions(context: context)
      .then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          availablePermissions = new List<Map>.from(responseBody['available_permissions']);

        }

        return response;

      }).whenComplete((){

        stopAvailablePermissionsLoader();

      });

  }

  void _onSubmit(){

    //  Reset server errors
    _resetServerErrors();
    
    //  Validate the form
    validateForm().then((success){

      if( success ){

        //  Save inputs
        _formKey.currentState!.save();

        startSubmittionLoader();

        final user = Provider.of<UsersProvider>(context, listen: false).getUser;

        Provider.of<LocationsProvider>(context, listen: false).updateUserPermissions(
          userId: user.id,
          permissions: userForm['permissions'],
          context: context
        ).then((response){

          _handleOnSubmitResponse(response);

        }).whenComplete((){

          stopSubmittionLoader();

        });

      //  If validation failed
      }else{

        final snackBar = SnackBar(content: Text('Check for mistakes', textAlign: TextAlign.center));

        //  Show snackbar  
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

      }

    });

  }

  Future<bool> validateForm() async {
    
    return await Future.delayed(const Duration(milliseconds: 100), () {

      // Run form validation
      return _formKey.currentState!.validate() == true;

    });
    
  }

  void _handleOnSubmitResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if(response.statusCode == 200){

      final snackBar = SnackBar(content: Text('Permissions updated successfully', textAlign: TextAlign.center));

      //  Show snackbar  
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      //  Navigate to the products
      Get.back(result: 'submitted');

    }

  }

  void _resetServerErrors(){
    serverErrors = {};
  }

  void _handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];

    /**
     *  validationErrors = {
     *    mobile_numbers: [Enter a valid mobile number containing only digits e.g 26771234567]
     *  }
     */
    validationErrors.forEach((key, value){
      serverErrors[key] = value[0];
    });

    // Run form validation
    _formKey.currentState!.validate();
    
  }

  Widget title({ text = 'Permissions' }){
    return Text(
      text,
      style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold),
    );
  }

  List<Widget> permissionCheckboxes(){

    return new List<Widget>.from(availablePermissions.asMap().map((int index, Map availablePermission){
        
      return MapEntry(index, 

        CustomCheckbox(
          text: availablePermission['name'],
          value: (userForm['permissions'] as List).contains(availablePermission['type']), 
          onChanged: isOwner ? null : (value){
            setState(() {
              if(value == true){
                (userForm['permissions'] as List).add(availablePermission['type']);
              }else{
                (userForm['permissions'] as List).remove(availablePermission['type']);
              }

              //  Sort alphabetically so that the listEquals can track changes properly
              userForm['permissions'] = sortAlphabetically(userForm['permissions']);
            });
          }
        )
      
      );
        
    }).values.toList());
  }

  Widget submittionButton(){
    return CustomButton(
      onSubmit: _onSubmit,
      isLoading: isSubmitting,
      text: 'Save Permissions',
      disabled: isOwner || listEquals(originalSelectedPermissions, userForm['permissions']),
    );
  }
  
  Widget formContent(){

    final List<Widget> content = [];

    final user = Provider.of<UsersProvider>(context, listen: false).getUser;
    final isLoading = (isLoadingUserPermissions || isLoadingAvailablePermissions);

    content.addAll([

      //  User profile
      UserProfileSummary(user: user),

      //  User performance
      CustomCard(
        icon: Icons.show_chart_rounded,
        title: 'Performance', 
        description: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Orders delivered'),
                Text('255'),
              ],
            )
          ],
        ),
      ),

      SizedBox(height: 10),

      //  User permissions
      CustomCard(
        icon: Icons.shield_sharp,
        title: 'Permissions', 
        subtitle: isOwner ? CustomCheckmarkText(text: 'Owner permissions cannot be modified', state: 'warning') : null, 
        description: [

          //  Loader
          if(isLoading == true) CustomLoader(bottomMargin: 40,),

          //  Permissions checkbox
          if(isLoading == false) ...permissionCheckboxes(),
    
          if(isLoading == false) Divider(height: 50),

          //  Submission button
          if(isLoading == false) submittionButton(),

        ],
      ),

      SizedBox(height: 100),

    ]);

    return Form(
      key: _formKey,
      child: Column(
        children: content
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UsersProvider>(context, listen: false).getUser;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          
              CustomBackButton(fallback: (){
                Get.offAll(() => UsersScreen());
              }),

              //  User role
              UserRoleTag(user: user),

            ],
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: formContent()
            ),
          )
        ],
      ),
    );
  }
}