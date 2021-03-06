
import 'package:bonako_mobile_app/models/locationTotals.dart';
import 'package:bonako_mobile_app/screens/dashboard/coupons/list/coupons_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/customers/list/customers_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/show/settings/settings.dart';

import './../screens/dashboard/instant_carts/list/instant_carts_screen.dart';
import './../screens/dashboard/orders/verify/order_options_screen.dart';
import './../screens/dashboard/products/list/products_screen.dart';
import './../screens/dashboard/stores/list/stores_screen.dart';
import './../components/custom_loader.dart';
import './../screens/auth/welcome.dart';
import './../providers/locations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import './../providers/stores.dart';
import './../providers/auth.dart';
import './../../constants.dart';
import 'package:get/get.dart';

class StoreDrawer extends StatelessWidget {

  buildOptionWidgets(List<Map> options, StoresProvider storesProvider, LocationsProvider locationsProvider){
    return options.where((option){
      
      if( storesProvider.hasStore && locationsProvider.hasLocation ) {

        //  Return all options
        return true;

      }
      
      if( option['requires_store'] == false ){

        //  Return only options that do not require any store
        return true;

      }

      return false;

    }).map((option) {
      
      if( storesProvider.hasStore && locationsProvider.hasLocation ) {

        if(option['title'] == 'Select store') {
          
          //  Change to "Switch store" name and icon
          option['title'] = 'Switch store';
          option['icon']['src'] = 'assets/icons/ecommerce_pack_1/exchange.svg';

        }

      }

      //  If we have the default location totals
      if( locationsProvider.hasLocationTotals ){

        final LocationTotals locationTotals = locationsProvider.locationTotals;

        if(option['title'] == 'Orders') {
          option['count'] = locationTotals.orderTotals.received.total;
        }else if(option['title'] == 'Products') {
          option['count'] = locationTotals.productTotals.total;
        }else if(option['title'] == 'Coupons') {
          option['count'] = locationTotals.couponTotals.total;
        }else if(option['title'] == 'Customers') {
          option['count'] = locationTotals.customerTotals.total;
        }else if(option['title'] == 'Instant carts') {
          option['count'] = locationTotals.instantCartTotals.total;
        }else if(option['title'] == 'Staff') {
          option['count'] = locationTotals.userTotals.total;
        }
        
      }

      return DrawerOption(option: option);

    }).toList();
  }

  @override
  Widget build(BuildContext context) {
                
    //  Get the default location totals (Listen for changes)
    final storesProvider = Provider.of<StoresProvider>(context);
    final locationsProvider = Provider.of<LocationsProvider>(context);
    final locationPermissions = locationsProvider.getLocationPermissions;
    final isLoadingLocation = (locationsProvider.isLoadingLocation || locationsProvider.isLoadingLocationTotals || locationsProvider.isLoadingLocationPermissions);

    final List<Map> primaryMenus = [
      {
        'title': 'Select store',
        'requires_store': false,
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/shop.svg'
        },
        'divider': true,
        'onPressed': () {
          storesProvider.switchStore(context: context);
        }, 
      },
      {
        'title': 'Orders',
        'requires_store': true,
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/package.svg'
        },
        'count': 0,
        'permission': 'manage-orders',
        'onPressed': () => {
          Get.offAll(() => OrderOptionsScreen())
        }, 
      },
      {
        'title': 'Products',
        'requires_store': true,
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/shopping-bag-2.svg'
        },
        'count': 0,
        'permission': 'manage-products',
        'onPressed': () => {
          Get.offAll(() => ProductsScreen())
        }, 
      },
      {
        'title': 'Coupons',
        'requires_store': true,
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/discount-coupon.svg'
        },
        'count': 0,
        'permission': 'manage-coupons',
        'onPressed': () => {
          Get.offAll(() => CouponsScreen())
        }, 
      },
      {
        'title': 'Customers',
        'requires_store': true,
        'icon': {
          'width': 34.00,
          'src': 'assets/icons/ecommerce_pack_1/customers-3.svg'
        },
        'count': 0,
        'permission': 'manage-customers',
        'onPressed': () => {
          Get.offAll(() => CustomersScreen())
        }, 
      },
      {
        'title': 'Instant carts',
        'requires_store': true,
        'icon': {
          'width': 32.00,
          'src': 'assets/icons/ecommerce_pack_1/shopping-cart-10.svg'
        },
        'count': 0,
        'permission': 'manage-instant-carts',
        'onPressed': () => {
          Get.offAll(() => InstantCartsScreen())
        }, 
      },
      {
        'title': 'Team',
        'requires_store': true,
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/employee-badge-1.svg'
        },
        'count': 0,
        'permission': 'manage-users',
        'onPressed': () => {
          
        }, 
      },
      {
        'title': 'Reports',
        'requires_store': true,
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/pie-chart.svg'
        },
        'permission': 'manage-reports',
        'divider': true,
        'onPressed': () => {
          
        }, 
      },
      {
        'title': 'Settings',
        'requires_store': true,
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/settings.svg'
        },
        'permission': 'manage-settings',
        'onPressed': () => {
          Get.offAll(() => StoreSettingsScreen())
        }, 
      },
      {
        'title': 'Feedback',
        'requires_store': false,
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/like-thumb.svg'
        },
        'onPressed': () => {
          
        }, 
      },
      {
        'title': 'Logout',
        'requires_store': false,
        'icon': {
          'width': 28.00,
          'src': 'assets/icons/ecommerce_pack_1/logout.svg'
        },
        'onPressed': () {

          Provider.of<AuthProvider>(context, listen: false).logout(context: context).then((response){
            if( response.statusCode == 200 ){
              Get.offAll(() => WelcomePage());
            }
          });
          
        },
      }
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

    final primaryOptionWidgets = buildOptionWidgets(allowedPrimaryMenus, storesProvider, locationsProvider);

    return Drawer(
      child: Container(
        color: Colors.blue.shade50,
        child: ListView(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  scale: 2.5,
                  //  fit: BoxFit.contain,
                  colorFilter: new ColorFilter.mode(Colors.blue.withOpacity(0.1), BlendMode.dstATop),
                  image: AssetImage('assets/images/logo-white.png')
                )
              ),
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //  User Account Info
                  SizedBox(height: 30),
                  DrawerHeaderUserAccount(),

                  //  Divider
                  SizedBox(height: 5),
                  Divider(color: Colors.white,),
                  SizedBox(height: 5),

                  //  Store Info
                  DrawerHeaderStore(
                    storesProvider: storesProvider,
                    locationsProvider: locationsProvider,
                  ),
                  
                ],
              ),
            ),

            if(isLoadingLocation == true) CustomLoader(topMargin: 40, bottomMargin: 40, text: 'Loading store'),
            
            if(isLoadingLocation == true) Divider(height: 0),

            if(isLoadingLocation == false) ...primaryOptionWidgets
          ],
        ),
      ),
    );

  }
}

