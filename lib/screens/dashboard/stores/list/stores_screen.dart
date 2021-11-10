import 'package:bonako_app_3/components/custom_instruction_message.dart';
import 'package:bonako_app_3/components/custom_search_bar.dart';
import './../../../../../components/custom_rounded_refresh_button.dart';
import './../../../../screens/dashboard/stores/show/store_screen.dart';
import '../../../../components/custom_floating_action_button.dart';
import './../../../../../components/custom_button.dart';
import './../../../../../components/custom_loader.dart';
import './../../../../components/custom_countdown.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/store_drawer.dart';
import './../create/create_store_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../providers/stores.dart';
import './../../../../../models/stores.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../../../../constants.dart';
import 'package:async/async.dart';
import 'package:get/get.dart';
import 'dart:convert';

class StoresScreen extends StatelessWidget {

  static const routeName = '/stores';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFloatingActionButton(),
      appBar: CustomAppBar(title: 'Stores'),
      drawer: StoreDrawer(),
      body: Content(),
    );
  }
}

class Content extends StatelessWidget {

  Widget createdStores(){
    return StoreList(
      title: 'My stores',
      subtitle: 'Stores created by you'
    );
  }

  Widget sharedStores(){
    return StoreList(
      shared: true,
      title: 'Shared stores',
      subtitle: 'Stores shared by others'
    );
  }

  Widget tabViews(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,  //  Height of TabBarView
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1))
      ),
      child: TabBarView(children: <Widget>[
        createdStores(),
        sharedStores(),
      ])
    );
  }

  Widget tabOptions() {
    return Container(
      child: TabBar(
        labelColor: Colors.blue,
        indicatorColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        tabs: <Widget> [
          tabOption('Created Stores'),
          tabOption('Shared Stores')
        ],
      ),
    );
  }

  Widget tabOption(String text){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Tab(text: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget> [
          tabOptions(),
          tabViews(context)
        ]
      )
    );
  }
}

class StoreList extends StatefulWidget {
  
  final bool shared;
  final String title;
  final String subtitle;

  StoreList({ this.title = '', this.subtitle = '', this.shared = false });

  @override
  _StoreListState createState() => _StoreListState();

}

class _StoreListState extends State<StoreList> {

  late ScrollController scrollController;
  late List<Store> stores = [];
  var isLoadingMore = false;
  var cancellableOperation;
  var isSearching = false;
  String searchWord = '';
  var isLoading = false;
  var paginatedStores;
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
    fetchStores();
    scrollController = new ScrollController()..addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Future<http.Response> fetchStores({ String searchWord: '', bool loadMore = false, bool resetPage = false, bool refreshContent = false, int limit = 10 }) async {
    
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

    final storesProvider = Provider.of<StoresProvider>(context, listen: false);

    /*
     * Fetch the user shared / created stores
     */
    final apiInstance = widget.shared 
      ? storesProvider.fetchSharedStores(searchWord: searchWord, page: page, limit: limit, context: context) 
      : storesProvider.fetchCreatedStores(searchWord: searchWord, page: page, limit: limit, context: context);

    cancellableOperation = CancelableOperation.fromFuture (
      apiInstance,
      onCancel: () => (cancellableOperation = null)
    );
    
    cancellableOperation.value.then((http.Response response){

      if(response.statusCode == 200 && mounted){

        final responseBody = jsonDecode(response.body);

        setState(() {

          //  If we are loading more stores
          if(loadMore == true){

            //  Add loaded stores to the list of existing paginated stores
            (paginatedStores as PaginatedStores).embedded.stores.addAll(PaginatedStores.fromJson(responseBody).embedded.stores);

            //  Re-calculate the store count
            (paginatedStores as PaginatedStores).count += PaginatedStores.fromJson(responseBody).count;

            //  Increment the current page
            (paginatedStores as PaginatedStores).currentPage = currentPage;

          }else{

            paginatedStores = PaginatedStores.fromJson(responseBody);

          }

          stores = (paginatedStores as PaginatedStores).embedded.stores;

        });

      }

      return response;

    });
    
    cancellableOperation.value.whenComplete(() {

      stopLoader(loadMore: loadMore);

    });

    return cancellableOperation.value;

  }

