import 'package:bonako_app_3/providers/products.dart';

import './.././../../../../components/custom_rounded_refresh_button.dart';
import '././../../../../screens/dashboard/stores/list/stores_screen.dart';
import '../../../../components/custom_floating_action_button.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_countdown.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_loader.dart';
import './../../../../components/store_drawer.dart';
import './../../products/list/products_screen.dart';
import './../../../../models/location_totals.dart';
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

class ShowStoreScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context){
                
    //  Get the store from the StoresProvider
    final store = Provider.of<StoresProvider>(context, listen: false).getStore;

    return Scaffold(
      drawer: StoreDrawer(),
      appBar: CustomAppBar(title: store.name),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: CustomFloatingActionButton(),
      body: Content(),
    );
  }
}

class Content extends StatefulWidget {

  @override
  _ContentState createState() => _ContentState();

}

class _ContentState extends State<Content> {

  late Store store;
  late Location location;
  var isLoadingTotals = false;
  var isLoadingLocation = false;
  late LocationTotals locationTotals;

  void startLocationLoader(){
    if (mounted) {
      setState(() {
        isLoadingLocation = true;
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

  void stopLocationLoader(){
    if (mounted) {
      setState(() {
        isLoadingLocation = false;
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

  @override
  void initState() {
                
    //  Get the default store from the StoresProvider
    store = Provider.of<StoresProvider>(context, listen: false).getStore;
    
    fetchLocation();

    super.initState();

  }

  void fetchLocation(){

    startLocationLoader();
    
    final locationsProvider = Provider.of<LocationsProvider>(context, listen: false);
  
    //  Fetch the default store location
    locationsProvider.fetchLocation(context: context)
      .then((http.Response response) async {
        
        if(response.statusCode == 200 && mounted){

          final responseBody = jsonDecode(response.body);

          setState(() {

            //  Get the location
            location = Location.fromJson(responseBody);

            //  Set the location as the default location
            locationsProvider.setLocation(location);

            //  Fetch the location totals
            fetchLocationTotals();

          });

        }

      }).whenComplete((){

        stopLocationLoader();

      });
  }

  void fetchLocationTotals(){

    startTotalsLoader();

    final locationsProvider = Provider.of<LocationsProvider>(context, listen: false);
  
    //  Fetch the default store location totals
    locationsProvider.fetchLocationTotals(context: context)
      .then((http.Response response) async {

        if(response.statusCode == 200 && mounted){

          setState(() {

            //  Get the location totals
            locationTotals = locationsProvider.getLocationTotals;

          });

        }

      }).whenComplete((){

        stopTotalsLoader();

      });
  }

  @override
  Widget build(BuildContext context){

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.off(() => StoresScreen());
              }),
              CustomRoundedRefreshButton(onPressed: fetchLocation),
            ],
          ),
          Divider(height: 0),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  StoreDialingInstructions(store: store),
                  SizedBox(height: 10),
                  SubcsriptionCountdown(store: store),
                  SizedBox(height: 10),
            
                  //  Resource Creation Slider
                  if(!isLoadingLocation) ResourceCreationSlider(),
            
                  //  Loader
                  if(isLoadingLocation || isLoadingTotals) Divider(),
                  if(isLoadingLocation || isLoadingTotals) CustomLoader(),
            
                  //  Store Menus
                  if(!isLoadingLocation && !isLoadingTotals) StoreMenus(
                    fetchLocationTotals: fetchLocationTotals
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}

class ResourceCreationSlider extends StatelessWidget {

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
        'body': 'You can sell food, beverages, vegetables, meat, farming products, building materials, make-up & cosmetics, clothes, tickets and more',
        'color': Colors.blue,
        'image': 'assets/images/vegetables-stall-2.jpeg',
        'button': {
          'name': '+ Add Products'
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
        'button': {
          'name': '+ Add Coupons'
        }
      },
      {
        'title': 'Instant Carts',
        'body': 'Instant carts allow you to take 2 or more products and make combos for faster shopping. Customer then dial and checkout with those products quick and easy',
        'color': Colors.blue,
        'image': 'assets/images/pizzas.jpeg',
        'button': {
          'name': '+ Add Instant Carts'
        }
      },
      {
        'title': 'Staff Members',
        'body': 'You can add employees, friends or family members to help you manage your store especially when demand for your services starts to increase',
        'color': Colors.blue,
        'image': 'assets/images/pizzas.jpeg',
        'button': {
          'name': '+ Add Staff'
        }
      }
    ];
    
    var sliderCardWidgets = buildSliderCards(sliders);

    return ClipRRect(
      child: Container(
        height: 220,
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
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: (size.width * 0.05) / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
              image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.1), BlendMode.dstIn),
                image: AssetImage(slider['image'])
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 5),
            blurRadius: 5
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(slider['title'], style: Theme.of(context).textTheme.headline6!.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),),
          SizedBox(height: 5),
          Text(
            slider['body'], 
            textAlign: TextAlign.justify,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.black.withOpacity(0.7))
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: (){
                slider['onPressed']();
              },
              child: Text(slider['button']['name'])
            ),
          )
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
      padding: const EdgeInsets.only(bottom: 10, left: 10),
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
        Get.off(() => StoresScreen());
      },
      endTime: endTime,
      margin: const EdgeInsets.only(bottom: 10, left: 10),
      endWidget: Text('Subscription ended', style: TextStyle(color: Colors.red),)
    );
  }
}

