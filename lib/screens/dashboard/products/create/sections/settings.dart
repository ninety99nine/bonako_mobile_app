
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

  //  By default the loader is not loading
  var isDeleting = false;

  void startDeleteLoader(){
    setState(() {
      isDeleting= true;
    });
  }

  void stopDeleteLoader(){
    setState(() {
      isDeleting = false;
    });
  }

  showDeleteAlertDialog(BuildContext context) {

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () => Navigator.pop(context),
    );

    Widget deleteButton = TextButton(
      child: Text('Delete', style: TextStyle(color: Colors.red)),
      onPressed: (){
        
        //  Start deleting
        onDelete();

        //  Close the alert dialog
        Navigator.pop(context);

        //  Re-open alert dialog since isDeleting = true
        showDeleteAlertDialog(context);

      }
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Row(
        children: [
          if(isDeleting) Container(height:20, width:20, margin: EdgeInsets.only(right: 10), child: CircularProgressIndicator(strokeWidth: 3,)),
          if(isDeleting) Text("Deleting product..."),
          if(!isDeleting) Flexible(child: Text("Are you sure you want to delete this product?")),
        ],
      ),
      actions: [
        cancelButton,
        if(!isDeleting) deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return alert;
          }
        );
      },
    );
  }

  void onDelete(){

    startDeleteLoader();

    productsProvider.deleteProduct(
      context: context
    ).then((response){
 
      if(response.statusCode == 200){

        showSnackbarMessage('Product deleted successfully');

        //  Navigate to the products screen
        Get.off(() => ProductsScreen());

      }else{

        showSnackbarMessage('Delete failed');

      }

    }).whenComplete((){
      
      //  Remove the alert dialog
      Navigator.pop(context);

      stopDeleteLoader();

    });

  }

  void showSnackbarMessage(String msg){

    //  Set snackbar content
    final snackBar = SnackBar(content: Text(msg, textAlign: TextAlign.center));

    //  Show snackbar  
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

  }

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
                      isLoading: isDeleting,
                      onSubmit: () => showDeleteAlertDialog(context),
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