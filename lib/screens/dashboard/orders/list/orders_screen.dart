import 'package:bonako_mobile_app/components/custom_multi_widget_separator.dart';
import 'package:bonako_mobile_app/models/customers.dart';
import 'package:bonako_mobile_app/providers/customers.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/components/orderStatusSummary.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/show/components/userProfileSummary.dart';

import './../../../../screens/dashboard/orders/show/order_screen.dart';
import './../../../../screens/dashboard/stores/show/store_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_floating_action_button.dart';
import './../../../../components/custom_instruction_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_search_bar.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_loader.dart';
import '../../../../components/store_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../providers/stores.dart';
import './../../../../providers/orders.dart';
import './../../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:convert';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool isLoadingMore = false;
  var cancellableOperation;
  bool isLoading = false;
  var paginatedOrders;
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

  CustomersProvider get customerProvider {
    return Provider.of<CustomersProvider>(context, listen: false);
  }

  bool get hasCustomer {
    return customerProvider.hasCustomer;
  }

  Customer get customer {
    return customerProvider.getCustomer;
  }

  @override
  void initState() {
    
    fetchOrders();

    super.initState();

  }

  Future<http.Response> fetchOrders({ String searchWord: '', bool loadMore = false, bool resetPage = false, bool refreshContent = false, int limit = 10 }) async {
    
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

    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    //  Set the customer orders url (If we have a customer set)
    final customerOrdersUrl = hasCustomer ? customer.links.bosOrders.href: null;

    final apiInstance = (ordersProvider.fetchOrders(alternativeUrl: customerOrdersUrl, searchWord: searchWord, page: page, limit: limit, context: context));

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

          //  If we are loading more orders
          if(loadMore == true){

            //  Add loaded orders to the list of existing paginated orders
            (paginatedOrders as PaginatedOrders).embedded.orders.addAll(PaginatedOrders.fromJson(responseBody).embedded.orders);

            //  Re-calculate the order count
            (paginatedOrders as PaginatedOrders).count += PaginatedOrders.fromJson(responseBody).count;

            //  Increment the current page
            (paginatedOrders as PaginatedOrders).currentPage = currentPage;

          }else{

            paginatedOrders = PaginatedOrders.fromJson(responseBody);

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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: CustomFloatingActionButton(),
        appBar: CustomAppBar(title: 'Orders'),
        drawer: StoreDrawer(),
        body: Content(
          paginatedOrders: paginatedOrders,
          isLoadingMore: isLoadingMore,
          fetchOrders: fetchOrders,
          isLoading: isLoading
        ),
      )
    );
  }
}

class Content extends StatefulWidget {

  final PaginatedOrders? paginatedOrders;
  final Function fetchOrders;
  final bool isLoadingMore;
  final bool isLoading;

  Content({ this.paginatedOrders, required this.isLoadingMore, required this.isLoading, required this.fetchOrders });
  
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late ScrollController scrollController;
  var filterStatus = false;
  var isSearching = false;
  List<Order> orders = [];
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

  CustomersProvider get customerProvider {
    return Provider.of<CustomersProvider>(context, listen: false);
  }

  bool get hasCustomer {
    return customerProvider.hasCustomer;
  }

  Customer get customer {
    return customerProvider.getCustomer;
  }

