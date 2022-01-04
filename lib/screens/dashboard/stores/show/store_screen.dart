import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/providers/coupons.dart';
import 'package:bonako_mobile_app/providers/instant_carts.dart';
import 'package:bonako_mobile_app/providers/products.dart';
import 'package:bonako_mobile_app/providers/users.dart';
import 'package:bonako_mobile_app/screens/dashboard/coupons/list/coupons_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/customers/list/customers_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/instant_carts/list/instant_carts_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/verify/order_options_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/show/settings/settings.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/list/users_screen.dart';

import './.././../../../../components/custom_rounded_refresh_button.dart';
import '././../../../../screens/dashboard/stores/list/stores_screen.dart';
import '../../../../components/custom_floating_action_button.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_countdown.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_loader.dart';
import './../../../../components/store_drawer.dart';
import './../../products/list/products_screen.dart';
import '../../../../models/locationTotals.dart';
import './../../orders/list/orders_screen.dart';
import './../../../../providers/locations.dart';
import './../../../../providers/stores.dart';
import './../../../../models/locations.dart';
import './../../../../models/stores.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:convert';

class ShowStoreScreen extends StatefulWidget {

  @override
  _ShowStoreScreenState createState() => _ShowStoreScreenState();
}

class _ShowStoreScreenState extends State<ShowStoreScreen> {

  Store? store;
  Location? location;
  bool isLoadingStore = false;
  bool isLoadingTotals = false;
  LocationTotals? locationTotals;
  bool isLoadingLocation = false;
  bool isLoadingPermissions = false;
  List<String> locationPermissions = [];

  void startStoreLoader(){
    setState(() {
      isLoadingStore = true;
    });
  }

  void stopStoreLoader(){
    setState(() {
      isLoadingStore = false;
    });
  }

  void startLocationLoader(){
    if (mounted) {
      setState(() {
        isLoadingLocation = true;
      });
    }
  }

