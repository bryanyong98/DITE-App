import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/landing/user_details.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationPage extends StatefulWidget {
  final String verificationId;
  final UserDetails userDetails;
  VerificationPage({Key key, @required this.verificationId, this.userDetails})
      : super(key: key);

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  TextEditingController verificationNumberController = TextEditingController();
  bool isButtonDisabled = true;

  @override
  void dispose() {
    super.dispose();
    verificationNumberController.dispose();
    print('Disposed text editor on verification page');
  }

  void showSmsCodeError() {
    popUpDialog(
        context: context,
        isSLI: widget.userDetails.isSLI,
        touchToDismiss: false,
        header: 'Pengesahan',
        content: Text(
          'Kod SMS Anda Tidak Sah. Sila Isi Kod Yang Betul.',
          textAlign: TextAlign.left,
          style: TextStyle(
              color: Colours.darkGrey,
              fontSize: FontSizes.normal),
        ),
        onClick: () {
          Navigator.pop(context);
        }
    );
  }

  void showWrongLoginError() {
    popUpDialog(
        context: context,
        isSLI: widget.userDetails.isSLI,
        touchToDismiss: false,
        header: 'Amaran',
        content: Text(
          'Anda telah memilih jenis Log Masuk yang salah. Sila cuba lagi.',
          textAlign: TextAlign.left,
          style: TextStyle(
              color: Colours.darkGrey,
              fontSize: FontSizes.normal),
        ),
        onClick: () {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
    );
  }

  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colours.white,
            appBar: AppBar(
              backgroundColor: Colours.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              title: Text(
                'Pengesahan Akaun',
                style: GoogleFonts.lato(
                    fontSize: FontSizes.mainTitle,
                    fontWeight: FontWeight.bold,
                    color: Colours.black),
              ),
              centerTitle: true,
              elevation: 0.0,
            ),
            body: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                Padding(
                    padding: Paddings.signUpPage,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: Dimensions.d_65),
                        Text(
                          "Masukkan kod dihantar melalui SMS",
                          style: TextStyle(fontSize: FontSizes.buttonText),
                        ),
                        InputField(
                          controller: verificationNumberController,
                          labelText: "Kod Anda",
                          keyboardType: TextInputType.phone,
                          isShortInput: true,
                          isPassword: true,
                          onChanged: (String text) {
                            setState(() {
                              if (verificationNumberController.text.length == 6)
                                isButtonDisabled = false;
                              else
                                isButtonDisabled = true;
                            });
                          },
                        ),
                        UserButton(
                          text: 'Teruskan',
                          color: widget.userDetails.isSLI ? Colours.orange : Colours.blue,
                          onClick: isButtonDisabled ? null : () async {
                            showLoadingAnimation(context: context);
                            String token = await AuthService().signInWithOTP(
                                context: context,
                                userDetails: widget.userDetails,
                                smsCode: verificationNumberController.text,
                                verId: widget.verificationId);

                            if (token != null) {
                              if (token == 'wrongLogin') {
                                showWrongLoginError();
                              }
                              else {
                                SharedPreferences preferences = await SharedPreferences
                                    .getInstance();
                                preferences.setBool('isSLI',
                                    widget.userDetails.isSLI);
                                print('preference for isSLI: ${preferences
                                    .getBool('isSLI')}');
                              }
                            }
                            else {
                              Navigator.pop(context);
                              showSmsCodeError();
                            }
                          },
                        ),
                      ],
                    )),
              ],
            )));
  }
}
