import './../../../../../components/custom_multi_coupon_selector';
import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import './../../../../../providers/coupons.dart';
import './../../../../../models/coupons.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectCouponsScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Select Coupons'),
        drawer: StoreDrawer(),
        body: Content(),
      )
    );

  }
}

class Content extends StatefulWidget {
  
  //  Set the form key
  @override
  _ContentState createState() => _ContentState();
  
}

class _ContentState extends State<Content> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  Map instantCartForm = {};
  Map serverErrors = {};
  
  late PaginatedCoupons paginatedCoupons;
  late List<Coupon> coupons;
  late int count;

  @override
  void initState() {

    ///  Clone the arguments. This is because the data passed holds a strong
    ///  reference to the same data on the previous screen. Therefore if we
    ///  mutate the arguments, then the data from the previous screen will
    ///  also be changed. To avoid this, then we must clone the arguments,
    ///  so that we can freely mutate the data while preserving the
    ///  orginal state on the previous screen.
    instantCartForm = new Map.from(Get.arguments['instantCartForm']);
    serverErrors = new Map.from(Get.arguments['serverErrors']);

    super.initState();

  }

  List get selectedCoupons {
    return instantCartForm['coupons'];
  }

  bool get hasSelectedCoupons {
    return selectedCoupons.length > 0;
  }

  String get hasSelectedCouponsTotal {
    return selectedCoupons.length.toString();
  }

  CouponsProvider get couponsProvider {
    return Provider.of<CouponsProvider>(context, listen: false);
  }

  Widget selectCouponsButton(){
    final List<int> selectedCouponIds = new List<int>.from(selectedCoupons.map((selectedCoupon) => selectedCoupon['id']).toList());

    return Container(
      width: 200,
      child: CustomMultiCouponSelector(
        selectedCouponIds: selectedCouponIds,
        onSelected: (selectedCoupons){
          selectedCoupons.forEach((coupon) {
            addCouponAsCoupon(coupon);
          });
        }
      ),
    );
  }

  void addCouponAsCoupon(Coupon coupon){

    final alreadyExists = selectedCoupons.map((couponItem) => couponItem['id']).toList().contains(coupon.id);

    if(alreadyExists == false){
      final couponItem = {
        'id': coupon.id,
        'name': coupon.name,
      };

      setState(() {
      
        selectedCoupons.add(couponItem);
        
      });

    }
  }

  Widget couponItemWidgets(){

    final couponItemWidgets = selectedCoupons.map((couponItem){
      return couponItemWidget(couponItem);
    }).toList();

    return Column(
      children: [
        if(hasSelectedCoupons == false) noCouponsSelectedWidget(),
        ...couponItemWidgets
      ],
    );

  }
  
  Widget noCouponsSelectedWidget(){
    return Container(
      margin: EdgeInsets.only(top: 5, left: 10),
      child: CustomCheckmarkText(text: 'Select atleast one coupon', state: 'warning',)
    );
  }
  
  Widget couponItemWidget(couponItem){

    final index = selectedCoupons.indexOf(couponItem);

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          couponItemNameWidget(index),
          couponItemRemoveIconWidget(index)
        ],
      ),
    );
  }

  Widget couponItemNameWidget(index){
    return Expanded(
      flex: 3,
      child: Text(selectedCoupons[index]['name'], style: TextStyle(fontWeight: FontWeight.bold),)
    );
  }

  Widget couponItemRemoveIconWidget(index){
    return Expanded(
      flex: 1,
      child: TextButton(
        child: Icon(Icons.delete_outlined, color: Colors.red,),
        onPressed: (){
          showDialog(
            context: context, 
            builder: (_) => AlertDialog(
              title: Text('Confirmation'),
              content: Text('Are you sure you want to remove '+selectedCoupons[index]['name']+'?'),
              actions: [

                //  Cancel Button
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () { 
                    //  Remove the alert dialog and return False as final value
                    Navigator.of(context).pop(false);
                  }
                ),

                //  Remove Button
                TextButton(
                  child: Text('Remove', style: TextStyle(color: Colors.red)),
                  onPressed: (){
                    setState((){
                      selectedCoupons.removeAt(index);
                      Navigator.of(context).pop(false);
                    });
                  }
                ),
              ],
            )
          );
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //  Pass the un-editted CouponForm as the argument
              CustomBackButton()
            ],
          ),

          Divider(height: 0),

          SizedBox(height: 20),

          //  Form
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[

                    selectCouponsButton(),
                      
                    Divider(height: 40),

                    couponItemWidgets(),
                      
                    if(hasSelectedCoupons) Divider(height: 40),

                    if(hasSelectedCoupons) CustomCheckmarkText(
                      margin: EdgeInsets.only(left: 5),
                      text: 'Checkout with the '+(hasSelectedCouponsTotal)+' '+(hasSelectedCouponsTotal == '1' ? 'coupon': 'coupons')+' listed'
                    ),

                    Divider(height: 40,),

                    CustomButton(
                      text: 'Done',
                      disabled: (hasSelectedCoupons == false),
                      onSubmit: () {
                        Get.back(result: instantCartForm);
                      },
                    ),
                    
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