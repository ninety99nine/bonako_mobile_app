import 'package:bonako_app_3/components/custom_instruction_message.dart';

import './../../../../screens/dashboard/stores/show/store_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_floating_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_search_bar.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_button.dart';
import './../../../../components/custom_loader.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/products.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../products/create/create.dart';
import './../../../../providers/stores.dart';
import './../../../../models/products.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'dart:convert';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool isLoadingMore = false;
  var cancellableOperation;
  bool isLoading = false;
  var paginatedProducts;
  int currentPage = 1;

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

  @override
  void initState() {
    
    fetchProducts();

    super.initState();

  }

  Future<http.Response> fetchProducts({ String searchWord: '', bool loadMore = false, bool resetPage = false, bool refreshContent = false, int limit = 10 }) async {
    
    startLoader(loadMore: loadMore);

    //  If we have a cancellable operation of fetching stores
    if(cancellableOperation != null){
      
      //  Cancel the request of fetching stores
      (cancellableOperation as CancelableOperation).cancel();

    }

    //  If we should load more  
    if(loadMore){

      //  Increment the page to target the next page content
      currentPage++;

    }

    //  If we should reset the page 
    if(resetPage){

      //  Set to target the first page content
      currentPage = 1;

    }

    /**
     *  If we should refresh the content already loaded, then set  
     *  the page equal to 1, otherwise set the current page.
     */
    final page = refreshContent ? 1 : currentPage;

    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    final apiInstance = (productsProvider.fetchProducts(searchWord: searchWord, page: page, limit: limit, context: context));

    cancellableOperation = CancelableOperation.fromFuture (
      apiInstance,
      onCancel: (){
        cancellableOperation = null;
      }
    );
    
    cancellableOperation.value.then((http.Response response){

      if(response.statusCode == 200 && mounted){

        final responseBody = jsonDecode(response.body);

        setState(() {

          //  If we are loading more products
          if(loadMore == true){

            //  Add loaded products to the list of existing paginated products
            (paginatedProducts as PaginatedProducts).embedded.products.addAll(PaginatedProducts.fromJson(responseBody).embedded.products);

            //  Re-calculate the product count
            (paginatedProducts as PaginatedProducts).count += PaginatedProducts.fromJson(responseBody).count;

            //  Increment the current page
            (paginatedProducts as PaginatedProducts).currentPage = currentPage;

          }else{

            paginatedProducts = PaginatedProducts.fromJson(responseBody);

          }

        });

      }

      return response;

    });
    
    cancellableOperation.value.whenComplete(() {

      stopLoader(loadMore: loadMore);

    });

    return cancellableOperation.value;

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: CustomFloatingActionButton(
        onAddProduct: () => fetchProducts(resetPage: true)
      ),
      appBar: CustomAppBar(title: 'Products'),
      drawer: StoreDrawer(),
      body: Content(
        paginatedProducts: paginatedProducts,
        fetchProducts: fetchProducts,
        isLoadingMore: isLoadingMore,
        isLoading: isLoading
      ),
    );
  }
}

class Content extends StatefulWidget {

  final PaginatedProducts? paginatedProducts;
  final Function fetchProducts;
  final bool isLoadingMore;
  final bool isLoading;

  Content({ this.paginatedProducts, required this.isLoadingMore, required this.isLoading, required this.fetchProducts });
  
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late ScrollController scrollController;
  List<int> originalOrderOfProducts = [];
  List<int> currentOrderOfProducts = [];
  List<Product> products = [];
  var filterStatus = false;
  var isSearching = false;
  Map activeFilters = {};
  var isLoading = false;
  String searchWord = '';

  void startLoader(){
    if(mounted){
      setState(() {
        isLoading = true;
      });
    }
  }

  void stopLoader(){
    if(mounted){
      setState(() {
        isLoading = false;
      });
    }
  }

  void startSearchLoader(){
    if(mounted){
      setState(() {
        isSearching = true;
      });
    }
  }

  void stopSearchLoader(){
    if(mounted){
      setState(() {
        isSearching = false;
      });
    }
  }

