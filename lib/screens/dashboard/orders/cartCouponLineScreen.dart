import 'package:bonako_mobile_app/components/custom_back_button.dart';
import 'package:bonako_mobile_app/components/custom_divider.dart';
import 'package:bonako_mobile_app/components/custom_explainer.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/show/order_screen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../components/custom_app_bar.dart';
import '../../../components/store_drawer.dart';
import '../../../providers/orders.dart';
import '../../../models/couponLines.dart';
import '../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CartCouponLineScreen extends StatelessWidget {

  final CouponLine couponLine;

  const CartCouponLineScreen({ required this.couponLine });
  
  @override
  Widget build(BuildContext context){

    final Order order = Provider.of<OrdersProvider>(context, listen: false).getOrder;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Order #' + order.number),
        drawer: StoreDrawer(),
        body: Content(
          couponLine: couponLine
        ),
      )
    );
  }
}

class Content extends StatelessWidget {

  final CouponLine couponLine;

  const Content({ required this.couponLine });

  Widget headingDivider(dynamic title){
    return CustomDivider(
      text: (title is Widget ) ? title : headingText(title), 
      alignment: CrossAxisAlignment.center,
      showLeftDivider: false, 
      bottomMargin: 40,
      topMargin: 40, 
      leftMargin: 0, 
    ); 
  }

  Widget headingText(String title){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5)
      ),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold))
    );
  }

  List<Map> getActivationRules(){
    
    final List<Map> rules = [];

    //  Activate on usage limit
    if(couponLine.allowUsageLimit.status == true){
      rules.add({
        'title': 'Limited usage',
        'value': couponLine.quantityRemaining.toString() + ' left',
        'description': couponLine.allowUsageLimit.description
      });
    }

    //  Activate on minimum total
    if(couponLine.allowDiscountOnMinimumTotal.status == true){
      rules.add({
        'title': 'Minimum total',
        'value': couponLine.discountOnMinimumTotal.currencyMoney,
        'description': couponLine.allowDiscountOnMinimumTotal.description
      });
    }

    //  Activate on total items
    if(couponLine.allowDiscountOnTotalItems.status == true){
      rules.add({
        'title': 'Total items',
        'value': couponLine.discountOnTotalItems.toString(),
        'description': couponLine.allowDiscountOnTotalItems.description
      });
    }

    //  Activate on total unique items
    if(couponLine.allowDiscountOnTotalUniqueItems.status == true){
      rules.add({
        'title': 'Total unique items',
        'value': couponLine.discountOnTotalUniqueItems.toString(),
        'description': couponLine.allowDiscountOnTotalUniqueItems.description
      });
    }

    //  Activate on start date time
    if(couponLine.allowDiscountOnStartDatetime.status == true){
      rules.add({
        'title': 'Start date',
        'value': couponLine.discountOnStartDatetime == null ? 'No date' : DateFormat("MMM d y @ HH:mm").format(couponLine.discountOnStartDatetime!).toString(),
        'description': couponLine.allowDiscountOnStartDatetime.description
      });
    }

    //  Activate on end date time
    if(couponLine.allowDiscountOnEndDatetime.status == true){
      rules.add({
        'title': 'End date',
        'value': couponLine.discountOnEndDatetime == null ? 'No date' : DateFormat("MMM d y @ HH:mm").format(couponLine.discountOnEndDatetime!).toString(),
        'description': couponLine.allowDiscountOnEndDatetime.description
      });
    }

    //  Activate on times
    if(couponLine.allowDiscountOnTimes.status == true){
      rules.add({
        'title': 'Times',
        'value': '',
        'description': couponLine.allowDiscountOnTimes.description
      });
    }

    //  Activate on days of the week
    if(couponLine.allowDiscountOnDaysOfTheWeek.status == true){
      rules.add({
        'title': 'Days of the week',
        'value': '',
        'description': couponLine.allowDiscountOnDaysOfTheWeek.description
      });
    }

    //  Activate on days of the month
    if(couponLine.allowDiscountOnDaysOfTheMonth.status == true){
      rules.add({
        'title': 'Days of the month',
        'value': '',
        'description': couponLine.allowDiscountOnDaysOfTheMonth.description
      });
    }

    //  Activate on months of the year
    if(couponLine.allowDiscountOnMonthsOfTheYear.status == true){
      rules.add({
        'title': 'Months of the year',
        'value': '',
        'description': couponLine.allowDiscountOnMonthsOfTheYear.description
      });
    }

    //  Activate on new customer
    if(couponLine.allowDiscountOnNewCustomer.status == true){
      rules.add({
        'title': 'New customer',
        'value': '',
        'description': couponLine.allowDiscountOnNewCustomer.description
      });
    }

    //  Activate on existing customer
    if(couponLine.allowDiscountOnExistingCustomer.status == true){
      rules.add({
        'title': 'Existing customer',
        'value': '',
        'description': couponLine.allowDiscountOnExistingCustomer.description
      });
    }

    return rules;
  }

  @override
  Widget build(BuildContext context) {
    
    final activationRules = getActivationRules();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.offAll(() => OrderScreen());
              })
            ],
          ),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 20),

                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, height: 1.5),
                          children: <TextSpan>[
                            TextSpan(text: 'Name: ', style: TextStyle(fontWeight: FontWeight.bold),),
                            TextSpan(text: couponLine.name),
                          ],
                        ),
                      ),
                    ),

                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: TextStyle(color: Colors.black, height: 1.5),
                        children: <TextSpan>[
                          TextSpan(text: 'Description: ', style: TextStyle(fontWeight: FontWeight.bold),),
                          TextSpan(text: couponLine.description),
                        ],
                      ),
                    ),

                    headingDivider('Discount'),
                    
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Offer Discount'),
                          Text(couponLine.applyDiscount.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    
                    if(couponLine.applyDiscount.status == true) Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(couponLine.discountRateType.name),
                          Text(couponLine.discountRateType.type == 'Percentage' ? couponLine.percentageRate.toString() + '%' : couponLine.fixedRate.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    if(couponLine.applyDiscount.status == true) Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(couponLine.discountRateType.description),
                    ),

                    headingDivider('Free Delivery'),
                    
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Offer Free Delivery'),
                          Text(couponLine.allowFreeDelivery.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    if(couponLine.allowFreeDelivery.status == true) Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(couponLine.allowFreeDelivery.description),
                    ),

                    headingDivider('Activation'),
                    
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Activation Type'),
                          Text(couponLine.activationType.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    
                    if(couponLine.activationType.type == 'use code') Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Code Used'),
                          Text(couponLine.code == null ? 'NONE' : couponLine.code!, style: TextStyle(fontWeight: FontWeight.bold, color: couponLine.code == null ? Colors.black : Colors.green)),
                        ],
                      ),
                    ),

                    headingDivider('Activation Rules'),

                    //  Activation rules
                    ...activationRules.map((activationRule){

                      final index = activationRules.indexOf(activationRule);
                      final position = (index + 1).toString();

                      return CustomExplainer(
                        mark: position,
                        title: activationRule['title'],
                        sideNote: activationRule['value'],
                        margin: EdgeInsets.only(bottom: 20),
                        description: activationRule.containsKey('description') ? activationRule['description'] : null,
                      );

                    }),

                    //  No Activation Rules
                    if(activationRules.length == 0) Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.grey, size: 12,),
                            SizedBox(width: 10),
                            Text('No activation rules', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ]
                        )
                    ),

                    SizedBox(height: 100),

                  ],
                ),
              )
            ),
          )

        ],
      ),
    );
  }
}