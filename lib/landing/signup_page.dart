import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:heard/landing/user_details.dart';
import 'package:heard/landing/verification_page.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  final bool isSLI;
  SignUpPage({this.isSLI = false});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool showLoadingAnimation = false;
  String verificationId;
  bool codeSent = false;
  UserDetails userDetails;
  bool isButtonDisabled = true;
  bool isSLI;
  int age;

  @override
  void initState() {
    super.initState();
    userDetails = UserDetails();
    userDetails.setUserType(isSLI: widget.isSLI);
  }

  @override
  void dispose() {
    super.dispose();
    userDetails.disposeTexts();
    print('Disposed text editor');
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSLI == null) {
      isSLI = widget.isSLI;
    }
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: showLoadingAnimation,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colours.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              isSLI ? 'Pendaftaran JBIM' : 'Pendaftaran',
              style: GoogleFonts.lato(
                  fontSize: FontSizes.mainTitle,
                  fontWeight: FontWeight.bold,
                  color: Colours.black
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
          ),
          backgroundColor: Colours.white,
          body: ListView(
            children: <Widget>[
              Padding(
                padding: Paddings.signUpPage,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    InputField(
                      controller: userDetails.fullName,
                      labelText: 'Nama Penuh',
                      onChanged: (String text) {
                        setState(() {
                          checkAllInformationFilled(checkBox: userDetails.termsAndConditions);
                        });
                      },
                    ),
                    InputField(
                      hintText: '+60123456789',
                      controller: userDetails.phoneNumber,
                      labelText: 'Nombor Telefon',
                      keyboardType: TextInputType.phone,
                      onChanged: (String text) {
                        setState(() {
                          checkAllInformationFilled(checkBox: userDetails.termsAndConditions);
                        });
                      },
                    ),
                    isSLI ? SizedBox.shrink() : InputField(
                      hintText: '',
                      controller: userDetails.age,
                      labelText: 'Umur',
                      keyboardType: TextInputType.number,
                      onChanged: (String text) {
                        setState(() {
                          checkAllInformationFilled(checkBox: userDetails.termsAndConditions);
                        });
                      },
                    ),
                    SizedBox(height: Dimensions.d_15),
                    Padding(
                      padding: Paddings.vertical_5,
                      child: Text(
                        'Jantina',
                        style: TextStyle(
                            fontSize: FontSizes.normal,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          flex: 20,
                          child: RadioListTile(
                              title: Text(
                                'Lelaki',
                              ),
                              value: Gender.male,
                              groupValue: userDetails.gender,
                              onChanged: (Gender value) {
                                setState(() {
                                  userDetails.gender = value;
                                  checkAllInformationFilled(checkBox: userDetails.termsAndConditions);
                                });
                              }),
                        ),
                        Flexible(
                          flex: 26,
                          child: RadioListTile(
                            // dense: true,
                              title: Text(
                                'Perempuan',

                              ),
                              value: Gender.female,
                              groupValue: userDetails.gender,
                              onChanged: (Gender value) {
                                setState(() {
                                  userDetails.gender = value;
                                  checkAllInformationFilled(checkBox: userDetails.termsAndConditions);
                                });
                              }),
                        ),
                      ],
                    ),
                    isSLI
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: Dimensions.d_15,
                              ),
                              CheckBoxTile(
                                value: userDetails.hasExperience,
                                onChanged: (bool value) {
                                  setState(() {
                                    userDetails.hasExperience = value;
                                  });
                                },
                                text:
                                    'Saya berpengalaman dalam bidang perubatan﻿',
                              ),
                              CheckBoxTile(
                                value: userDetails.isFluent,
                                onChanged: (bool value) {
                                  setState(() {
                                    userDetails.isFluent = value;
                                  });
                                },
                                text: 'Saya fasih berbahasa Isyarat Malaysia',
                              ),
                            ],
                          )
                        : SizedBox(height: 0),
                    CheckBoxTile(
                      value: userDetails.termsAndConditions,
                      onChanged: (bool value) {
                        setState(() {
                          userDetails.termsAndConditions = value;
                          checkAllInformationFilled(checkBox: value);
                        });
                      },
                      text: 'Saya bersetuju dengan ',
                      textLink: 'Terma dan Syarat'
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: UserButton(
            text: 'Daftar Sekarang',
            color: isSLI ? Colours.orange : Colours.blue,
            padding: EdgeInsets.all(Dimensions.d_30),
            onClick: isButtonDisabled ? null : () {
              setState(() {
                showLoadingAnimation = true;
              });
              verifyPhone(userDetails.phoneNumber.text);
            },
          ),
        ),
      ),
    );
  }

  bool allFieldsFilled(bool isSLI) {
    bool fieldCheck = userDetails.phoneNumber.text.isNotEmpty &&
        userDetails.fullName.text.isNotEmpty &&
        userDetails.gender != null;

    return !isSLI
        ? fieldCheck &&
        userDetails.age.text.isNotEmpty
        : fieldCheck;
  }

  void checkAllInformationFilled({bool checkBox}) {
    if (checkBox == true && allFieldsFilled(isSLI) == true)
      isButtonDisabled = false;
    else
      isButtonDisabled = true;
  }

  void pushVerificationPage() {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                VerificationPage(verificationId: this.verificationId, userDetails: this.userDetails)));
  }

  Future<void> verifyPhone(phoneNo) async {
    final auth.PhoneVerificationCompleted verified = (auth.AuthCredential authResult) async {
    };

    final auth.PhoneVerificationFailed verificationFailed =
        (auth.FirebaseAuthException authException) {
      debugPrint('${authException.message}');
      popUpDialog(
          context: context,
          isSLI: widget.isSLI,
          touchToDismiss: false,
          header: 'Pengesahan',
          content: Text(
            'Nombor Telefon Anda Tidak Sah. Sila Isi Nombor Yang Betul.',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colours.darkGrey,
                fontSize: FontSizes.normal),
          ),
          onClick: () {
            setState(() {
              showLoadingAnimation = false;
            });
            Navigator.pop(context);
          }
      );
    };

    final auth.PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
      popUpDialog(
          context: context,
          isSLI: widget.isSLI,
          touchToDismiss: false,
          header: 'Pengesahan',
          content: Text(
            'Daftar berjaya! Sila klik Teruskan untuk menyerus ke halaman pengesahan.',
            textAlign: TextAlign.left,
            style: TextStyle(
                color: Colours.darkGrey,
                fontSize: FontSizes.normal),
          ),
          buttonText: 'Teruskan',
          onClick: () {
            pushVerificationPage();
          }
      );
    };

    final auth.PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
      this.codeSent = true;
    };

    await auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationFailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}
