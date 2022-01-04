import 'package:bonako_mobile_app/components/custom_proceed_card.dart';
import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/models/customers.dart';
import 'package:bonako_mobile_app/models/users.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/providers/customers.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/list/orders_screen.dart';
import 'package:bonako_mobile_app/screens/dashboard/users/show/components/userProfileSummary.dart';

import './../../../../screens/dashboard/coupons/list/coupons_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_checkmark_text.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../../components/custom_loader.dart';
import './sections/activate_on_total_unique_items.dart';
import './sections/activate_on_existing_customers.dart';
import './sections/activate_on_months_of_the_year.dart';
import './sections/activate_on_days_of_the_month.dart';
import './sections/activate_on_days_of_the_week.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_divider.dart';
import './../../../../components/custom_button.dart';
import './sections/activate_on_minimum_total.dart';
import './sections/activate_on_new_customers.dart';
import '../../../../components/store_drawer.dart';
import './sections/activate_on_total_items.dart';
import './../../../../providers/locations.dart';
import './../../../../providers/coupons.dart';
import './sections/activate_usage_limit.dart';
import './sections/offer_free_delivery.dart';
import './../../../../models/coupons.dart';
import './sections/activate_on_dates.dart';
import './sections/activate_on_times.dart';
import './sections/activate_on_code.dart';
import './sections/offer_discount.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './sections/visibility.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'components/customerSummary.dart';

class ShowCustomerScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    final customer = Provider.of<CustomersProvider>(context, listen: false).getCustomer;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: customer.embedded.user.attributes.name),
        drawer: StoreDrawer(),
        body: Content(),
      )
    );
  }
}

class Content extends StatefulWidget {

  @override
  _ContentState createState() => _ContentState();

}

class _ContentState extends State<Content> {

  @override
  Widget build(BuildContext context) {

    final customer = Provider.of<CustomersProvider>(context, listen: false).getCustomer;
    final user = customer.embedded.user;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.offAll(() => CouponsScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){}),
            ],
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  //  Proceed to orders
                  UserProfileSummary(user: user),

                  //  Proceed to orders
                  CustomProceedCard(
                    title: 'Orders',
                    subtitle: 'View recent orders',
                    svgIcon: 'assets/icons/ecommerce_pack_1/package.svg',
                    onTap: () async {
                      await Get.to(() => OrdersScreen());
                    }
                  ),

                  CustomDivider(text: Text('History'), topMargin: 30, bottomMargin: 30),

                  CustomerSummary(customer: customer),

                  SizedBox(height: 100)
                ],
              )
            ),
          )

        ],
      ),
    );
  }
}