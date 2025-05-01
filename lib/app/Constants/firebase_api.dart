import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GetStorage box = GetStorage();
  var Title = "";
  var Message = "";

  Future<void> startNotification() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final String? firebaseToken = await _firebaseMessaging.getToken();
    box.write('Token', firebaseToken);
    print("Token: $firebaseToken");
    log(firebaseToken.toString());
    String tok = box.read('Token');

    await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ), onDidReceiveNotificationResponse: (NotificationResponse response) {
      selectNotification(response.payload);
    });

    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/* This function is here to show the notification when the app is open in BackGround*/

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  log('Background notification is clicked');
  print('Background Message Title: ${message.notification?.title}');
  print('Background Message Body: ${message.notification?.body}');

  showNotification(message);
}

/* This function is here to show the notification when the app is open in ForeGround*/
Future<void> handleForegroundMessage(RemoteMessage remoteMessage) async {
  log('Foreground Notification is clicked');
  final String title = remoteMessage.notification?.title ?? 'No Title';
  final String body = remoteMessage.notification?.body ?? 'No Message';

  log('Foreground Message Title: $title');
  log('Foreground Message Body: $body');

  // Show local system notification
  showNotification(remoteMessage);
}


void handleMessageOpenedApp(RemoteMessage message) {
  log('Message Opened App');
  print('Opened App Message Title: ${message.notification?.title}');
  print('Opened App Message Body: ${message.notification?.body}');

}

void showNotification(RemoteMessage message) async {
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
    'insabhi_icon_office_channel', // id
    'High Importance insabhi Notifications', // title
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
  );
  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: message.notification?.android?.clickAction,
  );
}

Future<void> selectNotification(String? payload) async {
  if (payload != null) {
    print('Notification payload: $payload');
    // _launchUrl(payload);
  }
}

//---->Fetch and collect the url link form the RemoteMessage message<---//
// void fetchClickAction(RemoteMessage message) {
//   // String? Url = message.notification?.android?.clickAction;
//   String? text = message.notification?.title;
//   String? body = message.notification?.title;
//   try {
//     if (text != null && body != null) {
//       log('Click Action URL: $text , $body');
//       Get.find<HomeController>().showDeliveryNotification(text, body);
//       print('Click Action URL: $text');
//     } else {
//       print("No URL has been Found");
//     }
//   } catch (e) {
//     log(e.toString());
//   }
// }



const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'insabhi_icon_office_channel',
  'Icon Office Notifications',
  description:
      'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);
