import 'package:bonako_mobile_app/components/custom_checkmark_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivateTotalItemsScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Activate On Total Items'),
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
  Map couponForm = {};
  Map serverErrors = {};

  @override
  void initState() {

    ///  Clone the arguments. This is because the data passed holds a strong
    ///  reference to the same data on the previous screen. Therefore if we
    ///  mutate the arguments, then the data from the previous screen will
    ///  also be changed. To avoid this, then we must clone the arguments,
    ///  so that we can freely mutate the data while preserving the
    ///  orginal state on the previous screen.
    couponForm = new Map.from(Get.arguments['couponForm']);
    serverErrors = new Map.from(Get.arguments['serverErrors']);

    super.initState();

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

                    Row(
                      children: [
                        Text('Activate On Total Items'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['allow_discount_on_total_items'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['allow_discount_on_total_items'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    SizedBox(height: 20),

                    if(couponForm['allow_discount_on_total_items']) TextFormField(
                      autofocus: false,
                      initialValue: couponForm['discount_on_total_items'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Minimum items",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SvgPicture.asset('assets/icons/ecommerce_pack_1/shopping-bag-2.svg', width: 16,),
                        ),
                        hintText: 'E.g 2',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Enter minimum total e.g 2';
                        }else if(serverErrors.containsKey('discount_on_total_items')){
                          return serverErrors['discount_on_total_items'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          couponForm['discount_on_total_items'] = value;
                        });
                      }
                    ),
                      
                    Divider(height: 40),

                    (couponForm['allow_discount_on_total_items'] == true) 
                      ? CustomCheckmarkText(
                          text: (couponForm['discount_on_total_items'] == null || couponForm['discount_on_total_items'] == ''
                            ? 'Enter the minimum number of items in the cart that this coupon is active for use' 
                            : 'This coupon will be valid for orders placed with a minimum number of '+couponForm['discount_on_total_items']+' items or greater'),
                          state: (couponForm['discount_on_total_items'] == null || couponForm['discount_on_total_items'] == '' ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'This coupon does not depend on the number of items being ordered'),

                    Divider(height: 40,),

                    CustomButton(
                      text: 'Done',
                      onSubmit: () {
                        Get.back(result: couponForm);
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