class StoreMenus extends StatelessWidget {

  final Function fetchLocationTotals;

  StoreMenus({ required this.fetchLocationTotals });

  StoreMenuItem buildMenuWidgets(menuItem, LocationTotals locationTotals){

      if(menuItem['title'] == 'Orders') {
        menuItem['count'] = locationTotals.orders.received.total;
      }else if(menuItem['title'] == 'Products') {
        menuItem['count'] = locationTotals.products.total;
      }else if(menuItem['title'] == 'Coupons') {
        menuItem['count'] = locationTotals.coupons.total;
      }else if(menuItem['title'] == 'Customers') {
        menuItem['count'] = locationTotals.customers.total;
      }else if(menuItem['title'] == 'Instant carts') {
        menuItem['count'] = locationTotals.instantCarts.total;
      }else if(menuItem['title'] == 'Staff') {
        menuItem['count'] = locationTotals.users.total;
      }

      return StoreMenuItem(menuItem: menuItem);
  }
  
  @override
  Widget build(BuildContext context) {
                
    //  Get the default location totals
    final locationTotals = Provider.of<LocationsProvider>(context, listen: false).locationTotals;
      
    final List<Map> primaryMenus = [
      {
        'title': 'Orders',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/package.svg'
        },
        'count': 15,
        'onPressed': () async {
          await Get.to(() => OrdersScreen());
          fetchLocationTotals();
        }, 
      },
      {
        'title': 'Products',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/shopping-bag-2.svg'
        },
        'count': 20,
        'onPressed': () async {
          await Get.to(() => ProductsScreen());
          fetchLocationTotals();
        },
      },
      {
        'title': 'Coupons',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/discount-coupon.svg'
        },
        'count': 2,
        'onPressed': () => {
          Get.to(() => OrdersScreen())
        }, 
      },
      {
        'title': 'Customers',
        'icon': {
          'width': 34.00,
          'src': 'assets/icons/ecommerce_pack_1/customers-3.svg'
        },
        'count': 245,
        'onPressed': () => {
          Get.to(() => OrdersScreen())
        }, 
      },
      {
        'title': 'Instant carts',
        'icon': {
          'width': 32.00,
          'src': 'assets/icons/ecommerce_pack_1/shopping-cart-10.svg'
        },
        'count': 1,
        'onPressed': () => {
          Get.to(() => OrdersScreen())
        }, 
      },
      {
        'title': 'Staff',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/employee-badge-1.svg'
        },
        'count': 2,
        'onPressed': () => {
          
        }, 
      },
      {
        'title': 'Reports',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/pie-chart.svg'
        },
        'onPressed': () => {
          Get.to(() => OrdersScreen())
        }, 
      },
      {
        'title': 'Settings',
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/settings.svg'
        },
        'onPressed': () => {
          Get.to(() => OrdersScreen())
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
          Get.to(() => StoresScreen())
        }, 
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      itemCount: primaryMenus.length,
      itemBuilder: (context, index) {
        return buildMenuWidgets(primaryMenus[index], locationTotals);
      },
    );
    
  }
}

class StoreMenuItem extends StatelessWidget {

  final Map menuItem;

  StoreMenuItem({ this.menuItem = const {} });

  @override
  Widget build(BuildContext context) {
    
    var hasCount = menuItem.containsKey('count') && menuItem['count'] != 0;

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
          StoreMenuItemCard(menuItem: menuItem),
          if(hasCount) StoreMenuItemCount(menuItem: menuItem),
        ]
      );
  }
}

class StoreMenuItemCard extends StatelessWidget {

  final Map menuItem;

  StoreMenuItemCard({ this.menuItem = const {} });

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
          onTap: () => {
            menuItem['onPressed']()
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