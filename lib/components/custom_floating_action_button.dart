import './../screens/dashboard/stores/create/create_store_screen.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import './../screens/dashboard/stores/list/stores_screen.dart';
import './../../../../providers/locations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../providers/stores.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import './../providers/products.dart';
import './../models/stores.dart';
import 'package:get/get.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final Function()? onAddProduct;

  CustomFloatingActionButton({ this.onAddProduct });

  void showAddStoreModal(StoresProvider storesProvider, BuildContext context, bool shouldRippleProducts){

    final hasStore = storesProvider.hasStore;
    final dialingCode = storesProvider.getStoreVisitShortCodeDialingCode;
    final store = storesProvider.store;

    showModalBottomSheet(
      context: context, 
      builder: (ctx) {
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
              
              if(hasStore) Divider(height:30),

              Expanded(
                child: ListView(
                  children: [
              
                    //  Add product option
                    if(hasStore) ModalOption(
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
                          //Get.to(() => ProductsScreen());
                        }
                      }
                    ),
              
                    //  Add coupon option
                    if(hasStore) ModalOption(
                      title: 'Add Coupon',
                      svg: 'assets/icons/ecommerce_pack_1/discount-coupon.svg',
                      onPressed: (){}
                    ),
              
                    //  Add instant cart option
                    if(hasStore) ModalOption(
                      title: 'Add Instant Cart',
                      svg: 'assets/icons/ecommerce_pack_1/shopping-cart-10.svg',
                      onPressed: (){}
                    ),
              
                    //  Add instant cart option
                    if(hasStore) ModalOption(
                      title: 'Visit store ('+dialingCode+')',
                      svg: 'assets/icons/ecommerce_pack_1/pin-1.svg',
                      onPressed: (){
                        storesProvider.launchVisitShortcode(store: store, context: context);
                      }
                    ),
                    
                    if(hasStore) Divider(),
              
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
      }
    );
    
  }

  @override
  Widget build(BuildContext context) {
    
    final storesProvider = Provider.of<StoresProvider>(context, listen: true);
    final locationsProvider = Provider.of<LocationsProvider>(context, listen: true);

    final shouldRippleProducts = (locationsProvider.hasLocationTotals && locationsProvider.totalLocationProducts == 0);

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
        showAddStoreModal(storesProvider, context, shouldRippleProducts)
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