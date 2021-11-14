import 'package:bonako_mobile_app/components/custom_checkmark_text.dart';

import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductVisibilityScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: CustomAppBar(title: 'Visibility'),
      drawer: StoreDrawer(),
      body: Content(),
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
  Map productForm = {};
  Map serverErrors = {};

  @override
  void initState() {

    ///  Clone the arguments. This is because the data passed holds a strong
    ///  reference to the same data on the previous screen. Therefore if we
    ///  mutate the arguments, then the data from the previous screen will
    ///  also be changed. To avoid this, then we must clone the arguments,
    ///  so that we can freely mutate the data while preserving the
    ///  orginal state on the previous screen.
    productForm = new Map.from(Get.arguments['productForm']);
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
              //  Pass the un-editted ProductForm as the argument
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
                        Text('Visible'),
                        Switch(
                          activeColor: Colors.green,
                          value: productForm['visible'], 
                          onChanged: (status){
                            setState(() {
                              productForm['visible'] = status;
                            });
                          }
                        ),
                        if(productForm['visible'] == false) Text('This product is hidden', style: TextStyle(color: Colors.orange),),
                      ],
                    ),

                    Divider(height: 40,),

                    CustomCheckmarkText(text: (productForm['visible'] == true) ? 'Visible for everyone' : 'Hidden for everyone'),

                    Divider(height: 40,),

                    CustomButton(
                      text: 'Done',
                      onSubmit: () {
                        Get.back(result: productForm);
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