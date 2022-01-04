import 'package:bonako_mobile_app/components/custom_instruction_message.dart';
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
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/coupons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../coupons/create/create.dart';
import './../../../../providers/stores.dart';
import './../../../../models/coupons.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'dart:convert';

class CouponsScreen extends StatefulWidget {
  @override
  _CouponsScreenState createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  bool isLoadingMore = false;
  var cancellableOperation;
  bool isLoading = false;
  var paginatedCoupons;
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
    
    fetchCoupons();

    super.initState();

  }

  Future<http.Response> fetchCoupons({ String searchWord: '', bool loadMore = false, bool resetPage = false, bool refreshContent = false, int limit = 10 }) async {
    
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

    final couponsProvider = Provider.of<CouponsProvider>(context, listen: false);

    final apiInstance = (couponsProvider.fetchCoupons(searchWord: searchWord, page: page, limit: limit, context: context));

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

          //  If we are loading more coupons
          if(loadMore == true){

            //  Add loaded coupons to the list of existing paginated coupons
            (paginatedCoupons as PaginatedCoupons).embedded.coupons.addAll(PaginatedCoupons.fromJson(responseBody).embedded.coupons);

            //  Re-calculate the coupon count
            (paginatedCoupons as PaginatedCoupons).count += PaginatedCoupons.fromJson(responseBody).count;

            //  Increment the current page
            (paginatedCoupons as PaginatedCoupons).currentPage = currentPage;

          }else{

            paginatedCoupons = PaginatedCoupons.fromJson(responseBody);

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
          onAddCoupon: (){
            fetchCoupons(resetPage: true);
          }
        ),
        appBar: CustomAppBar(title: 'Coupons'),
        drawer: StoreDrawer(),
        body: Content(
          paginatedCoupons: paginatedCoupons,
          fetchCoupons: fetchCoupons,
          isLoadingMore: isLoadingMore,
          isLoading: isLoading
        ),
      )
    );
  }
}

class Content extends StatefulWidget {

  final PaginatedCoupons? paginatedCoupons;
  final Function fetchCoupons;
  final bool isLoadingMore;
  final bool isLoading;

  Content({ this.paginatedCoupons, required this.isLoadingMore, required this.isLoading, required this.fetchCoupons });
  
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late ScrollController scrollController;
  List<Coupon> coupons = [];
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

    setCoupons();

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

      final paginatedCoupons = (widget.paginatedCoupons as PaginatedCoupons);

