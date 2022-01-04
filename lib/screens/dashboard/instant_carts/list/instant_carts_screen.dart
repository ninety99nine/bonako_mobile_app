import 'package:bonako_mobile_app/components/custom_countdown.dart';
import 'package:bonako_mobile_app/components/custom_instruction_message.dart';
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
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/instant_carts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../instant_carts/create/create.dart';
import './../../../../providers/stores.dart';
import '../../../../models/instantCarts.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'dart:convert';

class InstantCartsScreen extends StatefulWidget {
  @override
  _InstantCartsScreenState createState() => _InstantCartsScreenState();
}

class _InstantCartsScreenState extends State<InstantCartsScreen> {
  bool isLoadingMore = false;
  var paginatedInstantCarts;
  var cancellableOperation;
  bool isLoading = false;
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
    
    fetchInstantCarts();

    super.initState();

  }

  Future<http.Response> fetchInstantCarts({ String searchWord: '', bool loadMore = false, bool resetPage = false, bool refreshContent = false, int limit = 10 }) async {
    
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

    final instantCartsProvider = Provider.of<InstantCartsProvider>(context, listen: false);

    final apiInstance = (instantCartsProvider.fetchInstantCarts(searchWord: searchWord, page: page, limit: limit, context: context));

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

          //  If we are loading more instant carts
          if(loadMore == true){

            //  Add loaded instant carts to the list of existing paginated instant carts
            (paginatedInstantCarts as PaginatedInstantCarts).embedded.instantCarts.addAll(PaginatedInstantCarts.fromJson(responseBody).embedded.instantCarts);

            //  Re-calculate the instant cart count
            (paginatedInstantCarts as PaginatedInstantCarts).count += PaginatedInstantCarts.fromJson(responseBody).count;

            //  Increment the current page
            (paginatedInstantCarts as PaginatedInstantCarts).currentPage = currentPage;

          }else{

            paginatedInstantCarts = PaginatedInstantCarts.fromJson(responseBody);

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
        floatingActionButton: CustomFloatingActionButton(
          onAddInstantCart: (){
            fetchInstantCarts(resetPage: true);
          }
        ),
        appBar: CustomAppBar(title: 'Instant Carts'),
        drawer: StoreDrawer(),
        body: Content(
          paginatedInstantCarts: paginatedInstantCarts,
          fetchInstantCarts: fetchInstantCarts,
          isLoadingMore: isLoadingMore,
          isLoading: isLoading
        ),
      )
    );
  }
}

class Content extends StatefulWidget {

  final PaginatedInstantCarts? paginatedInstantCarts;
  final Function fetchInstantCarts;
  final bool isLoadingMore;
  final bool isLoading;

  Content({ this.paginatedInstantCarts, required this.isLoadingMore, required this.isLoading, required this.fetchInstantCarts });
  
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late ScrollController scrollController;
  List<InstantCart> instantCarts = [];
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

    setInstantCarts();

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

      final paginatedInstantCarts = (widget.paginatedInstantCarts as PaginatedInstantCarts);

