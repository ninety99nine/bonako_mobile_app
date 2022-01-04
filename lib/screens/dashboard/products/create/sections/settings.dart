
import './../../../../../screens/dashboard/products/list/products_screen.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import './../../../../../providers/products.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductSettingsScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
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

  ProductsProvider get productsProvider {
    return Provider.of<ProductsProvider>(context, listen: false);
  }

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

          Divider(height: 20),

          //  Form
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[

                    SizedBox(height: 20),

                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: 'Click the delete button to permanently delete ',
                        style: TextStyle(color: Colors.black, height: 1.4),
                        children: <TextSpan>[
                          TextSpan(text: productForm['name'], style: TextStyle(fontWeight: FontWeight.bold, height: 1.4),),
                          TextSpan(text: '. This product cannot be recovered after being deleted.', style: TextStyle(height: 1.4)),
                        ],
                      ),
                    ),

                    Divider(height: 40),

                    CustomButton(
                      text: 'Delete',
                      onSubmit: (){

                        final product = productsProvider.getProduct;
                        
                        Provider.of<ProductsProvider>(context, listen: false).handleDeleteProduct(
                          product: product,
                          context: context
                        ).then((result){

                          return Get.back(result: result == true ? 'deleted' : '');

                        });
                      },
                      color: Colors.red,
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