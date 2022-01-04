import 'package:bonako_mobile_app/components/custom_divider.dart';
import 'package:bonako_mobile_app/components/custom_instruction_message.dart';
import 'package:bonako_mobile_app/components/custom_multi_widget_separator.dart';
import 'package:bonako_mobile_app/components/custom_secondary_text.dart';
import 'package:bonako_mobile_app/components/custom_tag.dart';
import 'package:bonako_mobile_app/models/locationTotals.dart';
import 'package:bonako_mobile_app/providers/locations.dart';
import './../../../../screens/dashboard/stores/show/store_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_floating_action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_search_bar.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_button.dart';
import './../../../../components/custom_loader.dart';
import './../../customers/show/customer_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/customers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../providers/stores.dart';
import './../../../../models/customers.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'dart:convert';

class CustomersScreen extends StatefulWidget {
  @override
  _CustomersScreenState createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  bool isLoadingMore = false;
  var cancellableOperation;
  bool isLoading = false;
  var paginatedCustomers;
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
    
    fetchCustomers();

    super.initState();

  }

  Future<http.Response> fetchCustomers({ String searchWord: '', bool loadMore = false, bool resetPage = false, bool refreshContent = false, int limit = 10 }) async {
    
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

    final customersProvider = Provider.of<CustomersProvider>(context, listen: false);

    final apiInstance = (customersProvider.fetchCustomers(searchWord: searchWord, page: page, limit: limit, context: context));

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

          //  If we are loading more customers
          if(loadMore == true){

            //  Add loaded customers to the list of existing paginated customers
            (paginatedCustomers as PaginatedCustomers).embedded.customers.addAll(PaginatedCustomers.fromJson(responseBody).embedded.customers);

            //  Re-calculate the customer count
            (paginatedCustomers as PaginatedCustomers).count += PaginatedCustomers.fromJson(responseBody).count;

            //  Increment the current page
            (paginatedCustomers as PaginatedCustomers).currentPage = currentPage;

          }else{

            paginatedCustomers = PaginatedCustomers.fromJson(responseBody);

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
        appBar: CustomAppBar(title: 'Customers'),
        drawer: StoreDrawer(),
        body: Content(
          paginatedCustomers: paginatedCustomers,
          fetchCustomers: fetchCustomers,
          isLoadingMore: isLoadingMore,
          isLoading: isLoading
        ),
      )
    );
  }
}

class Content extends StatefulWidget {

  final PaginatedCustomers? paginatedCustomers;
  final Function fetchCustomers;
  final bool isLoadingMore;
  final bool isLoading;

  Content({ this.paginatedCustomers, required this.isLoadingMore, required this.isLoading, required this.fetchCustomers });
  
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late ScrollController scrollController;
  List<Customer> customers = [];
  var filterStatus = false;
  var isSearching = false;
  Map activeFilters = {};
  String searchWord = '';
  var isLoading = false;

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

  LocationTotals get locationTotals {
    return Provider.of<LocationsProvider>(context).getLocationTotals;
  }

