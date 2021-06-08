import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:skype_clone/models/user.dart';
import 'package:skype_clone/provider/image_upload_provider.dart';
import 'package:skype_clone/provider/user_provider.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:skype_clone/screens/home_screen.dart';
import 'package:skype_clone/screens/login_screen.dart';
import 'package:skype_clone/screens/search_screen.dart';
import 'package:skype_clone/provider/translate_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static const platform = const MethodChannel('TokenChannel');
  String token;
  _getdeviceToken() async {
    await _firebaseMessaging.getToken().then((deviceToken) {
      setState(() {
        token = deviceToken.toString();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getdeviceToken();
    sendData();
    Future.delayed(Duration(milliseconds: 500), () {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));
    });
  }

  Future<void> sendData() async {
    String message;
    try {
      message = await platform.invokeMethod(token);
      print(message);
    } on PlatformException catch (e) {
      message = "Failed to get data from native : '${e.message}'.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TranslateProvider()),
      ],
      child: MaterialApp(
        title: "Speakotron",
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/search_screen': (context) => SearchScreen(),
        },
        theme: ThemeData(brightness: Brightness.dark),
        home: FutureBuilder(
          future: _authMethods.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              return HomeScreen();
            } else {
              return LoginScreen(token: token);
            }
          },
        ),
      ),
    );
  }
}

class HomeWidget extends StatelessWidget {
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static const platform = const MethodChannel('TokenChannel');
  String token;


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _authMethods.getUserDetails(),
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginScreen(token: token);
        }
      },
    );
  }
}