  @override
  void initState() {

    setProducts();

    getFiltersFromDevice();

    scrollController = new ScrollController()..addListener(_scrollListener);

    super.initState();

  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {

    //  If we are 100 pixels or less from the scroll bottom
    if (scrollController.position.extentAfter == 0) {

      final paginatedProducts = (widget.paginatedProducts as PaginatedProducts);

      if( widget.isLoading == false && widget.isLoadingMore == false && paginatedProducts.count < paginatedProducts.total){
        
        widget.fetchProducts(searchWord: searchWord, loadMore: true);

      }
      
    }

  }

  @override
  void didUpdateWidget(covariant Content oldWidget) {

    setProducts();
    
    super.didUpdateWidget(oldWidget);

  }

  void setProducts(){

    //  If we have the paginated products
    if( widget.paginatedProducts != null ){

      //  Extract the products
      products = widget.paginatedProducts!.embedded.products;

      //  Track the order of products
      resetOrderOfProducts();

    }
  }

  void resetOrderOfProducts(){
      originalOrderOfProducts = products.map((product) => product.id).toList();
      currentOrderOfProducts = originalOrderOfProducts;
  }

  void updateProductArrangement(){

    startLoader();
    
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    
    productsProvider.updateProductArrangement(products: products, context: context).then((http.Response response) async {

      if(response.statusCode == 200 && mounted){

        setState(() {

          //  Track the order of products
          resetOrderOfProducts();

        });

      }

    }).whenComplete((){

      stopLoader();

    });

  }

  Future<http.Response> startSearch({ searchWord: '' }) async {
    if(mounted){
      setState(() {
          this.searchWord = searchWord;
      });
    }
      
    return await widget.fetchProducts(searchWord: searchWord, resetPage: true);
  }

  void navigateToAddProduct() async {
    
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    await productsProvider.navigateToAddProduct();

    //  Refetch the products as soon as we return
    widget.fetchProducts(resetPage: true);

  }

  void reorderProducts(int oldIndex, int newIndex){
    if(mounted){
      setState(() {
        if(newIndex > oldIndex){
          newIndex -= 1;
        }

        final product = products[oldIndex];
        products.removeAt(oldIndex);

        products.insert(newIndex, product);
        
        //  Track the current order of products
        currentOrderOfProducts = products.map((product) => product.id).toList();

      });
    }
  }

  void toggleFilterStatus(){
    
    if(mounted){
      setState(() {
        filterStatus = !filterStatus;
      });
    }

  }

  bool get productOrderHasChanged {
    return listEquals(currentOrderOfProducts, originalOrderOfProducts) == false;
  }

  bool get hasProducts {
    return (products.length > 0);
  }

  Widget saveChangesButton(){
    return Align(
      alignment: Alignment.center,
      child: CustomButton(
        width: MediaQuery.of(context).size.width * 0.5,
        margin: EdgeInsets.only(top: 10, bottom: 10),
        text: 'Save changes',
        size: 'small',
        ripple: true,
        onSubmit: (){
          updateProductArrangement();
        },
      ),
    );
  }


  Future getFiltersFromDevice() async {
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('productFilters') ?? '{}');

      updateActiveFilters(filters);

    });

  }

  void updateActiveFilters(Map filters){

    setState(() {

      //  Extract only the active filters
      activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

    });

    widget.fetchProducts(searchWord: searchWord, resetPage: true);

  }

  void showFiltersDialog(){

    var alertDialog = (filters, setState, isLoading) {

      bool hasFilters() {
        return filters.length > 0 ? true : false;
      }

      void toggleFilter(filterName) {

        SharedPreferences.getInstance().then((prefs) async {

          setState(() {

            filters[filterName] = !(filters[filterName] as bool);

          });

          //  Store the updated filters
          prefs.setString('productFilters', jsonEncode(filters));

          //  Update the UI active filters
          updateActiveFilters(filters);
          
        });
        
      }

      Widget filterSwitch({ required bool value, required void Function(bool)? onChanged, required String text }){

        return Row(
          children: [
            Switch(
              value: value, 
              onChanged: onChanged
            ),
            Flexible(child: Text(text, style: TextStyle(fontSize: 12),))
          ],
        );

      }

      return AlertDialog(
          title: Text('Product Filters'),
          content: Container(
            height: 320,
            child: Column(
              children: [
                Divider(height: 10,),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: <TextSpan>[
                      TextSpan(text: 'Turn filters '),
                      TextSpan(
                        text: 'on / off', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      TextSpan(text: ' to limit products to show.'),
                    ],
                  ),
                ),
                Divider(height: 10,),

                if(isLoading || hasFilters() == false) CustomLoader(),

                if(hasFilters()) filterSwitch(
                  text: 'Show products on sale',
                  value: filters['onSale'],
                  onChanged: (status){
                    toggleFilter('onSale');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show products not on sale',
                  value: filters['notOnSale'],
                  onChanged: (status){
                    toggleFilter('notOnSale');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show products out of stock',
                  value: filters['outOfStock'],
                  onChanged: (status){
                    toggleFilter('outOfStock');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show products with limited stock',
                  value: filters['limitedStock'],
                  onChanged: (status){
                    toggleFilter('limitedStock');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show products with unlimited stock',
                  value: filters['unlimitedStock'],
                  onChanged: (status){
                    toggleFilter('unlimitedStock');
                  },
                ),
              ],
            ),
          ),
        );
    };

    showDialog(
      context: context, 
      builder: (ctx){
        
        bool isLoading = false;
        bool hasSetFilters = false;

        Map defaultFilters = {
          'onSale' : false,
          'notOnSale' : false,
          'outOfStock' : false,
          'limitedStock' : false,
          'unlimitedStock' : false,
        };

        Map filters = {};

        Future setFiltersFromDevice(setState) async {

          setState(() {
            isLoading = true;
          });

          filters = await SharedPreferences.getInstance().then((prefs) async {

            var productFilters = prefs.getString('productFilters');

            //  If we have no product filters
            if(productFilters == null){

              //  Store the default filters
              prefs.setString('productFilters', jsonEncode(defaultFilters));

              //  return the default filters
              return defaultFilters;
              
            }else{
              
              //  Get the filters stored on the device
              final Map storedFilters = jsonDecode( prefs.getString('productFilters') ?? '{}');

              //  Merge the default filters with the stored filters
              final mergedFilters = {
                ...defaultFilters,
                ...storedFilters,
              };

              /**
               *  If the number of default filters and the number of stored filters
               *  are not the same, then it means that the filters must be re-stored
               *  as merged filters
               */
              if(defaultFilters.length != storedFilters.length){

                //  Store the default filters merged with the stored filters
                await prefs.setString('productFilters', jsonEncode(mergedFilters));
                

              }

              return mergedFilters;

            }

          }).whenComplete((){
            setState(() {
              isLoading = false;
              hasSetFilters = true;
            });
          });

        }

        return StatefulBuilder(
          builder: (context, setState) {

            if(hasSetFilters == false) setFiltersFromDevice(setState);

            return alertDialog(filters, setState, isLoading);
          }
        );
      }
    );

  }

  bool get hasActiveFilters {
    return activeFilters.length > 0;
  }

  bool get hasSearchWord {
    return searchWord != '';
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
                Get.off(() => ShowStoreScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){
                
                if(widget.paginatedProducts == null){

                  widget.fetchProducts(searchWord: searchWord, resetPage: true);

                }else{

                  /**
                   *  If the total number of products exceeds the per page limit, then request that we 
                   *  refetch the same number of products e.g If we limit by 10 per page, but we already 
                   *  loaded 20, then we should still load 20 when we refresh instead of the 10 limit.
                   */
                  final limit = (widget.paginatedProducts!.count > widget.paginatedProducts!.perPage) ? widget.paginatedProducts!.count : widget.paginatedProducts!.perPage;

                  widget.fetchProducts(searchWord: searchWord, refreshContent: true, limit: limit);

                }

              }),
            ],
          ),
          Divider(),

          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          
                  if(hasProducts || isSearching || searchWord != '') Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      //  Search Bar
                      Expanded(
                        child: CustomSearchBar(
                          labelText: 'Search products',
                          helperText: 'Search using product name',
                          onSearch: (searchWord){
                            startSearchLoader();
                            return startSearch(searchWord: searchWord).whenComplete(() => stopSearchLoader());
                          }
                        ),
                      ),
                      
                      //  Popup Menu
                      /*
                      PopUpMenu(
                        showFiltersDialog: showFiltersDialog,
                        updateActiveFilters: updateActiveFilters
                      )
                      */

                    ],
                  ),
          
                  SizedBox(height: 10,),
  
                  //  Filters
                  if((isLoading == false && widget.isLoading == false && hasSearchWord == false)) 
                    FilterTag(
                      activeFilters: activeFilters,
                      showFiltersDialog: showFiltersDialog,
                    ),

                  if((isLoading == false && widget.isLoading == false) && hasProducts == true) Column(
                    children: [
                      Divider(),

                      if(productOrderHasChanged == false && hasSearchWord && widget.paginatedProducts != null) 
                        CustomInstructionMessage(text: 'Showing '+widget.paginatedProducts!.count.toString()+' / '+widget.paginatedProducts!.total.toString()+' matches'),

                      if(productOrderHasChanged == false && isSearching == false && hasActiveFilters == false)
                        CustomInstructionMessage(text: 'Long press any product to drag and drop into a different position'),

                      if(productOrderHasChanged == false && isSearching == false && hasActiveFilters == false)
                        CustomInstructionMessage(text: 'Swipe any product to the right to delete'),

                      if(productOrderHasChanged == false && isSearching == false && hasSearchWord == false && hasActiveFilters == true) 
                        CustomInstructionMessage(text: 'Filters have been added to limit products'),

                      if(productOrderHasChanged == true && isSearching == false) 
                        saveChangesButton(),

                      Divider()
                    ],
                  ),

                  //  Loader
                  if(isLoading == true || widget.isLoading == true) CustomLoader(topMargin: 100),
                  
                  //  Product list
                  if((isLoading == false && widget.isLoading == false) && hasProducts == true)
                    ProductList(
                      paginatedProducts: widget.paginatedProducts!,
                      fetchProducts: widget.fetchProducts,
                      isLoadingMore: widget.isLoadingMore,
                      reorderProducts: reorderProducts,
                      searchWord: searchWord,
                      products: products,
                    ),
          
                  //  No products found
                  if((isLoading == false && widget.isLoading == false) && isSearching == false && hasProducts == false)
                    NoProductsFound(
                      navigateToAddProduct: navigateToAddProduct
                    ),
          
                  //  No products found
                  if((isLoading == false && widget.isLoading == false) && isSearching == true && hasProducts == false)
                    NoSearchedProductsFound(searchWord: searchWord, startSearch: startSearch),
                ],
              )
            ),
          )
        ],
      ),
    );
  }
}

