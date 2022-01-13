import 'package:bonako_mobile_app/components/custom_back_button.dart';
import 'package:bonako_mobile_app/components/custom_divider.dart';
import 'package:bonako_mobile_app/screens/dashboard/orders/show/order_screen.dart';
import 'package:get/get.dart';

import '../../../components/custom_app_bar.dart';
import '../../../components/store_drawer.dart';
import '../../../providers/orders.dart';
import '../../../models/itemLines.dart';
import '../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CartItemLineScreen extends StatelessWidget {

  final ItemLine itemLine;

  const CartItemLineScreen({ required this.itemLine });
  
  @override
  Widget build(BuildContext context){

    final Order order = Provider.of<OrdersProvider>(context, listen: false).getOrder;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Order #' + order.number),
        drawer: StoreDrawer(),
        body: Content(
          itemLine: itemLine
        ),
      )
    );
  }
}

class Content extends StatelessWidget {

  final ItemLine itemLine;

  const Content({ required this.itemLine });

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

  @override
  Widget build(BuildContext context) {

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
                            TextSpan(text: itemLine.name),
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
                          TextSpan(text: itemLine.description),
                        ],
                      ),
                    ),

                    headingDivider('Tracking'),
                    
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SKU'),
                          Text(itemLine.sku == null ? 'NONE' : itemLine.sku, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Barcode'),
                          Text(itemLine.barcode == null ? 'NONE' : itemLine.barcode, style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    headingDivider('Unit Pricing'),
                    
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Regular Price'),
                          Text(itemLine.unitRegularPrice.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, decoration: (itemLine.unitRegularPrice.amount != '0' && (itemLine.attributes.onSale.status || itemLine.isFree.status)) ? TextDecoration.lineThrough : TextDecoration.none),),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: itemLine.isFree.status ? 20 : 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sale Price'),
                          Text(itemLine.unitSalePrice.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, decoration: (itemLine.unitSalePrice.amount != '0' && itemLine.isFree.status) ? TextDecoration.lineThrough : TextDecoration.none),),
                        ],
                      ),
                    ),

                    if(itemLine.isFree.status) Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Free', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text('Yes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),

                    if(itemLine.attributes.onSale.status == true && itemLine.isFree.status == false) Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(text: 'Each item was on sale for '),
                            TextSpan(
                              text: itemLine.unitSalePrice.currencyMoney, 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            TextSpan(text: ' instead of the regular price of '),
                            TextSpan(
                              text: itemLine.unitRegularPrice.currencyMoney, 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            TextSpan(text: ' at the time the customer was shopping'),
                          ],
                        ),
                      ),
                    ),

                    if(itemLine.isFree.status == true) Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(text: 'Each item was sold for '),
                            TextSpan(
                              text: 'FREE', 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            
                            //  If we have a sale price and regular price
                            if(itemLine.attributes.onSale.status == true && itemLine.unitSalePrice.amount != '0') TextSpan(text: ' instead of the sale price of '),
                            if(itemLine.attributes.onSale.status == true && itemLine.unitSalePrice.amount != '0') TextSpan(
                              text: itemLine.unitSalePrice.currencyMoney,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            if(itemLine.attributes.onSale.status == true && itemLine.unitRegularPrice.amount != '0') TextSpan(text: ' or the regular price of '),
                            if(itemLine.attributes.onSale.status == true && itemLine.unitRegularPrice.amount != '0') TextSpan(
                              text: itemLine.unitRegularPrice.currencyMoney,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),

                            //  If we have a regular price only
                            if(itemLine.attributes.onSale.status == false && itemLine.unitRegularPrice.amount != '0') TextSpan(text: ' instead of the regular price of '),
                            if(itemLine.attributes.onSale.status == false && itemLine.unitRegularPrice.amount != '0') TextSpan(
                              text: itemLine.unitRegularPrice.currencyMoney,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),

                            TextSpan(text: ' at the time the customer was shopping.'),
                          ],
                        ),
                      ),
                    ),

                    headingDivider('Unit Quantity'),
                    
                    if(itemLine.originalQuantity != itemLine.quantity) Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Original Quantity'),
                          Text(itemLine.originalQuantity.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Checkout Quantity'),
                          Text(itemLine.quantity.toString(), style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),

                    if(itemLine.originalQuantity > itemLine.quantity) Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(text: 'The customer originally added '),
                            TextSpan(
                              text: itemLine.originalQuantity.toString(), 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            TextSpan(text: ' items to the cart, however the quantity was reduced to '),
                            TextSpan(
                              text: itemLine.quantity.toString(), 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            TextSpan(text: ' due to limited stock while checking out.'),
                          ],
                        ),
                      ),
                    ),

                    headingDivider(
                      Row(
                        children: [
                          headingText('Checkout Pricing'),
                          Text(' (x'+itemLine.quantity.toString()+')')
                        ],
                      )
                    ),

                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sub Total'),
                          Text(itemLine.subTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, decoration: (itemLine.subTotal.amount != '0' && itemLine.isFree.status) ? TextDecoration.lineThrough : TextDecoration.none),),
                        ],
                      ),
                    ),
                    
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sale Discount Total'),
                          Text(itemLine.saleDiscountTotal.currencyMoney, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, decoration: (itemLine.saleDiscountTotal.amount != '0' && itemLine.isFree.status) ? TextDecoration.lineThrough : TextDecoration.none),),
                        ],
                      ),
                    ),
                    
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Grand Total'),
                          Text(itemLine.grandTotal.currencyMoney, style: TextStyle(fontWeight: FontWeight.bold, decoration: (itemLine.grandTotal.amount != '0' && itemLine.isFree.status) ? TextDecoration.lineThrough : TextDecoration.none),),
                        ],
                      ),
                    ),

                    if(itemLine.isFree.status) Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Free', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Text('Yes', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),

                    if(itemLine.isFree.status == true) Container(
                      margin: EdgeInsets.only(top: 20),
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(
                              text: itemLine.quantity.toString() + (itemLine.quantity == 1 ? ' item ' : ' items '), 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            TextSpan(text: (itemLine.quantity == 1 ? ' was ' : ' where ') + ' sold for '),
                            TextSpan(
                              text: 'FREE', 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),

                            //  Grand total
                            if(itemLine.grandTotal.amount != '0') TextSpan(text: ' instead of the grand total of '),
                            if(itemLine.grandTotal.amount != '0') TextSpan(
                              text: itemLine.grandTotal.currencyMoney,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),

                            TextSpan(text: ' at the time the customer was shopping.'),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 100)
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