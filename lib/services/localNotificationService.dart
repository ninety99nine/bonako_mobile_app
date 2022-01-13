import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(BuildContext context){
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        //  Notification icon
        "@mipmap-hdpi/ic_launcher"
      ),
      iOS: IOSInitializationSettings(
        //  Add more settings here e.g
        //  onDidReceiveLocalNotification: onDidReceiveLocalNotification
        //  Learn more about the "onDidReceiveLocalNotification" : https://pub.dev/packages/flutter_local_notifications
      )
    );
    
    /**
     *  Define a callback function to handle the action of the user tapping on the notification
     *  from the notifications tray. If we do not define this callback then by default nothing
     *  will happen when the user clicks on the notification. It will simply dissapear.
     */
    final onSelectNotification = (String? payload) async {

      //  Convert the payload data to Json format
      final payloadData = jsonDecode( payload ?? '{}' );

      print('payloadData');
      print(payloadData);

    };

    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

  }

  //  Show the heads up notification when the App is on Foreground state
  static void display(RemoteMessage remoteMessage) async {

    try {

      final id = DateTime.now().millisecondsSinceEpoch ~/1000;
      
      /**
       *  We had to include the following metadata within the "/android/app/src/main/AndroidManifest.xml":
       * 
       *  <meta-data
       *    android:name="com.google.firebase.messaging.default_notification_channel_id"
       *    android:value="high_importance_channel" 
       *  />
       * 
       *  By default the flutter App did not contain this meta-data, but its important for us to allow our
       *  notification to show even when we are on Foreground mode. Foreground mode means that the App is
       *  currently open and being used by the user. Usually in this state, when notifications are sent,
       *  they are silenced and not shown to the user. This behaviour can be avoided by setting up a
       *  channel that can be used to deliver certain notifications for display even if we are in
       *  this Foreground mode.
       * 
       *  This is so that we could register the channel. I decided to enter "high_importance_channel" to the
       *  "android:value" as the channel ID. This can be any value you want e.g "bonako_important_channel" or
       *  whatever you want. From the Firebase Cloud Messaging console when creating a notification, the
       *  same channel id must be included on the notification from the "Additional options" section of
       *  the notification. You will see a field called "Android Notification Channel" which is where
       *  the channel id must be inserted. This is an indication that the notification is so important
       *  that even if the notification is received while on Foreground mode, we must still allow it
       *  to pop-up and show to the user. It must not be silently received. We show this notification
       *  by running the "_flutterLocalNotificationsPlugin.show()" method and passing the notification
       *  details.
       *
       *  Refer to the Youtube video: https://youtu.be/p7aIZ3aEi2w which i used to setup notifications
       */
      final NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "high_importance_channel",
          "High importance channel",
          channelDescription: "This is a very important channel",
          importance: Importance.max,
          priority: Priority.high
        )
      );
      
      await _flutterLocalNotificationsPlugin.show(
        id, 
        remoteMessage.notification!.title,
        remoteMessage.notification!.body,
        notificationDetails,
        /**
         *  The payload is sent as a parameter to the "onSelectNotification()" method found
         *  in the "initialize()" method of this Class. This is how we pass data when the
         *  notification is tapped. The payload must be a String, so we need to convert
         *  the JSON data to String.
         */
        payload: jsonEncode(remoteMessage.data)
      );

    } on Exception catch (e) {

      print(e);

    }

  }
}