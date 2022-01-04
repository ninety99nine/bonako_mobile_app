import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/providers/api.dart';

import './../../../../screens/dashboard/instant_carts/list/instant_carts_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_checkmark_text.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../../components/custom_loader.dart';
import './../../../../components/custom_divider.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_button.dart';
import './../../../../providers/instant_carts.dart';
import '../../../../components/store_drawer.dart';
import '../../../../models/instantCarts.dart';
import './../../../../providers/locations.dart';
import './sections/select_products_screen.dart';
import './sections/select_coupons_screen.dart';
import './sections/offer_free_delivery.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './sections/inventory.dart';
import 'package:get/get.dart';
import 'dart:convert';

enum Activity {
  isCreating,
  isEditing
}

class CreateInstantCartScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    final hasInstantCart = Provider.of<InstantCartsProvider>(context, listen: false).hasInstantCart;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: hasInstantCart ? 'Edit Instant Cart' : 'Create Instant Cart'),
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

  //  By default we are creating an instant cart
  Activity activityType = Activity.isCreating;

  //  By default the loader is not loading
  var isSubmitting = false;

  //  By default the loader is not loading
  var isLoading = false;
  
  Map instantCartForm = {};

  Map serverErrors = {};

  ApiProvider get apiProvider {
    return Provider.of<ApiProvider>(context, listen: false);
  }

  InstantCartsProvider get instantCartProvider {
    return Provider.of<InstantCartsProvider>(context, listen: false);
  }

  LocationsProvider get locationsProvider {
    return Provider.of<LocationsProvider>(context, listen: false);
  }

  void _resetServerErrors(){
    serverErrors = {};
  }

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

  void _handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];

    /**
     *  validationErrors = {
     *    name: [Enter instant cart name]
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

        instantCartProvider.updateInstantCart(
          body: instantCartForm,
          context: context
        ).then((response){

          _handleOnSubmitResponse(response);

        }).whenComplete((){
          
          stopSubmitLoader();

        });

      }else{

        instantCartProvider.createInstantCart(
          body: instantCartForm,
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

        apiProvider.showSnackbarMessage(msg: 'Sorry, you cannot update instant cart yet', context: context, type: SnackbarType.error);

      }else{

        apiProvider.showSnackbarMessage(msg: 'Sorry, you cannot create instant cart yet', context: context, type: SnackbarType.error);

      }

    }

  }


  void _handleOnSubmitResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 || response.statusCode == 201 ){

      //  Navigate to the instant carts
      Get.back(result: 'submitted');

    }

  }

  prepareInstantCart() {

    if( isEditing ){

      //  Fetch the instant carts
      this.fetchInstantCart().then((response){

        if( response.statusCode == 200 ){
          
          //  Set the form details
          this.instantCartForm = getInstantCartForm();
        
        }

        return response;

      });

    }else{

      //  Set the form details
      this.instantCartForm = getInstantCartForm();

    }

  }

  Future<http.Response> fetchInstantCart() async {

    startLoader();

    return await instantCartProvider.fetchInstantCart(context: context).then((response){

      if( response.statusCode == 200 ){

        final responseBody = jsonDecode(response.body);

        //  Set the instant carts on the instantCartProvider
        instantCartProvider.setInstantCart(InstantCart.fromJson(responseBody as Map<String, dynamic>));

      }

      return response;

    }).whenComplete((){

      stopLoader();

    });

  }

  InstantCart get edittableInstantCart {
    return instantCartProvider.getInstantCart;
  }

  Map getInstantCartForm(){

    return {
      
      'name': isEditing ? edittableInstantCart.name : '',
      'active': isEditing ? edittableInstantCart.active.status : true,
      'description': isEditing ? edittableInstantCart.description : '',
      'descristock_quantityption': isEditing ? edittableInstantCart.stockQuantity : 10,
      'allow_stock_management': isEditing ? edittableInstantCart.allowStockManagement.status : false,
      'stock_quantity': isEditing ? edittableInstantCart.stockQuantity.value.toString() : '10',
      'allow_free_delivery': isEditing ? edittableInstantCart.allowFreeDelivery.status : false,

      'items': isEditing ? getEdittableItems() : [],
      'coupons': isEditing ? getEdittableCoupons() : [],
      
      'location_id': locationsProvider.location.id,
    };
  }

  List<Map> getEdittableItems(){
    return edittableInstantCart.embedded.cart.embedded.itemLines.map((itemLine){
      return {
        'name': itemLine.name,
        'id': itemLine.productId,
        'quantity': itemLine.quantity
      };
    }).toList();
  }

  List<Map> getEdittableCoupons(){
    return edittableInstantCart.embedded.cart.embedded.couponLines.map((couponLine){
      return {
        'id': couponLine.embedded.coupon.id,
        'name': couponLine.embedded.coupon.name
      };
    }).toList();
  }

  void setActivity(){
    
    //  If we have an instant cart set on the instantCartProvider, then we are editing
    activityType = instantCartProvider.hasInstantCart ? Activity.isEditing : Activity.isCreating;

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
    
    prepareInstantCart();

    super.initState();

  }

  Widget customDivider(String text){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: <Widget>[
            Expanded(
              child: Divider()
            ),       
            SizedBox(width: 20),
            Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(width: 20),
            Expanded(
                child: Divider()
            ),
        ]
      ),
    );
  }

  Widget customCard({ required String title, required Widget screen , Widget bottomWidget: const Text(''), bool highlight: false }){
    return Card(
      color: highlight ? Colors.blue.shade200 : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          child: InkWell(
            splashColor: Colors.blue.withOpacity(0.2),
            highlightColor: Colors.blue.withOpacity(0.2),
            onTap: () async {

              Map arguments = {
                'instantCartForm': instantCartForm,
                'serverErrors': serverErrors,
              };
                    
              //  Navigate to the screen specified to collect additional instant cart form data
              var updatedInstantCartForm = await Get.to(() => screen, arguments: arguments);

              if( updatedInstantCartForm != null ){
                
                setState(() {
                  //  Update the instant cart form on return
                  instantCartForm = updatedInstantCartForm;
                });

              }
        
            },
            child: ListTile(
              tileColor: Colors.white,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
              
                      //  Title 
                      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
              
                      //  Forward Arrow 
                      TextButton(
                        onPressed: () => {}, 
                        child: Icon(Icons.arrow_forward, color: Colors.grey,),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            )
                          )
                        ),
                      )
              
                    ],
                  ),
                  bottomWidget
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget nameInput(){
    return TextFormField(
      autofocus: false,
      initialValue: instantCartForm['name'],
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "Instant Cart Name",
        hintText: 'E.g Combo Deal',
        border:OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: (value){
        if(value == null || value.isEmpty){
          return 'Please enter instant cart name';
        }else if(serverErrors.containsKey('name')){
          return serverErrors['name'];
        }
      },
      onSaved: (value){
        instantCartForm['name'] = value;
      }
    );
  }

  Widget descriptionInput(){
    return TextFormField(
      autofocus: false,
      initialValue: instantCartForm['description'],
      keyboardType: TextInputType.multiline,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: "Description",
        hintText: 'E.g 5x(2kg Oranges), 2x(1kg Apples) and 10% discount',
        border:OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: (value){
        if(value != null && value.length > 100){
          return 'The description is too long';
        }else if(serverErrors.containsKey('description')){
          return serverErrors['description'];
        }
      },
      onSaved: (value){
        instantCartForm['description'] = value;
      }
    );
  }

  Widget separator(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text('|', style: TextStyle(color: Colors.grey),),
    );
  }

  Widget productsCard(){
    return 
      customCard(
        title: 'Products',
        screen: SelectProductsScreen(),
        highlight: (instantCartForm['items'].length > 0),
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [   

              Text(instantCartForm['items'].length > 0 ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(instantCartForm['items'].length > 0) separator(),

              if(instantCartForm['items'].length > 0) Text(instantCartForm['items'].length.toString()+' '+(instantCartForm['items'].length == 1 ? 'item': 'items'), style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
      );
  }

  Widget couponsCard(){
    return 
      customCard(
        title: 'Coupons',
        screen: SelectCouponsScreen(),
        highlight: (instantCartForm['coupons'].length > 0),
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [   

              Text(instantCartForm['coupons'].length > 0 ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(instantCartForm['coupons'].length > 0) separator(),

              if(instantCartForm['coupons'].length > 0) Text(instantCartForm['coupons'].length.toString()+' '+(instantCartForm['coupons'].length == 1 ? 'coupon': 'coupons'), style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
      );
  }

  Widget inventoryCard(){
    return 
      customCard(
        title: 'Inventory',
        screen: InstantCartInventoryScreen(),
        highlight: (instantCartForm['allow_stock_management'] == true),
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              (instantCartForm['allow_stock_management'] == true) ? CustomCheckmarkText(text: 'Allow automatic stock management') : CustomCheckmarkText(text: 'Disable stock management'),
              if(instantCartForm['allow_stock_management'] == true) CustomCheckmarkText(text: 'Available Stock: ' + instantCartForm['stock_quantity'])
            ],
          ),
        )
      );
  }

  Widget offerFreeDeliveryCard(){
    return 
      customCard(
        title: 'Offer Free Delivery',
        screen: OfferFreeDeliveryScreen(),
        highlight: instantCartForm['allow_free_delivery'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [   

              //  Offer free delivery
              Text(instantCartForm['allow_free_delivery'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
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
      
            descriptionInput(),
            SizedBox(height: 10),

            CustomDivider(text: Text('Offers'), topMargin: 20, bottomMargin: 20),
      
            productsCard(),
            SizedBox(height: 10),
      
            couponsCard(),
            SizedBox(height: 10),

            offerFreeDeliveryCard(),
            SizedBox(height: 10),

            CustomDivider(text: Text('Settings'), topMargin: 20, bottomMargin: 20),

            inventoryCard(),
            SizedBox(height: 40),

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
                Get.offAll(() => InstantCartsScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){}),
            ],
          ),
          Divider(height: 0,),

          if(isLoading == true) SizedBox(height: 20),
          
          //  Loader
          if(isLoading == true) CustomLoader(),

          //  List of card widgets
          if(isLoading == false) Expanded(
            child: SingleChildScrollView(
              child: showForm()
            ),
          )

        ],
      ),
    );
  }
}