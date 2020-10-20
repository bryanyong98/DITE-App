import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:heard/firebase_services/auth_service.dart';

class FCM {
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  bool _initialized = false;
  static StreamController<Map<String, dynamic>> fcmStreamController = StreamController.broadcast();
  static final Stream<Map<String, dynamic>> onFcmMessage = fcmStreamController.stream;

  /// Make sure to include click_action: FLUTTER_NOTIFICATION_CLICK as a
  /// "Custom data" key-value-pair (under "Advanced options") when targeting
  /// an Android device.
  /// https://pub.dev/packages/firebase_messaging
  Future<void> init(String userType) async{
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("onMessageFCM: $message");
          fcmStreamController.add(message);
        },
        onBackgroundMessage: myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("onLaunchFCM: $message");
          fcmStreamController.add(message);
        },
        onResume: (Map<String, dynamic> message) async {
          print("onResumeFCM: $message");
          fcmStreamController.add(message);
        },
      );

      String fcmToken = await _firebaseMessaging.getToken();

      String authToken = await AuthService.getToken();
      var response = await http.post(
          'https://heard-project.herokuapp.com/fcm/upsert',
          headers: {
            'Authorization': authToken,
          },
          body: {
            'fcm_token': fcmToken,
            'type': userType,
          });
      _initialized = true;

      var code = response.statusCode;
    }
  }

  static Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
      final dynamic data = message['data'];
      print('data from push notification: ${data.toString()}');
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
      print('notification from push notification: ${notification.toString()}');
    }
  }
}