class FilterTag extends StatelessWidget {
  
  final activeFilters;
  final Function showFiltersDialog;

  FilterTag({ required this.activeFilters, required this.showFiltersDialog });

  bool get hasActiveFilters {
    return activeFilters.length > 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if(hasActiveFilters) GestureDetector(
          onTap: (){
            showFiltersDialog();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.shade200)
            ),
            child: Wrap(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blue.withOpacity(0.3),
                  child: Text(activeFilters.length.toString(), style: TextStyle(fontSize: 12, color: Colors.blue.shade900)),
                ),
                SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text('Filters'),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: (){
            showFiltersDialog();
          }, 
          child: Row(
            children: [
              Icon(hasActiveFilters ? Icons.edit : Icons.add, size: 14),
              SizedBox(width: 5),
              Text(hasActiveFilters ? 'Edit' : 'Add Filter'),
            ],
          )
        )
      ],
    );
  }
}

class PopUpMenu extends StatelessWidget {
  final Function showFiltersDialog;
  final Function updateActiveFilters;

  PopUpMenu({ required this.showFiltersDialog, required this.updateActiveFilters });

  customPopupMenuItem({ required int value, required String text, required icon, required Function()? onTap, required BuildContext context }){
    return 
      PopupMenuItem<int>(
        value: value,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            child: Row(
              children: [
                icon,
                const SizedBox(width: 7),
                Text(text)
              ],
            ),
          ),
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    
    return 
      PopupMenuButton<int>(
        icon: Icon(Icons.more_vert),
        offset: Offset(0, 40),
        color: Colors.white,
        itemBuilder: (context) => [
          customPopupMenuItem(
            value: 1,
            text: 'Filters',
            context: context,
            onTap: (){
              Navigator.of(context).pop();
              showFiltersDialog();
            },
            icon: SvgPicture.asset('assets/icons/ecommerce_pack_1/finger.svg', width: 18),
          )
        ]
      );
  }
}