  @override
  void initState() {

    setOrders();

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

      final paginatedOrders = (widget.paginatedOrders as PaginatedOrders);

      if( widget.isLoading == false && widget.isLoadingMore == false && paginatedOrders.count < paginatedOrders.total){
        
        widget.fetchOrders(searchWord: searchWord, loadMore: true);

      }
      
    }

  }

  @override
  void didUpdateWidget(covariant Content oldWidget) {

    setOrders();
    
    super.didUpdateWidget(oldWidget);

  }

  void setOrders(){

    //  If we have the paginated orders
    if( widget.paginatedOrders != null ){

      //  Extract the orders
      orders = widget.paginatedOrders!.embedded.orders;

    }

  }

  Future<http.Response> startSearch({ searchWord: '' }) async {
    if(mounted){
      setState(() {
          this.searchWord = searchWord;
      });
    }
      
    return await widget.fetchOrders(searchWord: searchWord, resetPage: true);
  }

  void toggleFilterStatus(){
    
    if(mounted){
      setState(() {
        filterStatus = !filterStatus;
      });
    }

  }

  bool get hasOrders {
    return (orders.length > 0);
  }

  Future getFiltersFromDevice() async {
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('orderFilters') ?? '{}');

      updateActiveFilters(filters);

    });

  }

  void updateActiveFilters(Map filters){

    setState(() {

      //  Extract only the active filters
      activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

    });

    widget.fetchOrders(searchWord: searchWord, resetPage: true);

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
          prefs.setString('orderFilters', jsonEncode(filters));

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
          title: Text('Order Filters'),
          content: Container(
            height: 320,
            child: Column(
              children: [
                Divider(height: 10,),
                RichText(
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: <TextSpan>[
                      TextSpan(text: 'Turn filters '),
                      TextSpan(
                        text: 'on / off', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      TextSpan(text: ' to limit orders to show.'),
                    ],
                  ),
                ),
                Divider(height: 10,),

                if(isLoading || hasFilters() == false) CustomLoader(),

                if(hasFilters()) filterSwitch(
                  text: 'Show orders on sale',
                  value: filters['onSale'],
                  onChanged: (status){
                    toggleFilter('onSale');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show orders not on sale',
                  value: filters['notOnSale'],
                  onChanged: (status){
                    toggleFilter('notOnSale');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show orders out of stock',
                  value: filters['outOfStock'],
                  onChanged: (status){
                    toggleFilter('outOfStock');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show orders with limited stock',
                  value: filters['limitedStock'],
                  onChanged: (status){
                    toggleFilter('limitedStock');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show orders with unlimited stock',
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

            var orderFilters = prefs.getString('orderFilters');

            //  If we have no order filters
            if(orderFilters == null){

              //  Store the default filters
              prefs.setString('orderFilters', jsonEncode(defaultFilters));

              //  return the default filters
              return defaultFilters;
              
            }else{
              
              //  Get the filters stored on the device
              final Map storedFilters = jsonDecode( prefs.getString('orderFilters') ?? '{}');

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
                await prefs.setString('orderFilters', jsonEncode(mergedFilters));

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

  bool get canShowPaginationSummaryInfo {
    return (widget.paginatedOrders != null && (widget.paginatedOrders as PaginatedOrders).count > 0);
  }

  bool get canShowActiveFiltersInfo {
    return (isSearching == false && hasSearchWord == false && hasActiveFilters == true);
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
                Get.offAll(() => ShowStoreScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){
                
                if(widget.paginatedOrders == null){

                  widget.fetchOrders(searchWord: searchWord, resetPage: true);

                }else{

                  /**
                   *  If the total number of orders exceeds the per page limit, then request that we 
                   *  refetch the same number of orders e.g If we limit by 10 per page, but we already 
                   *  loaded 20, then we should still load 20 when we refresh instead of the 10 limit.
                   */
                  final limit = (widget.paginatedOrders!.count > widget.paginatedOrders!.perPage) ? widget.paginatedOrders!.count : widget.paginatedOrders!.perPage;

                  widget.fetchOrders(searchWord: searchWord, refreshContent: true, limit: limit);

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

                  if(hasCustomer) UserProfileSummary(user: customer.embedded.user),
                  if(hasCustomer) Divider(),
          
                  if(hasOrders || isSearching || searchWord != '') Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      //  Search Bar
                      Expanded(
                        child: CustomSearchBar(
                          labelText: 'Search orders',
                          helperText: 'Search using order name',
                          onSearch: (searchWord){
                            startSearchLoader();
                            return startSearch(searchWord: searchWord).whenComplete(() => stopSearchLoader());
                          }
                        ),
                      ),

                    ],
                  ),
          
                  SizedBox(height: 10,),
  
                  //  Filters
                  if((isLoading == false && widget.isLoading == false && hasSearchWord == false)) 
                    FilterTag(
                      activeFilters: activeFilters,
                      showFiltersDialog: showFiltersDialog,
                    ),

                  if((isLoading == false && widget.isLoading == false) && hasOrders == true) Column(
                    children: [
                      if(canShowPaginationSummaryInfo || canShowActiveFiltersInfo) Divider(),

                      if(canShowPaginationSummaryInfo) CustomInstructionMessage(text: 'Showing '+widget.paginatedOrders!.count.toString()+' / '+widget.paginatedOrders!.total.toString()+' matches'),

                      if(canShowActiveFiltersInfo) CustomInstructionMessage(text: 'Filters have been added to limit orders'),

                      if(canShowPaginationSummaryInfo || canShowActiveFiltersInfo) Divider(),
                    ],
                  ),

                  //  Loader
                  if(isLoading == true || widget.isLoading == true) CustomLoader(topMargin: 100),
                  
                  //  Order list
                  if((isLoading == false && widget.isLoading == false) && hasOrders == true)
                    OrderList(
                      paginatedOrders: widget.paginatedOrders!,
                      isLoadingMore: widget.isLoadingMore,
                      fetchOrders: widget.fetchOrders,
                      searchWord: searchWord,
                      orders: orders,
                    ),
          
                  //  No orders found
                  if((isLoading == false && widget.isLoading == false) && isSearching == false && hasOrders == false)
                    NoOrdersFound(),
          
                  //  No searched orders found
                  if((isLoading == false && widget.isLoading == false) && isSearching == true && hasOrders == false)
                    NoSearchedOrdersFound(searchWord: searchWord, startSearch: startSearch),
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

class NoOrdersFound extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    final storesProvider = Provider.of<StoresProvider>(context, listen: false);
    final dialingCode = storesProvider.getStoreVisitShortCodeDialingCode;
    final store = storesProvider.store;
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.blue.shade100, width: 1),
          ),
          child: SvgPicture.asset('assets/icons/ecommerce_pack_1/package-2.svg', color: Colors.blue, width: 40,)
        ),
        SizedBox(height: 30),
        Text('No orders found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
        
        SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.all(20),
          child: RichText(
            textAlign: TextAlign.justify,
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

class NoSearchedOrdersFound extends StatelessWidget {

  final String searchWord;
  final Function startSearch;

  NoSearchedOrdersFound({ required this.searchWord, required this.startSearch });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.blue.shade100, width: 1),
            ),
            child: SvgPicture.asset('assets/icons/ecommerce_pack_1/package-2.svg', color: Colors.blue, width: 40,)
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
                      TextSpan(text: 'We could not find any orders matching the keyword '),
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

class OrderList extends StatelessWidget {
  final PaginatedOrders paginatedOrders;
  final Function fetchOrders;
  final List<Order> orders;
  final bool isLoadingMore;
  final searchWord;

  OrderList({ 
    required this.paginatedOrders, required this.orders, required this.fetchOrders, 
    required this.isLoadingMore, required this.searchWord
  });

  @override
  Widget build(BuildContext context) {

    Widget buildOrderListView(List<Order> orders){

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: orders.length,
        itemBuilder: (ctx, index){
          return OrderCard(order: orders[index], searchWord: searchWord, fetchOrders: fetchOrders);
        }
      );

    }

    return 
      Column(
        children: [
          buildOrderListView(orders),
          SizedBox(height: 40),
          if(paginatedOrders.count < paginatedOrders.total && isLoadingMore == true) CustomLoader(),
          if(paginatedOrders.count == paginatedOrders.total && isLoadingMore == false) Text('No more orders'),
          SizedBox(height: 60),
        ],
      );

  }
}

class OrderCard extends StatelessWidget {

  final Order order;
  final String searchWord;
  final Function fetchOrders;

  OrderCard({ required this.order, required this.searchWord, required this.fetchOrders });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);


    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        //  Order # & Customer name
                        Container(
                          width: size.width * 0.6,  //  Occupy 60%
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text('#'+order.number, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(top: 3, left: 10),
                                  child: Text(order.embedded.customer.embedded.user.attributes.name, overflow: TextOverflow.ellipsis,)
                                ),
                              ),
                              
                            ]
                          ),
                        ),
                        
                        SizedBox(height: 10),

                        //  Date
                        if(order.createdAt != null) Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.watch_later_outlined, color: Colors.grey, size: 14,),
                            SizedBox(width: 5),
                            Text(DateFormat("MMM d y @ HH:mm").format(order.createdAt!), style: TextStyle(fontSize: 14),),
                          ]
                        ),
                      ],
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          //  Grand Total
                          Expanded(
                            child: Container(
                              child: Text(order.embedded.activeCart.grandTotal.currencyMoney, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis,)
                            ),
                          ),
                                      
                          //  Forward Arrow 
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(Icons.arrow_forward, color: Colors.grey,),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                //  Payment status | Delivery status | Total items | Total coupons
                OrderStatusSummary(
                  order: order,
                )
                
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              child: Ink(
                height: 105,
                width: double.infinity
              ),
              onTap: () async {
                  
                //  Set the selected order on the OrdersProvider
                ordersProvider.setOrder(order);

                await Get.to(() => OrderScreen());

                //  Refetch the products as soon as we return back
                fetchOrders(searchWord: searchWord, resetPage: true);

              }, 
            )
          )
        ]
      )
    );
  }
}