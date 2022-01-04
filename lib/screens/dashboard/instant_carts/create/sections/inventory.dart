import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InstantCartInventoryScreen extends StatelessWidget {
  
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
              //  Pass the un-editted instantCartForm as the argument
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
                          value: instantCartForm['allow_stock_management'], 
                          onChanged: (status){
                            setState(() {
                              instantCartForm['allow_stock_management'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    if(instantCartForm['allow_stock_management'] == true) TextFormField(
                      autofocus: false,
                      initialValue: instantCartForm['stock_quantity'],
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
                        if(value == null || value.isEmpty){
                          return 'Please enter available stock quantity';
                        }else if(serverErrors.containsKey('stock_quantity')){
                          return serverErrors['stock_quantity'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          instantCartForm['stock_quantity'] = value;
                        });
                      }
                    ),

                    Divider(height: 40,),

                    (instantCartForm['allow_stock_management'] == true) ? CustomCheckmarkText(text: 'Allow automatic stock management') : CustomCheckmarkText(text: 'Disable stock management'),
                    if(instantCartForm['allow_stock_management'] == true) CustomCheckmarkText(text: 'Available Stock: ' + instantCartForm['stock_quantity']),

                    Divider(height: 20,),

                    SizedBox(height: 20),

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