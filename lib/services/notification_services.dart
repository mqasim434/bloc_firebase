import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((event) {
      print(event.notification!.title);
      if (Platform.isAndroid) {
        initNotifications(context, event);
        showNotification(event);
      }
    });
  }

  showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      Random.secure().nextInt(100).toString(),
      "Test Channel",
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Ticker',
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        1,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails,
      );
    });
  }

  void initNotifications(BuildContext context, RemoteMessage message) async {
    var androidIntitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings =
        InitializationSettings(android: androidIntitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {});
  }

  void requestNotificationPermissions() async {
    NotificationSettings notificationSettings =
        await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('Authorized');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Provisional');
    } else {}
  }

  Future<String?> getDeviceToken() async {
    String? token = await firebaseMessaging.getToken();
    return token;
  }

  void refreshToken() {
    firebaseMessaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}