  Future<http.Response> startSearch({ searchWord: '' }) async {
    if(mounted){
      setState(() {
          this.searchWord = searchWord;
      });
    }
      
    return await fetchStores(searchWord: searchWord, resetPage: true);
  }

  void _scrollListener() {

    //  If we are 100 pixels or less from the scroll bottom
    if (scrollController.position.extentAfter == 0) {

      if( isLoading == false && isLoadingMore == false && paginatedStores.count < paginatedStores.total){
        
        fetchStores(searchWord: searchWord, loadMore: true);

      }
      
    }
    
  }

  Widget title(){
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Text(
        widget.title,
        style: Theme.of(context).textTheme.headline6,
      )
    );
  }

  Widget refreshButton(){
    return CustomRoundedRefreshButton(onPressed: isLoading ? null : (){
        
      if(paginatedStores == null){

        fetchStores(searchWord: searchWord, resetPage: true);

      }else{

        /**
         *  If the total number of stores exceeds the per page limit, then request that we 
         *  refetch the same number of stores e.g If we limit by 10 per page, but we already 
         *  loaded 20, then we should still load 20 when we refresh instead of the 10 limit.
         */
        final limit = (paginatedStores.count > paginatedStores.perPage) ? paginatedStores.count : paginatedStores.perPage;

        fetchStores(searchWord: searchWord, refreshContent: true, limit: limit);

      }

    });
  }

  Widget titleAndRefreshButton(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget> [

        //  Title
        title(), 

        //  Rounded Refresh Button
        refreshButton()

      ],
    );
  }

  Widget subtitle(){
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Text(
        widget.subtitle,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(fontWeight: FontWeight.normal, color: Colors.grey),
      ),
    );
  }

  Widget searchBar(){
    return CustomSearchBar(
      labelText: 'Search stores',
      onSearch: (searchWord){
        startSearchLoader();
        return startSearch(searchWord: searchWord).whenComplete(() => stopSearchLoader());
      }
    );
  }

  Widget paginationResultSummary(){
    return Column(
      children: <Widget> [
        CustomInstructionMessage(text: 'Showing '+paginatedStores.count.toString()+' / '+paginatedStores.total.toString()+' stores'),
        Divider()
      ],
    );
  }

  Widget noStoresDesclaimer(){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: <Widget> [
          SvgPicture.asset('assets/icons/ecommerce_pack_1/shop.svg', width: 24),
          SizedBox(width: 10),
          Text('No stores found'),
        ],
      ),
    );
  }

  Widget noMoreStoresDesclaimer(){
    return Center(
      child: Text('No more stores')
    );
  }

  List<Widget> storeCards(List<Store> stores){

    return stores.map((store) {
      return StoreCard(store: store, shared: this.widget.shared, searchWord: searchWord, fetchStores: fetchStores);
    }).toList();

  }

  bool get hasStores {
    return (stores.length > 0);
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            
            //  Title & Refresh Button
            titleAndRefreshButton(),
    
            //  Subtitle
            subtitle(),
    
            //  Divider
            Divider(),

            //  Search bar
            searchBar(),
    
            //  Loader
            if(isLoading == true) CustomLoader(),

            //  Pagination result summary
            if(isLoading == false && hasStores == true) paginationResultSummary(),
    
            //  No stores desclaimer
            if(isLoading == false && stores.length == 0) noStoresDesclaimer(),
    
            //  List of store card widgets
            if(isLoading == false && stores.length > 0) ...storeCards(stores),

            SizedBox(height: 20),

            //  Loader (Loading more)
            if(isLoading == false && isLoadingMore == true && paginatedStores.count < paginatedStores.total) CustomLoader(),
            
            //  No more stores desclaimer
            if(isLoading == false && isLoadingMore == false && stores.length != 0 && paginatedStores.count == paginatedStores.total) noMoreStoresDesclaimer(),
            
            SizedBox(height: 80),
            
          ],
        ),
      ),
    );
  }
}

