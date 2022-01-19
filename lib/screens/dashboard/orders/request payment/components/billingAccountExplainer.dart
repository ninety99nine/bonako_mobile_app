import './../../../../../screens/dashboard/users/show/components/userProfileSummary.dart';
import 'package:bonako_mobile_app/components/custom_explainer.dart';
import 'package:bonako_mobile_app/models/users.dart';
import 'package:flutter/material.dart';

class BillingAccountExplainer extends StatelessWidget {

  final User? customerAccountUser;
  final User? differentAccountUser;
  final bool transactionPaidStatus;
  final bool isBillingCustomerAccount;
  final bool foundDifferentAccountUser;
  final String customerAccountMobileNumber;
  final String differentAccountMobileNumber;

  BillingAccountExplainer({ 
    required this.transactionPaidStatus, required this.customerAccountUser, required this.differentAccountUser, 
    required this.isBillingCustomerAccount, required this.foundDifferentAccountUser,
    required this.customerAccountMobileNumber, required this.differentAccountMobileNumber
  });

  @override
  Widget build(BuildContext context) {
    return CustomExplainer(
      mark: Icons.info_sharp,
      markBgColor: Colors.white,
      markColor: Colors.blue,
      title: 'Billing Account',
      description:  
        Wrap(
          children: [
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: TextStyle(color: Colors.black, height: 1.5, fontSize: 12),
                children: <TextSpan>[
                  if(isBillingCustomerAccount == true) TextSpan(text: 'The customer'),
                  if(isBillingCustomerAccount == false) TextSpan(text: 'A different'),
                  TextSpan(text: ' account using the mobile number '),
                  TextSpan(
                    text: isBillingCustomerAccount ? customerAccountMobileNumber : differentAccountMobileNumber, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  TextSpan(text: transactionPaidStatus ? ' was billed successfully' : ' will be billed', style: TextStyle(fontSize: 12)),
                ],
              )
            ),
            
            SizedBox(height: 20),

          ],
        ),
      
      footer: ((isBillingCustomerAccount == true && customerAccountUser != null) || 
               (isBillingCustomerAccount == false && foundDifferentAccountUser == true && differentAccountUser != null)) 
        ? UserProfileSummary(
            user: (isBillingCustomerAccount == true) ? customerAccountUser! :  differentAccountUser!
          )
        : null
    );
  }
}