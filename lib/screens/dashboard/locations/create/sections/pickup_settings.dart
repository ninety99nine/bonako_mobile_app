import 'package:bonako_mobile_app/screens/dashboard/locations/create/sections/reorder_destinations.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PickupSettingsScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Pickup Settings'),
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
  int valueKey1 = 1;
  int valueKey2 = 2;
  int valueKey3 = 3;
  Map locationForm = {};
  Map serverErrors = {};
  List _daysOfTheWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
    'Friday', 'Saturday', 'Sunday'
  ];
  List _times = [];

  @override
  void initState() {

    ///  Clone the arguments. This is because the data passed holds a strong
    ///  reference to the same data on the previous screen. Therefore if we
    ///  mutate the arguments, then the data from the previous screen will
    ///  also be changed. To avoid this, then we must clone the arguments,
    ///  so that we can freely mutate the data while preserving the
    ///  orginal state on the previous screen.
    locationForm = new Map.from(Get.arguments['locationForm']);
    serverErrors = new Map.from(Get.arguments['serverErrors']);

    setTimes();

    super.initState();

  }

  void setTimes(){
    for (var time = 6; time < 24; time++) {

      final curTime = ((time < 10) ? '0'+time.toString() : time.toString() + '') + ':00';
      final curHalfTime = ((time < 10) ? '0'+time.toString() : time.toString() + '') + ':30';

      _times.addAll([curTime, curHalfTime]);

    }
  }

  void captureValues(List<String> values){

    setState(() {

      final List<String> daysOfTheWeek = _daysOfTheWeek.map((dayOfTheWeek) => dayOfTheWeek.toString()).toList();

      daysOfTheWeek.removeWhere((dayOfTheWeek) => (values.contains(dayOfTheWeek) == false));
      
      locationForm['pickup_days'] = daysOfTheWeek;
      
      ++valueKey1;

    });

  }

  void captureTimeValues(List<String> values){

    setState(() {

      //  If we have two or more values
      if(values.length >= 2){

        //  Order the times in assending order from 00 to 23
        values.sort((a, b){

          late int intA;
          late int intB;
          
          //  If it start with 0 e.g "00", "01" or "02"
          if(a.substring(0, 1) == '0'){
            //  Get the second digit as an integer e.g "0", "1" or "2"
            intA = int.parse(a.substring(1).replaceAll(':', ''));
          //  If it does not start with 0 e.g "10", "11" or "12"
          }else{
            //  Get the intire digit as an integer e.g "10", "11" or "12"
            intA = int.parse(a.replaceAll(':', ''));
          }

          //  If it start with 0 e.g "00", "01" or "02"
          if(b.substring(0, 1) == '0'){
            //  Get the second digit as an integer e.g "0", "1" or "2"
            intB = int.parse((b).substring(1).replaceAll(':', ''));
          //  If it does not start with 0 e.g "10", "11" or "12"
          }else{
            //  Get the intire digit as an integer e.g "10", "11" or "12"
            intB = int.parse(b.replaceAll(':', ''));
          }

          //  Compare the numbers to return the smaller of the two
          return intA.compareTo(intB);

        });

      }
      
      locationForm['pickup_times'] = values;
      
      ++valueKey2;

    });

  }

  List get selectedDestinations {
    return locationForm['pickup_destinations'];
  }

  bool get hasDestinations {
    return locationForm['pickup_destinations'].length > 0;
  }

  Widget destinationWidgets(){

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pickup Destinations', style: TextStyle(fontWeight: FontWeight.bold,)),
          if(hasDestinations == true) Divider(height: 40,),
          if(hasDestinations == false) noDestinationsSelectedWidget(),
          listViewDestinationsWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(selectedDestinations.length >= 2) reorderDestinationsButton(),
              addDestinationButton(),
            ],
          ),
          Divider(height: 40,),
        ],
      ),
    );

  }
  
  Widget noDestinationsSelectedWidget(){
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: CustomCheckmarkText(text: 'No pickup destinations', state: 'warning',)
    );
  }

  Widget listViewDestinationsWidget(){

    return ListView.builder(
      key: ValueKey(valueKey3),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: selectedDestinations.length,
      itemBuilder: (ctx, index){
        return destinationWidget(destination: selectedDestinations[index]);
      }
    );
    
  }
  
  Widget destinationWidget({ destination }){

    final index = selectedDestinations.indexOf(destination);

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              destinationsNameWidget(index),
              destinationsRemoveIconWidget(index)
            ],
          ),
        ],
      ),
    );
  }

  Widget destinationsNameWidget(index){

    return Expanded(
      flex: 3,
      child: TextFormField(
        autofocus: false,
        initialValue: selectedDestinations[index]['name'],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: "Destination name",
          hintText: 'E.g Gaborone'
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Enter destination name';
          }else if(serverErrors.containsKey('destinations')){
            return serverErrors['destinations'];
          }
        },
        onChanged: (value){
          setState(() {
            selectedDestinations[index]['name'] = (value.isEmpty ? '0' : value);
          });
        }
      ),
    );
  }

  Widget destinationsRemoveIconWidget(index){
    return TextButton(
      child: Icon(Icons.delete_outlined, color: Colors.red,),
      onPressed: (){

        showDialog(
          context: context, 
          builder: (_) => AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to remove '+selectedDestinations[index]['name']+'?'),
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
                    selectedDestinations.removeAt(index);
                    Navigator.of(context).pop(false);
                  });
                }
              ),
            ],
          )
        );
      },
    );
  }

  Widget reorderDestinationsButton(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          width: 120,
          size: 'small',
          text: 'Re-order',
          color: Colors.green,
          onSubmit: () {
            navigateToReOrderPickupDestinations();
          },
        ),
      ],
    );
  }

  void navigateToReOrderPickupDestinations() async {

    Map arguments = {
      'destinations': locationForm['pickup_destinations'],
    };

    //  Navigate to the screen specified to re-order the destinations
    var updatedDestinations = await Get.to(() => ReOrderDestinationsScreen(), arguments: arguments);

    if( updatedDestinations != null ){
      
      setState(() {
        
        //  Update the location form on return
        locationForm['pickup_destinations'] = updatedDestinations;
      
        ++valueKey3;

      });

    }

  }

  Widget addDestinationButton(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          width: 200,
          size: 'small',
          text: '+ Add Destination',
          onSubmit: addDestination,
        ),
      ],
    );
  }

  void addDestination(){
    
    final Map pickupDestinations = {
      'name': 'Destination ' + (locationForm['pickup_destinations'].length + 1).toString(),
    };

    setState(() {
      locationForm['pickup_destinations'].add(pickupDestinations);
    });
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

          //  Form
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Text('Allow Pickup'),
                          Switch(
                            activeColor: Colors.green,
                            value: locationForm['allow_pickups'], 
                            onChanged: (status){
                              setState(() {
                                locationForm['allow_pickups'] = status;
                              });
                            }
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    if(locationForm['allow_pickups'] == true) TextFormField(
                      autofocus: false,
                      key: ValueKey('pickup_note'),
                      initialValue: locationForm['pickup_note'],
                      keyboardType: TextInputType.multiline,
                      minLines: 2,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Pickup note",
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Icon(Icons.sticky_note_2_outlined, size: 24,),
                        ),
                        hintText: 'E.g Pickups only on Tuesdays and Thursdays between 8am and 4pm',
                        border:OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      validator: (value){
                        if(value != null && value.length > 200){
                          return 'Pickup note is too long';
                        }else if(serverErrors.containsKey('pickup_note')){
                          return serverErrors['pickup_note'];
                        }
                      },
                      onChanged: (value){
                        setState(() {
                          locationForm['pickup_note'] = value;
                        });
                      }
                    ),
                      
                    if(locationForm['allow_pickups'] == true) Divider(height: 40),

                    if(locationForm['allow_pickups'] == true) destinationWidgets(),

                    if(locationForm['allow_pickups'] == true) SizedBox(height: 20),

                    if(locationForm['allow_pickups'] == true)
                      Container(
                        key: ValueKey(valueKey1),
                        child: MultiSelectDialogField(
                          buttonText: Text((locationForm['pickup_days'].length == 0 ? 'Select' : 'Change')+' Pickup Days:'),
                          buttonIcon: Icon(Icons.calendar_today, color: Colors.grey,),
                          initialValue: locationForm['pickup_days'],
                          items: _daysOfTheWeek.map((dayOfTheWeek) => MultiSelectItem(dayOfTheWeek, dayOfTheWeek)).toList(),
                          listType: MultiSelectListType.LIST,
                          
                          onConfirm: (values) {

                            final List<String> list = values.map((value) {
                              return value.toString();
                            }).toList();

                            captureValues(list);
                          },
                        ),
                      ),

                    SizedBox(height: 20),

                    if(locationForm['allow_pickups'] == true)
                      Container(
                        key: ValueKey(valueKey2),
                        child: MultiSelectDialogField(
                          buttonText: Text((locationForm['pickup_times'].length == 0 ? 'Select' : 'Change')+' Pickup Times:'),
                          buttonIcon: Icon(Icons.watch_later_outlined, color: Colors.grey,),
                          initialValue: locationForm['pickup_times'],
                          items: _times.map((time) => MultiSelectItem(time, time)).toList(),
                          listType: MultiSelectListType.LIST,
                          onConfirm: (values) {

                            final List<String> list = values.map((value) {
                              return value.toString();
                            }).toList();

                            captureTimeValues(list);
                          },
                        ),
                      ),

                    Divider(height: 40),
                    
                    if(locationForm['allow_pickups'] == true) CustomCheckmarkText(text: 'This location allows pickups for orders placed'),

                    Divider(height: 40,),

                    CustomButton(
                      text: 'Done',
                      onSubmit: () {
                        Get.back(result: locationForm);
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