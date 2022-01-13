import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/providers/api.dart';
import 'package:bonako_mobile_app/models/customers.dart';
import 'package:bonako_mobile_app/providers/customers.dart';
import 'package:bonako_mobile_app/screens/dashboard/customers/show/customer_screen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import './../../../../models/orders.dart';
import 'package:flutter/material.dart';
import './orderStatusSummary.dart';
import 'package:intl/intl.dart';

class CustomerSummaryCard extends StatelessWidget {

  final Function()? onReturn;
  final Order order;

  const CustomerSummaryCard({ required this.order, this.onReturn });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //  Customer name
                    Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.person, color: Colors.grey, size: 14,),
                          SizedBox(width: 5),
                          Expanded(child: Text(order.embedded.customer.embedded.user.attributes.name, overflow: TextOverflow.ellipsis,))
                        ],
                      ),
                    ),
                    //  Customer Number
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.phone, color: Colors.grey, size: 14,),
                          SizedBox(width: 5),
                          Text(order.embedded.customer.embedded.user.mobileNumber.number)
                        ]
                      ),
                    ),             
                    //  Forward Arrow 
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.arrow_forward, color: Colors.grey,),
                      ),
                    )
                  ],
                ),
                
                SizedBox(height: 10),

                //  Date
                if(order.createdAt != null) Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.watch_later_outlined, color: Colors.grey, size: 14,),
                    SizedBox(width: 5),
                    Text(DateFormat("MMM d y @ HH:mm").format(order.createdAt!), style: TextStyle(fontSize: 14),),
                  ]
                ),
                
                SizedBox(height: 10),

                //  Payment status | Delivery status | Total items | Total coupons
                OrderStatusSummary(
                  order: order,
                )
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              child: Ink(
                height: 105,
                width: double.infinity
              ),
              onTap: () async {

                final customersProvider = Provider.of<CustomersProvider>(context, listen: false);
                final apiProvider = Provider.of<ApiProvider>(context, listen: false);
                final Customer? customer = order.embedded.customer;
                
                if(customer != null){

                  //  Set the selected customer on the CustomersProvider
                  customersProvider.setCustomer(customer);

                  await Get.to(() => ShowCustomerScreen());

                  //  Unset the selected customer on the CustomersProvider
                  customersProvider.unsetCustomer();

                  //  If we have an on return callback
                  if( onReturn != null ){

                    onReturn!();

                  }

                }else{

                  //  Customer missing snackbar
                  apiProvider.showSnackbarMessage(msg: 'Customer information missing', context: context, type: SnackbarType.error);

                }

              }, 
            )
          )
        ]
      )
    );

  }
}