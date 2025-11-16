


🟨 Setup Push Notification
👉 for install flutter push notification

   add this dependencie:
```yaml
 firebase_messaging: 
 googleapis: 
 googleapis_auth:
```


🟢 
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
```

//////////////////////////////////// Step 1 Initilization in Main.dart File ////////////////
👉 `important: push notification is work only on background when app is terminated or minimize stage
   for show notification on open app should need to add local notification`
   
// add on the top of main function

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("👉 BG Notify: $message ");
}
```

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}
```

//////////////////////////////////// Step 2 Handle From External File ////////////////
```dart

import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "../main.dart";
import "dart:math";

class Notify {
  FirebaseMessaging msg = FirebaseMessaging.instance;
  void requestNotifyPermissionF() async {
    NotificationSettings stngs = await msg.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (stngs.authorizationStatus == AuthorizationStatus.authorized) {
      // have permission
    } else if (stngs.authorizationStatus == AuthorizationStatus.provisional) {
      // request permission => provisional means provide
    } else {
      // have no notify permmssion
    }
  }

  /////////////////////////
  Future getTokenF(context) async {
    String? token = await msg.getToken();
    debugPrint("👉 token: $token");
    // await Provider.of<CategoryChooseModeVmC>(context, listen: false)
    //     .addTokenVmF(token);
    return token;
  }

  void isTokenRefreshF() {
    msg.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  /////////////////////////
  initListenMsgsF(context) {
    FirebaseMessaging.onMessage.listen((event) {
      debugPrint("👉 IN APP Notify: $event ");
        String title = event.notification?.title ?? "";
        String body = event.notification?.body ?? "";
        // same keys used thats send in payload like in data key is image etc
        // can used image or image_url
        String imageUrl = event.data["image"] ??
          "https://www.iconpacks.net/icons/2/free-discount-icon-2045-thumb.png";
      // call local notification if need
      // showNotification(title: title, body: body, imageUrl: imageUrl);
      // and handle any thing Like: Navigation, snackbar And Others Etc
    });
  }

  onClickFcmNotifi(context) {
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      debugPrint("👉 On Click Notifiaction : $event ");
      // and handle any thing Like: Navigation, snackbar And Others Etc
    });
  }
}
```
///////////////////////////////////// end
🟨 Get Device Token
 get unique device token in home page or any page

```dart

Notify().requestNotifyPermissionF(); // for permssions 
Notify().initListenMsgsF(context); // on message listen
Notify().getTokenF(context); // get device tokens
```

 check in terminal debug console to find the token like => `token: abhxasjehaanksnsakjsendssywke_mqnw....`
 its used to send push notification with unique device token where you want to send to specific users or all if want to send to all users should need to collect all users devices tokens by firebase or by api post method and send notification by api with loop of all devices tokens


🟨 for set android notificaiton icon
paste this in flutterProject/android/app/main/AndroidManifist.xml file

```xml
      <meta-data
            android:name="firebase_messaging_auto_init_enabled"
            android:value="false" />
        <receiver
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:enabled="true"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
            </intent-filter>
        </receiver>
 <meta-data android:name="com.google.firebase.messaging.default_notification_icon" android:resource="@mipmap/imageNameOnly" />
