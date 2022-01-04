import 'package:bonako_mobile_app/components/custom_checkmark_text.dart';

import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivateUsageLimitScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Allow Usage Limit'),
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
  bool hasReset = false;
  late String originalUsageQuantity;

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

    originalUsageQuantity = couponForm['usage_quantity'];

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
                        Text('Allow Usage Limit'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['allow_usage_limit'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['allow_usage_limit'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    SizedBox(height: 20),

                    if(couponForm['allow_usage_limit']) TextFormField(
                      autofocus: false,
                      initialValue: couponForm['usage_limit'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Limit",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SvgPicture.asset('assets/icons/ecommerce_pack_1/tag.svg', width: 16,),
                        ),
                        hintText: 'E.g 100',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Enter available quantity e.g 2';
                        }else if(serverErrors.containsKey('usage_limit')){
                          return serverErrors['usage_limit'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          couponForm['usage_limit'] = value;
                        });
                      }
                    ),

                    SizedBox(height: 20),
                    
                    Row(
                      children: [

                        if(couponForm['allow_usage_limit']) 
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            autofocus: false,
                            key: ValueKey(couponForm['usage_quantity']),
                            initialValue: couponForm['usage_quantity'],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Used",
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: SvgPicture.asset('assets/icons/ecommerce_pack_1/tag.svg', width: 16,),
                              ),
                              hintText: 'E.g 10',
                              border:OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return 'Enter used quantity e.g 10';
                              }else if(serverErrors.containsKey('usage_quantity')){
                                return serverErrors['usage_quantity'];
                              }
                            },
                            onChanged: (value){
                              setState(() {
                                couponForm['usage_quantity'] = value;
                              });
                            }
                          ),
                        ),

                        if(couponForm['allow_usage_limit']) 
                        SizedBox(width: 10,),

                        if(couponForm['allow_usage_limit']) 
                        Flexible(
                          flex: 1,
                          child: CustomButton(
                            text: hasReset ? 'Undo Reset' : 'Reset',
                            color: Colors.grey,
                            solidColor: true,
                            size: 'small',
                            onSubmit: (){
                              setState(() {
                                hasReset = !hasReset;
                                if(hasReset){
                                  couponForm['usage_quantity'] = '0';
                                }else{
                                  couponForm['usage_quantity'] = originalUsageQuantity;
                                }
                              });
                            },
                          ),
                        )

                      ],
                    ),

                    Divider(height: 40),

                    (couponForm['allow_usage_limit'] == true) 
                      ? CustomCheckmarkText(
                          text: (couponForm['usage_limit'] == couponForm['usage_quantity']
                            ? 'They are no more coupons available for use by customers (The limit has been reached)'
                            : 'This coupon will be valid for use by the next '+(int.parse(couponForm['usage_limit']) - int.parse(couponForm['usage_quantity'])).toString()+' customers to claim'),
                          state: (couponForm['usage_limit'] == couponForm['usage_quantity'] ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'This coupon does not have a limit on the number of customers that can use it'),

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