class NoProductsFound extends StatelessWidget {

  final Function navigateToAddProduct;

  NoProductsFound({ required this.navigateToAddProduct });

  @override
  Widget build(BuildContext context) {
    
    final storesProvider = Provider.of<StoresProvider>(context, listen: false);
    final dialingCode = storesProvider.getStoreVisitShortCodeDialingCode;
    final store = storesProvider.store;
    
    return Column(
      children: [
        SizedBox(height: 30),
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: SvgPicture.asset('assets/icons/ecommerce_pack_1/shopping-bag-2.svg', width: 40.00, color: Colors.white,),
        ),
        SizedBox(height: 30),
        Text('No products found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
        
        SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.all(20),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.5),
              children: <TextSpan>[
                TextSpan(text: 'Add products to your store and ask customers to dial '),
                TextSpan(
                  text: dialingCode, 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, decoration: TextDecoration.underline), 
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      storesProvider.launchVisitShortcode(store: store, context: context);
                    }),
                TextSpan(text: ' to visit '),
                TextSpan(
                  text: store.name,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      storesProvider.launchVisitShortcode(store: store, context: context);
                    }),
                TextSpan(text: ' to start placing orders. '),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NoSearchedProductsFound extends StatelessWidget {

  final String searchWord;
  final Function startSearch;

  NoSearchedProductsFound({ required this.searchWord, required this.startSearch });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: SvgPicture.asset('assets/icons/ecommerce_pack_1/shopping-bag-2.svg', width: 40.00, color: Colors.white,),
          ),
          SizedBox(height: 30),
          Text('No search results', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: <TextSpan>[
                      TextSpan(text: 'We could not find any products matching the keyword '),
                      TextSpan(
                        text: searchWord, 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(),
        ]
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final PaginatedProducts paginatedProducts;
  final Function reorderProducts;
  final Function fetchProducts;
  final List<Product> products;
  final bool isLoadingMore;
  final searchWord;

  ProductList({ 
    required this.paginatedProducts, required this.products, required this.reorderProducts, 
    required this.fetchProducts, required this.isLoadingMore, required this.searchWord
  });

  @override
  Widget build(BuildContext context) {

    Widget buildProductListView(List<Product> products){

      var currNumberOfProducts = products.length;

      return ReorderableListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        onReorder: (oldIndex, newIndex) => reorderProducts(oldIndex, newIndex),
        itemCount: products.length,
        itemBuilder: (ctx, index){

          final productCard = ProductCard(product: products[index], searchWord: searchWord, fetchProducts: fetchProducts);

          return Dismissible(
            direction: DismissDirection.startToEnd,
            confirmDismiss: (dismissDirection) async {
              final isDeleted = await Provider.of<ProductsProvider>(context, listen: false).handleDeleteProduct(
                product: products[index], 
                context: ctx
              );
              //  Decrement the current number of products by one
              if(isDeleted) currNumberOfProducts--;

              //  Determine whether to dismiss the product card
              return isDeleted;
            },
            onDismissed: (dismissDirection){
              //  If the current number of products is Zero 
              if(currNumberOfProducts == 0){
                //  Fetch the products from the server
                fetchProducts(searchWord: searchWord, resetPage: true);
              }
            },
            child: productCard,
            key: ValueKey(products[index].id),
            background: Container(
              color: Colors.red.shade100,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Icon(Icons.delete, color: Colors.red)
            ),
          );
        }
      );

    }

    return 
      Column(
        children: [
          buildProductListView(products),
          SizedBox(height: 40),
          if(paginatedProducts.count < paginatedProducts.total && isLoadingMore == true) CustomLoader(),
          if(paginatedProducts.count == paginatedProducts.total && isLoadingMore == false) Text('No more products'),
          SizedBox(height: 60),
        ],
      );

  }
}

Widget showPricing(Product product){

  var pricing;
  
  //  If this is a Free product
  if(!product.allowVariants.status && product.isFree.status){

    pricing = Text(product.isFree.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green));

  //  If this product does not support variations and does not have a price
  }else if(!product.allowVariants.status && !product.isFree.status && !product.attributes.hasPrice.status){
  
    pricing = Text(product.attributes.hasPrice.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),);
                      
