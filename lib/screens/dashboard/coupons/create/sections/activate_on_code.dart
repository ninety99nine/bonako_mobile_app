import 'package:bonako_mobile_app/components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivateOnCodeScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Activate On Code'),
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
                        Text('Activate On Code'),
                        Switch(
                          activeColor: Colors.green,
                          value: (couponForm['activation_type'] == 'use code' ? true : false), 
                          onChanged: (status){
                            setState(() {
                              couponForm['activation_type'] = (status == true ? 'use code' : 'always apply');
                            });
                          }
                        )
                      ],
                    ),

                    SizedBox(height: 20),

                    if(couponForm['activation_type'] == 'use code') TextFormField(
                      autofocus: false,
                      initialValue: couponForm['code'],
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Activation Code",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: SvgPicture.asset('assets/icons/ecommerce_pack_1/padlock-1.svg', width: 16,),
                        ),
                        hintText: 'E.g 2',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Enter the activation code e.g save10';
                        }else if(serverErrors.containsKey('code')){
                          return serverErrors['code'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          couponForm['code'] = value;
                        });
                      }
                    ),
                      
                    Divider(height: 40),

                    (couponForm['activation_type'] == 'use code') 
                      ? CustomCheckmarkText(
                          text: (couponForm['code'] == null || couponForm['code'] == ''
                            ? 'Enter the activation code that is used to activate this coupon' 
                            : 'This coupon can only be activated using the activation code: '+couponForm['code']),
                          state: (couponForm['code'] == null || couponForm['code'] == '' ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'This coupon does not depend on an activation code. This means that every order will apply this coupon automatically'),

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