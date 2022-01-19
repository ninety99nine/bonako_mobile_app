import 'package:bonako_mobile_app/models/transactions.dart';
import 'package:bonako_mobile_app/providers/orders.dart';
import 'package:bonako_mobile_app/providers/auth.dart';
import 'package:flutter/material.dart';

class TransactionsProvider with ChangeNotifier{

  var _transaction;
  OrdersProvider ordersProvider;

  TransactionsProvider({ required this.ordersProvider });

  void launchPaymentShortcode ({ Transaction? transaction, required BuildContext context }) async {

    if( transaction != null ){

      final hasPaymentShortCode = transaction.attributes.hasPaymentShortCode;

      if( hasPaymentShortCode ){

        final paymentShortCode = transaction.attributes.paymentShortCode!;
        
        final dialingCode = paymentShortCode.dialingCode;
        
        authProvider.launchShortcode (dialingCode: dialingCode, loadingMsg: 'Preparing payment', context: context);

      }

    }

  }

  void setTransaction(Transaction transaction){
    print('setTransaction: before');
    print(this._transaction);
    this._transaction = transaction;
    print('setTransaction: after');
    print(this._transaction);
  }

  void unsetTransaction(){
    this._transaction = null;
  }

  Transaction get getTransaction {
    return _transaction;
  }

  bool get hasTransaction {
    return _transaction == null ? false : true;
  }

  AuthProvider get authProvider {
    return ordersProvider.authProvider;
  }

}