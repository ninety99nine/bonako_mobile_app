import 'package:bonako_mobile_app/components/custom_multi_widget_separator.dart';
import 'package:bonako_mobile_app/components/custom_proceed_card.dart';
import 'package:bonako_mobile_app/components/custom_secondary_text.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/providers/stores.dart';
import 'package:bonako_mobile_app/screens/dashboard/locations/create/sections/delivery_settings.dart';
import 'package:bonako_mobile_app/screens/dashboard/locations/create/sections/pickup_settings.dart';

import './../../../../screens/dashboard/locations/list/locations_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_checkmark_text.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../../components/custom_loader.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_divider.dart';
import './../../../../components/custom_button.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/locations.dart';
import './../../../../providers/locations.dart';
import './../../../../models/locations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './sections/visibility.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:convert';

enum Activity {
  isCreating,
  isEditing
}

class CreateLocationScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    final hasLocation = Provider.of<LocationsProvider>(context, listen: false).hasLocation;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: hasLocation ? 'Edit Location' : 'Create Location'),
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
  
  //  Set the form key
  final GlobalKey<FormState> _formKey = GlobalKey();

  //  By default we are creating a location
  Activity activityType = Activity.isCreating;

  //  By default the loader is not loading
  var isSubmitting = false;

  //  By default the loader is not loading
  var isLoadingLocation = false;

  //  Set the edittableLocation
  late Location edittableLocation;
  
  Map locationForm = {};

  Map serverErrors = {};

  ApiProvider get apiProvider {
    return Provider.of<ApiProvider>(context, listen: false);
  }

  LocationsProvider get locationsProvider {
    return Provider.of<LocationsProvider>(context, listen: false);
  }

  StoresProvider get storesProvider {
    return Provider.of<StoresProvider>(context, listen: false);
  }

  void _resetServerErrors(){
    serverErrors = {};
  }

  void startLocationLoader(){
    setState(() {
      isLoadingLocation = true;
    });
  }

  void stopLocationLoader(){
    setState(() {
      isLoadingLocation = false;
    });
  }

  void startSubmitLoader(){
    setState(() {
      isSubmitting= true;
    });
  }

  void stopSubmitLoader(){
    setState(() {
      isSubmitting = false;
    });
  }

  void setActivity(){
    //  If we have a location set on the locationsProvider, then we are editing
    activityType = locationsProvider.hasTemporaryLocation ? Activity.isEditing : Activity.isCreating;
  }

  bool get isEditing {
    return activityType == Activity.isEditing;
  }

  bool get isCreating {
    return activityType == Activity.isCreating;
  }

  @override
  void initState() {

    setActivity();
    
    prepareLocation();

    super.initState();

  }

  prepareLocation() {

    if( isEditing ){

      startLocationLoader();

      //  Set the temporary location url
      final locationUrl = locationsProvider.getTemporaryLocation.links.self.href;

      //  Fetch the location
      locationsProvider.fetchLocation(locationUrl: locationUrl, context: context).then((response){

        if( response.statusCode == 200 ){

          final responseBody = jsonDecode(response.body);

          edittableLocation = Location.fromJson(responseBody as Map<String, dynamic>);
            
          //  Set the form details
          locationForm = getLocationForm();
        
        }

        return response;

      }).whenComplete((){

        stopLocationLoader();

      });

    }else{

      //  Set the form details
      locationForm = getLocationForm();

    }

  }

  Map getLocationForm(){

          print('isEditing');
          print(isEditing.toString());

    return {
      
      'name': isEditing ? edittableLocation.name : '',
      'abbreviation': isEditing ? edittableLocation.abbreviation : '',
      'currency': isEditing ? edittableLocation.currency.code : 'BWP',
      'about_us': isEditing ? edittableLocation.aboutUs : '',
      'contact_us': isEditing ? edittableLocation.contactUs : '',
      'call_to_action': isEditing ? edittableLocation.callToAction : '',
      'online': isEditing ? edittableLocation.online.status : true,
      'offline_message': isEditing ? edittableLocation.offlineMessage : '',

      'allow_delivery': isEditing ? edittableLocation.allowDelivery.status : true,
      'delivery_note': isEditing ? edittableLocation.deliveryNote : '',
      'allow_free_delivery': isEditing ? edittableLocation.allowFreeDelivery.status : false,
      'delivery_flat_fee': isEditing ? edittableLocation.deliveryFlatFee.amount.toString() : '0',
      'delivery_destinations': isEditing ? new List<Map>.from(edittableLocation.deliveryDestinations.map((deliveryDestination){
          return {
            'name': deliveryDestination.name,
            'cost': deliveryDestination.cost.amount.toString(),
            'allow_free_delivery': deliveryDestination.allowFreeDelivery.status
          };
        })) : [],
      'delivery_days': isEditing ? edittableLocation.deliveryDays : [],
      'delivery_times': isEditing ? edittableLocation.deliveryTimes : [],
      
      'allow_pickups': isEditing ? edittableLocation.allowPickups.status : false,
      'pickup_note': isEditing ? edittableLocation.pickupNote : '',
      'pickup_destinations': isEditing  ? new List<Map>.from(edittableLocation.pickupDestinations.map((pickupDestination){
          return {
            'name': pickupDestination.name
          };
        })) : [],
      'pickup_days': isEditing ? edittableLocation.pickupDays : [],
      'pickup_times': isEditing ? edittableLocation.pickupTimes : [],
      'allow_payments': isEditing ? edittableLocation.allowPayments.status : false,
      'orange_money_merchant_code': isEditing ? edittableLocation.orangeMoneyMerchantCode : '',
      'minimum_stock_quantity': isEditing ? edittableLocation.minimumStockQuantity : '0',
      'allow_sending_merchant_sms': isEditing ? edittableLocation.allowSendingMerchantSms.status : true,

      'store_id': isEditing ? storesProvider.getStore.id : true,

    };
  }

  void _handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];

    /**
     *  validationErrors = {
     *    name: [Enter location name]
     *  }
     */
    validationErrors.forEach((key, value){
      serverErrors[key] = value[0];
    });
    
    // Run form validation
   _formKey.currentState!.validate();
    
  }

  void onSubmit(){

    //  Reset server errors
    _resetServerErrors();
    
    //  If local validation passed
    if( _formKey.currentState!.validate() == true ){

      //  Save inputs
      _formKey.currentState!.save();

      startSubmitLoader();
      
      if( isEditing ){

        print('locationForm');
        print(locationForm);

        //  Set the temporary location url
        final locationUrl = locationsProvider.getTemporaryLocation.links.self.href;

        locationsProvider.updateLocation(
          locationUrl: locationUrl,
          body: locationForm,
          context: context
        ).then((response){

          _handleOnSubmitResponse(response);

        }).whenComplete((){
          
          stopSubmitLoader();

        });

      }else{

        locationsProvider.createLocation(
          body: locationForm,
          context: context
        ).then((response){

          _handleOnSubmitResponse(response);

        }).whenComplete((){
          
          stopSubmitLoader();

        });

      }
    
    //  If validation failed
    }else{

      if( isEditing ){

        apiProvider.showSnackbarMessage(msg: 'Sorry, you cannot update location yet', context: context, type: SnackbarType.error);

      }else{

        apiProvider.showSnackbarMessage(msg: 'Sorry, you cannot create location yet', context: context, type: SnackbarType.error);

      }

    }

  }


  void _handleOnSubmitResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 || response.statusCode == 201 ){

      //  Navigate to the locations
      Get.back(result: 'submitted');

    }

  }

  Widget nameInput(){
    return TextFormField(
      autofocus: false,
      initialValue: locationForm['name'],
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "Location name",
        hintText: 'E.g Gaborone',
        border:OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: (value){
        if(value == null || value.isEmpty){
          return 'Please enter store name';
        }else if(serverErrors.containsKey('name')){
          return serverErrors['name'];
        }
      },
      onChanged: (value){
        locationForm['name'] = value;
      },
      onSaved: (value){
        locationForm['name'] = value;
      }
    );
  }
  
  Widget callToActionInput(){
    return TextFormField(
      autofocus: false,
      initialValue: locationForm['call_to_action'],
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "Call to action",
        hintText: 'E.g Buy Fruits',
        helperText: 'Examples: Order Food / Purchase Tickets / Buy Gifts',
        border:OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: (value){
        if(value == null || value.isEmpty){
          return 'Please enter call to action e.g Order food';
        }else if(serverErrors.containsKey('call_to_action')){
          return serverErrors['call_to_action'];
        }
      },
      onChanged: (value){
        locationForm['call_to_action'] = value;
      },
      onSaved: (value){
        locationForm['call_to_action'] = value;
      }
    );
  }

  Widget aboutUsInput(){
    return TextFormField(
      autofocus: false,
      initialValue: locationForm['about_us'],
      keyboardType: TextInputType.multiline,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: "About Us",
        hintText: 'E.g Welcome to Heavenly Fruits Gaborone mobile market. We sell local fresh fruits at affordable prices',
        border:OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: (value){
        if(value != null && value.length > 200){
          return 'The about us information is too long';
        }else if(serverErrors.containsKey('about_us')){
          return serverErrors['about_us'];
        }
      },
      onSaved: (value){
        locationForm['about_us'] = value;
      }
    );
  }

  Widget contactUsInput(){
    return TextFormField(
      autofocus: false,
      initialValue: locationForm['contact_us'],
      keyboardType: TextInputType.multiline,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: "Contact Us",
        hintText: 'Reach us on 72000123 or email care@heavenlyfruits.co.bw for direct assistance',
        border:OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: (value){
        if(value != null && value.length > 100){
          return 'The contact us information is too long';
        }else if(serverErrors.containsKey('contact_us')){
          return serverErrors['contact_us'];
        }
      },
      onSaved: (value){
        locationForm['contact_us'] = value;
      }
    );
  }

  void navigateToUpdateLocationForm({ required Widget screen }) async {

    Map arguments = {
      'locationForm': locationForm,
      'serverErrors': serverErrors,
    };
          
    //  Navigate to the screen specified to collect additional location form data
    var updatedLocationForm = await Get.to(() => screen, arguments: arguments);

    if( updatedLocationForm != null ){
      
      setState(() {
        
        //  Update the location form on return
        locationForm = updatedLocationForm;

      });

    }

  }

  Widget deliverySettingsCard(){
    return 
      CustomProceedCard(
        title: 'Delivery settings',
        subtitle: CustomSecondaryText(text: locationForm['allow_delivery'] ? 'Yes' : 'No'),
        onTap: (){
          navigateToUpdateLocationForm(screen: DeliverySettingsScreen());
        },
      );
  }

  Widget pickupSettingsCard(){
    return 
      CustomProceedCard(
        title: 'Pickup settings',
        subtitle: CustomSecondaryText(text: locationForm['allow_pickups'] ? 'Yes' : 'No'),
        onTap: (){
          navigateToUpdateLocationForm(screen: PickupSettingsScreen());
        },
      );
  }

  Widget showForm(){

    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[

            SizedBox(height: 40),
      
            nameInput(),
            SizedBox(height: 10),

            callToActionInput(),
            SizedBox(height: 20),
      
            aboutUsInput(),
            SizedBox(height: 10),

            contactUsInput(),
            SizedBox(height: 20),

            deliverySettingsCard(),
            SizedBox(height: 20),

            pickupSettingsCard(),
            SizedBox(height: 20),

            CustomButton(
              text: isEditing ? 'Save' : 'Create',
              isLoading: isSubmitting,
              onSubmit: (isSubmitting) ? null : onSubmit,
            ),

            SizedBox(height: 50),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.offAll(() => LocationsScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){}),
            ],
          ),
          Divider(),

          if(isLoadingLocation == true) SizedBox(height: 20),
          
          //  Loader
          if(isLoadingLocation == true) CustomLoader(),

          //  List of card widgets
          if(isLoadingLocation == false) Expanded(
            child: SingleChildScrollView(
              child: showForm()
            ),
          )

        ],
      ),
    );
  }
}