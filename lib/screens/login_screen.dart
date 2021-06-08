import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skype_clone/resources/auth_methods.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skype_clone/utils/universal_variables.dart';
import 'home_screen.dart';
import 'package:skype_clone/screens/pageviews/Translator/conversation_page.dart';

class LoginScreen extends StatefulWidget {
  final String token;
  LoginScreen({Key key, this.token}) : super(key: key);
  @override
  LoginScreenState createState() => LoginScreenState(this.token);
}

class LoginScreenState extends State<LoginScreen> {
  String token;
  LoginScreenState(this.token);
  final AuthMethods _authMethods = AuthMethods();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      body: Stack(
        children: [
          Center(
            child: loginButton(),
          ),
          isLoginPressed
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container()
        ],
      ),
    );
  }

  Widget loginButton() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: UniversalVariables.senderColor,
      child: FlatButton(
        padding: EdgeInsets.all(35),
        child: Text(
          "LOGIN",
          style: TextStyle(
              fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        onPressed: () => performLogin(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void performLogin() async {
  
    setState(() {
      isLoginPressed = true;
    });

    FirebaseUser user = await _authMethods.signIn();

    if (user != null) {
      authenticateUser(user,token);
    }
    setState(() {
      isLoginPressed = false;
    });
  }

  void authenticateUser(FirebaseUser user,String token) {
    _authMethods.authenticateUser(user).then((isNewUser) {
      setState(() {
        isLoginPressed = false;
      });

      if (isNewUser) {
        _authMethods.addDataToDb(user,token).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}
