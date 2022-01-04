import 'package:bonako_mobile_app/enum/enum.dart';
import 'package:bonako_mobile_app/providers/api.dart';

import './../../../../screens/dashboard/coupons/list/coupons_screen.dart';
import './../../../../components/custom_rounded_refresh_button.dart';
import './../../../../components/custom_checkmark_text.dart';
import './../../../../components/custom_back_button.dart';
import './../../../../../components/custom_loader.dart';
import './sections/activate_on_total_unique_items.dart';
import './sections/activate_on_existing_customers.dart';
import './sections/activate_on_months_of_the_year.dart';
import './sections/activate_on_days_of_the_month.dart';
import './sections/activate_on_days_of_the_week.dart';
import './../../../../components/custom_app_bar.dart';
import './../../../../components/custom_divider.dart';
import './../../../../components/custom_button.dart';
import './sections/activate_on_minimum_total.dart';
import './sections/activate_on_new_customers.dart';
import '../../../../components/store_drawer.dart';
import './sections/activate_on_total_items.dart';
import './../../../../providers/locations.dart';
import './../../../../providers/coupons.dart';
import './sections/activate_usage_limit.dart';
import './sections/offer_free_delivery.dart';
import './../../../../models/coupons.dart';
import './sections/activate_on_dates.dart';
import './sections/activate_on_times.dart';
import './sections/activate_on_code.dart';
import './sections/offer_discount.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './sections/visibility.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:convert';

enum Activity {
  isCreating,
  isEditing
}

class CreateCouponScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context){

    final hasCoupon = Provider.of<CouponsProvider>(context, listen: false).hasCoupon;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: hasCoupon ? 'Edit Coupon' : 'Create Coupon'),
        drawer: StoreDrawer(),
        body: Content(),
      )
    );
  }
}

class Content extends StatefulWidget {

  @override
  _ContentState createState() => _ContentState();

}

class _ContentState extends State<Content> {
  
  //  Set the form key
  final GlobalKey<FormState> _formKey = GlobalKey();

  //  By default we are creating a coupon
  Activity activityType = Activity.isCreating;

  //  By default the loader is not loading
  var isSubmitting = false;

  //  By default the loader is not loading
  var isLoadingCoupon = false;
  
  Map couponForm = {};

  Map serverErrors = {};

  ApiProvider get apiProvider {
    return Provider.of<ApiProvider>(context, listen: false);
  }

  CouponsProvider get couponsProvider {
    return Provider.of<CouponsProvider>(context, listen: false);
  }

  LocationsProvider get locationsProvider {
    return Provider.of<LocationsProvider>(context, listen: false);
  }

  void _resetServerErrors(){
    serverErrors = {};
  }

  void startCouponLoader(){
    setState(() {
      isLoadingCoupon = true;
    });
  }

  void stopCouponLoader(){
    setState(() {
      isLoadingCoupon = false;
    });
  }

  void startSubmitLoader(){
    setState(() {
      isSubmitting= true;
    });
  }

  void stopSubmitLoader(){
    setState(() {
      isSubmitting = false;
    });
  }

  void _handleValidationErrors(http.Response response){

    final responseBody = jsonDecode(response.body);

    final Map validationErrors = responseBody['errors'];

    /**
     *  validationErrors = {
     *    name: [Enter coupon name]
     *  }
     */
    validationErrors.forEach((key, value){
      serverErrors[key] = value[0];
    });
    
    // Run form validation
   _formKey.currentState!.validate();
    
  }

  void onSubmit(){

    //  Reset server errors
    _resetServerErrors();
    
    //  If local validation passed
    if( _formKey.currentState!.validate() == true ){

      //  Save inputs
      _formKey.currentState!.save();

      startSubmitLoader();

      if( isEditing ){

        print('couponForm');
        print(couponForm);

        couponsProvider.updateCoupon(
          body: couponForm,
          context: context
        ).then((response){

          _handleOnSubmitResponse(response);

        }).whenComplete((){
          
          stopSubmitLoader();

        });

      }else{

        couponsProvider.createCoupon(
          body: couponForm,
          context: context
        ).then((response){

          _handleOnSubmitResponse(response);

        }).whenComplete((){
          
          stopSubmitLoader();

        });

      }
    
    //  If validation failed
    }else{

      if( isEditing ){

        apiProvider.showSnackbarMessage(msg: 'Sorry, you cannot update coupon yet', context: context, type: SnackbarType.error);

      }else{

        apiProvider.showSnackbarMessage(msg: 'Sorry, you cannot create coupon yet', context: context, type: SnackbarType.error);

      }

    }

  }


