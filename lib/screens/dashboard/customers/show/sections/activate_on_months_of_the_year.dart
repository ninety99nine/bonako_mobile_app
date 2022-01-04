import 'package:bonako_mobile_app/components/custom_checkmark_text.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivateOnMonthsOfTheYearScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Activate On Months Of The Year'),
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
  int valueKey = 1;
  Map couponForm = {};
  Map serverErrors = {};
  List _monthsOfTheYear = [
    'January', 'February', 'March', 'April', 'May', 'June', 
    'July', 'August', 'September', 'October', 'November', 
    'December'
  ];

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

  void captureValues(List<String> values){

    setState(() {

      final List<String> monthsOfTheYear = _monthsOfTheYear.map((dayOfTheWeek) => dayOfTheWeek.toString()).toList();

      monthsOfTheYear.removeWhere((dayOfTheWeek) => (values.contains(dayOfTheWeek) == false));
      
      couponForm['discount_on_months_of_the_year'] = monthsOfTheYear;
      
      ++valueKey;

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
                        Text('Activate On Months Of The Year'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['allow_discount_on_months_of_the_year'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['allow_discount_on_months_of_the_year'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    if(couponForm['allow_discount_on_months_of_the_year'] == true) SizedBox(height: 20),

                    if(couponForm['allow_discount_on_months_of_the_year'] == true)
                    Container(
                      key: ValueKey(valueKey),
                      child: MultiSelectDialogField(
                        buttonText: Text('Select Days Of Month:'),
                        buttonIcon: Icon(Icons.calendar_today, color: Colors.grey,),
                        initialValue: couponForm['discount_on_months_of_the_year'],
                        items: _monthsOfTheYear.map((monthOfTheYear) => MultiSelectItem(monthOfTheYear, monthOfTheYear)).toList(),
                        listType: MultiSelectListType.LIST,
                        
                        onConfirm: (values) {

                          final List<String> list = values.map((value) {
                            return value.toString();
                          }).toList();

                          captureValues(list);
                        },
                      ),
                    ),
                      
                    Divider(height: 40),

                    (couponForm['allow_discount_on_months_of_the_year'] == true) 
                      ? CustomCheckmarkText(
                          text: (couponForm['discount_on_months_of_the_year'].length == 0
                            ? 'Select the months of the year that this coupon is active for use' 
                            : 'This coupon will be valid for the '+couponForm['discount_on_months_of_the_year'].length.toString()+' selected months of any year'),
                          state: ((couponForm['discount_on_months_of_the_year'].length == 0) ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'Does not depend on any month of the year'),

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