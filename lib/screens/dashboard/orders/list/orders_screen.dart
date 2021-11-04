import 'package:bonako_app_3/screens/dashboard/stores/show/store_screen.dart';
import './../../../../screens/dashboard/orders/show/order_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import '../../../../components/custom_floating_action_button.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../../components/custom_loader.dart';
import './../../../../components/custom_app_bar.dart';
import 'package:bonako_app_3/providers/stores.dart';
import '../../../../components/store_drawer.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../../models/stores.dart';
import './../../../../providers/orders.dart';
import './../../../../models/orders.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import './../../../../constants.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:convert';

class OrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      floatingActionButton: CustomFloatingActionButton(),
      appBar:CustomAppBar(title: 'Orders'),
      drawer: StoreDrawer(),
      body: Content(),
    );
  }
}

class Content extends StatefulWidget {

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  late PaginatedOrders paginatedOrders;

  List<Order> orders = [];

  var isLoading = false;

  void startLoader(){
    if(mounted){
      setState(() {
        isLoading = true;
      });
    }
  }

  void stopLoader(){
    if(mounted){
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    
    fetchOrders();

    super.initState();

  }

  void fetchOrders(){

    startLoader();

    final apiInstance;
    final locationsProvider = Provider.of<OrdersProvider>(context, listen: false);
    
    //  Fetch the location orders
    apiInstance = locationsProvider.fetchOrders(context: context);

    //  Handle API request
    apiInstance.then((http.Response response) async {

        final responseBody = jsonDecode(response.body);

        setState(() {

          paginatedOrders = PaginatedOrders.fromJson(responseBody);
          orders = paginatedOrders.embedded.orders;

        });

      }).whenComplete((){

        stopLoader();

      });
      
  }

  bool get hasOrders {
    return (orders.length > 0);
  }

  @override
  Widget build(BuildContext context) {
    
    final storesProvider = Provider.of<StoresProvider>(context, listen: false);
    final dialingCode = storesProvider.getStoreVisitShortCodeDialingCode;
    final store = storesProvider.store;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomBackButton(fallback: (){
                Get.off(() => ShowStoreScreen());
              }),
              CustomRoundedRefreshButton(onPressed: fetchOrders),
            ],
          ),
          Divider(),

          SizedBox(height: 20),
          
          if(hasOrders) Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              //  Search Orders
              SearchOrders(),
        
              //  Search Orders
              FilterOrders(),
              
            ],
          ),

          if(hasOrders) SizedBox(height: 20,),

          if(hasOrders) Expanded(
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
          
                //  Store Orders
                OrderList(
                  orders: orders
                ),
          
              ],
            ),
          ),    

          //  Loader
          if(!hasOrders && isLoading == true) CustomLoader(),

          //  No orders found
          if(!hasOrders && isLoading == false) Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: SvgPicture.asset('assets/icons/ecommerce_pack_1/package-6.svg', width: 40.00, color: Colors.white,),
              ),
              SizedBox(height: 30),
              Text('No orders found', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),),
              
              SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.all(20),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, height: 1.5),
                    children: <TextSpan>[
                      TextSpan(text: 'Add products to your store and ask customers to dial '),
                      TextSpan(
                        text: dialingCode, 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, decoration: TextDecoration.underline), 
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            storesProvider.launchVisitShortcode(store: store, context: context);
                          }),
                      TextSpan(text: ' to visit '),
                      TextSpan(
                        text: store.name,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            storesProvider.launchVisitShortcode(store: store, context: context);
                          }),
                      TextSpan(text: ' to start placing orders. '),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return 
      Expanded(
        child: TextField(
          decoration: InputDecoration(
            isDense: true,
            labelText: "Search orders",
            helperText: 'Search using order number or customer name',
            labelStyle: TextStyle(
              fontSize: 14
            ),
            border:OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.circular(15.0),
            ),
            suffixIcon: Icon(Icons.search)
          )
        ),
      );
  }
}

class FilterOrders extends StatefulWidget {

  @override
  _FilterOrdersState createState() => _FilterOrdersState();
}

class _FilterOrdersState extends State<FilterOrders> {

  final List<String> countList = [
    "Paid",
    "Unpaid",
    "Delivered",
    "Undelivered"
  ];

  List<String>? selectedCountList = [];

  void _openFilterDialog() async {
    await FilterListDialog.display<String>(
      context,
      height: 250,
      listData: countList,
      hideSearchField: true,
      headlineText: "Select Filters",
      applyButtonTextStyle: TextStyle(
        fontSize: 16
      ),
      controlButtonTextStyle: TextStyle(
        fontSize: 16,
        color: Colors.black
      ),
      selectedListData: selectedCountList,
      choiceChipLabel: (item) {
        return item;
      },
      validateSelectedItem: (list, val) {
          return list!.contains(val);
      },
      onItemSearch: (list, text) {
          if (list!.any((element) =>
              element.toLowerCase().contains(text.toLowerCase()))) {
            return list.where((element) =>
                    element.toLowerCase().contains(text.toLowerCase()))
                .toList();
          }
          else{
            return [];
          }
        },
      onApplyButtonClick: (list) {
        if (list != null) {
          setState(() {
            selectedCountList = List.from(list);
          });
        }
        Navigator.pop(context);
      });
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: ElevatedButton(
        
        style: ButtonStyle(

          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(vertical: 12, horizontal: 0)
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50)
            )
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.green)
          
