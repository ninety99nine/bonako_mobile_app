import 'package:bonako_mobile_app/components/custom_checkmark_text.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import './../../../../../components/custom_back_button.dart';
import './../../../../../components/custom_app_bar.dart';
import './../../../../../components/custom_button.dart';
import '../../../../../components/store_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActivateOnTimesScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Activate On Hours Of Day'),
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
  List _times = [
    '00', '01', '02', '03', '04', '05', '06', '07', '08',
    '09', '10', '11', '12', '13', '14', '15', '16', '17',
    '18', '19', '20', '21', '22', '23'
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

      //  If we have two or more values
      if(values.length >= 2){

        //  Order the times in assending order from 00 to 23
        values.sort((a, b){

          late int intA;
          late int intB;
          
          //  If it start with 0 e.g "00", "01" or "02"
          if(a.substring(0, 1) == '0'){
            //  Get the second digit as an integer e.g "0", "1" or "2"
            intA = int.parse(a.substring(1));
          //  If it does not start with 0 e.g "10", "11" or "12"
          }else{
            //  Get the intire digit as an integer e.g "10", "11" or "12"
            intA = int.parse(a);
          }

          //  If it start with 0 e.g "00", "01" or "02"
          if(b.substring(0, 1) == '0'){
            //  Get the second digit as an integer e.g "0", "1" or "2"
            intB = int.parse((b).substring(1));
          //  If it does not start with 0 e.g "10", "11" or "12"
          }else{
            //  Get the intire digit as an integer e.g "10", "11" or "12"
            intB = int.parse(b);
          }

          //  Compare the numbers to return the smaller of the two
          return intA.compareTo(intB);

        });

      }
      
      couponForm['discount_on_times'] = values;
      
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
                        Text('Activate On Hours Of Day'),
                        Switch(
                          activeColor: Colors.green,
                          value: couponForm['allow_discount_on_times'], 
                          onChanged: (status){
                            setState(() {
                              couponForm['allow_discount_on_times'] = status;
                            });
                          }
                        )
                      ],
                    ),

                    SizedBox(height: 20),

                    if(couponForm['allow_discount_on_times'] == true)
                    Container(
                      key: ValueKey(valueKey),
                      child: MultiSelectDialogField(
                        buttonText: Text('Select Hours Of Day:'),
                        buttonIcon: Icon(Icons.watch_later_outlined, color: Colors.grey,),
                        initialValue: couponForm['discount_on_times'],
                        items: _times.map((time) => MultiSelectItem(time, time+':00')).toList(),
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

                    (couponForm['allow_discount_on_times'] == true) 
                      ? CustomCheckmarkText(
                          text: (couponForm['discount_on_times'].length == 0
                            ? 'Select the hours of the day that this coupon is active for use' 
                            : 'This coupon will be valid for the '+couponForm['discount_on_times'].length.toString()+' selected hours of any day'),
                          state: ((couponForm['discount_on_times'].length == 0) ? 'warning' : 'success')
                        )
                      : CustomCheckmarkText(text: 'This coupon does not depend on any hours of the day'),

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