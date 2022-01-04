import 'package:multi_select_flutter/multi_select_flutter.dart';
import './../../../../../components/custom_checkmark_text.dart';
import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivateOnDaysOfTheWeekScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Activate On Days Of The Week'),
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
  List _daysOfTheWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
    'Friday', 'Saturday', 'Sunday'
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

      final List<String> daysOfTheWeek = _daysOfTheWeek.map((dayOfTheWeek) => dayOfTheWeek.toString()).toList();

      daysOfTheWeek.removeWhere((dayOfTheWeek) => (values.contains(dayOfTheWeek) == false));
      
      couponForm['discount_on_days_of_the_week'] = daysOfTheWeek;
      
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
                        Text('Activate On Days Of The Week'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['allow_discount_on_days_of_the_week'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['allow_discount_on_days_of_the_week'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    if(couponForm['allow_discount_on_days_of_the_week'] == true) SizedBox(height: 20),

                    if(couponForm['allow_discount_on_days_of_the_week'] == true)
                    Container(
                      key: ValueKey(valueKey),
                      child: MultiSelectDialogField(
                        buttonText: Text('Select Days Of Week:'),
                        buttonIcon: Icon(Icons.calendar_today, color: Colors.grey,),
                        initialValue: couponForm['discount_on_days_of_the_week'],
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
                      
                    Divider(height: 40),

                    (couponForm['allow_discount_on_days_of_the_week'] == true) 
                      ? CustomCheckmarkText(
                          text: (couponForm['discount_on_days_of_the_week'].length == 0
                            ? 'Select the days of the week that this coupon is active for use' 
                            : 'This coupon will be valid for the '+couponForm['discount_on_days_of_the_week'].length.toString()+' selected days of any week'),
                          state: ((couponForm['discount_on_days_of_the_week'].length == 0) ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'This coupon does not depend on any days of the week'),

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