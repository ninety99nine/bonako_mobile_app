import './../components/custom_scaffold_dialog.dart';
import './../components/custom_search_bar.dart';
import './../components/custom_checkbox.dart';
import './../components/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../providers/products.dart';
import './../models/products.dart';
import 'dart:convert';

class CustomMultiProductSelector extends StatefulWidget {

  final String buttonText;
  final Function(List<Product>) onSelected;
  final List<int> selectedProductIds;

  CustomMultiProductSelector({ this.buttonText = 'Select Products', this.selectedProductIds = const [], required this.onSelected });

  @override
  _CustomMultiProductSelectorState createState() => _CustomMultiProductSelectorState();

}

class _CustomMultiProductSelectorState extends State<CustomMultiProductSelector> {

  @override
  void initState() {

    super.initState();

  }

  bool get hasSelectedProducts {
    return widget.selectedProductIds.length > 0;
  }

  @override
  Widget build(BuildContext context) {

    return CustomButton(
      size: 'small',
      text: widget.buttonText,
      ripple: (hasSelectedProducts == false),
      onSubmit: (){
        showSelectItemsDialog(
          selectedProductIds: widget.selectedProductIds,
          onSelected: widget.onSelected,
          context: context);
      }
    );

  }

  void showSelectItemsDialog({ required List<int> selectedProductIds, required void Function(List<Product>) onSelected, required BuildContext context }) async {

    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation){
        
        late PaginatedProducts paginatedProducts;
        List<Product> currSelectedProducts = [];
        bool fetchedInitialProducts = false;
        List<Product> products = [];
        bool isSearching = false;

        void addProductId(Product product){
          currSelectedProducts.add(product);
        }
        
        void removeProductId(Product product){
          currSelectedProducts.removeWhere((currSelectedProduct) => currSelectedProduct.id == product.id);
          selectedProductIds.removeWhere((selectedProductId) => selectedProductId == product.id);
        }

        return StatefulBuilder(
          builder: (context, setState) {

            void startSearchingLoader(){
              setState((){
                isSearching = true;
              });
            }

            void stopSearchingLoader(){
              setState((){
                isSearching = false;
              });
            }

            Future<http.Response> searchProducts({ searchWord: '' }){

              startSearchingLoader();

              final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
              
              return productsProvider.fetchProducts(searchWord: searchWord, context: context)
                .then((http.Response response){
  
                  if(response.statusCode == 200){

                    final responseBody = jsonDecode(response.body);

                    setState(() {

                      paginatedProducts = PaginatedProducts.fromJson(responseBody);
                      products = paginatedProducts.embedded.products;

                    });

                  }

                  return response;

                }).whenComplete((){

                  fetchedInitialProducts = true;
                  
                  stopSearchingLoader();

                });

            }

            //  Fetch the products as soon as this dialog is launched
            if(fetchedInitialProducts == false) searchProducts();

            return CustomScaffoldDialog(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Search Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                  ),
                  SizedBox(height: 20),

                  //  Search bar
                  CustomSearchBar(
                    labelText: 'Search products',
                    onSearch: (searchWord){
                      return searchProducts(searchWord: searchWord);
                    }
                  ),
                  Expanded(
                    child: Container(
                    child: Column(
                      children: [

                        //  Loader
                        if(isSearching == true) Expanded(child: Center(child: Container(width:20, height:20, margin: EdgeInsets.only(right: 10), child: CircularProgressIndicator(strokeWidth: 3)))),
                        
                        //  Divider
                        if(isSearching == false) Divider(),

                        //  Products
                        if(isSearching == false && products.length > 0) ...products.map((product){

                          final isChecked = (selectedProductIds.contains(product.id) || currSelectedProducts.map((currSelectedProduct) => currSelectedProduct.id).contains(product.id));

                          return CustomCheckbox(
                            value: isChecked,
                            text: product.name,
                            onChanged: selectedProductIds.contains(product.id) ? null : (value) {
                              if(value != null){
                                setState(() {
                                  if(value == true){
                                    addProductId(product);
                                  }else{
                                    removeProductId(product);
                                  }
                                });
                              }
                            }
                          );

                        }).toList(),

                        //  No products
                        if(isSearching == false && products.length == 0) Container(
                          margin: EdgeInsets.only(top: 50),
                          child: Text('No products found')
                        )
                      ],
                    ),
                  )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      //  Cancel Button
                      Container(
                        margin: EdgeInsets.only(right: 20),
                        child: TextButton(
                          child: Text("Cancel", style: Theme.of(context).textTheme.bodyText1),
                          onPressed: () {

                            //  Remove the alert dialog
                            Navigator.of(context).pop(false);

                          }
                        )
                      ),

                      //  Delete Button
                      if(!isSearching) TextButton(
                        child: Text(currSelectedProducts.length > 0 ? 'Add ('+currSelectedProducts.length.toString()+')' : 'Done', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: (){
                          
                          //  Pass the selected product ids
                          onSelected(currSelectedProducts);

                          //  Remove the alert dialog
                          Navigator.of(context).pop(false);

                        }
                      ),

                    ]
                  )
                ],
              )
            );
          }
        );
      },
    );

  }
}