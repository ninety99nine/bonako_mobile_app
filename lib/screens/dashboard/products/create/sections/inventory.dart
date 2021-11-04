import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductInventoryScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: CustomAppBar(title: 'Inventory'),
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

  Widget checkmarkText(String text){
    return Row(
      children: [
        Icon(Icons.check_circle_outline_outlined, color: Colors.green, size: 12),
        SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 12),)
      ],
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
                        Text('Allow Stock Management'),
                        Switch(
                          activeColor: Colors.green,
                          value: productForm['allow_stock_management'], 
                          onChanged: (status){
                            setState(() {
                              productForm['allow_stock_management'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    if(productForm['allow_stock_management'] == true) TextFormField(
                      initialValue: productForm['stock_quantity'],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Available stock",
                        hintText: 'E.g 100',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null){
                          return 'Please enter available stock quantity';
                        }else if(serverErrors['stock_quantity'] != ''){
                          return serverErrors['stock_quantity'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          productForm['stock_quantity'] = value;
                        });
                      }
                    ),
                    
                    if(productForm['allow_stock_management'] == true) SizedBox(height: 10),

                    if(productForm['allow_stock_management'] == true) Row(
                      children: [
                        Text('Manage Stock Automatically'),
                        Switch(
                          activeColor: Colors.green,
                          value: productForm['auto_manage_stock'], 
                          onChanged: (status){
                            setState(() {
                              productForm['auto_manage_stock'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    Divider(height: 40,),

                    (productForm['allow_stock_management'] == true) ? checkmarkText('Allow '+(productForm['auto_manage_stock'] ? 'automatic' : 'manual')+' stock management') : checkmarkText('Disable stock management'),
                    if(productForm['allow_stock_management'] == true) checkmarkText('Available Stock: ' + productForm['stock_quantity']),
                    if(productForm['allow_multiple_quantity_per_order'] == true && productForm['allow_maximum_quantity_per_order'] == true) checkmarkText('Allow between 1 and '+productForm['maximum_quantity_per_order']+' quantities per order'),

                    Divider(height: 40,),

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