  void stopLocationLoader(){
    if (mounted) {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  void startTotalsLoader(){
    if (mounted) {
      setState(() {
        isLoadingTotals = true;
      });
    }
  }

  void stopTotalsLoader(){
    if (mounted) {
      setState(() {
        isLoadingTotals = false;
      });
    }
  }

  void startPermissionsLoader(){
    if (mounted) {
      setState(() {
        isLoadingPermissions = true;
      });
    }
  }

  void stopPermissionsLoader(){
    if (mounted) {
      setState(() {
        isLoadingPermissions = false;
      });
    }
  }

  StoresProvider get storesProvider {
    return Provider.of<StoresProvider>(context, listen: false);
  }

  @override
  void initState() {
                
    //  Get the default store from the StoresProvider
    store = storesProvider.getStore;
    
    fetchLocation();

    super.initState();

  }

  Future<http.Response> fetchStore(){

    startStoreLoader();

    return storesProvider.fetchStore(context: context)
      .then((response){
        if(response.statusCode == 200){
          final store = jsonDecode(response.body);
          storesProvider.setStore(Store.fromJson(store));
        }
        return response;
      }).whenComplete((){
        stopStoreLoader();
      });

  }

  Future<http.Response> fetchLocation(){

    startLocationLoader();
    
    final locationsProvider = Provider.of<LocationsProvider>(context, listen: false);
  
    //  Fetch the default store location
    return locationsProvider.fetchLocation(context: context)
      .then((http.Response response) async {
        
        if(response.statusCode == 200 && mounted){

          final responseBody = jsonDecode(response.body);

          setState(() {

            //  Get the location
            location = Location.fromJson(responseBody);

            //  Set the location as the default location
            locationsProvider.setLocation(location!);

            //  Fetch the location totals
            fetchLocationTotals();

            //  Fetch the location user permissions
            fetchMyLocationPermissions();

          });

        }

        return response;

      }).whenComplete((){

        stopLocationLoader();

      });
  }

  Future<http.Response> fetchLocationTotals(){

    startTotalsLoader();

    final locationsProvider = Provider.of<LocationsProvider>(context, listen: false);
  
    //  Fetch the default store location totals
    return locationsProvider.fetchLocationTotals(context: context)
      .then((http.Response response) async {

        if(response.statusCode == 200 && mounted){

          setState(() {

            //  Get the location totals
            locationTotals = locationsProvider.getLocationTotals;

          });

        }

        return response;

      }).whenComplete((){

        stopTotalsLoader();

      });
  }

  Future<http.Response> fetchMyLocationPermissions(){

    startPermissionsLoader();

    final locationsProvider = Provider.of<LocationsProvider>(context, listen: false);
  
    //  Fetch the default store location totals
    return locationsProvider.fetchMyLocationPermissions(context: context)
      .then((http.Response response) async {

        if(response.statusCode == 200 && mounted){

          setState(() {

            //  Get the location permissions
            locationPermissions = new List<String>.from(locationsProvider.getLocationPermissions);

          });

        }

        return response;

      }).whenComplete((){

        stopPermissionsLoader();

      });
  }

  @override
  Widget build(BuildContext context){
                
    //  Get the store from the StoresProvider
    final store = storesProvider.getStore;

    return Scaffold(
      drawer: StoreDrawer(),
      appBar: CustomAppBar(title: isLoadingStore ? CustomLoader(color: Colors.white, topMargin: 0, rightPadding: 50) : Text(store.name)),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButton: CustomFloatingActionButton(
          onAddInstantCart: () async {
            //  If we submitted an instant cart successfully
            await Get.to(() => InstantCartsScreen());
            fetchLocationTotals();
          },
          onAddProduct: () async {
            //  If we submitted a product successfully
            await Get.to(() => ProductsScreen());
            fetchLocationTotals();
          },
          onAddCoupon: () async {
            //  If we submitted a coupon successfully
            await Get.to(() => CouponsScreen());
            fetchLocationTotals();
          },
          onAddUser: () async {
            //  If we submitted a user successfully
            await Get.to(() => UsersScreen());
            fetchLocationTotals();
          }
        ),
      body: Content(
        store: store,
        location: location,
        fetchStore: fetchStore,
        fetchLocation: fetchLocation,
        locationTotals: locationTotals,
        isLoadingStore: isLoadingStore,
        isLoadingTotals: isLoadingTotals,
        isLoadingLocation: isLoadingLocation,
        locationPermissions: locationPermissions,
        fetchLocationTotals: fetchLocationTotals,
        isLoadingPermissions: isLoadingPermissions,
      ),
    );
  }
}

class Content extends StatefulWidget {

  final Store? store;
  final bool isLoadingStore;
  final bool isLoadingTotals;
  final bool isLoadingLocation;
  final Location? location;
  final bool isLoadingPermissions;
  final Function() fetchStore;
  final Function() fetchLocation;
  final LocationTotals? locationTotals;
  final Function() fetchLocationTotals;
  final List<String> locationPermissions;

  Content({ 
    required this.store, required this.location, required this.fetchStore, required this.fetchLocation, 
    required this.isLoadingStore, required this.isLoadingTotals, required this.isLoadingLocation, 
    required this.isLoadingPermissions, required this.locationTotals, required this.fetchLocationTotals, 
    required this.locationPermissions, 
  });

  @override
  _ContentState createState() => _ContentState();

}

class _ContentState extends State<Content> {

  bool get hasStore {
    return (widget.store != null);
  }

  StoresProvider get storesProvider {
    return Provider.of<StoresProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context){

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(onOveride: (){
                
                //  Overide the default function by switching the store
                storesProvider.switchStore(context: context);

              }),
              CustomRoundedRefreshButton(onPressed: widget.fetchLocation),
            ],
          ),
          Divider(height: 0),

          Expanded(
            child: Stack(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        if(hasStore) StoreDialingInstructions(store: widget.store!),
                        SizedBox(height: 10),
                        if(hasStore) SubcsriptionCountdown(store: widget.store!),
                        SizedBox(height: 10),
                  
                        //  Resource Creation Slider
                        if(!widget.isLoadingLocation && !widget.isLoadingTotals && !widget.isLoadingPermissions) ResourceCreationSlider(locationPermissions: widget.locationPermissions),
                  
                        //  Loader
                        if(widget.isLoadingLocation || widget.isLoadingTotals || widget.isLoadingPermissions) Divider(),
                        if(widget.isLoadingLocation || widget.isLoadingTotals || widget.isLoadingPermissions) CustomLoader(),
                  
                        //  Store Menus
                        if(!widget.isLoadingLocation && !widget.isLoadingTotals && !widget.isLoadingPermissions) StoreMenus(
                          locationPermissions: widget.locationPermissions,
                          fetchLocationTotals: widget.fetchLocationTotals,
                          fetchLocation: widget.fetchLocation,
                          fetchStore: widget.fetchStore
                        ),
          
                        SizedBox(height: 80)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}

class ResourceCreationSlider extends StatelessWidget {
  
  final List locationPermissions;

  ResourceCreationSlider({ required this.locationPermissions });

  List<Map> getAllowedSliders(List<Map> sliders){

    //  Return primary menus that match the allowed location permissions
    return new List<Map>.from(sliders.where((slider){

      if( slider.containsKey('permission') ){

        return locationPermissions.contains(slider['permission']);

      }

      return true;

    }).toList()); 
    
  }

  List<Widget> buildSliderCards(List<Map> sliders){
    return sliders.map((slider) {
      return SliderCard(slider: slider);
    }).toList();

  }

  @override
  Widget build(BuildContext context) {

    final List<Map> sliders = [
      {
        'title': 'Add Products',
        'body': 'Sell food, beverages, vegetables, meat, farming products, building materials, make-up & cosmetics, clothes, tickets and more',
        'color': Colors.blue,
        'image': 'assets/images/vegetables-stall-2.jpeg',
        'permissions': 'manage-products',
        'button': {
          'name': '+ Add Product'
        },
        'onPressed': () async {
          final result = await Provider.of<ProductsProvider>(context, listen: false).navigateToAddProduct();

          //  If we submitted a product successfully
          if( result == 'submitted' ){
            Get.to(() => ProductsScreen());
          }
        }
      },
      {
        'title': 'Coupons for discounts',
        'body': 'Offer coupons to allow your customers to claim discounts or free delivery. Coupons can also be limited e.g Only valid for the first 100 customers',
        'color': Colors.blue,
        'image': 'assets/images/clothing-sale.jpeg',
        'permissions': 'manage-coupons',
        'button': {
          'name': '+ Add Coupon'
        },
        'onPressed': () async {
          final result = await Provider.of<CouponsProvider>(context, listen: false).navigateToAddCoupon();

          //  If we submitted a coupon successfully
          if( result == 'submitted' ){
            Get.to(() => CouponsScreen());
          }
        }
      },
      {
        'title': 'Instant Carts',
        'body': 'Take 2 or more products and make combos for faster shopping. Customer then dial and checkout with those products quick and easy',
        'color': Colors.blue,
        'image': 'assets/images/pizzas.jpeg',
        'permissions': 'manage-instant-carts',
        'button': {
          'name': '+ Add Instant Cart'
        },
        'onPressed': () async {
          final result = await Provider.of<InstantCartsProvider>(context, listen: false).navigateToAddInstantCart();

          //  If we submitted an instant cart successfully
          if( result == 'submitted' ){
            Get.to(() => InstantCartsScreen());
          }
        }
      },
      {
        'title': 'Team Members',
        'body': 'You can add staff, friends or family members to help you manage your store especially when demand for your services starts to increase',
        'color': Colors.blue,
        'image': 'assets/images/pizzas.jpeg',
        'permissions': 'manage-users',
        'button': {
          'name': '+ Add Team'
        },
        'onPressed': () async {
          final result = await Provider.of<UsersProvider>(context, listen: false).navigateToInviteUsers();

          //  If we invited users successfully
          if( result == 'submitted' ){
            Get.to(() => UsersScreen());
          }
        }
      }
    ];
    
    var sliderCardWidgets = buildSliderCards(getAllowedSliders(sliders));

    return ClipRRect(
      child: Container(
        height: 230,
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        child: ListView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          children: [
            ...sliderCardWidgets
          ],
        ),
      ),
    );
  }
}

class SliderCard extends StatelessWidget {

  final Map slider;

  SliderCard({ required this.slider });

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return Container(
      width: (size.width * 0.8),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(horizontal: (size.width * 0.05) / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 5),
            blurRadius: 5
          )
        ]
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Colors.blue.withOpacity(0.05),
            child: Image.asset('assets/images/logo-white.png')
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slider['title'], style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),),
                SizedBox(height: 10),
                Text(
                  slider['body'], 
                  textAlign: TextAlign.justify,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.black.withOpacity(0.7))
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomButton(
                    margin: EdgeInsets.only(top: 15, bottom: 10),
                    text: slider['button']['name'],
                    size: 'small',
                    width: 200,
                    onSubmit: (){
                      slider['onPressed']();
                    },
                  )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class StoreDialingInstructions extends StatelessWidget {

  final Store store;

  StoreDialingInstructions({ required this.store });

  @override
  Widget build(BuildContext context) {

    final storesProvider = Provider.of<StoresProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 20),
      child: TextButton(
        onPressed: () => storesProvider.launchVisitShortcode(store: store, context: context),
        child: Row(
          children: [
            Text('Dial', style: Theme.of(context).textTheme.subtitle2),
            SizedBox(width: 5),
            Text(storesProvider.getStoreVisitShortCodeDialingCode, style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Colors.blue, decoration: TextDecoration.underline),),
            SizedBox(width: 5),
            Text('to visit store', style: Theme.of(context).textTheme.subtitle1,),
          ],
        ),
      ),
    );
  }
}