```
    // paste notification image in all mipmap folder 

🟨 Setup Firebase Messaging
    if `firebase` not setup with flutter project then you should need to setup this
after this click on left sidebar engage tab in this also on messaging tab and and click on create your first campaign if this option is not show then refresh this page
after creat first campaign open an alert box in this 2 options select first option to show notification outside of the app 
in next area box enter notification title and text and can enter image link if need then send for test message

🟨 Send Notification From Api
   for send with api first go to top left project-settings and in cloud messaging enable both 1.firebase cloud messaging api (v1) 2. cloud messaging api(legacy) when for lagecy from another page after enabled go back and copy token key for set it into the post api headers authorization: Bearer AAAjkasakkskla..... 
 =>  for find private server tokens keys go to services account tab from same page and select node.js and generate new private key.

🟨 for send notifications with custom keys by this url 
 - url
    method: POST.
    
   ```dart
      https://fcm.googleapis.com/fcm/send
   ```
    // json data 
    // can add customKey in Data Key If Needed


```dart
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getTokenKey() async {
  //----------------- 1. access by file
  // final jsonKeys =
  //     await rootBundle.loadString('assets/json/pushkey.json');
  // final creds = auth.ServiceAccountCredentials.fromJson(jsonKeys);

  //----------------- 2. access by json code
  var jsonKeys = {
    "type": "service_account",
    "project_id": "meetworth-cc6a1",
    "private_key_id": "c847c1fa2684b97658a6ae6d4e10a43ea60721d0",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCuIL04rUT7P6JT\nU8kqkywF708p2UGp0GdrM8T0sfssc238N1YU7wdSK63DPC/OHD3rVYDzoL0p4DBc\nMmM+1yrfZTmlqmtUHu/TWLWmLtzyGX3NSYwVAr5swkbvSTw+tadWdwJIeCLZAfnZ\nAJjfjQ69lWWq2YA+hOn+5Oj0dN4Z1DDoAiIk2KR1CH6zTuS339wjePKMBL6xT53v\n4c5fVoiJkNnlkWr6lIljSdLj/nO1EJzo1NZ00yoRQbR0wyECtft4nCAJ4rvOCL5x\nHfYunj769jqCC+78jjnx7U16++4bxhiXXbkFWWE/f2vBEY4ulv9Ya2OjDgR7qpop\nl6hR7uSVAgMBAAECggEAGQsBW9DjrmThAi33LSXce4AG+SRTYspjzVG1PmIIl0SE\nqXUF7t3Pxjwc8grKb1C1gQ6bjK5t9kNVgTUH/AYzFsz2pQJlDESkxlcoTN3JjhIn\neypcOLtbysWIMSrtvLEgf3l/PQ/2JxK3LcP9uI0PdSmy5QcCADvacXvXmyzhsoIK\nv4c1i8wN/mX5HcPoQ5cOnZtvd9Q9Tgz3/1dHC28nRshqBoUKb2d3vZou+ciQfs2y\n+douEK6RFf09nRsAEdpXqmaE7tO9D+MLcFNHryPEudC3taXvDQgHF/23N3tAdWag\nmvfIf+vGZXzFRki+FOj4NzAQgEW+6vj4RNEdqaPKMQKBgQDa2EhpjGcbLNWqweIl\n5sVw49lXqwFLOEI+0an8fJ1Y7Of1yUk494IuU8Yp5ERSwJ7MhY/m+uvOGKL40XNR\npuIu60CR+8K4k272qlLzIvgfBNFTx8snDit+3AiUUNySekvTTQezD/0HKl/Q3aiI\ntyliSMaYyVCbGrZYAWvZAEsTfQKBgQDLsOjpAjeAD/bDKkHYRCHXemWoBHO98E5T\nAnrXVtCiG7J4ZO8mvfAI3xbk9NIy5dqsLn4RzAvzWRI6x58/0fa2kqYdWAYT1YVA\nexBhE60U4LdV8HYT6cseRk/dg2m8+6JVAAPE3PMfv547rRpGBcY1C9Vq+pjjrQiK\naMZyqv+w+QKBgBDhQ9yYTs+iyqxMHiRsQ2hsurPvZb8mjL2JsIHgHsbgJxgnOXWi\nabEnFw7eI4L6hoUh/DKFwjB4aAGnLizrIWEbFjTsZV2VSabPBmzokpjZ50d+DqZp\nimNTl3nRLuJBep3GwERIhGzMEO3sWvaIojGJiX/5bzU3fz8UhPwM8L2FAoGBAJRX\nEkgfRSwOdDdN3wYRGFRE3yOtml0JVQE/HRcWMnrckOz9FO2yBc1wKswzP6Gxo78h\nXM65OzrN82i7WE6yKmpsAm38XPC034ZGGXeZTMOXo+0CYfu+mB5ENoWr3qWy3FXq\n3NPR1X2ZnzL2rduw+NhI9fQi7JVivoWOKHf58JyBAoGAHE0/Bd3NG8kdGmGrqqnH\nB0w8RWp5ybVwsi+OB9XnAW23okzP9HFswZB62X9E+Phv3afQO6o1Qql/4YihpwL2\nku6PuOWWTNuag1Ee6CQ1/54fg0IcaBhpik5YiM3vh1ht8V5g3arPmJM7ZvXfbL1a\n/Apzz0HaOGgjyt3gweTOKd4=\n-----END PRIVATE KEY-----\n",
    "client_email": "byhasan@meetworth-cc6a1.iam.gserviceaccount.com",
    "client_id": "109511986734768120683",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/byhasan%40meetworth-cc6a1.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

  final creds = auth.ServiceAccountCredentials.fromJson(jsonKeys);

  List<String> scopes = [
    'https://www.googleapis.com/auth/userinfo.email',
    // 'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/firebase.database',
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  final client = await auth.clientViaServiceAccount(creds, scopes);

  auth.AccessCredentials credentials =
      await auth.obtainAccessCredentialsViaServiceAccount(
          auth.ServiceAccountCredentials.fromJson(jsonKeys), scopes, client);

  String tokenIs = credentials.accessToken.data;
  // client.close();
  return tokenIs;
}

sendPushMessagef(
    {required String recipientToken,
    required String title,
    required String body}) async {
  try {
    String serverKeyIs = await getTokenKey();
    print('👉 Server Key: $serverKeyIs');

    const String projectId = 'meetworth-cc6a1'; // Use your Firebase project ID.

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKeyIs',
      },
      body: jsonEncode({
        'message': {
          'token': recipientToken,
          "notification": {
            "title": "Sales",
            "body": "Sale rozana",
            "image": "https://salerozana.com/images/sales/1707308104.jpeg",
            "scheduledTime": "2024-03-08 10:00:00"
          },
          "data": {
            "message": "Offer!",
            "image_url": "https://salerozana.com/images/sales/1707308104.jpeg",
            "image": "https://salerozana.com/images/sales/1707308104.jpeg",
            "customkey": "ABC"
          }
        },
      }),
    );

    print('👉🔔 Response Status: ${response.statusCode}');
    print('🔔 Response Body: ${response.body}');

    if (response.statusCode == 404) {
      print(
          '❌ 404 Requested entity not found. Check recipient token and project ID.');
    }
  } catch (e) {
    print('❌ Error sending push message: $e');
  }
}
```
