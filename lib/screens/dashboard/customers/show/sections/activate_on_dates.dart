import 'package:intl/intl.dart';

import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import 'package:date_time_picker/date_time_picker.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivateOnDatesScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Activate On Dates'),
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
  Map couponForm = {};
  Map serverErrors = {};

  @override
  void initState() {

    ///  Clone the arguments. This is because the data passed holds a strong
    ///  reference to the same data on the previous screen. Therefore if we
    ///  mutate the arguments, then the data from the previous screen will
    ///  also be changed. To avoid this, then we must clone the arguments,
    ///  so that we can freely mutate the data while preserving the
    ///  orginal state on the previous screen.
    couponForm = new Map.from(Get.arguments['couponForm']);
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

                    Row(
                      children: [
                        Text('Activate On Start Date'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['allow_discount_on_start_datetime'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['allow_discount_on_start_datetime'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    if(couponForm['allow_discount_on_start_datetime']) SizedBox(height: 20),

                    if(couponForm['allow_discount_on_start_datetime']) DateTimePicker(
                      initialValue: couponForm['discount_on_start_datetime'].toString(),
                      type: DateTimePickerType.dateTimeSeparate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      icon: Icon(Icons.event),
                      dateMask: 'd MMM, yyyy',
                      dateLabelText: 'Start Date',
                      timeLabelText: "Start Time",
                      selectableDayPredicate: (date) {

                        //  Return false on a condition to show/hide certain dates
                        /*
                        final now = DateTime.now();

                        if (date.isAfter(now) ) {

                          return true;

                        }
                        
                        return false;
                        */

                        return true;

                      },
                      validator: (val) {
                        return null;
                      },
                      onChanged: (val){
                        setState(() {
                          couponForm['discount_on_start_datetime'] = DateTime.parse(val);
                        });
                      },
                      onSaved: (val){
                        setState(() {
                          if(val != null){
                            couponForm['discount_on_start_datetime'] = DateTime.parse(val);
                          }
                        });
                      },

                    ),

                    if(couponForm['allow_discount_on_start_datetime']) SizedBox(height: 40),

                    Row(
                      children: [
                        Text('Activate On End Date'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['allow_discount_on_end_datetime'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['allow_discount_on_end_datetime'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    if(couponForm['allow_discount_on_end_datetime']) SizedBox(height: 20),
                    
                    if(couponForm['allow_discount_on_end_datetime']) DateTimePicker(
                      initialValue: couponForm['discount_on_end_datetime'].toString(),
                      type: DateTimePickerType.dateTimeSeparate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      icon: Icon(Icons.event),
                      dateMask: 'd MMM, yyyy',
                      dateLabelText: 'End Date',
                      timeLabelText: "End Time",
                      selectableDayPredicate: (date) {

                        //  Return false on a condition to show/hide certain dates
                        /*
                        final now = DateTime.now();

                        if (date.isAfter(now) ) {

                          return true;

                        }
                        
                        return false;
                        */

                        return true;

                      },
                      validator: (val) {
                        return null;
                      },
                      onChanged: (val){
                        setState(() {
                          couponForm['discount_on_end_datetime'] = DateTime.parse(val);
                        });
                      },
                      onSaved: (val){
                        setState(() {
                          if(val != null){
                            couponForm['discount_on_end_datetime'] = DateTime.parse(val);
                          }
                        });
                      },

                    ),

                    if(couponForm['allow_discount_on_end_datetime']) SizedBox(height: 20),

                    Divider(height: 40),

                    (couponForm['allow_discount_on_start_datetime'] == true) 
                      ? CustomCheckmarkText(
                          text: (couponForm['discount_on_start_datetime'] == null
                            ? 'Enter the start date' 
                            : 'This coupon will be valid for use from '+DateFormat('dd MMM yyyy H:mm').format(couponForm['discount_on_start_datetime']).toString()),
                          state: ((couponForm['discount_on_start_datetime'] == null) ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'Does not depend on a start date'),

                    (couponForm['allow_discount_on_end_datetime'] == true) 
                      ? CustomCheckmarkText(
                          text: (couponForm['discount_on_end_datetime'] == null
                            ? 'Enter the end date' 
                            : 'This coupon will be valid for use till '+DateFormat('dd MMM yyyy H:mm').format(couponForm['discount_on_end_datetime']).toString()),
                          state: ((couponForm['discount_on_end_datetime'] == null) ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'This coupon does not depend on an end date'),

                    Divider(height: 40,),
                    
                    CustomButton(
                      text: 'Done',
                      onSubmit: () {
                        Get.back(result: couponForm);
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