class DrawerHeaderUserAccount extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
      
    final authUser = Provider.of<AuthProvider>(context).getAuthUser;

    return Row(
      children: [
        SizedBox(width: 5),
        SvgPicture.asset('assets/icons/ecommerce_pack_1/user-profile.svg', width: 30, color: Colors.white),
        SizedBox(width: 25),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authUser.attributes.name,
              style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white)
            ),
            SizedBox(height: 5),
            Text(
              authUser.mobileNumber.number,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Colors.white)
            ),
          ],
        )
      ],
    );
  }
}

class DrawerHeaderStore extends StatelessWidget {

  final StoresProvider storesProvider;
  final LocationsProvider locationsProvider;

  DrawerHeaderStore({
    required this.storesProvider,
    required this.locationsProvider
  });

  @override
  Widget build(BuildContext context) {

    final hasStore = storesProvider.hasStore;
    final hasLocation = locationsProvider.hasLocation;

    return Row(
      children: [
        SvgPicture.asset('assets/icons/ecommerce_pack_1/pin-1.svg', width: 40, color: Colors.white),
        SizedBox(width: 20),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hasStore 
              ? Text(
                  storesProvider.store.name,
                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white)
                )
              : Text(
                  'No store selected',
                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white, fontSize: 16)
                ),
            if(hasLocation) SizedBox(height: 5),
            if(hasLocation) Text(
              locationsProvider.location.name,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Colors.white)
            ),
          ],
        )
      ],
    );
  }
}

class DrawerOption extends StatelessWidget{

  final Map option;

  DrawerOption({ this.option = const {} });

  @override
  Widget build(BuildContext context){
    
    var hasCount = option.containsKey('count') && option['count'] != 0;
    var hasDivider = option.containsKey('divider') && option['divider'] == true;
    
    var listTile = ListTile(
        leading: SvgPicture.asset(option['icon']['src'], width: option['icon']['width']),
        title: Text(option['title']),
        onTap: () => {
          
          //  Close the drawer
          Navigator.pop(context),

          //  Handle option on pressed callback
          option['onPressed'](),

        },
        trailing: hasCount ? DrawerOptionCount(option: option) : null,
      );

    if(hasDivider){

      //  Return listTile and divider only
      return Column(
        children: [
          listTile,
          Divider()
        ],
      );

    }

    //  Return listTile only
    return listTile;

  }

}

class DrawerOptionCount extends StatelessWidget{

  final Map option;

  DrawerOptionCount({ this.option = const {} });

  @override
  Widget build(BuildContext context) {

    var count = option['count'].toString();

    //  Count the number of characters
    var numberOfCharacters = count.length;

    //  Calcultate the container width
    var countContainerWidth = 10.00 * (numberOfCharacters == 1 ? 2 : numberOfCharacters);

    return Container(
      height: 20,
      width: countContainerWidth,
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