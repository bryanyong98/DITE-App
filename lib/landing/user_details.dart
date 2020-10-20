import 'package:flutter/material.dart';
import 'package:heard/constants.dart';

class UserDetails {
  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  bool hasExperience = false;
  bool isFluent = false;
  bool termsAndConditions = false;
  bool isSLI = false;
  bool isLogin = false;
  Gender gender;
  TextEditingController age = TextEditingController();

  void disposeTexts() {
    fullName.dispose();
    phoneNumber.dispose();
    age.dispose();
  }

  void setUserType({bool isSLI}) {
    this.isSLI = isSLI;
  }

  void setIsLogin({bool isLogin}) {
    this.isLogin = isLogin;
  }
}