  @override
  void initState() {

    setCustomers();

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

      final paginatedCustomers = (widget.paginatedCustomers as PaginatedCustomers);

      if( widget.isLoading == false && widget.isLoadingMore == false && paginatedCustomers.count < paginatedCustomers.total){
        
        widget.fetchCustomers(searchWord: searchWord, loadMore: true);

      }
      
    }

  }

  @override
  void didUpdateWidget(covariant Content oldWidget) {

    setCustomers();
    
    super.didUpdateWidget(oldWidget);

  }

  void setCustomers(){

    //  If we have the paginated customers
    if( widget.paginatedCustomers != null ){

      //  Extract the customers
      customers = widget.paginatedCustomers!.embedded.customers;

    }

  }

  Future<http.Response> startSearch({ searchWord: '' }) async {
    if(mounted){
      setState(() {
          this.searchWord = searchWord;
      });
    }
      
    return await widget.fetchCustomers(searchWord: searchWord, resetPage: true);
  }

  void toggleFilterStatus(){
    
    if(mounted){
      setState(() {
        filterStatus = !filterStatus;
      });
    }

  }

  bool get hasCustomers {
    return (customers.length > 0);
  }

  Future getFiltersFromDevice() async {
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('customerFilters') ?? '{}');

      updateActiveFilters(filters);

    });

  }

  void updateActiveFilters(Map filters){

    setState(() {

      //  Extract only the active filters
      activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

    });

    widget.fetchCustomers(searchWord: searchWord, resetPage: true);

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
          prefs.setString('customerFilters', jsonEncode(filters));

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
          title: Text('Customer Filters'),
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
                      TextSpan(text: ' to limit customers to show.'),
                    ],
                  ),
                ),
                Divider(height: 10,),

                if(isLoading || hasFilters() == false) CustomLoader(),

                if(hasFilters()) filterSwitch(
                  text: 'Show active customers',
                  value: filters['active'],
                  onChanged: (status){
                    toggleFilter('active');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show inactive customers',
                  value: filters['inactive'],
                  onChanged: (status){
                    toggleFilter('inactive');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show customers offering free delivery',
                  value: filters['free delivery'],
                  onChanged: (status){
                    toggleFilter('free delivery');
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
          'active' : false,
          'inactive' : false,
          'free delivery' : false,
        };

        Map filters = {};

        Future setFiltersFromDevice(setState) async {

          setState(() {
            isLoading = true;
          });

          filters = await SharedPreferences.getInstance().then((prefs) async {

            var customerFilters = prefs.getString('customerFilters');

            //  If we have no customer filters
            if(customerFilters == null){

              //  Store the default filters
              prefs.setString('customerFilters', jsonEncode(defaultFilters));

              //  return the default filters
              return defaultFilters;
              
            }else{
              
              //  Get the filters stored on the device
              final Map storedFilters = jsonDecode( prefs.getString('customerFilters') ?? '{}');

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
                await prefs.setString('customerFilters', jsonEncode(mergedFilters));

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
                Get.offAll(() => ShowStoreScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){
                
                if(widget.paginatedCustomers == null){

                  widget.fetchCustomers(searchWord: searchWord, resetPage: true);

                }else{

                  /**
                   *  If the total number of customers exceeds the per page limit, then request that we 
                   *  refetch the same number of customers e.g If we limit by 10 per page, but we already 
                   *  loaded 20, then we should still load 20 when we refresh instead of the 10 limit.
                   */
                  final limit = (widget.paginatedCustomers!.count > widget.paginatedCustomers!.perPage) ? widget.paginatedCustomers!.count : widget.paginatedCustomers!.perPage;

                  widget.fetchCustomers(searchWord: searchWord, refreshContent: true, limit: limit);

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
          
                  if(hasCustomers || isSearching || searchWord != '') Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      //  Search Bar
                      Expanded(
                        child: CustomSearchBar(
                          labelText: 'Search customers',
                          helperText: 'Search using customer name',
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
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && locationTotals.customerTotals.total > 0)
                    FilterTag(
                      activeFilters: activeFilters,
                      showFiltersDialog: showFiltersDialog,
                    ),

                  if((isLoading == false && widget.isLoading == false) && hasCustomers == true) Column(
                    children: [
                      Divider(),

                      if(hasSearchWord && widget.paginatedCustomers != null) 
                        CustomInstructionMessage(text: 'Showing '+widget.paginatedCustomers!.count.toString()+' / '+widget.paginatedCustomers!.total.toString()+' matches'),

                      if(isSearching == false && hasActiveFilters == false)
                        CustomInstructionMessage(text: 'Swipe any customer to the right to delete'),

                      if(isSearching == false && hasSearchWord == false && hasActiveFilters == true) 
                        CustomInstructionMessage(text: 'Filters have been added to limit customers'),

                      Divider()
                    ],
                  ),

                  //  Loader
                  if(isLoading == true || widget.isLoading == true) CustomLoader(topMargin: 100),
                  
                  //  Customer list
                  if((isLoading == false && widget.isLoading == false) && hasCustomers == true)
                    CustomerList(
                      paginatedCustomers: widget.paginatedCustomers!,
                      isLoadingMore: widget.isLoadingMore,
                      fetchCustomers: widget.fetchCustomers,
                      searchWord: searchWord,
                      customers: customers,
                    ),
          
                  //  No customers found
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && hasCustomers == false && hasSearchWord == false)
                    NoCustomersFound(),
          
                  //  No customers found
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && hasCustomers == false && hasSearchWord == true)
                    NoSearchedCustomersFound(
                      searchWord: searchWord
                    ),
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

class NoCustomersFound extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    
    final storesProvider = Provider.of<StoresProvider>(context, listen: false);
    final dialingCode = storesProvider.getStoreVisitShortCodeDialingCode;
    final store = storesProvider.store;
    
    return Column(
      children: [
        SizedBox(height: 30),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.blue.shade100, width: 1),
          ),
          child: SvgPicture.asset('assets/icons/ecommerce_pack_1/customers-3.svg', color: Colors.blue, width: 40,)
        ),
        
        SizedBox(height: 30),

        Text('No customers found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),

        SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.all(20),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.5),
              children: <TextSpan>[
                TextSpan(text: 'Ask customers to dial '),
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

class NoSearchedCustomersFound extends StatelessWidget {

  final String searchWord;

  NoSearchedCustomersFound({ required this.searchWord });

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
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.blue.shade100, width: 1),
            ),
            child: SvgPicture.asset('assets/icons/ecommerce_pack_1/customers-3.svg', color: Colors.blue, width: 40,)
          ),
          SizedBox(height: 30),
          Text('No search results', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),

          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: <TextSpan>[
                      TextSpan(text: 'We could not find any customers matching the keyword '),
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

class AddCustomerButton extends StatelessWidget {

  final Function navigateToAddCustomer;

  AddCustomerButton({ required this.navigateToAddCustomer });

  @override
  Widget build(BuildContext context) {

    return CustomButton(
      width: 300,
      text: '+ Add Customer',
      onSubmit: () async {
        navigateToAddCustomer();
      }, 
    );
  }
}

class CustomerList extends StatelessWidget {
  final PaginatedCustomers paginatedCustomers;
  final Function fetchCustomers;
  final List<Customer> customers;
  final bool isLoadingMore;
  final searchWord;

  CustomerList({ 
    required this.paginatedCustomers, required this.customers,
    required this.fetchCustomers, required this.isLoadingMore, 
    required this.searchWord
  });

  @override
  Widget build(BuildContext context) {

    Widget buildCustomerListView(List<Customer> customers){

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: customers.length,
        itemBuilder: (ctx, index){

          final Customer customer = customers[index];

          return CustomerCard(customer: customer, searchWord: searchWord, fetchCustomers: fetchCustomers);

        }
      );

    }

    return 
      Column(
        children: [
          buildCustomerListView(customers),
          SizedBox(height: 40),
          if(paginatedCustomers.count < paginatedCustomers.total && isLoadingMore == true) CustomLoader(),
          if(paginatedCustomers.count == paginatedCustomers.total && isLoadingMore == false) Text('No more customers'),
          SizedBox(height: 60),
        ],
      );

  }
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

class CustomerCard extends StatelessWidget {

  final Customer customer;
  final String searchWord;
  final Function fetchCustomers;

  CustomerCard({ required this.customer, required this.searchWord, required this.fetchCustomers });

  @override
  Widget build(BuildContext context) {

    final customersProvider = Provider.of<CustomersProvider>(context, listen: false);

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
                
                      //  Customer name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              customer.embedded.user.attributes.name,
                              maxLines: 2,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )
                        ]
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
          
                          //  Orders
                          CustomMultiWidgetSeparator(
                            texts: [
                              {
                                'widget': CustomSecondaryText(text: 'Total Orders : ' + customer.totalOrdersPlacedByCustomer.toString()),
                                'value': customer.totalOrdersPlacedByCustomer.toString()
                              },
                              {
                                'widget': CustomSecondaryText(text: 'Total Amount : ' + customer.checkoutSubTotal.currencyMoney),
                                'value': customer.checkoutSubTotal.currencyMoney
                              },
                            ]
                          ),

                          ],
                        )
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    
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
                  
                //  Set the selected customer on the CustomersProvider
                customersProvider.setCustomer(customer);

                await Get.to(() => ShowCustomerScreen());

                //  Refetch the customers as soon as we return back
                fetchCustomers(searchWord: searchWord, resetPage: true);

              }, 
            )
          )
        ]
      )
    );
  }
}