import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import './../../../../../providers/locations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductPricingScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: CustomAppBar(title: 'Pricing'),
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
  
  var unitRegularPriceController = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  var unitSalePriceController = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  var unitCostPriceController = new MoneyMaskedTextController(decimalSeparator: '.', thousandSeparator: ',');
  
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

    //  Update money values
    unitRegularPriceController.updateValue(double.parse(productForm['unit_regular_price']));
    unitSalePriceController.updateValue(double.parse(productForm['unit_sale_price']));
    unitCostPriceController.updateValue(double.parse(productForm['unit_cost']));

    super.initState();

  }

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    String getLocationCurrencySymbol = Provider.of<LocationsProvider>(context, listen: false).getLocationCurrencySymbol;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                        Text('This is a Free product'),
                        Switch(
                          activeColor: Colors.green,
                          value: productForm['is_free'], 
                          onChanged: (status){
                            setState(() {
                              productForm['is_free'] = status;
                            });
                          }
                        ),
                      ],
                    ),

                    if(productForm['is_free'] == true) Divider(),

                    if(productForm['is_free'] == true) Text('Any customer placing an order of this product will not be charged', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),),

                    if(productForm['is_free'] == true) Divider(),

                    SizedBox(height: 10),
              
                    if(productForm['is_free'] == false) TextFormField(
                      controller: unitRegularPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: getLocationCurrencySymbol,
                        labelText: "Regular Price",
                        hintText: 'E.g 24.95',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Please enter product regular price';
                        }else if(serverErrors['unit_regular_price'] != ''){
                          return serverErrors['unit_regular_price'];
                        }
                      },
                      onChanged: (value){
                        productForm['unit_regular_price'] = value.toString();
                      }
                    ),

                    if(productForm['is_free'] == false) SizedBox(height: 10),
              
                    if(productForm['is_free'] == false) TextFormField(
                      controller: unitSalePriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: getLocationCurrencySymbol,
                        labelText: "Sale Price",
                        hintText: 'E.g 19.95',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Please enter product sale price';
                        }else if(serverErrors['unit_sale_price'] != ''){
                          return serverErrors['unit_sale_price'];
                        }
                      },
                      onChanged: (value){
                        productForm['unit_sale_price'] = value.toString();
                      }
                    ),

                    if(productForm['is_free'] == false) SizedBox(height: 10),
              
                    if(productForm['is_free'] == false) TextFormField(
                      controller: unitCostPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: getLocationCurrencySymbol,
                        labelText: "Cost Price",
                        hintText: 'E.g 15.00',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'Please enter product cost price';
                        }else if(serverErrors['unit_cost'] != ''){
                          return serverErrors['unit_cost'];
                        }
                      },
                      onChanged: (value){
                        productForm['unit_cost'] = value.toString();
                      }
                    ),

                    SizedBox(height: 40),

                    CustomButton(
                      text: 'Done',
                      onSubmit: () {
                        print('DONE');
                        print(productForm);
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