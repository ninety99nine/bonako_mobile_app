import 'dart:convert';

import 'package:async/async.dart';
import 'package:bonako_app_3/components/custom_checkmark_text.dart';
import 'package:bonako_app_3/components/custom_loader.dart';
import 'package:bonako_app_3/components/custom_rounded_refresh_button.dart';
import 'package:bonako_app_3/screens/dashboard/products/create/sections/variations/product_variation_card.dart';
import 'package:bonako_app_3/screens/dashboard/products/create/sections/variations/variation_tag.dart';
import 'package:bonako_app_3/models/products.dart';
import 'package:bonako_app_3/providers/products.dart';
import 'package:bonako_app_3/screens/dashboard/products/create/create.dart';
import 'package:provider/provider.dart';

import '../../../../../../components/custom_back_button.dart';
import '../../../../../../components/custom_app_bar.dart';
import '../../../../../../components/custom_button.dart';
import '../../../../../../components/store_drawer.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductVariationsScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: CustomAppBar(title: 'Variations'),
      drawer: StoreDrawer(),
      body: Content(),
    );

  }
}

class Content extends StatefulWidget {
  
  //  Set the form key
  @override
  _ContentState createState() => _ContentState();
  
}

class _ContentState extends State<Content> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  List variantAttributesFormBeforeChanges = [];
  late PaginatedProducts paginatedProducts;
  bool isGeneratingVariations = false;
  List variantAttributesForm = [];
  List<Product> products = [];
  bool isLoadingMore = false;
  var cancellableOperation;
  bool isLoading = false;
  String searchWord = '';
  Map productForm = {};
  int page = 1;

  void startLoader({ loadMore: false }){
    if(mounted){
      setState(() {
        loadMore ? isLoadingMore = true : isLoading = true;
      });
    }
  }

  void stopLoader({ loadMore: false }){
    if(mounted){
      setState(() {
        loadMore ? isLoadingMore = false : isLoading = false;
      });
    }
  }

  void startGeneratingVariationsLoader(){
    if(mounted){
      setState(() {
        isGeneratingVariations = true;
      });
    }
  }

  void stopGeneratingVariationsLoader(){
    if(mounted){
      setState(() {
        isGeneratingVariations = false;
      });
    }
  }

  

  @override
  void initState() {

    ///  Clone the arguments. This is because the data passed holds a strong
    ///  reference to the same data on the previous screen. Therefore if we
    ///  mutate the arguments, then the data from the previous screen will
    ///  also be changed. To avoid this, then we must clone the arguments,
    ///  so that we can freely mutate the data while preserving the
    ///  orginal state on the previous screen.
    productForm = new Map.from(Get.arguments['productForm']);
    variantAttributesForm = getVariantAttributesForm();
    copyVariantAttributesBeforeUpdate();

    //  If the product does not already have variant attributes
    if( variantAttributesForm.length == 0 ){

      //  Add the default variable attributes
      addVariantAttribute();

    }

    fetchProductVariations();

    super.initState();

  }

  List getVariantAttributesForm() {
    //  If the variant attributes equate to null
    if( productForm['variant_attributes'] == null ){
      //  Return an empty list
      return [];
    }else{
      //  Clone the product variant attributes list
      return new List.from(productForm['variant_attributes']);
    }
  }

  void copyVariantAttributesBeforeUpdate(){
    //  Clone the variant attributes before any changes occur
    this.variantAttributesFormBeforeChanges = new List.from( variantAttributesForm );
  }

  void addVariantAttribute(){

    setState(() {

      if( variantAttributesForm.where((variantAttribute) => variantAttribute['name'] == 'Color').length == 0 ){

        variantAttributesForm.add({
          'name': 'Color',
          'values': ['Blue', 'Red'],
          'instruction': 'Select color'
        });

      }else if( variantAttributesForm.where((variantAttribute) => variantAttribute['name'] == 'Material').length == 0 ){

        variantAttributesForm.add({
          'name': 'Material',
          'values': ['Cotton', 'Nylon'],
          'instruction': 'Select material'
        });

      }else if( variantAttributesForm.where((variantAttribute) => variantAttribute['name'] == 'Size').length == 0 ){

        variantAttributesForm.add({
          'name': 'Size',
          'values': ['Small', 'Medium', 'Large'],
          'instruction': 'Select size'
        });

      }else{

        variantAttributesForm.add({
          'name': 'Weight',
          'values': ['5kg', '10kg'],
          'instruction': 'Select weight'
        });

      }

    });

  }


  void removeVariantAttribute(index) {

      //  If we have more that one variant attribute
      if( variantAttributesForm.length > 1 ){

        //  Remove the variant attribute
        if(mounted){
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Confirmation'),
                content: Flexible(child: Text("Are you sure you want to remove this variant?")),
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
                      setState(() {
                        variantAttributesForm.removeAt(index);
                        productsProvider.showSnackbarMessage('Variant removed successfully', context);
                        Navigator.of(context).pop();
                      });
                    }
                  ),
                ],
              );
            }
          );
        }

      }else{
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Container(
                margin: EdgeInsets.only(top: 10),
                child: Flexible(child: Text("You must have atleast one variant"))
              ),
              actions: [
                //  Ok Button
                TextButton(
                  child: Text("Ok"),
                  onPressed: () { 
                    Navigator.of(context).pop();
                  }
                ),
              ],
            );
          }
        );

      }
  }

  ProductsProvider get productsProvider {
    return Provider.of<ProductsProvider>(context, listen: false);
  }

  Future<http.Response> fetchProductVariations({ String searchWord: '', bool loadMore = false, bool resetPage = false, int limit = 10 }) async {
    
    startLoader(loadMore: loadMore);

    //  If we have a cancellable operation of fetching products
    if(cancellableOperation != null){
      
      //  Cancel the request of fetching products
      (cancellableOperation as CancelableOperation).cancel();

    }

    //  If we should load more  
    if(loadMore){

      //  Increment the page to target the next page content
      page++;

    }

    //  If we should load more  
    if(resetPage){

      //  Set to target thr first page content
      page = 1;

    }

    cancellableOperation = CancelableOperation.fromFuture (
      
      //  Future API call
      productsProvider.fetchProductVariations(searchWord: searchWord, page: page, limit: limit, context: context),
      
      //  On cancel callback
      onCancel: (){
        cancellableOperation = null;
      }

    );
    
    cancellableOperation.value.then((http.Response response){

      if(response.statusCode == 200){

        final responseBody = jsonDecode(response.body);

        if(mounted){

          setState(() {

            //  If we are loading more products
            if(loadMore == true){

              //  Add loaded products to the list of existing paginated products
              paginatedProducts.embedded.products.addAll(PaginatedProducts.fromJson(responseBody).embedded.products);

              //  Re-calculate the product count
              paginatedProducts.count += PaginatedProducts.fromJson(responseBody).count;

              //  Increment the current page
              paginatedProducts.currentPage = page;

            }else{

              paginatedProducts = PaginatedProducts.fromJson(responseBody);

            }

          });

        }

      }

      return response;

    });
    
    cancellableOperation.value.whenComplete(() {

      stopLoader(loadMore: loadMore);

    });

    return cancellableOperation.value;

  }

  Future<http.Response> generateProductVariations() async {

    startGeneratingVariationsLoader();

    productsProvider.generateProductVariations(body: variantAttributesForm, context: context)
      .then((http.Response response){

        if(response.statusCode == 200){
          
          fetchProductVariations();

        }

        return response;

      }).whenComplete(() {

        stopGeneratingVariationsLoader();

      });

    return cancellableOperation.value;

  }
  
  String capitalize(String string) {
    if (string.isEmpty) {
      return string;
    }

    return string[0].toUpperCase() + string.substring(1);
  }

  bool get hasProducts {
    return (products.length > 0);
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
              //  Pass the un-editted ProductForm as the argument
              CustomBackButton()
            ],
          ),

          Divider(height: 0),

          //  Form
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    
                    //  Variant Attributes Container
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(5),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

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

                          Divider(height: 20,),
                          
                          CustomCheckmarkText(text: (productForm['allow_variants'] == true) ? 'Allow different variations for this product' : 'Disable variations for this product'),

                          Divider(height: 20,),
                          
                          //  Variant Attributes Setting e.g Color, Material, Size
                          ...variantAttributesForm.mapIndexed((index, attribute){
                            final number = (index + 1).toString();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                //  Variation number
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Variation # '+ number, style: TextStyle(fontWeight: FontWeight.bold),),
                                    GestureDetector(
                                      onTap: () => removeVariantAttribute(index),
                                      child: Icon(Icons.delete_outline_outlined, color: Colors.red,)
                                    )
                                  ],
                                ),

                                SizedBox(height: 20),

                                //  Variation instruction
                                TextFormField(
                                  initialValue: variantAttributesForm[index]['name'],
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: "Name",
                                    hintText: 'E.g Color',
                                    border:OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value){
                                    if(value == null || value.isEmpty){
                                      return 'Please enter the variation name';
                                    }
                                  },
                                  onChanged: (value){
                                    setState(() {
                                      variantAttributesForm[index]['name'] = value;
                                    });
                                  }
                                ),

                                SizedBox(height: 10),

                                //  Variation instruction
                                TextFormField(
                                  initialValue: variantAttributesForm[index]['instruction'],
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: "Instruction",
                                    hintText: 'E.g Select color',
                                    border:OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                  validator: (value){
                                    if(value == null || value == ''){
                                      return 'Please enter the variation instruction';
                                    }
                                  },
                                  onChanged: (value){
                                    setState(() {
                                      variantAttributesForm[index]['instruction'] = value;
                                    });
                                  }
                                ),

                                SizedBox(height: 10),


                                TextFieldTags(
                                  initialTags: (variantAttributesForm[index]['values'] as List).map((value) => value.toString()).toList(),
                                  textFieldStyler: TextFieldStyler(
                                    icon: Icon(Icons.sell_outlined),
                                    hintText: 'Red, Blue, Green',
                                    helperText: 'Enter options e.g Red, Blue, Green',
                                  ),
                                  tagsStyler: TagsStyler(
                                    showHashtag: false,
                                    tagMargin: const EdgeInsets.symmetric(horizontal: 2.0),
                                    tagDecoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                    ),
                                    tagPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                                    tagCancelIcon: const Icon(Icons.cancel, size: 14.0, color: Colors.white, ),
                                    tagTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  onTag: (tag) {
                                    setState(() {
                                      (variantAttributesForm[index]['values'] as List).add(capitalize(tag.trim()));
                                    });
                                  },
                                  onDelete: (tag){
                                    setState(() {
                                      (variantAttributesForm[index]['values'] as List).removeWhere((currentTag){
                                        return (currentTag.toLowerCase() == tag.toLowerCase());
                                      });
                                    });
                                  },
                                  validator: (tag){
                                    if( tag.length > 30 ){
                                      return "Tag is too long";
                                    }
                                    return null;
                                  },

                                  //tagsDistanceFromBorderEnd: 0.725,
                                  //scrollableTagsMargin: EdgeInsets.only(left: 9),
                                  //scrollableTagsPadding: EdgeInsets.only(left: 9),
                                ),

                                ((index + 1) < variantAttributesForm.length) ? Divider(height: 40) : SizedBox(height: 20)

                              ],
                            );
                          }).toList(),

                          Divider(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: CustomButton(
                                  color: ( !isGeneratingVariations && !isLoading ) ? Colors.green : Colors.grey,
                                  solidColor: ( !isGeneratingVariations && !isLoading ) ? false : true,
                                  text: '+ Add Variation',
                                  size: 'small',
                                  width: 130,
                                  onSubmit: () {
                                    if( !isGeneratingVariations && !isLoading ){
                                      addVariantAttribute();
                                    }
                                  },
                                ),
                              ),
                              Flexible(
                                child: CustomButton(
                                  color: ( !isGeneratingVariations && !isLoading ) ? Colors.blue : Colors.grey,
                                  solidColor: ( !isGeneratingVariations && !isLoading ) ? false : true,
                                  text: 'Create Variations',
                                  size: 'small',
                                  onSubmit: () {
                                    if( !isGeneratingVariations && !isLoading ){
                                      generateProductVariations();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          Divider(height: 30),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Variations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              CustomRoundedRefreshButton(onPressed: (){
                                fetchProductVariations();
                              })
                            ],
                          ),
                          Divider(height: 30),

                          if(isLoading == true || isGeneratingVariations == true) CustomLoader(),

                          //  Product Variation list
                          if(isLoading == false && isGeneratingVariations == false)
                            ProductVariationList(
                              paginatedProducts: paginatedProducts,
                              fetchVariations: fetchProductVariations,
                              isLoadingMore: isLoadingMore,
                              searchWord: searchWord,
                            ),
                          
                          Divider(height: 50),
                          
                        ],
                      ),
                    ),

                  ],
                ),
              )
            ),
          )
        ],
      ),
    );
    
  }
}

class ProductVariationList extends StatelessWidget {
  final PaginatedProducts paginatedProducts;
  final Function fetchVariations;
  final bool isLoadingMore;
  final searchWord;

  ProductVariationList({ 
    required this.paginatedProducts, required this.fetchVariations, 
    required this.isLoadingMore, required this.searchWord
  });

  List<Product> get products {
    return paginatedProducts.embedded.products;
  }

  Widget buildProductListView(List<Product> products){

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: products.length,
      shrinkWrap: true,
      itemBuilder: (ctx, index){
        return ProductVariationCard(
          product: products[index], 
          fetchVariations: fetchVariations
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {

    return 
      Column(
        children: [
          buildProductListView(products),
          SizedBox(height: 20),
          if(paginatedProducts.count < paginatedProducts.total && isLoadingMore == true) CustomLoader(),
          if(paginatedProducts.count == paginatedProducts.total && isLoadingMore == false) Text('No more variations'),
          SizedBox(height: 60),
        ],
      );

  }
}