class StoreCard extends StatelessWidget {

  final Store store;
  final bool shared;
  final String searchWord;
  final Function fetchStores;

  StoreCard({ required this.store, required this.shared, required this.searchWord, required this.fetchStores });

  Widget forwardArrowButton(){
    return TextButton(
      onPressed: (){
        Get.to(() => ShowStoreScreen());
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

  Widget optionsButton(){
    return Row(
      children: <Widget> [

        SvgPicture.asset('assets/icons/ecommerce_pack_1/padlock-1.svg', width: 16),
        SizedBox(width: 20),
        StoreCardOptionButton(store: store, shared: shared, searchWord: searchWord, fetchStores: fetchStores)

      ]
    );
  }

  Widget storeNameAndDialingCode(bool hasSubscription, bool hasVisitShortCode, visitShortCodeDialingCode){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget> [

        //  Store Name
        storeName(),
        
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

  Widget storeName(){
    return Text(store.name, style: TextStyle(fontWeight: FontWeight.bold));
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
        fetchStores(searchWord: searchWord, resetPage: true);
      },
      endTime: endTime,
      endWidget: subscriptionEnded()
    );
  }

  @override
  Widget build(BuildContext context) {

    //  Subscription information
    final subscription = store.attributes.subscription;
    final hasSubscription = store.attributes.hasSubscription;
    final subscriptionExpiryTime = (hasSubscription ? subscription!.endAt : null);

    //  Visit shortcode information
    final visitShortCode = store.attributes.visitShortCode;
    final hasVisitShortCode = store.attributes.hasVisitShortCode;
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
                      storeNameAndDialingCode(hasSubscription, hasVisitShortCode, visitShortCodeDialingCode),

                      //  Subscription End Date 
                      if(hasSubscription) subscriptionCountDown(endTime)

                    ], 

                  ),
          
                  Container(
                    child:
                      hasSubscription
                        //  Arrow Button
                        ? forwardArrowButton()
                        //  Options Button
                        : optionsButton()
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
                      
                      //  Set the selected store on the StoresProvider
                      Provider.of<StoresProvider>(context, listen: false).setStore(store);

                      //  Navigate to show store screen
                      await Get.to(() => ShowStoreScreen());

                      //  Refetch stores on return
                      fetchStores(searchWord: searchWord, resetPage: true);
                      
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

class StoreCardOptionButton extends StatelessWidget {

  final Store store;
  final bool shared;
  final String searchWord;
  final Function fetchStores;

  StoreCardOptionButton({ required this.store, required this.shared, required this.searchWord, required this.fetchStores });

  void showOptionsDialog(BuildContext context){

    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(store.name),
          children: <Widget> [

            Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text(
                shared ? 'Subscribe to access this store'
                      : 'Subscribe to access this store and start adding products and receiving orders.'
              ),
            ),

            Divider(),

            //  Subscribe option
            StoreDialogOption(
              title: 'Subscribe',
              svg: 'assets/icons/ecommerce_pack_1/mobile-phone-2.svg',
              onPressed: () async {

                Provider.of<StoresProvider>(context, listen: false).launchPaymentShortcode(
                  store: store,
                  context: context
                );

              }
            ),

            //  Invite option
            if(shared == false)
              StoreDialogOption(
                title: 'Invite team',
                svg: 'assets/icons/ecommerce_pack_1/add-contact.svg',
                onPressed: (){
                  Navigator.of(context).pop();
                  showInviteStaffDialog(context);
                },
              ),

            Divider(),

            //  Delete option
            if(shared == false)
              StoreDialogOption(
                title: 'Delete',
                color: Colors.red,
                svg: 'assets/icons/ecommerce_pack_1/delete.svg',
                onPressed: () async {

                  //  Remove the alert dialog
                  Navigator.of(context).pop();

                  Provider.of<StoresProvider>(context, listen: false).handleDeleteStore(
                    store: store,
                    context: context
                  ).whenComplete((){

                    //  Re-fetch the stores
                    fetchStores(searchWord: searchWord, resetPage: true);

                  });

                }
              ),

            //  Delete option
            if(shared == true)
              StoreDialogOption(
                title: 'Decline invitation',
                color: Colors.red,
                svg: 'assets/icons/ecommerce_pack_1/delete.svg'
              ),
          ],
        );
      }
    );

  }