  void _handleOnSubmitResponse(http.Response response){
    
    //  If this is a validation error
    if(response.statusCode == 422){

      _handleValidationErrors(response);
      
    }else if( response.statusCode == 200 || response.statusCode == 201 ){

      //  Navigate to the coupons
      Get.back(result: 'submitted');

    }

  }

  prepareCoupon() {

    if( isEditing ){

      //  Fetch the coupon
      this.fetchCoupon().then((response){

        if( response.statusCode == 200 ){
          
          //  Set the form details
          this.couponForm = getCouponForm();
        
        }

        return response;

      });

    }else{

      //  Set the form details
      this.couponForm = getCouponForm();

    }

  }

  Future<http.Response> fetchCoupon() async {

    startCouponLoader();

    return await couponsProvider.fetchCoupon(context: context).then((response){

      if( response.statusCode == 200 ){

        final responseBody = jsonDecode(response.body);

        //  Set the coupon on the couponsProvider
        couponsProvider.setCoupon(Coupon.fromJson(responseBody as Map<String, dynamic>));

      }

      return response;

    }).whenComplete((){

      stopCouponLoader();

    });

  }

  Coupon get edittableCoupon {
    return couponsProvider.getCoupon;
  }

  Map getCouponForm(){

    return {
      
      'name': isEditing ? edittableCoupon.name : '',
      'active': isEditing ? edittableCoupon.active.status : true,
      'description': isEditing ? edittableCoupon.description : '',

      'activation_type': isEditing ? edittableCoupon.activationType.type : 'always apply',
      'code': isEditing ? edittableCoupon.code : '',

      'apply_discount': isEditing ? edittableCoupon.applyDiscount.status : false,
      'allow_free_delivery': isEditing ? edittableCoupon.allowFreeDelivery.status : false,

      'currency': isEditing ? edittableCoupon.currency.code: 'BWP',
      'discount_rate_type': isEditing ? edittableCoupon.discountRateType.type : 'Percentage',
      'percentage_rate': isEditing ? edittableCoupon.percentageRate.toString() : '0',
      'fixed_rate': isEditing ? edittableCoupon.fixedRate.amount.toString() : '0.00',

      'allow_discount_on_minimum_total': isEditing ? edittableCoupon.allowDiscountOnMinimumTotal.status : false,
      'discount_on_minimum_total': isEditing ? edittableCoupon.discountOnMinimumTotal.amount.toString() : '100.00',

      'allow_discount_on_total_items': isEditing ? edittableCoupon.allowDiscountOnTotalItems.status : false,
      'discount_on_total_items': isEditing ? edittableCoupon.discountOnTotalItems.toString() : '2',

      'allow_discount_on_total_unique_items': isEditing ? edittableCoupon.allowDiscountOnTotalUniqueItems.status : false,
      'discount_on_total_unique_items': isEditing ? edittableCoupon.discountOnTotalUniqueItems.toString() : '2',

      'allow_discount_on_start_datetime': isEditing ? edittableCoupon.allowDiscountOnStartDatetime.status : false,
      'discount_on_start_datetime': isEditing ? edittableCoupon.discountOnStartDatetime : DateTime.now(),

      'allow_discount_on_end_datetime': isEditing ? edittableCoupon.allowDiscountOnEndDatetime.status : false,
      'discount_on_end_datetime': isEditing ? edittableCoupon.discountOnEndDatetime : DateTime.now().add(Duration(days: 7)),

      'allow_usage_limit': isEditing ? edittableCoupon.allowUsageLimit.status : false,
      'usage_quantity': isEditing ? edittableCoupon.usageQuantity.toString() : '0',
      'usage_limit': isEditing ? edittableCoupon.usageLimit.toString() : '100',

      'allow_discount_on_times': isEditing ? edittableCoupon.allowDiscountOnTimes.status : false,
      'discount_on_times': isEditing ? edittableCoupon.discountOnTimes : [],

      'allow_discount_on_days_of_the_week': isEditing ? edittableCoupon.allowDiscountOnDaysOfTheWeek.status : false,
      'discount_on_days_of_the_week': isEditing ? edittableCoupon.discountOnDaysOfTheWeek : [],

      'allow_discount_on_days_of_the_month': isEditing ? edittableCoupon.allowDiscountOnDaysOfTheMonth.status : false,
      'discount_on_days_of_the_month': isEditing ? edittableCoupon.discountOnDaysOfTheMonth : [],

      'allow_discount_on_months_of_the_year': isEditing ? edittableCoupon.allowDiscountOnMonthsOfTheYear.status : false,
      'discount_on_months_of_the_year': isEditing ? edittableCoupon.discountOnMonthsOfTheYear : [],

      'allow_discount_on_new_customer': isEditing ? edittableCoupon.allowDiscountOnNewCustomer.status : false,
      'allow_discount_on_existing_customer': isEditing ? edittableCoupon.allowDiscountOnExistingCustomer.status : false,
      
      'location_id': locationsProvider.location.id,

    };
  }

