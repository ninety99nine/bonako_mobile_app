import '../../create.dart';
import 'variation_tag.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../../../../providers/products.dart';
import '../../../../../../models/products.dart';
import 'package:get/get.dart';

class ProductVariationCard extends StatelessWidget {

  final Product product;
  final Function fetchVariations;

  ProductVariationCard({ required this.product, required this.fetchVariations });

  @override
  Widget build(BuildContext context) {

    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);

    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),

                    //  Product name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(product.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),)
                      ]
                    ),
                    SizedBox(height: 5),

                    //  Has variations
                    if(product.allowVariants.status) Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.device_hub_rounded, color: Colors.grey, size: 14,),
                        SizedBox(width: 5),
                        Text('Has variations', style: TextStyle(fontSize: 14),),
                      ]
                    ),

                    Row(
                      children: [

                        if(product.visible.status == false) Icon(Icons.visibility_off, color: Colors.grey, size: 20,),
                        if(product.visible.status == false) SizedBox(width: 5),
                        
                        //  Has Stock
                        if(!product.allowVariants.status && product.visible.status == false) Text('|', style: TextStyle(fontSize: 14, color: Colors.grey),),
                        if(!product.allowVariants.status && product.visible.status == false) SizedBox(width: 5),
                        if(!product.allowVariants.status) Text(product.attributes.hasStock.name, style: TextStyle(fontSize: 14, color: (product.attributes.hasStock.status ? Colors.grey: Colors.red))),
                        if(!product.allowVariants.status && product.attributes.hasStock.name != 'Unlimited Stock' && product.attributes.hasStock.status) Text(' ('+product.stockQuantity.value.toString()+')', style: TextStyle(fontSize: 14, color: (product.attributes.hasStock.status ? Colors.grey: Colors.red))),

                      ]
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: [
                        ...(product.embedded.variables).map((variable){
                          return ProductVariationTag(value: variable['value']);
                        }).toList()
                      ]
                    ),
                  ],
                ),
                Row(
                  children: [

                    Column(
                      children: [

                        if(!product.allowVariants.status && product.isFree.status) Text(product.isFree.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),

                        if(!product.allowVariants.status && !product.isFree.status && !product.attributes.hasPrice.status) Text(product.attributes.hasPrice.name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),),
                  
                        if(!product.allowVariants.status && !product.isFree.status && product.attributes.hasPrice.status) Text(product.attributes.unitPrice.currencyMoney, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),

                        if(!product.allowVariants.status && product.attributes.onSale.status) Text(product.unitRegularPrice.currencyMoney, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough, color: Colors.grey)),
                        
                      ],
                    ),

                    //  Forward Arrow 
                    TextButton(
                      onPressed: () => {}, 
                      child: Icon(Icons.arrow_forward, color: Colors.grey,),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)
                          )
                        )
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.blue.withOpacity(0.2),
              highlightColor: Colors.blue.withOpacity(0.2),
              child: Ink(
                height: 80,
                width: double.infinity
              ),
              onTap: () async {

                //  Get the current product variation on the ProductsProvider
                final productVariation = productsProvider.getProduct;
                  
                //  Set the selected product on the ProductsProvider
                productsProvider.setProduct(product);

                //  Go to the create product screen to edit this selected product
                await Get.to(() => CreateProductScreen());
                  
                //  On return reset the current product variation on the ProductsProvider
                productsProvider.setProduct(productVariation);

                //  Refetch the products as soon as we return back
                fetchVariations(resetPage: true);

              }, 
            )
          )
        ]
      )
    );
  }
}