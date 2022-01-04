import 'package:bonako_mobile_app/components/custom_checkmark_text.dart';

import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OfferFreeDeliveryScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Offer Free Delivery'),
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
                        Text('Offer Free Delivery'),
                        Switch(
                          activeColor: Colors.green,
                          value: instantCartForm['allow_free_delivery'], 
                          onChanged: (status){
                            setState(() {
                              instantCartForm['allow_free_delivery'] = status;
                            });
                          }
                        )
                      ],
                    ),
                      
                    Divider(height: 40),

                    CustomCheckmarkText(
                      text: instantCartForm['allow_free_delivery']
                        ? 'This instant cart offers free delivery to any order' 
                        : 'This instant cart does not offer free delivery to any order'
                    ),

                    Divider(height: 40,),

                    CustomButton(
                      text: 'Done',
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