class SubcsriptionCountdown extends StatelessWidget {

  final Store store;

  SubcsriptionCountdown({ required this.store });

  @override
  Widget build(BuildContext context) {

    final subscription = store.attributes.subscription;
    final hasSubscription = store.attributes.hasSubscription;
    final subscriptionExpiryTime = (hasSubscription ? subscription!.endAt : null);

    final endTime = (subscriptionExpiryTime == null) ? DateTime.now().millisecondsSinceEpoch : subscriptionExpiryTime.millisecondsSinceEpoch;

    return CustomCountdown(
      onEnd: (){
        Get.offAll(() => StoresScreen());
      },
      endTime: endTime,
      margin: const EdgeInsets.only(bottom: 10, left: 20),
      endWidget: Text('Subscription ended', style: TextStyle(color: Colors.red),)
    );
  }
}

class StoreMenus extends StatelessWidget {
  
  final Function fetchLocationTotals;
  final List locationPermissions;
  final Function fetchLocation;
  final Function fetchStore;

  StoreMenus({ required this.fetchLocationTotals, required this.locationPermissions, required this.fetchLocation, required this.fetchStore });

  StoreMenuItem buildMenuWidgets(menuItem, LocationTotals locationTotals){

      if(menuItem['title'] == 'Orders') {
        menuItem['count'] = locationTotals.orderTotals.received.total;
      }else if(menuItem['title'] == 'Products') {
        menuItem['count'] = locationTotals.productTotals.total;
      }else if(menuItem['title'] == 'Coupons') {
        menuItem['count'] = locationTotals.couponTotals.total;
      }else if(menuItem['title'] == 'Customers') {
        menuItem['count'] = locationTotals.customerTotals.total;
      }else if(menuItem['title'] == 'Instant carts') {
        menuItem['count'] = locationTotals.instantCartTotals.total;
      }else if(menuItem['title'] == 'Team') {
        menuItem['count'] = locationTotals.userTotals.total;
      }

      return StoreMenuItem(menuItem: menuItem, fetchLocationTotals: fetchLocationTotals);
  }
  
