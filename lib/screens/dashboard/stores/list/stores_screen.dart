import './../../../../../components/custom_rounded_refresh_button.dart';
import './../../../../screens/dashboard/stores/show/store_screen.dart';
import '../../../../components/custom_floating_action_button.dart';
import './../../../../../components/custom_button.dart';
import './../../../../../components/custom_loader.dart';
import './../../../../components/custom_countdown.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/store_drawer.dart';
import './../create/create_store_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './../../../../providers/stores.dart';
import './../../../../../models/stores.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './../../../../constants.dart';
import 'package:get/get.dart';
import 'dart:convert';

class StoresScreen extends StatelessWidget {

  static const routeName = '/stores';

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: CustomAppBar(title: 'Stores'),
      drawer: StoreDrawer(),
      body: Content(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomFloatingActionButton(),
    );
  }
}

class Content extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [

          //  Add Store
          CustomButton(
            text: '+ Add Store',
            color: Colors.blue,
            margin: EdgeInsets.symmetric(vertical: 20),
            onSubmit: () async {
              await Get.to(() => CreateStoresScreen());
            }
          ),

          //  List of created stores
          StoreList(
            title: 'My stores',
            subtitle: 'Stores created by you'
          ),

          SizedBox(height: 20),

          //  List of shared stores
          StoreList(
            shared: true,
            title: 'Shared stores',
            subtitle: 'Stores shared by others'
          ),

        ],
      ),
    );
  }
}

class AddStoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 30),
      child: ElevatedButton(
        onPressed: () => {
          Get.to(() => CreateStoresScreen())
        }, 
        child: Text(
          '+ Add Store',
          style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),  
        )
      ),
    );
  }
}

class StoreList extends StatefulWidget {
  
  final bool shared;
  final String title;
  final String subtitle;

  StoreList({ this.title = '', this.subtitle = '', this.shared = false });

  @override
  _StoreListState createState() => _StoreListState();
}

class _StoreListState extends State<StoreList> {

  late PaginatedStores paginatedStores;
  late List<Store> stores = [];
  var isLoading = false;

  void startLoader(){
    setState(() {
      isLoading = true;
    });
  }

  void stopLoader(){
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    
    fetchStores();

    super.initState();

  }

  void fetchStores(){

    print('fetchStores');

    startLoader();

    final apiInstance;
    final storesProvider = Provider.of<StoresProvider>(context, listen: false);
    

    if( widget.shared ){

      print('fetchSharedStores');

      //  Fetch the user shared stores
      apiInstance = storesProvider.fetchSharedStores(context: context);

    }else{

      print('fetchCreatedStores');

      //  Fetch the user created stores
      apiInstance = storesProvider.fetchCreatedStores(context: context);
      
    }

    //  Handle API request
    apiInstance.then((http.Response response) async {

        final responseBody = jsonDecode(response.body);

        setState(() {

          paginatedStores = PaginatedStores.fromJson(responseBody);
          stores = paginatedStores.embedded.stores;

        });

      }).whenComplete((){

        stopLoader();

      });
  }

  List<Widget> buildStoreCards(List<Store> stores){

    return stores.map((store) {
      return StoreCard(store: store, shared: this.widget.shared, fetchStores: fetchStores);
    }).toList();

  }

  @override
  Widget build(BuildContext context) {

    var storeCardWidgets = buildStoreCards(stores);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          //  Title & Refresh Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //  Title
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ), 
              //  Rounded Refresh Button
              CustomRoundedRefreshButton(onPressed: fetchStores)
            ],
          ),

          //  Subtitle
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(fontWeight: FontWeight.normal, color: Colors.grey),
            ),
          ),

          //  Divider
          Divider(),

          //  Loader
          if(isLoading == true) CustomLoader(),

            //  No stores
          if(isLoading == false && stores.length == 0) Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SvgPicture.asset('assets/icons/ecommerce_pack_1/shop.svg', width: 24),
                SizedBox(width: 10),
                Text('No stores found'),
              ],
            ),
          ),

            //  List of card widgets
          if(isLoading == false && stores.length > 0) ...storeCardWidgets
          
        ],
      ),
    );
  }
}

class StoreCard extends StatelessWidget {

