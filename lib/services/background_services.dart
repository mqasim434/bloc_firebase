import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundServices{
  FlutterBackgroundService service = FlutterBackgroundService();

  Future<void> initService() async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(),
    );
    service.startService();
  }

  Future<void> sendNotification() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,

    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',

      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Alert!',
      'App Close',
      platformChannelSpecifics,
    );
  }


  @pragma("vm:entry-point")
  static onStart(ServiceInstance service) async {

    DartPluginRegistrant.ensureInitialized();
    if (service is AndroidServiceInstance) {
        service.setAsForegroundService();
    }

    Future<void> sendNotification() async {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,

      );

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'your_channel_id',
        'Your Channel Name',

        importance: Importance.high,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0,
        'Alert!',
        'App Close',
        platformChannelSpecifics,
      );
    }

    Timer(const Duration(seconds: 15), ()  {
      sendNotification();
      changeOnlineStatus(false,service);
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
      changeOnlineStatus(true,service);
    });

  }


   static void changeOnlineStatus(bool onlineStatus,ServiceInstance serviceInstance) async {
    await Firebase.initializeApp();
    final email = FirebaseAuth.instance.currentUser!.email;
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
      in querySnapshot.docs) {
        await docSnapshot.reference.update({'isOnline': onlineStatus});
        serviceInstance.stopSelf();
        print('User online status updated successfully for email: $email');
      }
    } catch (error) {
      print('Error updating user online status for email $email: $error');
    }
  }


}