  @override
  Widget build(BuildContext context) {
                
    //  Get the default location totals
    final storesProvider = Provider.of<StoresProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationsProvider>(context, listen: false);
      
    final List<Map> primaryMenus = [
      {
        'title': 'Orders',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/package.svg'
        },
        'count': 0,
        'permission': 'manage-orders',
        'onPressed': () async {
          return Get.to(() => OrderOptionsScreen());
        }, 
      },
      {
        'title': 'Products',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/shopping-bag-2.svg'
        },
        'count': 0,
        'permission': 'manage-products',
        'onPressed': () async {
          return Get.to(() => ProductsScreen());
        },
      },
      {
        'title': 'Coupons',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/discount-coupon.svg'
        },
        'count': 0,
        'permission': 'manage-coupons',
        'onPressed': () {
          return Get.to(() => CouponsScreen());
        }, 
      },
      {
        'title': 'Customers',
        'icon': {
          'width': 34.00,
          'src': 'assets/icons/ecommerce_pack_1/customers-3.svg'
        },
        'count': 0,
        'permission': 'manage-customers',
        'onPressed': () {
          return Get.to(() => CustomersScreen());
        }, 
      },
      {
        'title': 'Instant carts',
        'icon': {
          'width': 32.00,
          'src': 'assets/icons/ecommerce_pack_1/shopping-cart-10.svg'
        },
        'count': 0,
        'permission': 'manage-instant-carts',
        'onPressed': () {
          return Get.to(() => InstantCartsScreen());
        }, 
      },
      {
        'title': 'Team',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/employee-badge-1.svg'
        },
        'count': 0,
        'permission': 'manage-users',
        'onPressed': () {
          return Get.to(() => UsersScreen());
        }, 
      },
      {
        'title': 'Reports',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/pie-chart.svg'
        },
        'permission': 'manage-reports',
        'onPressed': () {
          
        }, 
      },
      {
        'title': 'Settings',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/settings.svg'
        },
        'permission': 'manage-settings',
        'onPressed': () async {
          await Get.to(() => StoreSettingsScreen());
          await fetchStore();
        }, 
      },
      {
        'title': 'Feedback',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/like-thumb.svg'
        },
        'onPressed': () => {
          Get.to(() => OrdersScreen())
        }, 
      },
      {
        'title': 'Switch store',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/exchange.svg'
        },
        'onPressed': () => {
          storesProvider.switchStore(context: context)
        }, 
      },
    ];

    List<Map> getAllowedPrimaryMenus(){

      //  Return primary menus that match the allowed location permissions
      return new List<Map>.from(primaryMenus.where((primaryMenu){

        if( primaryMenu.containsKey('permission') ){

          return locationPermissions.contains(primaryMenu['permission']);

        }

        return true;

      }).toList()); 
      
    }

    final allowedPrimaryMenus = getAllowedPrimaryMenus();

    return Container(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: allowedPrimaryMenus.length,
        itemBuilder: (context, index) {
          return buildMenuWidgets(allowedPrimaryMenus[index], locationProvider.locationTotals);
        },
      ),
    );
    
  }
}