  void showInviteStaffDialog(BuildContext context){

    showDialog(
      context: context, 
      builder: (BuildContext context) {
  
        //  Set the form key
        final GlobalKey<FormState> _formKey = GlobalKey();
        bool isSubmitting = false;
        Map staffMemberForm = {
          'mobile_number': ''
        };

        void onSubmit() {
    
          //  If local validation passed
          if( _formKey.currentState!.validate() == true ){

            //  Save inputs
            _formKey.currentState!.save();

            /*
            startSubmitLoader();

            if( isEditing ){

              productsProvider.updateProduct(
                body: productForm,
                context: context
              ).then((response){

                if(response.statusCode == 200){

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
                
                if(response.statusCode == 200){

                  showSnackbarMessage('Product created successfully');

                }

                _handleOnSubmitResponse(response);

              }).whenComplete((){
                
                stopSubmitLoader();

              });

            }

            */
          
          //  If validation failed
          }

        }

        return StatefulBuilder(
          builder: (context, setState) {
            return SimpleDialog(
              title: Text(store.name),
              children: <Widget> [
          
                Divider(),
          
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Text(
                    'Invite staff members to assist in managing ' + store.name + '. Simply enter the mobile number of the staff member to invite.'
                  ),
                ),
          
                Divider(),
          
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
          
                        TextFormField(
                          initialValue: staffMemberForm['mobile_number'],
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'e.g 72000123',
                            border: InputBorder.none,
                              fillColor: Colors.black.withOpacity(0.05),
                            filled: true
                          ),
                          validator: (value){
                            if(value == null || value.isEmpty){
                              return 'Please enter mobile number';
                            }
                          },
                          onChanged: (value){
                            staffMemberForm['mobile_number'] = value;
                          },
                          onSaved: (value){
                            staffMemberForm['mobile_number'] = value;
                          },
                        ),
          
                        Divider(height: 20),
          
                        CustomButton(
                          text: 'Invite',
                          isLoading: isSubmitting,
                          onSubmit: (isSubmitting) ? null : onSubmit,
                        ),
          
                      ]
                    )
                  ),
                )
          
              ],
            );
          }
        );
      }
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 15),
      child: ElevatedButton(
        onPressed: () => {
          showOptionsDialog(context)
        }, 
        child: Text('Options', style: TextStyle(fontSize: 12),),
        style:  ElevatedButton.styleFrom(
          primary: Colors.blue,
        ),
      ),
    );
  }
}

class StoreDialogOption extends StatelessWidget {

  final String title;
  final Color? color;
  final String? svg;
  final Function()? onPressed;

  const StoreDialogOption({ this.title = 'Option', this.color, this.svg, this.onPressed });

  @override
  Widget build(BuildContext context) {

    bool hasSvg = (svg != null);
    bool hasColor = (color != null);

    return SimpleDialogOption(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      onPressed: onPressed,
      child: Row(
        children: <Widget> [
          if(hasSvg) SvgPicture.asset(svg!, width: 20, color: hasColor ? color : Colors.black,),
          SizedBox(width: 10), 
          Text(title, style: TextStyle(
            color: hasColor ? color : Colors.black,
            fontSize: 14
          ))
        ]
      )
    );
  }
}