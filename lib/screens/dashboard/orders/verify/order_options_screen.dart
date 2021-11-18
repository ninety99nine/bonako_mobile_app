import 'package:bonako_mobile_app/components/custom_button.dart';
import 'package:bonako_mobile_app/components/custom_loader.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:bonako_mobile_app/screens/auth/components/mobile_verification_pin_code_input.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/show/order_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/verify/verify_order_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/stores/show/store_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './../../../../screens/dashboard/orders/list/orders_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../components/custom_app_bar.dart';
import '../../../../components/store_drawer.dart';
import './../../../../providers/orders.dart';
import './../../../../models/orders.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class OrderOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:CustomAppBar(title: 'Orders'),
      drawer: StoreDrawer(),
      body: Content(),
    );
  }
}

class Content extends StatelessWidget {

  Widget _instructionText(){

    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 30),
      child: Text('What would you like to do?', style: TextStyle(color: Colors.grey,)),
    );

  }

  Widget _orderOptions(BuildContext context){

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          _optionCard(
            name: 'View Orders', 
            svg: 'assets/icons/ecommerce_pack_1/package-2.svg',
            onTap: (){
              Get.to(() => OrdersScreen());
            }
          ),
          _optionCard(
            name: 'Verify Orders', 
            svg: 'assets/icons/ecommerce_pack_1/like.svg',
            onTap: (){
              Get.to(() => VerifyOrderScreen());
            }
          ),
        ]
      ),
    );

  }

  Widget _optionCard({ required String name, required String svg, required onTap }){
    return 
      Card(
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.blue.shade100, width: 1),
                  ),
                  child: SvgPicture.asset(svg, color: Colors.blue, width: 20,)
                ),
                Text(name, style: TextStyle(color: Colors.blue,))
              ],
            ),
          ),
        ),
      );
  }
  
  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.off(() => ShowStoreScreen());
              }),
            ],
          ),
          Divider(),
          SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [

                  _instructionText(),
                  _orderOptions(context)
          
                ],
              ),
            ),
          )
        
        ],
      ),
    );
  }

}