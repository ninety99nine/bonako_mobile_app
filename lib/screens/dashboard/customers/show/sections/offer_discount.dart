import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfferDiscountScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Offer Discount'),
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
                        Text('Offer Discounts'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['apply_discount'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['apply_discount'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    SizedBox(height: 20),

                    if(couponForm['apply_discount'] == true) 
                      Row(
                        children: [
                          Text('Discount Type:'),
                          SizedBox(width: 10),
                          DropdownButton<String>(
                            value: couponForm['discount_rate_type'],
                            items: <String>['Percentage', 'Fixed'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                couponForm['discount_rate_type'] = value;
                              });
                            },
                          ),
                        ],
                      ),

                    SizedBox(height: 20),

                    if(couponForm['apply_discount'] == true && couponForm['discount_rate_type'] == 'Percentage') TextFormField(
                      autofocus: false,
                      key: ValueKey('percentage'),
                      initialValue: couponForm['percentage_rate'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Percentage discount",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text('%', style: TextStyle(fontSize: 16)),
                        ),
                        hintText: 'E.g 50',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Enter percentage discount e.g 50';
                        }else if(serverErrors.containsKey('percentage_rate')){
                          return serverErrors['percentage_rate'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          couponForm['percentage_rate'] = value;
                        });
                      }
                    ),

                    if(couponForm['apply_discount'] == true && couponForm['discount_rate_type'] == 'Fixed') TextFormField(
                      autofocus: false,
                      key: ValueKey('fixed'),
                      initialValue: couponForm['fixed_rate'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Fixed discount",
                        hintText: 'E.g 50',
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 15, right: 20),
                          child: Text(couponForm['currency'], style: TextStyle(fontSize: 16)),
                        ),
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Enter fixed discount e.g 50.00';
                        }else if(serverErrors.containsKey('fixed_rate')){
                          return serverErrors['fixed_rate'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          couponForm['fixed_rate'] = value;
                        });
                      }
                    ),
                      
                    Divider(height: 40),

                    if(couponForm['apply_discount'] == true && couponForm['discount_rate_type'] == 'Percentage') 
                      CustomCheckmarkText(
                        text: (couponForm['percentage_rate'] == null || couponForm['percentage_rate'] == ''
                          ? 'Enter the percentage to discount the order using this coupon' 
                          : 'This coupon will discount an order by '+couponForm['percentage_rate']+'%'),
                        state: (couponForm['percentage_rate'] == null || couponForm['percentage_rate'] == '' ? 'warning' : 'success')
                      ),

                    if(couponForm['apply_discount'] == true && couponForm['discount_rate_type'] == 'Fixed') 
                      CustomCheckmarkText(
                          text: (couponForm['fixed_rate'] == null || couponForm['fixed_rate'] == ''
                            ? 'Enter the percentage to discount the order using this coupon' 
                            : 'This coupon will discount an order by '+couponForm['currency']+couponForm['fixed_rate']),
                          state: (couponForm['fixed_rate'] == null || couponForm['fixed_rate'] == '' ? 'warning' : 'success')
                        ),
                      
                    if(couponForm['apply_discount'] == false) CustomCheckmarkText(text: 'This coupon does not offer discounts for any order being placed'),

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