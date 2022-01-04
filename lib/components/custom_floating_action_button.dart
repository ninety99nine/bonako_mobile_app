import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/providers/coupons.dart';
import 'package:bonako_mobile_app/providers/users.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/list/users_screen.dart';

import './../screens/dashboard/stores/create/create_store_screen.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import './../screens/dashboard/stores/list/stores_screen.dart';
import './../../../../providers/locations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../providers/stores.dart';
import './../providers/instant_carts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './../providers/products.dart';
import './../models/stores.dart';
import 'package:get/get.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final Function()? onAddUser;
  final Function()? onAddCoupon;
  final Function()? onAddProduct;
  final Function()? onAddInstantCart;

  CustomFloatingActionButton({ this.onAddUser, this.onAddProduct, this.onAddCoupon, this.onAddInstantCart });

  void showAddStoreModal(BuildContext context, bool shouldRippleProducts){
    
    showModalBottomSheet(
      context: context, 
      builder: (_){

        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
            
          final storesProvider = Provider.of<StoresProvider>(context, listen: true);
          final locationsProvider = Provider.of<LocationsProvider>(context, listen: true);
          
          final isLoadingLocation = (locationsProvider.isLoadingLocation || locationsProvider.isLoadingLocationTotals || locationsProvider.isLoadingLocationPermissions);
          final dialingCode = storesProvider.getStoreVisitShortCodeDialingCode;
          final locationPermissions = locationsProvider.locationPermissions;
          final hasLocation = locationsProvider.hasLocation;
          final hasStore = storesProvider.hasStore;
          final store = storesProvider.store;

          bool hasPermission(String permission){
            return locationPermissions.contains(permission);
          }

          return Container(
            height: 400,
            color: Colors.blue.shade50,
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
                if(hasStore) Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text((storesProvider.store as Store).name, style: Theme.of(context).textTheme.headline6,),
                ),
                
                if(hasStore && hasLocation) Divider(height:30),

                Expanded(
                  child: ListView(
                    children: [
                      
                      //  Loader
                      if(isLoadingLocation) CustomLoader(),
                
                      //  Add product option
                      if(hasStore && hasLocation && !isLoadingLocation && hasPermission('manage-products')) ModalOption(
                        title: 'Add Product',
                        ripple: shouldRippleProducts,
                        svg: 'assets/icons/ecommerce_pack_1/shopping-bag-2.svg',
                        onPressed: () async {

                          final result = await Provider.of<ProductsProvider>(context, listen: false).navigateToAddProduct();

                          //  If we submitted a product successfully
                          if( result == 'submitted' ){

                            if(onAddProduct != null){
                              onAddProduct!();
                            }
                            
                          }
                        }
                      ),
                
                      //  Add coupon option
                      if(hasStore && hasLocation && !isLoadingLocation && hasPermission('manage-coupons')) ModalOption(
                        title: 'Add Coupon',
                        svg: 'assets/icons/ecommerce_pack_1/discount-coupon.svg',
                        onPressed: () async {

                          final result = await Provider.of<CouponsProvider>(context, listen: false).navigateToAddCoupon();

                          //  If we submitted a coupon successfully
                          if( result == 'submitted' ){

                            if(onAddCoupon != null){
                              onAddCoupon!();
                            }
                            
                          }
                        }
                      ),
                
                      //  Add instant cart option
                      if(hasStore && hasLocation && !isLoadingLocation && hasPermission('manage-instant-carts')) ModalOption(
                        title: 'Add Instant Cart',
                        svg: 'assets/icons/ecommerce_pack_1/shopping-cart-10.svg',
                        onPressed: () async {

                          final result = await Provider.of<InstantCartsProvider>(context, listen: false).navigateToAddInstantCart();

                          //  If we submitted an instant cart successfully
                          if( result == 'submitted' ){

                            if(onAddInstantCart != null){
                              onAddInstantCart!();
                            }
                            
                          }
                        }
                      ),
                
                      //  Add coupon option
                      if(hasStore && hasLocation && !isLoadingLocation && hasPermission('manage-users')) ModalOption(
                        title: 'Invite Team',
                        svg: 'assets/icons/ecommerce_pack_1/employee-badge-1.svg',
                        onPressed: () async {

                          final result = await Provider.of<UsersProvider>(context, listen: false).navigateToInviteUsers();

                          //  If invited users successfully
                          if( result == 'submitted' ){

                            if(onAddUser != null){
                              onAddUser!();
                            }
                            
                          }
                        }
                      ),
                
                      //  Visit store option
                      if(hasStore && hasLocation && !isLoadingLocation) ModalOption(
                        title: 'Visit store ('+dialingCode+')',
                        svg: 'assets/icons/ecommerce_pack_1/pin-1.svg',
                        onPressed: (){
                          storesProvider.launchVisitShortcode(store: store, context: context);
                        }
                      ),
                      
                      if(isLoadingLocation) SizedBox(height: 30),
                      if((hasStore && hasLocation && !isLoadingLocation) || isLoadingLocation) Divider(),
                
                      //  Add store option
                      ModalOption(
                        title: 'Add Store',
                        svg: 'assets/icons/ecommerce_pack_1/plus.svg',
                        onPressed: () async {
                          await Get.to(() => CreateStoresScreen());
                          Get.to(() => StoresScreen());
                        }
                      ),
                
                    ]
                  ),
                )
              ],
            ),
          );

        });

      }
    );
    
  }

  @override
  Widget build(BuildContext context) {
    
    final locationsProvider = Provider.of<LocationsProvider>(context, listen: true);
    final shouldRippleProducts = (locationsProvider.hasLocation && locationsProvider.hasLocationTotals && locationsProvider.totalLocationProducts == 0);

    final basicPlusWidget = const Text('+', style: TextStyle(fontSize: 20));
    final ripplePlusWidget = RippleAnimation(
      repeat: true,
      minRadius: 50,
      ripplesCount: 2,
      color: Colors.blue,
      child: basicPlusWidget
    );

    return FloatingActionButton(
      child: shouldRippleProducts ? ripplePlusWidget : basicPlusWidget,
      onPressed: () => {
        showAddStoreModal(context, shouldRippleProducts)
      },
    );
  }

}

class ModalOption extends StatelessWidget {

  final String title;
  final Color? color;
  final String? svg;
  final bool ripple;
  final Function onPressed;

  const ModalOption({ this.title = 'Option', this.color, this.svg, this.ripple = false, required this.onPressed });

  @override
  Widget build(BuildContext context) {

    bool hasSvg = (svg != null);
    bool hasColor = (color != null);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        child: ListTile(
          leading: (hasSvg) ? 
            (ripple ? RippleAnimation(
              repeat: true,
              minRadius: 25,
              ripplesCount: 2,
              color: Colors.blue.shade300,
              child: SvgPicture.asset(svg!, width: 20.00, color: hasColor ? color : Colors.black,)
            ) : SvgPicture.asset(svg!, width: 20.00, color: hasColor ? color : Colors.black,)) : null,
          title: Text(title, style: TextStyle(
            color: hasColor ? color : Colors.black,
            fontSize: 16
          )),
          onTap: () {
            Navigator.pop(context);
            onPressed();
          },
        ),
      ),
    );
    
  }
}