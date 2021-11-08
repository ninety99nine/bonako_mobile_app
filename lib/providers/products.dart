import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import './../screens/dashboard/products/create/create.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../providers/locations.dart';
import './../providers/stores.dart';
import './../models/locations.dart';
import './../models/products.dart';
import './../providers/auth.dart';
import './../providers/api.dart';
import 'package:get/get.dart';

class ProductsProvider with ChangeNotifier{

  var product;
  LocationsProvider locationsProvider;

  ProductsProvider({ required this.locationsProvider });
  
  Future<http.Response> fetchProducts({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = productsUrl+'?page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('productFilters') ?? '{}');

      final activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

      //  If we have any active filters
      if( activeFilters.length > 0){

        //  Add filters to Url string
        url = url + '&status=' + activeFilters.keys.map((filterKey) {

            /**
             * filterKey: onSale / notOnSale / outOfStock / limitedStock / unlimitedStock
             */
            final Map<String, String> urlFilters = {
              'onSale': 'On sale',
              'notOnSale': 'Not on sale',
              'outOfStock': 'Out Of Stock',
              'limitedStock': 'Limited stock',
              'unlimitedStock': 'Unlimited stock',
            };

            return urlFilters[filterKey];

        }).join(',');

      }

    });

    return apiProvider.get(url: url, context: context);
    
  }
  
  Future<http.Response> fetchProduct({ required BuildContext context }){

    return apiProvider.get(url: productUrl, context: context);
    
  }
  
  Future<http.Response> createProduct({ required Map body, required BuildContext context }){

    return apiProvider.post(url: createProductUrl, body: body, context: context).then((response){

        if( response.statusCode == 200 ){

          locationsProvider.fetchLocationTotals(context: context);

        }

        return response;

      });
    
  }
  
  Future<http.Response> updateProduct({ required Map body, required BuildContext context }){

    return apiProvider.put(url: productUrl, body: body, context: context);
    
  }
  
  Future<http.Response> deleteProduct({ required BuildContext context }){

    return apiProvider.delete(url: productUrl, context: context).then((response){

        if( response.statusCode == 200 ){

          locationsProvider.fetchLocationTotals(context: context);

        }

        return response;

      });
    
  }
  
  Future<http.Response> updateProductArrangement({ required List<Product> products, required BuildContext context }){

    final List<Map<String, int>> productArrangements = products.map((product) {

      var arrangement = products.indexOf(product) + 1;

      return {
        'id': product.id,
        'arrangement': arrangement
      };

    }).toList();

    final body = {
      'location_id': (locationsProvider.location as Location).id,
      'product_arrangements': productArrangements,
    };

    return apiProvider.post(url: productArrangementUrl, body: body, context: context).then((response){

        if( response.statusCode == 200 ){

          showSnackbarMessage('Arrangement saved successfully', context);

        }else{

          showSnackbarMessage('Arrangement Failed', context);

        }

        return response;

      });
    
  }
  
  Future<http.Response> fetchProductLocations({ required BuildContext context }){

    return apiProvider.get(url: productLocationsUrl, context: context);
    
  }
  
  Future<http.Response> fetchProductVariations({ String searchWord: '', int page = 1, int limit: 10, required BuildContext context }) async {

    var url = productVariationsUrl+'?page='+page.toString()+'&limit='+limit.toString()+(searchWord == '' ? '':  '&search='+searchWord);

    return apiProvider.get(url: url, context: context);
    
  }
  
  Future<http.Response> generateProductVariations({ required body, required BuildContext context }) async {

    return apiProvider.post(url: productVariationsUrl, body: body, context: context);
    
  }

  handleDeleteProduct({ required Product product, required BuildContext context }) async {
    
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (context, setState) {

            void startLoader(){
              setState((){
                isDeleting = true;
              });
            }

            void stopLoader(){
              setState((){
                isDeleting = false;
              });
            }

            Future<http.Response> onDelete(){
              
              startLoader();

              this.setProduct(product);

              return this.deleteProduct(
                context: context
              ).then((response){

                if( response.statusCode == 200 ){

                  showSnackbarMessage('Product deleted successfully', context);

                }else{

                  showSnackbarMessage('Delete Failed', context);

                }

                return response;

              }).whenComplete((){

                stopLoader();
                
                //  Remove the alert dialog and return True as final value
                Navigator.of(context).pop(true);

              });

            }

            return AlertDialog(
              title: Text('Confirmation'),
              content: Row(
                children: [
                  if(isDeleting) Container(height:20, width:20, margin: EdgeInsets.only(right: 10), child: CircularProgressIndicator(strokeWidth: 3,)),
                  if(isDeleting) Text("Deleting product..."),
                  if(!isDeleting) Flexible(child: Text("Are you sure you want to delete ${product.name}?")),
                ],
              ),
              actions: [

                //  Cancel Button
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () { 
                    //  Remove the alert dialog and return False as final value
                    Navigator.of(context).pop(false);
                  }
                ),

                //  Delete Button
                if(!isDeleting) TextButton(
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: (){
                    onDelete();
                  }
                ),
              ],
              
            );
          }
        );
      },
    );

  }

  void showSnackbarMessage(String msg, BuildContext context){

    //  Set snackbar content
    final snackBar = SnackBar(content: Text(msg, textAlign: TextAlign.center));

    //  Show snackbar  
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }

  String get productsUrl {
    return locationsProvider.getLocation.links.bosProducts.href;
  }

  String get productUrl {
    return (product as Product).links.self.href;
  }
  
  String get productArrangementUrl {
      return (this.locationsProvider.location as Location).links.bosProductArrangement.href;
  }

  String get createProductUrl {
    return apiProvider.apiHome['_links']['bos:products']['href'];
  }

  String get productLocationsUrl {
    return (product as Product).links.bosLocations.href;
  }

  String get productVariationsUrl {
    return (product as Product).links.bosVariations.href;
  }

  void setProduct(Product product){
    this. product = product;
  }

  void unsetProduct(){
    this. product = null;
  }

  Future navigateToAddProduct() async {

    this.unsetProduct();
    
    return await Get.to(() => CreateProductScreen());
    
  }

  Product get getProduct {
    return product;
  }

  bool get hasProduct {
    return product == null ? false : true;
  }

  bool get isVariationProduct {
      if( product == null ){
        return false;
      }else{
        return (product as Product).parentProductId == null ? false : true;
      }
  }

  StoresProvider get storesProvider {
    return locationsProvider.storesProvider;
  }

  AuthProvider get authProvider {
    return storesProvider.authProvider;
  }

  ApiProvider get apiProvider {
    return authProvider.apiProvider;
  }

}