      if( widget.isLoading == false && widget.isLoadingMore == false && paginatedInstantCarts.count < paginatedInstantCarts.total){
        
        widget.fetchInstantCarts(searchWord: searchWord, loadMore: true);

      }
      
    }

  }

  @override
  void didUpdateWidget(covariant Content oldWidget) {

    setInstantCarts();
    
    super.didUpdateWidget(oldWidget);

  }

  void setInstantCarts(){

    //  If we have the paginated instant carts
    if( widget.paginatedInstantCarts != null ){

      //  Extract the instant carts
      instantCarts = widget.paginatedInstantCarts!.embedded.instantCarts;

    }

  }

  Future<http.Response> startSearch({ searchWord: '' }) async {
    if(mounted){
      setState(() {
          this.searchWord = searchWord;
      });
    }
      
    return await widget.fetchInstantCarts(searchWord: searchWord, resetPage: true);
  }

  void navigateToAddInstantCart() async {
    
    final instantCartsProvider = Provider.of<InstantCartsProvider>(context, listen: false);

    await instantCartsProvider.navigateToAddInstantCart();

    //  Refetch the instant cartS as soon as we return
    widget.fetchInstantCarts(resetPage: true);

  }

  void removeinstantCart(int userId, int currNumberOfinstantCarts){

    setState(() {
      instantCarts.removeWhere((user) => user.id == userId);
      
      //  If the current number of instant carts is Zero 
      if(currNumberOfinstantCarts == 0){

        //  Fetch the instant carts from the server
        widget.fetchInstantCarts(searchWord: searchWord, resetPage: true);

      }
    });

  }

  void toggleFilterStatus(){
    
    if(mounted){
      setState(() {
        filterStatus = !filterStatus;
      });
    }

  }

  bool get hasInstantCarts {
    return (instantCarts.length > 0);
  }

  Future getFiltersFromDevice() async {
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('instantCartFilters') ?? '{}');

      updateActiveFilters(filters);

    });

  }

  void updateActiveFilters(Map filters){

    setState(() {

      //  Extract only the active filters
      activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

    });

    widget.fetchInstantCarts(searchWord: searchWord, resetPage: true);

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
          prefs.setString('instantCartFilters', jsonEncode(filters));

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
          title: Text('Instant Cart Filters'),
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
                      TextSpan(text: ' to limit instant carts to show.'),
                    ],
                  ),
                ),
                Divider(height: 10,),

                if(isLoading || hasFilters() == false) CustomLoader(),

                if(hasFilters()) filterSwitch(
                  text: 'Show active instant carts',
                  value: filters['active'],
                  onChanged: (status){
                    toggleFilter('active');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show inactive instant carts',
                  value: filters['inactive'],
                  onChanged: (status){
                    toggleFilter('inactive');
                  },
                )
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

            var instantCartFilters = prefs.getString('instantCartFilters');

            //  If we have no instant cart filters
            if(instantCartFilters == null){

              //  Store the default filters
              prefs.setString('instantCartFilters', jsonEncode(defaultFilters));

              //  return the default filters
              return defaultFilters;
              
            }else{
              
              //  Get the filters stored on the device
              final Map storedFilters = jsonDecode( prefs.getString('instantCartFilters') ?? '{}');

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
                await prefs.setString('instantCartFilters', jsonEncode(mergedFilters));

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
                
                if(widget.paginatedInstantCarts == null){

                  widget.fetchInstantCarts(searchWord: searchWord, resetPage: true);

                }else{

                  /**
                   *  If the total number of instant carts exceeds the per page limit, then request that we 
                   *  refetch the same number of instant carts e.g If we limit by 10 per page, but we already 
                   *  loaded 20, then we should still load 20 when we refresh instead of the 10 limit.
                   */
                  final limit = (widget.paginatedInstantCarts!.count > widget.paginatedInstantCarts!.perPage) ? widget.paginatedInstantCarts!.count : widget.paginatedInstantCarts!.perPage;

                  widget.fetchInstantCarts(searchWord: searchWord, refreshContent: true, limit: limit);

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
          
                  if(hasInstantCarts || isSearching || searchWord != '') Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      //  Search Bar
                      Expanded(
                        child: CustomSearchBar(
                          labelText: 'Search instant carts',
                          helperText: 'Search using instant cart name',
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
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && locationTotals.instantCartTotals.total > 0)
                    FilterTag(
                      activeFilters: activeFilters,
                      showFiltersDialog: showFiltersDialog,
                    ),

                  if((isLoading == false && widget.isLoading == false) && hasInstantCarts == true) Column(
                    children: [
                      Divider(),

                      if(hasSearchWord && widget.paginatedInstantCarts != null) 
                        CustomInstructionMessage(text: 'Showing '+widget.paginatedInstantCarts!.count.toString()+' / '+widget.paginatedInstantCarts!.total.toString()+' matches'),

                      if(isSearching == false && hasActiveFilters == false)
                        CustomInstructionMessage(text: 'Swipe any instant cart to the right to delete'),

                      if(isSearching == false && hasSearchWord == false && hasActiveFilters == true) 
                        CustomInstructionMessage(text: 'Filters have been added to limit instant carts'),

                      Divider()
                    ],
                  ),

                  //  Loader
                  if(isLoading == true || widget.isLoading == true) CustomLoader(topMargin: 100),
                  
                  //  Instant cart list
                  if((isLoading == false && widget.isLoading == false) && hasInstantCarts == true)
                    InstantCartList(
                      paginatedInstantCarts: widget.paginatedInstantCarts!,
                      fetchInstantCarts: widget.fetchInstantCarts,
                      removeinstantCart: removeinstantCart,
                      isLoadingMore: widget.isLoadingMore,
                      instantCarts: instantCarts,
                      searchWord: searchWord,
                    ),
          
                  //  No instant carts found
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && hasInstantCarts == false && hasSearchWord == false)
                    NoInstantCartsFound(
                      navigateToAddInstantCart: navigateToAddInstantCart
                    ),
          
                  //  No instant carts found
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && hasInstantCarts == false && hasSearchWord == true)
                    NoSearchedInstantCartsFound(
                      searchWord: searchWord, 
                      navigateToAddInstantCart: navigateToAddInstantCart
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

class NoInstantCartsFound extends StatelessWidget {

  final Function navigateToAddInstantCart;

  NoInstantCartsFound({ required this.navigateToAddInstantCart });

  @override
  Widget build(BuildContext context) {
    
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
          child: SvgPicture.asset('assets/icons/ecommerce_pack_1/shopping-cart-10.svg', color: Colors.blue, width: 40,)
        ),
        
        SizedBox(height: 30),

        Text('No instant carts found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
        
        SizedBox(height: 30),

        AddInstantCartButton(
          navigateToAddInstantCart: navigateToAddInstantCart,
        ),

        SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.all(20),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.5),
              children: <TextSpan>[
                TextSpan(text: 'Add instant carts to your store and allow customers to place orders faster'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class NoSearchedInstantCartsFound extends StatelessWidget {

  final String searchWord;
  final Function navigateToAddInstantCart;

  NoSearchedInstantCartsFound({ required this.searchWord, required this.navigateToAddInstantCart });

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
            child: SvgPicture.asset('assets/icons/ecommerce_pack_1/shopping-cart-10.svg', color: Colors.blue, width: 40,)
          ),
          SizedBox(height: 30),
          Text('No search results', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
        
          SizedBox(height: 30),
          AddInstantCartButton(
            navigateToAddInstantCart: navigateToAddInstantCart,
          ),

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
                      TextSpan(text: 'We could not find any instant carts matching the keyword '),
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

class AddInstantCartButton extends StatelessWidget {

  final Function navigateToAddInstantCart;

  AddInstantCartButton({ required this.navigateToAddInstantCart });

  @override
  Widget build(BuildContext context) {

    return CustomButton(
      width: 300,
      text: '+ Add Instant Cart',
      onSubmit: () async {
        navigateToAddInstantCart();
      }, 
    );
  }
}

class InstantCartList extends StatelessWidget {
  final PaginatedInstantCarts paginatedInstantCarts;
  final List<InstantCart> instantCarts;
  final Function removeinstantCart;
  final Function fetchInstantCarts;
  final bool isLoadingMore;
  final searchWord;

  InstantCartList({ 
    required this.paginatedInstantCarts, required this.instantCarts, required this.removeinstantCart,
    required this.fetchInstantCarts, required this.isLoadingMore, required this.searchWord
  });

  @override
  Widget build(BuildContext context) {

    Widget buildInstantCartListView(List<InstantCart> instantCarts){

      var currNumberOfInstantCarts = instantCarts.length;

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: instantCarts.length,
        itemBuilder: (ctx, index){

          final instantCart = instantCarts[index];
          final instantCartCard = InstantCartCard(instantCart: instantCart, searchWord: searchWord, fetchInstantCarts: fetchInstantCarts);

          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (dismissDirection) async {
              final bool isDeleted = await Provider.of<InstantCartsProvider>(context, listen: false).handleDeleteInstantCart(
                instantCart: instantCart, 
                context: ctx
              //  Default to false if null value
              ) ?? false;

              if( isDeleted ){

                //  Decrement the current number of instant carts by one
                currNumberOfInstantCarts--;

                //  Remove the instant cart from the list of instant carts
                removeinstantCart(instantCart.id, currNumberOfInstantCarts);

              }

              //  Determine whether to dismiss the instant cart card
              return isDeleted;

            },
            child: instantCartCard,
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
          buildInstantCartListView(instantCarts),
          SizedBox(height: 40),
          if(paginatedInstantCarts.count < paginatedInstantCarts.total && isLoadingMore == true) CustomLoader(),
          if(paginatedInstantCarts.count == paginatedInstantCarts.total && isLoadingMore == false) Text('No more instant carts'),
          SizedBox(height: 60),
        ],
      );

  }
}

class InstantCartCard extends StatelessWidget {

  final String searchWord;
  final InstantCart instantCart;
  final Function fetchInstantCarts;

  InstantCartCard({ required this.instantCart, required this.searchWord, required this.fetchInstantCarts });

  void navigateToInstantCart(BuildContext context) async {

    final instantCartsProvider = Provider.of<InstantCartsProvider>(context, listen: false);
         
    //  Set the selected instant cart on the InstantCartsProvider
    instantCartsProvider.setInstantCart(instantCart);

    await Get.to(() => CreateInstantCartScreen());

    //  Refetch the instant carts as soon as we return back
    fetchInstantCarts(searchWord: searchWord, resetPage: true);
  }

  Widget forwardArrowButton(BuildContext context){
    return TextButton(
      onPressed: (){
        navigateToInstantCart(context);
      }, 
      child: Icon(Icons.arrow_forward, color: Colors.grey,),
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          )
        )
      )
    );
  }

  Widget optionsButton(BuildContext context){
    return CustomButton(
      width: 100,
      size: 'small',
      text: 'Subscribe',
      solidColor: true,
      margin: EdgeInsets.only(right: 10),
      onSubmit: () {
        Provider.of<InstantCartsProvider>(context, listen: false).launchPaymentShortcode(
          instantCart: instantCart,
          context: context
        );
      }
    );
  }

  Widget instantCartNameAndDialingCode(bool hasSubscription, bool hasVisitShortCode, visitShortCodeDialingCode){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget> [

        //  Instant Cart Name
        instantCartName(),
        
        SizedBox(width: 10),

        //  Store Dialing Code
        if(hasSubscription && hasVisitShortCode) 
          visitDialingCode(visitShortCodeDialingCode),

        //  Store Dialing Code (Unknown)
        if(hasSubscription && !hasVisitShortCode) 
          noShortcodeDesclaimer(),
          
        ]
    );
  }

  Widget instantCartName(){
    return Text(instantCart.name, style: TextStyle(fontWeight: FontWeight.bold));
  }

  Widget visitDialingCode(String visitShortCodeDialingCode){
    return Text(visitShortCodeDialingCode);
  }

  Widget noShortcodeDesclaimer(){
    return Text('No shortcode', style: TextStyle(color: Colors.red));
  }

  Widget subscriptionEnded(){
    return Text('Subscription ended', style: TextStyle(color: Colors.red),);
  }

  Widget subscriptionCountDown(int endTime){
    return CustomCountdown(
      onEnd: (){
        //  Refetch the stores
        fetchInstantCarts(searchWord: searchWord, resetPage: true);
      },
      endTime: endTime,
      endWidget: subscriptionEnded()
    );
  }

  @override
  Widget build(BuildContext context) {

    //  Subscription information
    final subscription = instantCart.attributes.subscription;
    final hasSubscription = instantCart.attributes.hasSubscription;
    final subscriptionExpiryTime = (hasSubscription ? subscription!.endAt : null);

    //  Visit shortcode information
    final visitShortCode = instantCart.attributes.visitShortCode;
    final hasVisitShortCode = instantCart.attributes.hasVisitShortCode;
    final visitShortCodeDialingCode = (hasVisitShortCode ? visitShortCode!.dialingCode : '');

    //  Time to visit shortcode expiry
    final endTime = (subscriptionExpiryTime == null) ? DateTime.now().millisecondsSinceEpoch : subscriptionExpiryTime.millisecondsSinceEpoch;

    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Card(
        elevation: 3,
        child: Stack(
          children: <Widget> [
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
          
                  //  Store Name & Dialing Code
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget> [
                      
                      //  Store Name and Dialing code
                      instantCartNameAndDialingCode(hasSubscription, hasVisitShortCode, visitShortCodeDialingCode),

                      //  Subscription End Date 
                      if(hasSubscription) subscriptionCountDown(endTime)

                    ], 

                  ),
          
                  Container(
                    child:
                      hasSubscription
                        //  Arrow Button
                        ? forwardArrowButton(context)
                        //  Options Button
                        : optionsButton(context)
                  )
                  
                ]
              ),
            ),

            //  InkWell splash color
            if(hasSubscription == true)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Ink(
                    height: 78,
                    width: double.infinity,
                  ),
                  onTap: () async {
                    if( hasSubscription ){
                      navigateToInstantCart(context);
                    }
                  }, 
                )
              )
          ],
        ),
      ),
    );
  }
}