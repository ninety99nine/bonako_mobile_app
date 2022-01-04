import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivateOnMinimumTotalScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Inventory'),
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
                        Text('Activate On Minimum Total'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['allow_discount_on_minimum_total'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['allow_discount_on_minimum_total'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    SizedBox(height: 20),

                    if(couponForm['allow_discount_on_minimum_total']) TextFormField(
                      autofocus: false,
                      initialValue: couponForm['discount_on_minimum_total'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Minimum total",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 15, right: 20),
                          child: Text(couponForm['currency'], style: TextStyle(fontSize: 16)),
                        ),
                        hintText: 'E.g 50',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Enter minimum total e.g 100';
                        }else if(serverErrors.containsKey('discount_on_minimum_total')){
                          return serverErrors['discount_on_minimum_total'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          couponForm['discount_on_minimum_total'] = value;
                        });
                      }
                    ),
                      
                    Divider(height: 40),

                    (couponForm['allow_discount_on_minimum_total'] == true) 
                      ? CustomCheckmarkText(
                          text: (couponForm['discount_on_minimum_total'] == null || couponForm['discount_on_minimum_total'] == ''
                            ? 'Enter the minimum order amount that this coupon is active for use' 
                            : 'This coupon will be valid for orders placed with a minimum amount of '+couponForm['currency']+couponForm['discount_on_minimum_total']+' or greater'),
                          state: (couponForm['discount_on_minimum_total'] == null || couponForm['discount_on_minimum_total'] == '' ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'This coupon does not depend on any minimum amount of the order being placed'),

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