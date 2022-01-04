import 'package:bonako_mobile_app/components/custom_checkmark_text.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivateOnDaysOfTheMonthScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Activate On Days Of The Month'),
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
  List _daysOfTheMonth = [
    '01', '02', '03', '04', '05', '06', '07', '08',
    '09', '10', '11', '12', '13', '14', '15', '16', 
    '17', '18', '19', '20', '21', '22', '23', '24',
    '25', '26', '27', '28', '29', '30', '31'
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

  void captureValues(List<String> days){

    setState(() {

      //  Return the days without leading Zeros
      final List<int> formattedDaysOfTheMonth = days.map((day){

        //  If it start with 0 e.g "01", "02" or "03"
        if(day.substring(0, 1) == '0'){

          //  Return everything else after the "0" e.g "1", "2" or "3"
          return int.parse(day.substring(1));

        }else{

          //  Return as is e.g "10", "11" or "12"
          return int.parse(day);
        
        }

      }).toList();

      //  If we have two or more days
      if(formattedDaysOfTheMonth.length >= 2){

        //  Order the days in assending order from 1 to 31
        formattedDaysOfTheMonth.sort((day1, day2){

          //  Compare the numbers to return the smaller of the two
          return day1.compareTo(day2);

        });

      }
      
      couponForm['discount_on_days_of_the_month'] = formattedDaysOfTheMonth;
      
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
                        Text('Activate On Days Of The Month'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['allow_discount_on_days_of_the_month'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['allow_discount_on_days_of_the_month'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    if(couponForm['allow_discount_on_days_of_the_month'] == true) SizedBox(height: 20),

                    if(couponForm['allow_discount_on_days_of_the_month'] == true)
                    Container(
                      key: ValueKey(valueKey),
                      child: MultiSelectDialogField(
                        buttonText: Text('Select Days Of Month:'),
                        buttonIcon: Icon(Icons.calendar_today, color: Colors.grey,),
                        initialValue: (couponForm['discount_on_days_of_the_month'] as List<int>).map((day){

                          if(day.toString().length == 1){
                            return '0' + day.toString();
                          }

                          return day.toString();

                        }).toList(),
                        items: _daysOfTheMonth.map((dayOfTheMonth) => MultiSelectItem(dayOfTheMonth, dayOfTheMonth)).toList(),
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

                    (couponForm['allow_discount_on_days_of_the_month'] == true) 
                      ? CustomCheckmarkText(
                          text: (couponForm['discount_on_days_of_the_month'].length == 0
                            ? 'Select the days of the month that this coupon is active for use' 
                            : 'This coupon will be valid for the '+couponForm['discount_on_days_of_the_month'].length.toString()+' selected days of any month'),
                          state: ((couponForm['discount_on_days_of_the_month'].length == 0) ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'This coupon does not depend on any days of the month'),

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