import 'package:flutter/material.dart';
import 'package:heard/api/user.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/home/navigation.dart';
import 'package:heard/http_services/sli_services.dart';
import 'package:heard/http_services/user_services.dart';
import 'package:heard/landing/login_page.dart';
import 'package:heard/landing/signup_page.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  bool showEmptyScreen = false;

  @override
  void initState() {
    super.initState();
    isSignedIn();
  }

  void isSignedIn() async {
    this.setState(() {
      showEmptyScreen = true;
    });

    SharedPreferences preferences = await SharedPreferences.getInstance();
    auth.User firebaseUser = auth.FirebaseAuth.instance.currentUser;
    String token = await AuthService.getToken();
    print('Firebase user: $firebaseUser');
    print('Shared Preference isSLI: ${preferences.containsKey('isSLI')}');

    if (firebaseUser != null) {
      User user;
      user = await SLIServices().getSLI(headerToken: token);

      if (user == null) {
        user = await UserServices().getUser(headerToken: token);
      }
      if (user != null) {
        if (!preferences.containsKey('isSLI')) {
          bool isSLI = user.experienced_medical ?? false;
          preferences.setBool('isSLI', isSLI);
        }
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              Navigation(isSLI: preferences.getBool('isSLI'))),
        );
      }
      else {
        AuthService().deleteAndSignOut(context: context);
      }
    }
    else {
      this.setState(() {
        showEmptyScreen = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: showEmptyScreen ? Container() : Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            Padding(
              padding: Paddings.startupMain,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: Paddings.vertical_15,
                    height: Dimensions.d_280,
                    child: Hero(
                      tag: 'appLogo',
                      child: Image(
                        image: AssetImage('images/diteLogo.png'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.d_15,
                  ),
                  UserButton(
                    text: 'Log Masuk',
                    textColour: Colours.black,
                    height: Dimensions.d_65,
                    color: Colours.grey,
                    onClick: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                  SizedBox(
                    height: Dimensions.d_15,
                  ),
                  Padding(
                    padding: EdgeInsets.all(Dimensions.d_10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            color: Colours.darkGrey,
                            thickness: Dimensions.d_1,
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            'Pengguna baru? Daftar sekarang!',
                            style: TextStyle(
                              color: Colours.darkGrey,
                              fontWeight: FontWeight.w500
                            ),
                            textAlign: TextAlign.center ,
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colours.darkGrey,
                            thickness: Dimensions.d_1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  UserButton(
                    text: 'Daftar Sebagai Pengguna',
                    height: Dimensions.buttonHeight,
                    color: Colours.blue,
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.d_5),
                    onClick: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                  ),
                  UserButton(
                    text: 'Daftar Sebagai JBIM',
                    height: Dimensions.buttonHeight,
                    color: Colours.orange,
                    onClick: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage(isSLI: true)),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
