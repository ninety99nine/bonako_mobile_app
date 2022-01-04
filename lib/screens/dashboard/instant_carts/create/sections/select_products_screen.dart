import './../../../../../components/custom_multi_product_selector.dart';
import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import './../../../../../providers/products.dart';
import './../../../../../models/products.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectProductsScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Select Products'),
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
  
  late PaginatedProducts paginatedProducts;
  late List<Product> products;
  late int count;

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

  List get selectedItems {
    return instantCartForm['items'];
  }

  bool get hasSelectedItems {
    return selectedItems.length > 0;
  }

  String get hasSelectedItemsTotal {
    return selectedItems.length.toString();
  }

  ProductsProvider get productsProvider {
    return Provider.of<ProductsProvider>(context, listen: false);
  }

  Widget selectProductsButton(){
    final List<int> selectedProductIds = new List<int>.from(selectedItems.map((selectedItem) => selectedItem['id']).toList());

    return Container(
      width: 200,
      child: CustomMultiProductSelector(
        selectedProductIds: selectedProductIds,
        onSelected: (selectedProducts){
          selectedProducts.forEach((product) {
            addProductAsItem(product);
          });
        }
      ),
    );
  }

  void addProductAsItem(Product product){

    final alreadyExists = selectedItems.map((item) => item['id']).toList().contains(product.id);

    if(alreadyExists == false){
      final item = {
        'quantity': 1,
        'id': product.id,
        'name': product.name,
      };

      setState(() {
      
        selectedItems.add(item);
        
      });

    }
  }

  Widget itemWidgets(){

    final itemWidgets = selectedItems.map((item){
      return itemWidget(item);
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        children: [
          if(hasSelectedItems == true) Row(
            children: [
              Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold,))),
              Expanded(flex: 2, child: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold,))),
            ],
          ),
          if(hasSelectedItems == true) Divider(height: 40,),
          if(hasSelectedItems == false) noItemsSelectedWidget(),
          ...itemWidgets
        ],
      ),
    );

  }
  
  Widget noItemsSelectedWidget(){
    return Container(
      margin: EdgeInsets.only(top: 5, left: 10),
      child: CustomCheckmarkText(text: 'Select atleast one product', state: 'warning',)
    );
  }
  
  Widget itemWidget(item){

    final index = selectedItems.indexOf(item);

    return Row(
      children: [
        itemNameWidget(index),
        itemQuantityWidget(index),
        itemRemoveIconWidget(index)
      ],
    );
  }

  Widget itemNameWidget(index){
    return Expanded(
      flex: 3,
      child: Text(selectedItems[index]['name'])
    );
  }

  Widget itemQuantityWidget(index){
    return Expanded(
      flex: 1,
      child: TextFormField(
        autofocus: false,
        key: ValueKey(selectedItems[index]['id']),
        initialValue: selectedItems[index]['quantity'].toString(),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'E.g 2',
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Enter the item quantity';
          }else if(serverErrors.containsKey('items')){
            return serverErrors['items'];
          }
        },
        onChanged: (value){
          setState(() {
            print('onChanged');
            print('value.isEmpty');
            print(value.isEmpty);

            selectedItems[index]['quantity'] = (value.isEmpty ? '1' : value);
          });
        }
      ),
    );
  }

  Widget itemRemoveIconWidget(index){
    return Expanded(
      flex: 1,
      child: TextButton(
        child: Icon(Icons.delete_outlined, color: Colors.red,),
        onPressed: (){
          showDialog(
            context: context, 
            builder: (_) => AlertDialog(
              title: Text('Confirmation'),
              content: Text('Are you sure you want to remove '+selectedItems[index]['name']+'?'),
              actions: [

                //  Cancel Button
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () { 
                    //  Remove the alert dialog and return False as final value
                    Navigator.of(context).pop(false);
                  }
                ),

                //  Remove Button
                TextButton(
                  child: Text('Remove', style: TextStyle(color: Colors.red)),
                  onPressed: (){
                    setState((){
                      selectedItems.removeAt(index);
                      Navigator.of(context).pop(false);
                    });
                  }
                ),
              ],
            )
          );
        },
      )
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

                    selectProductsButton(),
                      
                    Divider(height: 40),

                    itemWidgets(),
                      
                    if(hasSelectedItems) Divider(height: 40),

                    if(hasSelectedItems) CustomCheckmarkText(
                      margin: EdgeInsets.only(left: 5),
                      text: 'Checkout with the '+(hasSelectedItemsTotal)+' '+(hasSelectedItemsTotal == '1' ? 'item': 'items')+' listed'
                    ),

                    Divider(height: 40,),

                    CustomButton(
                      text: 'Done',
                      disabled: (hasSelectedItems == false),
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