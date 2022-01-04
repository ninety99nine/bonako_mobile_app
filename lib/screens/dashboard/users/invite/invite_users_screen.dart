import 'package:bonako_mobile_app/components/custom_divider.dart';
import 'package:bonako_mobile_app/components/previous_step_button.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/models/users.dart';
import 'package:bonako_mobile_app/providers/locations.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/list/stores_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/show/store_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/list/users_screen.dart';
import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/components/custom_loader.dart';
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

class InviteUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        drawer: StoreDrawer(),
        appBar: CustomAppBar(),
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

  List<User> users = [];
  Map serverErrors = {};
  bool isInviting = false;
  bool isLoadingUsers = false;
  bool acceptedGoldenRules = false;
  bool isLoadingPermissions = false;
  late PaginatedUsers paginatedUsers;
  List<Map> availablePermissions = [];
  final GlobalKey<FormState> _formKey = GlobalKey();
  InviteTeamStage inviteTeamStage = InviteTeamStage.enterTeamMobileNumbers;

  Map invitationForm = {
    'mobile_numbers': [''],
    'permissions': [] 
  };

  void startLoader(loader){
    setState(() {
      loader = true;
    });
  }

  void stopLoader(loader){
    setState(() {
      loader = false;
    });
  }

  @override
  void initState() {
    fetchUsers();
    fetchAvailablePermissions();
    
    super.initState();
  }

  Future<http.Response> fetchUsers(){

    startLoader(isLoadingUsers);

    return Provider.of<LocationsProvider>(context, listen: false).fetchLocationUsers(context: context)
      .then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);
          paginatedUsers = PaginatedUsers.fromJson(responseBody);
          users = paginatedUsers.embedded.users;

        }

        return response;

      }).whenComplete((){

        stopLoader(isLoadingUsers);

      });

  }

  Future<http.Response> fetchAvailablePermissions(){

    startLoader(isLoadingPermissions);

    return Provider.of<LocationsProvider>(context, listen: false).fetchAvailablePermissions(context: context)
      .then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          availablePermissions = new List<Map>.from(responseBody['available_permissions']);

        }

        return response;

      }).whenComplete((){

        stopLoader(isLoadingPermissions);

      });

  }

  void _onSubmit(){

    //  Reset server errors
    _resetServerErrors();
    
    //  Validate the form
    validateForm().then((success){

      if( success ){

        if( acceptedGoldenRules == true ){

          //  Save inputs
          _formKey.currentState!.save();

          startLoader(isInviting);

          Provider.of<LocationsProvider>(context, listen: false).inviteUsers(
            body: invitationForm,
            context: context
          ).then((response){

            _handleOnSubmitResponse(response);

          }).whenComplete((){

            stopLoader(isInviting);

          });

        //  If validation failed
        }else{

          final snackBar = SnackBar(content: Text('Check for mistakes', textAlign: TextAlign.center));

          //  Show snackbar  
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }

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

    setState(() {

      final mobileNumbersError = serverErrors.containsKey('mobile_numbers');
      final permissionsError = serverErrors.containsKey('permissions');

      //  If we have server errors on the mobile numbers
      if( mobileNumbersError ){

        inviteTeamStage = InviteTeamStage.enterTeamMobileNumbers;

      //  If we have server errors on the permissions
      }else if( permissionsError ){

        inviteTeamStage = InviteTeamStage.selectPermissions;

      }else{

        inviteTeamStage = InviteTeamStage.enterTeamMobileNumbers;

      }

      /**
       *  Since the form is hidden while we are loading, we need to give the
       *  application a chance to set the text input value before we can
       *  validate, we buy ourselves this time by delaying the execution 
       *  of the form validation.
       */
      Future.delayed(const Duration(milliseconds: 100), () {

          // Run form validation
        _formKey.currentState!.validate();

      });
      
    });
    
  }

  Widget goldenRuleTitle(){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          left: BorderSide(color: Colors.orange.shade100, width: 2),
          right: BorderSide(color: Colors.orange.shade100, width: 2)
        )
      ),
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Text(
            '10 Golden Rules',
            style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
          ),
          Text(
            'Accept these rules to continue',
            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.orange),
          )
        ],
      ),
    );
  }

  Widget goldenRule(number, rule) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10, right: 20),
      margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text(number, style: TextStyle(color: Colors.orange.shade100, fontSize: 40, fontWeight: FontWeight.bold,),),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            margin: EdgeInsets.only(right: 10),
          ),
          Flexible(child: Text(rule, textAlign: TextAlign.justify, style: TextStyle(),))
        ],
      ),
    );
  }

  List<Widget> goldenRuleList() {

    const List<String> rules = [
      'The first golden rule',
      'The second golden rule',
      'The third golden rule',
    ];

    final ruleWidgets = rules.mapIndexed((index, rule){
      
      final number = (index + 1).toString();
      
      return goldenRule(number, rule);

    }).toList();

    return ruleWidgets;

  }

  Widget checkboxToAccept(){
    return CustomCheckbox(
      text: 'I Accept to follow these',
      linkText: '10 Golden Rules',
      value: acceptedGoldenRules, 
      link: 'https://github.com/ninety99nine/bonako-mobile-app-privacy-policy/blob/main/privacy-policy',
      onChanged: (value) {
        if(value != null){
          setState(() {
            acceptedGoldenRules = value;
          });
        }
      },
    );
  }

  Widget goldenRuleContent(){
    return Container(
      child: Column(
        children: [
          goldenRuleTitle(),
          SizedBox(height: 20),
          ...goldenRuleList(),
          checkboxToAccept(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget inviteTeamTitle({ text = 'Invite Team' }){
    return Text(
      text,
      style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget inviteTeamDesctiption({ text = 'Get your team to join and be more productive' }){
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  List<Widget> mobileNumberFields(){

    return new List<Widget>.from(invitationForm['mobile_numbers'].asMap().map((int index, String mobileNumber){

      final String number = (index + 1).toString();
      final String key = index.toString() + DateTime.now().toIso8601String();
      final hasMoreThanOneTeamMember = (invitationForm['mobile_numbers'].length > 1);
        
      return MapEntry(index, 

        Container(
          margin: EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextFormField(
                  autofocus: false,
                  key: ValueKey(key),
                  initialValue: mobileNumber,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Team'+(hasMoreThanOneTeamMember ? ' #'+number : '')+' mobile number',
                    hintText: 'e.g 72000123' + number,
                      border:OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  validator: (value){

                    final alreadyExists = users.where((user) => (user.mobileNumber.number == value) || user.mobileNumber.callingNumber == value).length > 0;
                    final hasDuplicates = (invitationForm['mobile_numbers'] as List).where((mobileNumber) => mobileNumber == value).length > 1;

                    if(value == null || value.isEmpty){
                      return 'Enter member #'+number+' mobile number';
                    }else if(serverErrors.containsKey('mobile_numbers')){
                      return serverErrors['mobile_numbers'].toString();
                    }else if(alreadyExists){
                      return 'Already team member';
                    }else if(hasDuplicates){
                      return 'Duplicate mobile numbers';
                    }
                  },
                  onChanged: (value){
                    invitationForm['mobile_numbers'][index] = value;
                  },
                  onSaved: (value){
                    invitationForm['mobile_numbers'][index] = value;
                  }
                ),
              ),
              if(hasMoreThanOneTeamMember) removeMobileNumberIconWidget(index)
            ],
          ),
        )
      
      );
        
    }).values.toList());
  }

  Widget removeMobileNumberIconWidget(int index){
    return TextButton(
      child: Icon(Icons.delete_outlined, color: Colors.red,),
      onPressed: (){
        showDialog(
          context: context, 
          builder: (_) => AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to remove this field?'),
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
              TextButton(
                child: Text('Remove', style: TextStyle(color: Colors.red)),
                onPressed: (){
                  setState((){
                    invitationForm['mobile_numbers'].removeAt(index);
                    Navigator.of(context).pop(false);
                  });
                }
              ),
            ],
          )
        );
      },
    );
  }

  Widget addMoreTeamButton(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          width: 150,
          size: 'small',
          solidColor: true,
          color: Colors.green,
          text: '+ Add more team',
          margin: EdgeInsets.only(bottom: 50),
          onSubmit: (){
            setState(() {
              invitationForm['mobile_numbers'].add('');
            });
          },
        ),
      ]
    );
  }

  List<Widget> permissionCheckboxes(){

    return new List<Widget>.from(availablePermissions.asMap().map((int index, Map availablePermission){
        
      return MapEntry(index, 

        CustomCheckbox(
          text: availablePermission['name'],
          value: (invitationForm['permissions'] as List).contains(availablePermission['type']), 
          onChanged: (value){
            setState(() {
              if(value == true){
                (invitationForm['permissions'] as List).add(availablePermission['type']);
              }else{
                (invitationForm['permissions'] as List).remove(availablePermission['type']);
              }
            });
          }
        )
      
      );
        
    }).values.toList());
  }

  Widget proceedButton(){

    var text = 'Invite Team';
    var disabled = false;
    Function()? action = (){
      setState(() {
        inviteTeamStage = InviteTeamStage.inviting;
        _onSubmit();
      });
    };

    if( inviteTeamStage == InviteTeamStage.enterTeamMobileNumbers ){
      
      if(invitationForm['permissions'].length == 0){
        
        text = 'Next';

        action = (){

          //  Reset server errors
          _resetServerErrors();
    
          //  Validate the form (Make sure mobile numbers are provided)
          validateForm().then((success){

            if( success ){

              setState(() {
                inviteTeamStage = InviteTeamStage.selectPermissions;

              });
              
            }

          });

        };
        
      }

    }else if( inviteTeamStage == InviteTeamStage.selectPermissions ){

      text = 'Grant permissions';
      disabled = (invitationForm['permissions'].length == 0);
      
      if(acceptedGoldenRules == false){

        action = (){
          setState(() {
            inviteTeamStage = InviteTeamStage.acceptGoldenRules;
          });
        };

      }

    }else if( inviteTeamStage == InviteTeamStage.acceptGoldenRules ){

      text = 'Accept';
      disabled = (acceptedGoldenRules == false);

      action = (){
        setState(() {
          inviteTeamStage = InviteTeamStage.inviting;
          _onSubmit();
        });
      };

    }

    return CustomButton(
      text: text,
      onSubmit: action,
      disabled: disabled,
    );
  }

  Widget previousStepButton() {
    return Flexible(
      child: PreviousStepButton(
        onTap: () {
          setState(() {

            if( inviteTeamStage == InviteTeamStage.acceptGoldenRules ){
              
              inviteTeamStage = InviteTeamStage.selectPermissions;

            }else if( inviteTeamStage == InviteTeamStage.selectPermissions ){
              
              inviteTeamStage = InviteTeamStage.enterTeamMobileNumbers;

            }

          });
        }
      )
    );
  }

  Widget proceedWithPreviousStepButton() {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          previousStepButton(),
          Flexible(
            flex: 4,
            child: proceedButton(),
          )
        ],
      ),
    );
  }
  
  Widget inviteTeamContent(){

    final content = [];

    if(inviteTeamStage == InviteTeamStage.enterTeamMobileNumbers){

      //  Add the title and description
      content.addAll([

        //  Title
        inviteTeamTitle(),

        //  Description
        inviteTeamDesctiption(),
      
        Divider(height: 50),

        //  Mobile number fields
        ...mobileNumberFields(),

        //  Add Team button
        addMoreTeamButton(),

        //  Proceed button
        proceedButton()

      ]);

    }else if(inviteTeamStage == InviteTeamStage.selectPermissions){

      content.addAll([
        
        //  Title
        inviteTeamTitle(text: 'Give Permissions'),

        //  Description
        inviteTeamDesctiption(text: 'Select permissions to assign to your team'),
      
        Divider(height: 50),

        //  Permission checkboxes
        ...permissionCheckboxes(),
        
        Divider(height: 50),

        //  Proceed button
        proceedWithPreviousStepButton()

      ]);

    }else if(inviteTeamStage == InviteTeamStage.acceptGoldenRules){

      content.addAll([

        //  Golden rules
       goldenRuleContent(),

        //  Proceed button
        proceedWithPreviousStepButton()
        
      ]);

    }else if(inviteTeamStage == InviteTeamStage.inviting){

      //  Loader
      content.addAll([
        CustomLoader(text: 'Inviting team members')
      ]);

    }

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            ...content
          ]
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          CustomBackButton(fallback: (){
            Get.offAll(() => UsersScreen());
          }),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: inviteTeamContent()
            ),
          )
        ],
      ),
    );
  }
}