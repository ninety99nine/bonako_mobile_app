import 'package:bonako_mobile_app/components/custom_checkbox.dart';
import 'package:bonako_mobile_app/providers/locations.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReOrderDestinationsScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Re-order Destinations'),
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

  List selectedDestinations = [];

  @override
  void initState() {

    ///  Clone the arguments. This is because the data passed holds a strong
    ///  reference to the same data on the previous screen. Therefore if we
    ///  mutate the arguments, then the data from the previous screen will
    ///  also be changed. To avoid this, then we must clone the arguments,
    ///  so that we can freely mutate the data while preserving the
    ///  orginal state on the previous screen.
    selectedDestinations = new List.from(Get.arguments['destinations']);

    super.initState();

  }

  void reorderDestinations(int oldIndex, int newIndex){
    if(mounted){
      setState(() {
        if(newIndex > oldIndex){
          newIndex -= 1;
        }

        final deliveryDestination = selectedDestinations[oldIndex];
        selectedDestinations.removeAt(oldIndex);

        selectedDestinations.insert(newIndex, deliveryDestination);

      });
    }
  }
  
  Widget destinationsWidget({ destination }){

    final index = selectedDestinations.indexOf(destination);

    return Container(
      key: UniqueKey(),
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.blue.shade100)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(selectedDestinations[index]['name']),
              Icon(Icons.view_headline_rounded)
            ],
          )
        ],
      ),
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
              //  Pass the un-editted LocationForm as the argument
              CustomBackButton()
            ],
          ),

          Divider(height: 0),

          SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Destinations', style: TextStyle(fontWeight: FontWeight.bold,)),
                        
                        SizedBox(height: 20),

                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: selectedDestinations.length,
                          onReorder: (oldIndex, newIndex) => reorderDestinations(oldIndex, newIndex),
                          itemBuilder: (ctx, index){
                            return destinationsWidget(destination: selectedDestinations[index]);
                          }
                        ),
                      ],
                    ),
                  ),
                        
                  SizedBox(height: 20),

                  CustomButton(
                    text: 'Done',
                    onSubmit: () {
                      Get.back(result: selectedDestinations);
                    },
                  ),
                  
                ],
              )
            ),
          )
        ],
      ),
    );
    
  }
}