class StoreMenuItem extends StatelessWidget {

  final Function fetchLocationTotals;
  final Map menuItem;

  StoreMenuItem({ this.menuItem = const {}, required this.fetchLocationTotals });

  @override
  Widget build(BuildContext context) {
    
    var hasCount = menuItem.containsKey('count') && menuItem['count'] != 0;

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
          StoreMenuItemCard(menuItem: menuItem, fetchLocationTotals: fetchLocationTotals),
          if(hasCount) StoreMenuItemCount(menuItem: menuItem),
        ]
      );
  }
}

class StoreMenuItemCard extends StatelessWidget {

  final Function fetchLocationTotals;
  final Map menuItem;

  StoreMenuItemCard({ this.menuItem = const {}, required this.fetchLocationTotals });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 5),
            blurRadius: 5
          )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await menuItem['onPressed']();
            
            //  If the menu name does not match the given list of menu titles
            if(['Switch store', 'Feedback', 'Settings'].contains(menuItem['title']) == false){

              //  Fetch the location totals
              fetchLocationTotals();

            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(menuItem['icon']['src'], width: menuItem['icon']['width']),
              SizedBox(height: 10),
              Text(menuItem['title']),
            ],
          ),
        ),
      ),
    );
  }
}

class StoreMenuItemCount extends StatelessWidget{

  final Map menuItem;

  StoreMenuItemCount({ this.menuItem = const {} });

  @override
  Widget build(BuildContext context) {

    var count = menuItem['count'].toString();

    //  Count the number of characters
    var numberOfCharacters = count.length;

    //  Calcultate the container width
    var countContainerWidth = 14.00 * (numberOfCharacters == 1 ? 2 : numberOfCharacters);

    return Container(
      height: 20,
      width: countContainerWidth,
      margin: EdgeInsets.only(top: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Center(
        child: Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12
          ),
        ),
      ),
    );
    
  }
}