          /*
          padding: EdgeInsets.all(12),
          primary: Colors.grey,
          
          textStyle: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold
          ),
          */
        ),
        onPressed: () => { 
          _openFilterDialog()
        }, 
        child: Icon(Icons.filter_alt_outlined, color: Colors.white),
      ),
    );
  }
}

class OrderList extends StatelessWidget {

  final List<Order> orders;

  OrderList({ required this.orders });

  @override
  Widget build(BuildContext context) {

    Widget buildOrderListView(List<Order> orders){

      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: orders.length,
        itemBuilder: (ctx, index){
          return OrderCard(order: orders[index]);
        }
      );

    }

    final orderListView = buildOrderListView(orders);

    return SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: <Widget>[

          //  List of card widgets
          orderListView,

        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {

  final Order order;

  OrderCard({ required this.order });

  @override
  Widget build(BuildContext context) {

    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

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
                    SizedBox(height: 10),
                    //  Order # & Customer name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('#'+order.number, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        SizedBox(width: 10),
                        Text(order.embedded.customer.embedded.user.attributes.name)
                      ]
                    ),
                    SizedBox(height: 10),
                    //  Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.watch_later_outlined, color: Colors.grey, size: 14,),
                        SizedBox(width: 5),
                        Text(DateFormat("MMM d y @ HH:mm").format(order.createdAt), style: TextStyle(fontSize: 14),),
                      ]
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(order.embedded.paymentStatus.name, style: TextStyle(fontSize: 14, color: (order.embedded.paymentStatus.name == 'Paid' ? Colors.green: Colors.grey))),
                        SizedBox(width: 10),
                        Text(order.embedded.deliveryStatus.name, style: TextStyle(fontSize: 14, color: (order.embedded.deliveryStatus.name == 'Delivered' ? Colors.green: Colors.grey))),
                        //  Total Items
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(width: 5),
                              Text('|', style: TextStyle(fontSize: 14, color: Colors.grey),),
                              SizedBox(width: 5),
                              Text(order.embedded.activeCart.totalItems.toString(), style: TextStyle(fontSize: 14, color: Colors.grey),),
                              Text(order.embedded.activeCart.totalItems.toString() == '1' ? ' item' : ' items', style: TextStyle(fontSize: 14, color: Colors.grey),)
                            ]
                          ),
                        ),
                      ]
                    ),
                  ],
                ),
                Row(
                  children: [
              
                    Text(order.embedded.activeCart.grandTotal.currencyMoney, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              
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
              child: Ink(
                height: 105,
                width: double.infinity
              ),
              onTap: () {
                  
                //  Set the selected order on the OrdersProvider
                ordersProvider.setOrder(order);

                Get.to(() => OrderScreen());

              }, 
            )
          )
        ]
      )
    );
  }
}

class StoreCardOptionButton extends StatelessWidget {

  final Store store;
  final bool shared;

  StoreCardOptionButton({ required this.store, required this.shared });

  void showSimpleDialog(BuildContext context) => showDialog(
    context: context, 
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(store.name),
        children: <Widget>[

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Text(
              shared ? 'Subscribe to access this store'
                     : 'Subscribe to access this store and start adding products and receiving orders.'
            ),
          ),

          Divider(),

          //  Subscribe option
          StoreDialogOption(
            title: 'Subscribe',
            svg: 'assets/icons/ecommerce_pack_1/mobile-phone-2.svg'
          ),

          //  Invite option
          if(shared == false)
            StoreDialogOption(
              title: 'Invite team',
              svg: 'assets/icons/ecommerce_pack_1/add-contact.svg'
            ),

          Divider(),

          //  Delete option
          if(shared == false)
            StoreDialogOption(
              title: 'Delete',
              color: Colors.red,
              svg: 'assets/icons/ecommerce_pack_1/delete.svg'
            ),

          //  Delete option
          if(shared == true)
            StoreDialogOption(
              title: 'Decline invitation',
              color: Colors.red,
              svg: 'assets/icons/ecommerce_pack_1/delete.svg'
            ),
        ],
      );
    }
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ElevatedButton(
          onPressed: () => {
            showSimpleDialog(context)
          }, 
          child: Text('Options'),
          style:  ElevatedButton.styleFrom(
            primary: kPrimaryColor
          ),
        ),
      );
  }
}

class StoreDialogOption extends StatelessWidget {

  final String title;
  final Color? color;
  final String? svg;

  const StoreDialogOption({ this.title = 'Option', this.color, this.svg });

  @override
  Widget build(BuildContext context) {

    bool hasSvg = (svg != null);
    bool hasColor = (color != null);

    return SimpleDialogOption(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      onPressed: () { 
      
      },
      child: Row(
        children: [
          if(hasSvg) SvgPicture.asset(svg!, width: 20.00, color: hasColor ? color : Colors.black,),
          SizedBox(width: 10),
          Text(title, style: TextStyle(
            color: hasColor ? color : Colors.black,
            fontSize: 16
          ))
        ]
      )
    );
  }
}