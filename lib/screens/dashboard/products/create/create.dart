import 'package:bonako_app_3/screens/dashboard/products/create/sections/variations/variations.dart';

import './../../../../screens/dashboard/products/create/sections/quantities.dart';
import './../../../../screens/dashboard/products/create/sections/inventory.dart';
import './../../../../screens/dashboard/products/create/sections/locations.dart';
import './../../../../screens/dashboard/products/create/sections/settings.dart';
import './../../../../screens/dashboard/products/create/sections/tracking.dart';
import './../../../../screens/dashboard/products/create/sections/pricing.dart';
import './../../../../screens/dashboard/products/list/products_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../../components/custom_loader.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_button.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/locations.dart';
import './../../../../providers/products.dart';
import './../../../../models/products.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

class CreateProductScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    final hasProduct = Provider.of<ProductsProvider>(context, listen: false).hasProduct;

    return Scaffold(
      appBar: CustomAppBar(title: hasProduct ? 'Edit Product' : 'Create Product'),
      drawer: StoreDrawer(),
      body: Content(),
    );
  }
}

enum Activity {
  isCreating,
  isEditing
}

class Content extends StatefulWidget {

  @override
  _ContentState createState() => _ContentState();

}

class _ContentState extends State<Content> {
  
  //  Set the form key
  final GlobalKey<FormState> _formKey = GlobalKey();

  //  By default we are creating a product
  Activity activityType = Activity.isCreating;

  //  By default the loader is not loading
  var isSubmitting = false;

  //  By default the loader is not loading
  var isLoadingProduct = false;

  //  By default the loader is not loading
  var isLoadingLocations = false;
  
  Map productForm = {};

  List locationIds = [];

  Map serverErrors = {
    'name': '',
    'description': '',
    'unit_regular_price': '',
    'unit_sale_price': '',
    'unit_cost': '',
    'maximum_quantity_per_order': '',
    'stock_quantity': '',
  };

  ProductsProvider get productsProvider {
    return Provider.of<ProductsProvider>(context, listen: false);
  }

  LocationsProvider get locationsProvider {
    return Provider.of<LocationsProvider>(context, listen: false);
  }

  void _resetServerErrors(){
    serverErrors = {
    'name': '',
    'description': '',
    'unit_regular_price': '',
    'unit_sale_price': '',
    'unit_cost': '',
    'maximum_quantity_per_order': '',
    'stock_quantity': '',
    };
  }

  void startProductLoader(){
    setState(() {
      isLoadingProduct = true;
    });
  }

  void stopProductLoader(){
    setState(() {
      isLoadingProduct = false;
    });
  }

  void startLocationsLoader(){
    setState(() {
      isLoadingLocations = true;
    });
  }