  void setActivity(){
    
    //  If we have a coupon set on the couponsProvider, then we are editing
    activityType = couponsProvider.hasCoupon ? Activity.isEditing : Activity.isCreating;

  }

  bool get isEditing {
    return activityType == Activity.isEditing;
  }

  bool get isCreating {
    return activityType == Activity.isCreating;
  }

  @override
  void initState() {

    setActivity();
    
    prepareCoupon();

    super.initState();

  }

  Widget customDivider(String text){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: <Widget>[
            Expanded(
              child: Divider()
            ),       
            SizedBox(width: 20),
            Text(text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(width: 20),
            Expanded(
                child: Divider()
            ),
        ]
      ),
    );
  }

  Widget customCard({ required String title, required Widget screen , Widget bottomWidget: const Text(''), bool highlight: false }){
    return Card(
      color: highlight ? Colors.blue.shade200 : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          child: InkWell(
            splashColor: Colors.blue.withOpacity(0.2),
            highlightColor: Colors.blue.withOpacity(0.2),
            onTap: () async {

              Map arguments = {
                'couponForm': couponForm,
                'serverErrors': serverErrors,
              };
                    
              //  Navigate to the screen specified to collect additional coupon form data
              var updatedCouponForm = await Get.to(() => screen, arguments: arguments);

              if( updatedCouponForm != null ){
                
                setState(() {
                  //  Update the coupon form on return
                  couponForm = updatedCouponForm;
                });

              }
        
            },
            child: ListTile(
              tileColor: Colors.white,
              title: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
              
                      //  Title 
                      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
              
                      //  Forward Arrow 
                      TextButton(
                        onPressed: () => {}, 
                        child: Icon(Icons.arrow_forward, color: Colors.grey,),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            )
                          )
                        ),
                      )
              
                    ],
                  ),
                  bottomWidget
                ],
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget nameInput(){
    return TextFormField(
      autofocus: false,
      initialValue: couponForm['name'],
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: "Coupon Name",
        hintText: 'E.g Save 20%',
        border:OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: (value){
        if(value == null || value.isEmpty){
          return 'Please enter coupon name';
        }else if(serverErrors.containsKey('name')){
          return serverErrors['name'];
        }
      },
      onSaved: (value){
        couponForm['name'] = value;
      }
    );
  }

  Widget descriptionInput(){
    return TextFormField(
      autofocus: false,
      initialValue: couponForm['description'],
      keyboardType: TextInputType.multiline,
      minLines: 2,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: "Description",
        hintText: 'E.g Served with salad and 330ml coke',
        border:OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      validator: (value){
        if(value != null && value.length > 100){
          return 'The description is too long';
        }else if(serverErrors.containsKey('description')){
          return serverErrors['description'];
        }
      },
      onSaved: (value){
        couponForm['description'] = value;
      }
    );
  }

  Widget separator(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text('|', style: TextStyle(color: Colors.grey),),
    );
  }

  Widget offerDiscountCard(){
    return 
      customCard(
        title: 'Offer Discount',
        screen: OfferDiscountScreen(),
        highlight: couponForm['apply_discount'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [   

              //  Apply discount
              Text(couponForm['apply_discount'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['apply_discount']) separator(),

              //  Discount rate type
              if(couponForm['apply_discount']) Text(couponForm['discount_rate_type'], style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['apply_discount']) separator(),

              //  Percentage discount rate type
              if(couponForm['apply_discount'] && couponForm['discount_rate_type'] == 'Percentage') Text(couponForm['percentage_rate']+'%', style: TextStyle(fontSize: 12, color: Colors.grey)),

              //  Percentage discount rate type
              if(couponForm['apply_discount'] && couponForm['discount_rate_type'] == 'Fixed') Text(couponForm['currency'] +' '+ couponForm['fixed_rate'], style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
      );
  }

  Widget offerFreeDeliveryCard(){
    return 
      customCard(
        title: 'Offer Free Delivery',
        screen: OfferFreeDeliveryScreen(),
        highlight: couponForm['allow_free_delivery'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [   

              //  Offer free delivery
              Text(couponForm['allow_free_delivery'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
      );
  }

  Widget activateOnCodeCard(){
    return 
      customCard(
        title: 'Activate On Code',
        screen: ActivateOnCodeScreen(),
        highlight: (couponForm['activation_type'] == 'use code'),
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [   

              //  Activate on code
              Text((couponForm['activation_type'] == 'use code') ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['activation_type'] == 'use code') separator(),

              //  Activation Code
              if((couponForm['activation_type'] == 'use code'))
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    children: <TextSpan>[
                      TextSpan(text: 'Activation Code: '),
                      TextSpan(
                        text: couponForm['code'],
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        )
      );
  }

  Widget activateOnMinimumTotalCard(){
    return 
      customCard(
        title: 'Activate On Minimum Total',
        screen: ActivateOnMinimumTotalScreen(),
        highlight: couponForm['allow_discount_on_minimum_total'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [   

              //  Activate On Minimum Total
              Text(couponForm['allow_discount_on_minimum_total'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_discount_on_minimum_total']) separator(),

              //  Minimum Total
              if(couponForm['allow_discount_on_minimum_total']) Text(couponForm['currency'] +' '+ couponForm['discount_on_minimum_total'], style: TextStyle(fontSize: 12, color: Colors.grey)),
            
            ],
          ),
        )
      );
  }

  Widget activateOnTotalItemsCard(){
    return 
      customCard(
        title: 'Activate On Total Items',
        screen: ActivateTotalItemsScreen(),
        highlight: couponForm['allow_discount_on_total_items'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [    

              //  Activate On Total Items
              Text(couponForm['allow_discount_on_total_items'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_discount_on_total_items']) separator(),

              if(couponForm['allow_discount_on_total_items']) Text(couponForm['discount_on_total_items'], style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
      );
  }

  Widget activateOnTotalUniqueItemsCard(){
    return 
      customCard(
        title: 'Activate On Total Unique Items',
        screen: ActivateTotalUniqueItemsScreen(),
        highlight: couponForm['allow_discount_on_total_unique_items'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [    

              //  Activate On Total Unique Items
              Text(couponForm['allow_discount_on_total_unique_items'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_discount_on_total_unique_items']) separator(),

              if(couponForm['allow_discount_on_total_unique_items']) Text(couponForm['discount_on_total_unique_items'], style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
      );
  }

  Widget activateUsageLimitCard(){
    return 
      customCard(
        title: 'Limit Usage',
        screen: ActivateUsageLimitScreen(),
        highlight: couponForm['allow_usage_limit'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [

              //  Activate On Total Unique Items
              Text(couponForm['allow_usage_limit'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_usage_limit']) separator(),

              if(couponForm['allow_usage_limit']) Text((int.parse(couponForm['usage_limit']) - int.parse(couponForm['usage_quantity'])).toString()+' Available', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_usage_limit']) separator(),

              if(couponForm['allow_usage_limit']) Text(couponForm['usage_limit']+' Limited', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_usage_limit']) separator(),

              if(couponForm['allow_usage_limit']) Text(couponForm['usage_quantity']+' Used', style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
      );
  }

  Widget activateOnDatesCard(){
    return 
      customCard(
        title: 'Activate On Dates',
        screen: ActivateOnDatesScreen(),
        highlight: (couponForm['allow_discount_on_start_datetime'] || couponForm['allow_discount_on_end_datetime']),
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
  
              Text(couponForm['allow_discount_on_start_datetime'] || couponForm['allow_discount_on_end_datetime'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_discount_on_start_datetime'] || couponForm['allow_discount_on_end_datetime']) SizedBox(width: 5),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: couponForm['allow_discount_on_days_of_the_week'] ? Colors.grey : Colors.transparent)
                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        if(couponForm['allow_discount_on_start_datetime']) Text('Start: '+DateFormat('dd MMM yyyy H:mm').format(couponForm['discount_on_start_datetime']).toString(), style: TextStyle(fontSize: 12, color: Colors.grey)),

                        if(couponForm['allow_discount_on_start_datetime'] && couponForm['allow_discount_on_end_datetime']) SizedBox(height: 5),

                        if(couponForm['allow_discount_on_end_datetime']) Text('End:  '+DateFormat('dd MMM yyyy H:mm').format(couponForm['discount_on_end_datetime']).toString(), style: TextStyle(fontSize: 12, color: Colors.grey)),
                      
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      );
  }

  Widget activateOnTimesCard(){
    return 
      customCard(
        title: 'Activate On Hours Of Day',
        screen: ActivateOnTimesScreen(),
        highlight: couponForm['allow_discount_on_times'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
  
              Text(couponForm['allow_discount_on_times'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_discount_on_times']) SizedBox(width: 5),

              if(couponForm['allow_discount_on_times']) 
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: couponForm['allow_discount_on_times'] ? Colors.grey : Colors.transparent)
                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Wrap(
                      runSpacing: 5.0,
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        ...(couponForm['discount_on_times'] as  List<String>).map((String time){
                            final index = couponForm['discount_on_times'].indexOf(time);
                            final notTheOnlyOne = (couponForm['discount_on_times'].length >= 2);
                            final isLastItem = ((index + 1) == couponForm['discount_on_times'].length);
                            final isSecondLastItem = ((index + 2) == couponForm['discount_on_times'].length);

                            return Text((isLastItem && notTheOnlyOne ? ' and ' : '')+time+':00'+(isLastItem ? '' : (isSecondLastItem ? '' : ', ')), style: TextStyle(fontSize: 12, color: Colors.grey));

                        }).toList()
                      ],
                    ),
                  ),
                ),
              )

            ],
          ),
        )
      );
  }

  Widget activateOnDaysOfTheWeekCard(){
    return 
      customCard(
        title: 'Activate On Days Of The Week',
        screen: ActivateOnDaysOfTheWeekScreen(),
        highlight: couponForm['allow_discount_on_days_of_the_week'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
  
              Text(couponForm['allow_discount_on_days_of_the_week'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_discount_on_days_of_the_week']) SizedBox(width: 5),

              if(couponForm['allow_discount_on_days_of_the_week']) 
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: couponForm['allow_discount_on_days_of_the_week'] ? Colors.grey : Colors.transparent)
                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Wrap(
                      runSpacing: 5.0,
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        ...(couponForm['discount_on_days_of_the_week'] as  List<String>).map((String dayOfTheWeek){
                            final index = couponForm['discount_on_days_of_the_week'].indexOf(dayOfTheWeek);
                            final notTheOnlyOne = (couponForm['discount_on_days_of_the_week'].length >= 2);
                            final isLastItem = ((index + 1) == couponForm['discount_on_days_of_the_week'].length);
                            final isSecondLastItem = ((index + 2) == couponForm['discount_on_days_of_the_week'].length);

                            return Text((isLastItem && notTheOnlyOne ? ' and ' : '')+dayOfTheWeek+(isLastItem ? '' : (isSecondLastItem ? '' : ', ')), style: TextStyle(fontSize: 12, color: Colors.grey));

                        }).toList()
                      ],
                    ),
                  ),
                ),
              )

            ],
          ),
        )
      );
  }

  Widget activateOnDaysOfTheMonthCard(){
    return 
      customCard(
        title: 'Activate On Days Of The Month',
        screen: ActivateOnDaysOfTheMonthScreen(),
        highlight: couponForm['allow_discount_on_days_of_the_month'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
  
              Text(couponForm['allow_discount_on_days_of_the_month'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_discount_on_days_of_the_month']) SizedBox(width: 5),

              if(couponForm['allow_discount_on_days_of_the_month']) 
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: couponForm['allow_discount_on_days_of_the_month'] ? Colors.grey : Colors.transparent)
                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Wrap(
                      runSpacing: 5.0,
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        ...(couponForm['discount_on_days_of_the_month'] as  List<int>).map((dayOfTheMonth){
                            final index = couponForm['discount_on_days_of_the_month'].indexOf(dayOfTheMonth);
                            final notTheOnlyOne = (couponForm['discount_on_days_of_the_month'].length >= 2);
                            final isLastItem = ((index + 1) == couponForm['discount_on_days_of_the_month'].length);
                            final isSecondLastItem = ((index + 2) == couponForm['discount_on_days_of_the_month'].length);          

                            return Text((isLastItem && notTheOnlyOne ? ' and ' : '')+dayOfTheMonth.toString()+(isLastItem ? '' : (isSecondLastItem ? '' : ', ')), style: TextStyle(fontSize: 12, color: Colors.grey));

                        }).toList()
                      ],
                    ),
                  ),
                ),
              )
              
            ],
          ),
        )
      );
  }

  Widget activateOnMonthsOfTheYearCard(){
    return 
      customCard(
        title: 'Activate On Months Of The Year',
        screen: ActivateOnMonthsOfTheYearScreen(),
        highlight: couponForm['allow_discount_on_months_of_the_year'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
  
              Text(couponForm['allow_discount_on_months_of_the_year'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

              if(couponForm['allow_discount_on_months_of_the_year']) SizedBox(width: 5),

              if(couponForm['allow_discount_on_months_of_the_year']) 
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: couponForm['allow_discount_on_months_of_the_year'] ? Colors.grey : Colors.transparent)
                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Wrap(
                      runSpacing: 5.0,
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        ...(couponForm['discount_on_months_of_the_year'] as  List<String>).map((String monthsOfTheYear){
                            final index = couponForm['discount_on_months_of_the_year'].indexOf(monthsOfTheYear);
                            final notTheOnlyOne = (couponForm['discount_on_months_of_the_year'].length >= 2);
                            final isLastItem = ((index + 1) == couponForm['discount_on_months_of_the_year'].length);
                            final isSecondLastItem = ((index + 2) == couponForm['discount_on_months_of_the_year'].length);

                            return Text((isLastItem && notTheOnlyOne ? ' and ' : '')+monthsOfTheYear+(isLastItem ? '' : (isSecondLastItem ? '' : ', ')), style: TextStyle(fontSize: 12, color: Colors.grey));

                        }).toList()
                      ],
                    ),
                  ),
                ),
              )

            ],
          ),
        )
    );
  }    

  Widget activateOnNewCustomerCard(){
    return 
      customCard(
        title: 'Activate On New Customers',
        screen: ActivateOnNewCustomers(),
        highlight: couponForm['allow_discount_on_new_customer'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
  
              Text(couponForm['allow_discount_on_new_customer'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
      );
  }

  Widget activateOnExistingCustomerCard(){
    return 
      customCard(
        title: 'Activate On Existing Customers',
        screen: ActivateOnExistingCustomers(),
        highlight: couponForm['allow_discount_on_existing_customer'],
        bottomWidget: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
  
              Text(couponForm['allow_discount_on_existing_customer'] ? 'Yes' : 'No', style: TextStyle(fontSize: 12, color: Colors.grey)),

            ],
          ),
        )
      );
  }

  Widget showForm(){

    return Form(
        key: _formKey,
        child: Column(
          children: <Widget>[

            SizedBox(height: 40),
      
            nameInput(),
            SizedBox(height: 10),
      
            descriptionInput(),
            SizedBox(height: 10),

            CustomDivider(text: Text('Offers'), topMargin: 20, bottomMargin: 20),
      
            offerDiscountCard(),
            SizedBox(height: 10),
      
            offerFreeDeliveryCard(),
            SizedBox(height: 10),

            CustomDivider(text: Text('Activation Rules'), topMargin: 20, bottomMargin: 20),

            activateOnCodeCard(),
            SizedBox(height: 10),

            activateOnMinimumTotalCard(),
            SizedBox(height: 10),

            activateOnTotalItemsCard(),
            SizedBox(height: 10),

            activateOnTotalUniqueItemsCard(),
            SizedBox(height: 10),

            activateUsageLimitCard(),
            SizedBox(height: 10),

            activateOnDatesCard(),
            SizedBox(height: 10),

            activateOnTimesCard(),
            SizedBox(height: 10),

            activateOnDaysOfTheWeekCard(),
            SizedBox(height: 10),

            activateOnDaysOfTheMonthCard(),
            SizedBox(height: 10),

            activateOnMonthsOfTheYearCard(),
            SizedBox(height: 10),

            activateOnNewCustomerCard(),
            SizedBox(height: 10),

            activateOnExistingCustomerCard(),
            SizedBox(height: 10),

            

            CustomButton(
              text: isEditing ? 'Save' : 'Create',
              isLoading: isSubmitting,
              onSubmit: (isSubmitting) ? null : onSubmit,
            ),

            SizedBox(height: 50),
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
              CustomBackButton(fallback: (){
                Get.offAll(() => CouponsScreen());
              }),
              CustomRoundedRefreshButton(onPressed: (){}),
            ],
          ),
          Divider(height: 0,),

          if(isLoadingCoupon == true) SizedBox(height: 20),
          
          //  Loader
          if(isLoadingCoupon == true) CustomLoader(),

          //  List of card widgets
          if(isLoadingCoupon == false) Expanded(
            child: SingleChildScrollView(
              child: showForm()
            ),
          )

        ],
      ),
    );
  }
}