  //  If this product does not support variations and does have a price
  }else if(!product.allowVariants.status && !product.isFree.status && product.attributes.hasPrice.status) {
  
    pricing = AutoSizeText(
      product.attributes.unitPrice.currencyMoney,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
      maxLines: 1,
    );
                
  }else if(!product.allowVariants.status && product.attributes.onSale.status){
    
    pricing = Text(product.unitRegularPrice.currencyMoney, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough, color: Colors.grey));

  }else{
    
    pricing = Text('');

  }

  return Container(
    width: 80,
    child: pricing,
  );

}

Widget showForwardArrow(){
  return GestureDetector(
    onTap: () => {},
    child: Container(
      margin: EdgeInsets.only(right: 10),
      child: Icon(Icons.arrow_forward, color: Colors.grey,)
    )
  );
}

class ProductCard extends StatelessWidget {

  final Product product;
  final String searchWord;
  final Function fetchProducts;

  ProductCard({ required this.product, required this.searchWord, required this.fetchProducts });

  @override
  Widget build(BuildContext context) {

    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                
                      //  Product name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              product.name,
                              maxLines: 2,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )
                        ]
                      ),
                      SizedBox(height: 5),
                
                      //  Has variations
                      if(product.allowVariants.status) Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.device_hub_rounded, color: Colors.blue, size: 14,),
                          SizedBox(width: 5),
                          Text('Has variations', style: TextStyle(fontSize: 14),),
                        ]
                      ),
                
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                
                          //  Visibility
                          if(product.visible.status == false) Icon(Icons.visibility_off, color: Colors.grey, size: 20,),
                          if(product.visible.status == false) SizedBox(width: 5),
                          
                          //  Has Stock
                          if(!product.allowVariants.status && product.visible.status == false) Text('|', style: TextStyle(fontSize: 14, color: Colors.grey),),
                          if(!product.allowVariants.status && product.visible.status == false) SizedBox(width: 5),
                          if(!product.allowVariants.status) Text(product.attributes.hasStock.name, style: TextStyle(fontSize: 14, color: (product.attributes.hasStock.status ? Colors.grey: Colors.red))),
                          if(!product.allowVariants.status && product.attributes.hasStock.name != 'Unlimited Stock' && product.attributes.hasStock.status) Text(' ('+product.stockQuantity.value.toString()+')', style: TextStyle(fontSize: 14, color: (product.attributes.hasStock.status ? Colors.grey: Colors.red))),
                
                        ]
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    
                    //  Pricing
                    showPricing(product),
                
                    //  Forward Arrow 
                    showForwardArrow(),

                  ],
                )
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blue.withOpacity(0.2),
              highlightColor: Colors.blue.withOpacity(0.2),
              child: Ink(
                height: 80,
                width: double.infinity
              ),
              onTap: () async {
                  
                //  Set the selected product on the ProductsProvider
                productsProvider.setProduct(product);

                await Get.to(() => CreateProductScreen());

                //  Refetch the products as soon as we return back
                fetchProducts(searchWord: searchWord, resetPage: true);

              }, 
            )
          )
        ]
      )
    );
  }
}