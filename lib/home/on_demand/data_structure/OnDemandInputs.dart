import 'package:flutter/cupertino.dart';
import 'package:heard/constants.dart';

class OnDemandInputs {
  TextEditingController hospital = TextEditingController();
  TextEditingController department = TextEditingController();
  TextEditingController patientName = TextEditingController();
  TextEditingController noteToSLI = TextEditingController();
  bool isEmergency = false;
  bool isBookingForOthers = false;
  Gender genderType;

  void disposeTexts() {
    hospital.dispose();
    department.dispose();
    patientName.dispose();
    noteToSLI.dispose();
  }

  void reset() {
    hospital.clear();
    department.clear();
    patientName.clear();
    noteToSLI.clear();
    isEmergency = false;
    isBookingForOthers = false;
    genderType = null;
  }
}