  void stopLocationsLoader(){
    setState(() {
      isLoadingLocations = false;
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
     *    name: [Enter product name]
     *  }
     */
    validationErrors.forEach((key, value){
      if( serverErrors.containsKey(key) ){
        serverErrors[key] = value[0];
      }
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

        productsProvider.updateProduct(
          body: productForm,
          context: context
        ).then((response){

          if( response.statusCode == 200 ){

            showSnackbarMessage('Product saved successfully');

          }

          _handleOnSubmitResponse(response);

        }).whenComplete((){
          
          stopSubmitLoader();

        });

      }else{

        productsProvider.createProduct(
          body: productForm,
          context: context
        ).then((response){

          if( response.statusCode == 200 ){
          
            showSnackbarMessage('Product created successfully');

          }

          _handleOnSubmitResponse(response);

        }).whenComplete((){
          
          stopSubmitLoader();

        });

      }
    
    //  If validation failed
    }else{

      showSnackbarMessage(isEditing ? 'Sorry, you cannot update product yet' : 'Sorry, you cannot create product yet');

    }

  }


  void _handleOnSubmitResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 ){

      //  Navigate to the products
      Get.back(result: 'submitted');

    }

  }

  void showSnackbarMessage(String msg){

    //  Set snackbar content
    final snackBar = SnackBar(content: Text(msg, textAlign: TextAlign.center));

    //  Show snackbar  
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }

  prepareProduct() {

    if( isEditing ){

      //  Fetch the product
      this.fetchProduct().then((response){

        if( response.statusCode == 200 ){
          
          //  Set the form details
          this.productForm = getProductForm();

          //  If this product is not a variation
          if( !productsProvider.isVariationProduct ){

            //  Fetch the product locations
            this.fetchProductLocations();

          }
        
        }

        return response;

      });

    }else{

      //  Set the form details
      this.productForm = getProductForm();

    }

  }

  Future<http.Response> fetchProduct() async {

    startProductLoader();

    return await productsProvider.fetchProduct(context: context).then((response){

      if( response.statusCode == 200 ){

        final responseBody = jsonDecode(response.body);

        //  Set the product on the productsProvider
        productsProvider.setProduct(Product.fromJson(responseBody as Map<String, dynamic>));

      }

      return response;

    }).whenComplete((){

      stopProductLoader();

    });

  }

  Future<http.Response> fetchProductLocations() async {

    startLocationsLoader();

    return await productsProvider.fetchProductLocations(context: context).then((response){

      print('fetchProductLocations');

      if( response.statusCode == 200 ){

        final responseBody = jsonDecode(response.body);
        final locations = (responseBody['_embedded']['locations']);

        locations.forEach((location) => productForm['location_ids'].add(location['id']));

        //  Set the product locations on the productsProvider
        //  final productLocations = Product.fromJson(response);

        /*

        //  Stop loader
        self.isLoadingLocations = false;

        if( self.productForm ){

            //  Set the locations
            self.productForm.location_ids = ((data || [])['_embedded'] || [])['locations'].map((location) => {
                return location.id
            });

        }else{

            //  Get the locations
            self.location_ids = ((data || [])['_embedded'] || [])['locations'].map((location) => {
                return location.id
            });

        }
        */

      }

      return response;

    }).whenComplete((){

      stopLocationsLoader();

    });
        
  }

  Map getProductForm(){

    return {

      //  Product Management
      'name': isEditing ? productsProvider.product.name : '',
      'description': isEditing ? productsProvider.product.description : '',
      'show_description': isEditing ? productsProvider.product.showDescription.status : false,
      'sku' : isEditing ? productsProvider.product.sku : '',
      'barcode': isEditing ? productsProvider.product.barcode : '',
      'visible': isEditing ? productsProvider.product.visible.status : true,
      'location_ids': [locationsProvider.location.id],
      'product_type_id': isEditing ? productsProvider.product.productTypeId : 1,

      //  Variation Management
      'allow_variants': isEditing ? productsProvider.product.allowVariants.status : false,
      'variant_attributes': isEditing ? productsProvider.product.variantAttributes : [],

      //  Pricing Management
      'is_free': isEditing ? productsProvider.product.isFree.status : false,
      'currency': isEditing ? productsProvider.product.currency.code : 'BWP',
      'unit_regular_price': isEditing ? productsProvider.product.unitRegularPrice.amount.toString() : '0.00',
      'unit_sale_price': isEditing ? productsProvider.product.unitSalePrice.amount.toString() : '0.00',
      'unit_cost': isEditing ? productsProvider.product.unitCost.amount.toString() : '0.00',

      //  Quantity Management
      'allow_multiple_quantity_per_order': isEditing ? productsProvider.product.allowMultipleQuantityPerOrder.status : true,
      'allow_maximum_quantity_per_order': isEditing ? productsProvider.product.allowMaximumQuantityPerOrder.status : false,
      'maximum_quantity_per_order': isEditing ? productsProvider.product.maximumQuantityPerOrder.toString() : '5',

      //  Stock Management
      'allow_stock_management': isEditing ? productsProvider.product.allowStockManagement.status : false,
      'auto_manage_stock': isEditing ? productsProvider.product.autoManageStock.status : true,
      'stock_quantity': isEditing ? productsProvider.product.stockQuantity.value.toString() : '10',

    };
  }

  void setActivity(){
    
    //  If we have a product set on the productsProvider, then we are editing
    activityType = productsProvider.hasProduct ? Activity.isEditing : Activity.isCreating;

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
    
    prepareProduct();

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

  Widget customCard({ required String title, required Widget screen , Widget bottomWidget: const Text('') }){
    return Card(
      child: Container(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          child: InkWell(
            splashColor: Colors.blue.withOpacity(0.2),
            highlightColor: Colors.blue.withOpacity(0.2),
            onTap: () async {

              Map arguments = {
                'productForm': productForm,
                'serverErrors': serverErrors,
              };

              print('arguments');
              print(arguments);
                    
              //  Navigate to the screen specified to collect additional product form data
              var updatedProductForm = await Get.to(() => screen, arguments: arguments);

              if( updatedProductForm != null ){

                print('updatedProductForm');
                print(updatedProductForm);
                
                setState(() {
                  //  Update the product form on return
                  productForm = updatedProductForm;
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
                      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              
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

  Widget checkmarkText(String text){
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_outlined, color: Colors.green, size: 12),
          SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 12),)
        ],
      ),
    );
  }

  bool empty(text){
    return (text == '' || text == null);
  }

  bool notEmpty(text){
    return (text != '' && text != null);
  }

  bool get isFree {
    return productForm['is_free'];
  }

  bool get hasPrice {
    return (notEmpty(productForm['unit_regular_price']) && (double.parse(productForm['unit_regular_price']) > 0) && isFree == false);
  }

  bool get allowVariants {
    return (productForm['allow_variants']);
  }

  Widget showForm(){

    String getLocationCurrencySymbol = Provider.of<LocationsProvider>(context, listen: false).getLocationCurrencySymbol;

    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[

            SizedBox(height: 10),

            Row(
              children: [
                Text('Visible'),
                Switch(
                  activeColor: Colors.green,
                  value: productForm['visible'], 
                  onChanged: (status){
                    setState(() {
                      productForm['visible'] = status;
                    });
                  }
                ),
                if(productForm['visible'] == false) Text('This product is hidden', style: TextStyle(color: Colors.orange),),
              ],
            ),

            Row(
              children: [
                Text('Allow Variations'),
                Switch(
                  activeColor: Colors.green,
                  value: productForm['allow_variants'], 
                  onChanged: (status){
                    setState(() {
                      productForm['allow_variants'] = status;
                    });
                  }
                ),
              ],
            ),
      
            TextFormField(
              initialValue: productForm['name'],
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Name",
                hintText: 'E.g Rice and chicken',
                border:OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              validator: (value){
                if(value == null){
                  return 'Please enter product name';
                }else if(serverErrors['name'] != ''){
                  return serverErrors['name'];
                }
              },
              onSaved: (value){
                productForm['name'] = value;
              }
            ),

            Row(
              children: [
                Text('Show description to customer'),
                Switch(
                  activeColor: Colors.green,
                  value: productForm['show_description'], 
                  onChanged: (status){
                    setState(() {
                      productForm['show_description'] = status;
                    });
                  }
                ),
              ],
            ),
      
            if(productForm['show_description']) TextFormField(
              initialValue: productForm['description'],
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: 'E.g Served with salad and 330ml coke',
                border:OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              validator: (value){
                if(value == null){
                  return 'Please enter product description';
                }else if(serverErrors['description'] != ''){
                  return serverErrors['description'];
                }
              },
              onSaved: (value){
                productForm['description'] = value;
              }
            ),

            if(productForm['show_description']) SizedBox(height: 10),

            Divider(height: 20),

            if(allowVariants == false) customCard(
              title: 'Pricing',
              screen: ProductPricingScreen(),
              bottomWidget: Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [   

                    //  Is Free
                    if(isFree) Text('Free product', style: TextStyle(fontSize: 12, color: Colors.green),),

                    //  No price
                    if(hasPrice == false && isFree == false) Text('No price', style: TextStyle(fontSize: 12, color: Colors.red),),

                    //  Regular price
                    if(hasPrice == true && notEmpty(productForm['unit_regular_price'])) Row(children: [Text('Price: ', style: TextStyle(fontSize: 12, color: Colors.grey),), Text(getLocationCurrencySymbol + productForm['unit_regular_price'], style: TextStyle(fontSize: 12),)],),
                    
                    //  Divider
                    if(isFree == false &&  notEmpty(productForm['unit_regular_price']) && notEmpty(productForm['unit_sale_price'])) Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text('|', style: TextStyle(color: Colors.grey),),
                    ),

                    //  Sale price
                    if(isFree == false && notEmpty(productForm['unit_sale_price'])) Row(children: [Text('Sale: ', style: TextStyle(fontSize: 12, color: Colors.grey),), Text(getLocationCurrencySymbol + productForm['unit_sale_price'], style: TextStyle(fontSize: 12),)],),//  Divider
                    
                    //  Divider
                    if(isFree == false &&  notEmpty(productForm['unit_sale_price']) && notEmpty(productForm['unit_cost'])) Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text('|', style: TextStyle(color: Colors.grey),),
                    ),

                    //  Cost price
                    if(isFree == false && notEmpty(productForm['unit_cost'])) Row(children: [Text('Cost: ', style: TextStyle(fontSize: 12, color: Colors.grey),), Text(getLocationCurrencySymbol + productForm['unit_cost'], style: TextStyle(fontSize: 12),)],),

                  ],
                ),
              )
            ),

            if(allowVariants == false) customCard(
              title: 'Quantities',
              screen: ProductQuantitiesScreen(),
              bottomWidget: Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    if(productForm['allow_multiple_quantity_per_order'] == false) checkmarkText('Allow only 1 quantity per order'),
                    if(productForm['allow_multiple_quantity_per_order'] == true && productForm['allow_maximum_quantity_per_order'] == false) checkmarkText('Allow more than 1 quantity per order'),
                    if(productForm['allow_multiple_quantity_per_order'] == true && productForm['allow_maximum_quantity_per_order'] == true) checkmarkText('Allow between 1 and '+productForm['maximum_quantity_per_order']+' quantities per order')
                  ],
                ),
              )
            ),

            if(allowVariants == false) customCard(
              title: 'Inventory',
              screen: ProductInventoryScreen(),
              bottomWidget: Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Column(
                  children: [
                    (productForm['allow_stock_management'] == true) ? checkmarkText('Allow '+(productForm['auto_manage_stock'] ? 'automatic' : 'manual')+' stock management') : checkmarkText('Disable stock management'),
                    if(productForm['allow_stock_management'] == true) checkmarkText('Available Stock: ' + productForm['stock_quantity']),
                    if(productForm['allow_multiple_quantity_per_order'] == true && productForm['allow_maximum_quantity_per_order'] == true) checkmarkText('Allow between 1 and '+productForm['maximum_quantity_per_order']+' quantities per order')
                  ],
                ),
              )
            ),

            if(allowVariants == false) customCard(
              title: 'Tracking',
              screen: ProductTrackingScreen(),
              bottomWidget: Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    if(notEmpty(productForm['barcode'])) Row(children: [Text('Barcode: ', style: TextStyle(fontSize: 12, color: Colors.grey),), Text(productForm['barcode'], style: TextStyle(fontSize: 12),)],),
                    if(notEmpty(productForm['barcode']) && notEmpty(productForm['sku'])) Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text('|', style: TextStyle(color: Colors.grey),),
                    ),
                    if(notEmpty(productForm['sku'])) Row(children: [Text('SKU: ', style: TextStyle(fontSize: 12, color: Colors.grey),), Text(productForm['sku'], style: TextStyle(fontSize: 12),)],),
                    if(empty(productForm['barcode']) && empty(productForm['sku'])) Text('NONE', style: TextStyle(fontSize: 12, color: Colors.grey),),
                  ],
                ),
              )
            ),

            customCard(
              title: 'Variations',
              screen: ProductVariationsScreen(),
              bottomWidget: Container(
                margin: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    (productForm['allow_variants']) ? checkmarkText('Allow variations') : Text('NONE', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              )
            ),

            customCard(
              title: 'Locations',
              screen: ProductLocationsScreen()
            ),

            if(isEditing) customCard(
              title: 'Settings',
              screen: ProductSettingsScreen()
            ),

            Divider(height: 20),

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
                Get.off(() => ProductsScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){}),
            ],
          ),
          Divider(height: 0,),

          if(isLoadingProduct == true) SizedBox(height: 20),
          
          //  Loader
          if(isLoadingProduct == true) CustomLoader(),

          //  List of card widgets
          if(isLoadingProduct == false) Expanded(
            child: SingleChildScrollView(
              child: showForm()
            ),
          )

        ],
      ),
    );
  }
}