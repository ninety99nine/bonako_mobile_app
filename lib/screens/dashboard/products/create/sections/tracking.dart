import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductTrackingScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Tracking'),
        drawer: StoreDrawer(),
        body: Content(),
      )
    );

  }
}

class Content extends StatelessWidget {
  
  //  Set the form key
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    /**
     *  Clone the arguments. This is because the data passed holds a strong
     *  reference to the same data on the previous screen. Therefore if we
     *  mutate the arguments, then the data from the previous screen will
     *  also be changed. To avoid this, then we must clone the arguments,
     *  so that we can freely mutate the data while preserving the
     *  orginal state on the previous screen. 
     */
    Map productForm = new Map.from(Get.arguments['productForm']);
    Map serverErrors = new Map.from(Get.arguments['serverErrors']);

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
              
                    TextFormField(
                      initialValue: productForm['sku'] ?? '',
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "SKU (Stock Keeping Unit)",
                        hintText: 'E.g F00001',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      onChanged: (value){
                        productForm['sku'] = value;
                      }
                    ),

                    SizedBox(height: 10),
              
                    TextFormField(
                      initialValue: productForm['barcode'] ?? '',
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: "Barcode",
                        hintText: 'E.g 0000012345',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      onChanged: (value){
                        productForm['barcode'] = value;
                      }
                    ),

                    SizedBox(height: 40),

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