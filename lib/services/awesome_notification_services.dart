import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:bloc_firebase/main.dart';
import 'package:provider/provider.dart';

class AwesomeNotificationServices {
  String? receiverEmail;
  ChatProvider chatProvider = ChatProvider();

  void initializeProvider(BuildContext context,String email){
    chatProvider = Provider.of<ChatProvider>(context);
    receiverEmail = email;
  }

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'high_importance_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notifications channel for chat',
          channelGroupKey: 'high_importance_channel',
          defaultColor: Colors.purple,
          ledColor: Colors.purple,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        ),
      ],
      debug: true,
    );
    await AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        } else {
          await AwesomeNotifications().setListeners(
            onActionReceivedMethod: onActionReceivedMethod,
            onDismissActionReceivedMethod: onDismissActionReceivedMethod,
            onNotificationCreatedMethod: onNotificationCreatedMethod,
            onNotificationDisplayedMethod: onNotificationDisplayedMethod,
          );
        }
      },
    );

  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {

    print(receivedAction.buttonKeyInput);

    // AwesomeNotificationServices().chatProvider.sendMessage(
    //     senderEmail: RegistrationProvider().currentUser!.email.toString(),
    //     receiverEmail: AwesomeNotificationServices().receiverEmail.toString(),
    //     message: receivedAction.buttonKeyInput);

    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == 'true') {
      MyApp.navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (context) {
        return ChatScreen(
          otherUser: RegistrationProvider().currentUser!,
          message: receivedAction.buttonKeyInput,);
      }));
    }
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? notificationCategory,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: -1,
          channelKey: 'high_importance_channel',
          title: title,
          body: body,
          actionType: actionType,
          notificationLayout: notificationLayout,
          summary: summary,
          category: notificationCategory,
          payload: payload,
          bigPicture: bigPicture,
        ),
        actionButtons: actionButtons,
        schedule: scheduled
            ? NotificationInterval(
                interval: interval,
                timeZone:
                    await AwesomeNotifications().getLocalTimeZoneIdentifier(),
                preciseAlarm: true)
            : null);
  }

}