      if( widget.isLoading == false && widget.isLoadingMore == false && paginatedCoupons.count < paginatedCoupons.total){
        
        widget.fetchCoupons(searchWord: searchWord, loadMore: true);

      }
      
    }

  }

  @override
  void didUpdateWidget(covariant Content oldWidget) {

    setCoupons();
    
    super.didUpdateWidget(oldWidget);

  }

  void setCoupons(){

    //  If we have the paginated coupons
    if( widget.paginatedCoupons != null ){

      //  Extract the coupons
      coupons = widget.paginatedCoupons!.embedded.coupons;

    }

  }

  Future<http.Response> startSearch({ searchWord: '' }) async {
    if(mounted){
      setState(() {
          this.searchWord = searchWord;
      });
    }
      
    return await widget.fetchCoupons(searchWord: searchWord, resetPage: true);
  }

  void navigateToAddCoupon() async {
    
    final couponsProvider = Provider.of<CouponsProvider>(context, listen: false);

    await couponsProvider.navigateToAddCoupon();

    //  Refetch the coupons as soon as we return
    widget.fetchCoupons(resetPage: true);

  }

  void removeCoupon(int couponId, int currNumberOfCoupons){

    setState(() {
      coupons.removeWhere((coupon) => coupon.id == couponId);
      
      //  If the current number of coupons is Zero 
      if(currNumberOfCoupons == 0){

        //  Fetch the coupons from the server
        widget.fetchCoupons(searchWord: searchWord, resetPage: true);

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

  bool get hasCoupons {
    return (coupons.length > 0);
  }

  Future getFiltersFromDevice() async {
    
    await SharedPreferences.getInstance().then((prefs) async {

      final filters = await jsonDecode(prefs.getString('couponFilters') ?? '{}');

      updateActiveFilters(filters);

    });

  }

  void updateActiveFilters(Map filters){

    setState(() {

      //  Extract only the active filters
      activeFilters = Map.from(filters)..removeWhere((key, value) => (value == false));

    });

    widget.fetchCoupons(searchWord: searchWord, resetPage: true);

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
          prefs.setString('couponFilters', jsonEncode(filters));

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
          title: Text('Coupon Filters'),
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
                      TextSpan(text: ' to limit coupons to show.'),
                    ],
                  ),
                ),
                Divider(height: 10,),

                if(isLoading || hasFilters() == false) CustomLoader(),

                if(hasFilters()) filterSwitch(
                  text: 'Show active coupons',
                  value: filters['active'],
                  onChanged: (status){
                    toggleFilter('active');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show inactive coupons',
                  value: filters['inactive'],
                  onChanged: (status){
                    toggleFilter('inactive');
                  },
                ),
                if(hasFilters()) filterSwitch(
                  text: 'Show coupons offering free delivery',
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

            var couponFilters = prefs.getString('couponFilters');

            //  If we have no coupon filters
            if(couponFilters == null){

              //  Store the default filters
              prefs.setString('couponFilters', jsonEncode(defaultFilters));

              //  return the default filters
              return defaultFilters;
              
            }else{
              
              //  Get the filters stored on the device
              final Map storedFilters = jsonDecode( prefs.getString('couponFilters') ?? '{}');

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
                await prefs.setString('couponFilters', jsonEncode(mergedFilters));

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
                
                if(widget.paginatedCoupons == null){

                  widget.fetchCoupons(searchWord: searchWord, resetPage: true);

                }else{

                  /**
                   *  If the total number of coupons exceeds the per page limit, then request that we 
                   *  refetch the same number of coupons e.g If we limit by 10 per page, but we already 
                   *  loaded 20, then we should still load 20 when we refresh instead of the 10 limit.
                   */
                  final limit = (widget.paginatedCoupons!.count > widget.paginatedCoupons!.perPage) ? widget.paginatedCoupons!.count : widget.paginatedCoupons!.perPage;

                  widget.fetchCoupons(searchWord: searchWord, refreshContent: true, limit: limit);

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
          
                  if(hasCoupons || isSearching || searchWord != '') Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                
                      //  Search Bar
                      Expanded(
                        child: CustomSearchBar(
                          labelText: 'Search coupons',
                          helperText: 'Search using coupon name',
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
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && locationTotals.couponTotals.total > 0)
                    FilterTag(
                      activeFilters: activeFilters,
                      showFiltersDialog: showFiltersDialog,
                    ),

                  if((isLoading == false && widget.isLoading == false) && hasCoupons == true) Column(
                    children: [
                      Divider(),

                      if(hasSearchWord && widget.paginatedCoupons != null) 
                        CustomInstructionMessage(text: 'Showing '+widget.paginatedCoupons!.count.toString()+' / '+widget.paginatedCoupons!.total.toString()+' matches'),

                      if(isSearching == false && hasActiveFilters == false)
                        CustomInstructionMessage(text: 'Swipe any coupon to the right to delete'),

                      if(isSearching == false && hasSearchWord == false && hasActiveFilters == true) 
                        CustomInstructionMessage(text: 'Filters have been added to limit coupons'),

                      Divider()
                    ],
                  ),

                  //  Loader
                  if(isLoading == true || widget.isLoading == true) CustomLoader(topMargin: 100),
                  
                  //  Coupon list
                  if((isLoading == false && widget.isLoading == false) && hasCoupons == true)
                    CouponList(
                      paginatedCoupons: widget.paginatedCoupons!,
                      isLoadingMore: widget.isLoadingMore,
                      fetchCoupons: widget.fetchCoupons,
                      removeCoupon: removeCoupon,
                      searchWord: searchWord,
                      coupons: coupons,
                    ),
          
                  //  No coupons found
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && hasCoupons == false && hasSearchWord == false)
                    NoCouponsFound(
                      navigateToAddCoupon: navigateToAddCoupon
                    ),
          
                  //  No coupons found
                  if((isLoading == false && widget.isLoading == false && isSearching == false) && hasCoupons == false && hasSearchWord == true)
                    NoSearchedCouponsFound(
                      searchWord: searchWord, 
                      navigateToAddCoupon: navigateToAddCoupon
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

class NoCouponsFound extends StatelessWidget {

  final Function navigateToAddCoupon;

  NoCouponsFound({ required this.navigateToAddCoupon });

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
          child: SvgPicture.asset('assets/icons/ecommerce_pack_1/discount-coupon.svg', color: Colors.blue, width: 40,)
        ),
        
        SizedBox(height: 30),

        Text('No coupons found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
        
        SizedBox(height: 30),

        AddCouponButton(
          navigateToAddCoupon: navigateToAddCoupon,
        ),

        SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.all(20),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, height: 1.5),
              children: <TextSpan>[
                TextSpan(text: 'Add coupons to your store and ask customers to dial '),
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

class NoSearchedCouponsFound extends StatelessWidget {

  final String searchWord;
  final Function navigateToAddCoupon;

  NoSearchedCouponsFound({ required this.searchWord, required this.navigateToAddCoupon });

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
            child: SvgPicture.asset('assets/icons/ecommerce_pack_1/discount-coupon.svg', color: Colors.blue, width: 40,)
          ),
          SizedBox(height: 30),
          Text('No search results', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
        
          SizedBox(height: 30),
          AddCouponButton(
            navigateToAddCoupon: navigateToAddCoupon
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
                      TextSpan(text: 'We could not find any coupons matching the keyword '),
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

class AddCouponButton extends StatelessWidget {

  final Function navigateToAddCoupon;

  AddCouponButton({ required this.navigateToAddCoupon });

  @override
  Widget build(BuildContext context) {

    return CustomButton(
      width: 300,
      text: '+ Add Coupon',
      onSubmit: () async {
        navigateToAddCoupon();
      }, 
    );
  }
}

class CouponList extends StatelessWidget {
  final PaginatedCoupons paginatedCoupons;
  final Function removeCoupon;
  final Function fetchCoupons;
  final List<Coupon> coupons;
  final bool isLoadingMore;
  final searchWord;

  CouponList({ 
    required this.paginatedCoupons, required this.coupons, required this.removeCoupon,
    required this.fetchCoupons, required this.isLoadingMore, required this.searchWord
  });

  @override
  Widget build(BuildContext context) {

    Widget buildCouponListView(List<Coupon> coupons){

      var currNumberOfCoupons = coupons.length;

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: coupons.length,
        itemBuilder: (ctx, index){

          final Coupon coupon = coupons[index];
          final couponCard = CouponCard(coupon: coupon, searchWord: searchWord, fetchCoupons: fetchCoupons);

          return Dismissible(
            key: ValueKey(coupon.id),
            direction: DismissDirection.startToEnd,
            confirmDismiss: (dismissDirection) async {
              final bool isDeleted = await Provider.of<CouponsProvider>(context, listen: false).handleDeleteCoupon(
                coupon: coupon, 
                context: ctx
              //  Default to false if null value
              ) ?? false;

              if( isDeleted ){

                //  Decrement the current number of coupons by one
                currNumberOfCoupons--;

                //  Remove the coupon from the list of coupons
                removeCoupon(coupon.id, currNumberOfCoupons);

              }

              //  Determine whether to dismiss the coupon card
              return isDeleted;

            },
            child: couponCard,
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
          buildCouponListView(coupons),
          SizedBox(height: 40),
          if(paginatedCoupons.count < paginatedCoupons.total && isLoadingMore == true) CustomLoader(),
          if(paginatedCoupons.count == paginatedCoupons.total && isLoadingMore == false) Text('No more coupons'),
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

class CouponCard extends StatelessWidget {

  final Coupon coupon;
  final String searchWord;
  final Function fetchCoupons;

  CouponCard({ required this.coupon, required this.searchWord, required this.fetchCoupons });

  @override
  Widget build(BuildContext context) {

    final couponsProvider = Provider.of<CouponsProvider>(context, listen: false);

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
                
                      //  Coupon name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              coupon.name,
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
                            if(coupon.active.status == true && coupon.applyDiscount.status && coupon.discountRateType.type == 'PercenCustomTage') CustomTag(text: 'Discount ('+coupon.percentageRate.toString()+'%)'),
                            if(coupon.active.status == true && coupon.applyDiscount.status && coupon.discountRateType.type == 'Fixed') CustomTag(text: 'Fixed Discount ('+coupon.currency.code+coupon.fixedRate.amount.toString()+')'),
                            if(coupon.active.status == true && coupon.allowFreeDelivery.status) CustomTag(text: 'Free delivery'),
                            if(coupon.active.status == true && coupon.activationType.type == 'use code') CustomTag(text: 'Code ', boldedText: coupon.code.toString()),

                            if(coupon.active.status == true && coupon.hasQuantityRemaining.name == 'Unlimited') CustomTag(text: 'Unlimited available'),
                            if(coupon.active.status == true && coupon.hasQuantityRemaining.name == 'Finished') CustomTag(text: 'No coupons', color: Colors.amber),
                            if(coupon.active.status == true && coupon.hasQuantityRemaining.name == 'Limited') CustomTag(text: coupon.quantityRemaining.toString()+' left'),

                            if(coupon.active.status == false) CustomTag(text: coupon.active.name, color: Colors.amber)
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
                  
                //  Set the selected coupon on the CouponsProvider
                couponsProvider.setCoupon(coupon);

                await Get.to(() => CreateCouponScreen());

                //  Refetch the coupons as soon as we return back
                fetchCoupons(searchWord: searchWord, resetPage: true);

              }, 
            )
          )
        ]
      )
    );
  }
}