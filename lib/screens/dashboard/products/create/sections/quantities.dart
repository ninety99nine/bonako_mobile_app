import 'package:bonako_app_3/components/custom_checkmark_text.dart';

import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductQuantitiesScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Quantities'),
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
                        Text('Allow multiple products per order'),
                        Switch(
                          activeColor: Colors.green,
                          value: productForm['allow_multiple_quantity_per_order'], 
                          onChanged: (status){
                            setState(() {
                              productForm['allow_multiple_quantity_per_order'] = status;
                            });
                          }
                        ),
                      ],
                    ),

                    if(productForm['allow_multiple_quantity_per_order'] == true) Row(
                      children: [
                        Text('Limit maximum products per order'),
                        Switch(
                          activeColor: Colors.green,
                          value: productForm['allow_maximum_quantity_per_order'], 
                          onChanged: (status){
                            setState(() {
                              productForm['allow_maximum_quantity_per_order'] = status;
                            });
                          }
                        ),
                      ],
                    ),
              
                    if(productForm['allow_multiple_quantity_per_order'] == true && productForm['allow_maximum_quantity_per_order'] == true) TextFormField(
                      initialValue: productForm['maximum_quantity_per_order'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Maximum per order",
                        hintText: 'E.g 5',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Please enter maximum quantity per order';
                        }else if(serverErrors['maximum_quantity_per_order'] != ''){
                          return serverErrors['maximum_quantity_per_order'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          productForm['maximum_quantity_per_order'] = value;
                        });
                      }
                    ),

                    Divider(height: 40,),

                    if(productForm['allow_multiple_quantity_per_order'] == false) CustomCheckmarkText(text: 'Allow only 1 quantity per order'),
                    if(productForm['allow_multiple_quantity_per_order'] == true && productForm['allow_maximum_quantity_per_order'] == false) CustomCheckmarkText(text: 'Allow more than 1 quantity per order'),
                    if(productForm['allow_multiple_quantity_per_order'] == true && productForm['allow_maximum_quantity_per_order'] == true) CustomCheckmarkText(text: 'Allow between 1 and '+productForm['maximum_quantity_per_order']+' quantities per order'),

                    Divider(height: 20,),

                    SizedBox(height: 20),

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