  final Store store;
  final bool shared;
  final Function fetchStores;

  StoreCard({ required this.store, required this.shared, required this.fetchStores });

  @override
  Widget build(BuildContext context) {

    final subscription = store.attributes.subscription;
    final hasSubscription = store.attributes.hasSubscription;
    final subscriptionExpiryTime = (hasSubscription ? subscription!.endAt : null);

    final visitShortCode = store.attributes.visitShortCode;
    final hasVisitShortCode = store.attributes.hasVisitShortCode;
    final visitShortCodeDialingCode = (hasVisitShortCode ? visitShortCode!.dialingCode : '');

    final endTime = (subscriptionExpiryTime == null) ? DateTime.now().millisecondsSinceEpoch : subscriptionExpiryTime.millisecondsSinceEpoch;

    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Card(
        elevation: 3,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
          
                  //  Store Name & Dialing Code
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
    
                          //  Store Name
                          Text(store.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                          
                          SizedBox(width: 10),
          
                          //  Store Dialing Code
                          if(hasSubscription && hasVisitShortCode) 
                            Text(visitShortCodeDialingCode),
          
                          //  Store Dialing Code (Unknown)
                          if(hasSubscription && !hasVisitShortCode) 
                            Text('No shortcode', style: TextStyle(color: Colors.red)),
                           
                         ]
                      ),

                      //  Subscription End Date 
                      if(hasSubscription)
                        CustomCountdown(
                          onEnd: (){
                            
                          },
                          endTime: endTime,
                          endWidget: Text('Subscription ended', style: TextStyle(color: Colors.red),)
                        )
                      ], 

                  ),
          
                  Container(
                    child:
                      hasSubscription
                        //  Arrow Button
                        ? TextButton(
                          onPressed: (){
                            Get.to(() => ShowStoreScreen());
                          }, 
                          child: Icon(Icons.arrow_forward, color: Colors.grey,),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)
                              )
                            )
                          )
                        )
                        : //  Options Button
                        Row(
                          children: <Widget>[

                            SvgPicture.asset('assets/icons/ecommerce_pack_1/padlock-1.svg', width: 16),
                            SizedBox(width: 20),
                            StoreCardOptionButton(store: store, shared: shared, fetchStores: fetchStores)

                          ]
                        )
                      )
                ]
              ),
            ),

            //  InkWell splash color
            if(hasSubscription == true)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Ink(
                    height: 78,
                    width: double.infinity
                  ),
                  onTap: () {
                    if( hasSubscription ){
                      
                      //  Set the selected store on the StoresProvider
                      Provider.of<StoresProvider>(context, listen: false).setStore(store);

                      Get.to(() => ShowStoreScreen());
                      
                    }
                  }, 
                )
              )
          ],
        ),
      ),
    );
    
  }
}

class StoreCardOptionButton extends StatelessWidget {

  final Store store;
  final bool shared;
  final Function fetchStores;

  StoreCardOptionButton({ required this.store, required this.shared, required this.fetchStores });

  void showSimpleDialog(BuildContext context){

    showDialog(
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
              svg: 'assets/icons/ecommerce_pack_1/mobile-phone-2.svg',
              onPressed: () async {

                Provider.of<StoresProvider>(context, listen: false).launchPaymentShortcode(
                  store: store,
                  context: context
                );

              }
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
                svg: 'assets/icons/ecommerce_pack_1/delete.svg',
                onPressed: () async {

                  Provider.of<StoresProvider>(context, listen: false).deleteStore(
                    store: store,
                    context: context
                  ).whenComplete((){

                    //  Remove the alert dialog
                    Navigator.of(context).pop();

                    //  Re-fetch the stores
                    fetchStores();

                  });

                }
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 15),
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
  final Function()? onPressed;

  const StoreDialogOption({ this.title = 'Option', this.color, this.svg, this.onPressed });

  @override
  Widget build(BuildContext context) {

    bool hasSvg = (svg != null);
    bool hasColor = (color != null);

    return SimpleDialogOption(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      onPressed: onPressed,
      child: Row(
        children: [
          if(hasSvg) SvgPicture.asset(svg!, width: 20, color: hasColor ? color : Colors.black,),
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