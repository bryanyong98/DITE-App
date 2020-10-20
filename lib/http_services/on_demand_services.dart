import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heard/api/on_demand_request.dart';
import 'package:heard/api/on_demand_status.dart';
import 'package:heard/home/on_demand/data_structure/OnDemandInputs.dart';
import 'package:http/http.dart' as http;

class OnDemandServices {

  Future<List<OnDemandRequest>> getAllRequests({String headerToken}) async {
    var response = await http
        .get('https://heard-project.herokuapp.com/ondemand/all', headers: {
      'Authorization': headerToken,
    });

    print('Get all On-demand request: ${response.statusCode}, body: ${response.body}');

    List<OnDemandRequest> onDemandRequests = [];
    if (response.statusCode == 200) {
      List<dynamic> requestsBody = jsonDecode(response.body);
      for (int i = 0; i < requestsBody.length; i++) {
        OnDemandRequest request = OnDemandRequest.fromJson(requestsBody[i]);
        onDemandRequests.add(request);
      }
    }

    return onDemandRequests;
  }

  Future<bool> acceptOnDemandRequest({String headerToken, String onDemandID}) async {
    var response = await http
        .post('https://heard-project.herokuapp.com/ondemand/accept', headers: {
      'Authorization': headerToken,
    }, body: {
      'on_demand_id': onDemandID,
    });

    print('Accept On-Demand Request: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    }
    else {
      return false;
    }
  }

  Future<OnDemandStatus> getOnDemandStatus({String headerToken, @required bool isSLI}) async {
    var response = await http.get('https://heard-project.herokuapp.com/ondemand/status?type=${isSLI ? 'sli' : 'user'}',
      headers: {
        'Authorization': headerToken,
      },
    );

    print('Get On-Demand Status: ${response.statusCode}, body: ${response.body}');

    OnDemandStatus onDemandStatus;
    if (response.statusCode == 200) {
      Map<String, dynamic> statusBody = jsonDecode(response.body);
      onDemandStatus = OnDemandStatus.fromJson(statusBody);
    }

    return onDemandStatus;
  }

  Future<String> makeOnDemandRequest({String headerToken, OnDemandInputs onDemandInputs}) async {
    var response = await http.post('https://heard-project.herokuapp.com/ondemand/request',
        headers: {
          'Authorization': headerToken,
        },
        body: {
          'hospital': onDemandInputs.hospital.text,
          'hospital_department': onDemandInputs.department.text,
          'emergency': onDemandInputs.isEmergency.toString(),
          'on_behalf': onDemandInputs.isBookingForOthers.toString(),
          'gender': onDemandInputs.genderType.toString().split('.').last,
          'patient_name': onDemandInputs.patientName.text,
          'note': onDemandInputs.noteToSLI.text,
        }
    );

    if (response.statusCode == 200) {
      print("On-Demand Request Success");
      return "Successful request";
    }
    else {
      print("On-Demand Request Failed");
      return "Failed request";
    }
  }

  Future<String> cancelOnDemandRequest({String headerToken}) async {
    var response = await http.post('https://heard-project.herokuapp.com/ondemand/cancel',
        headers: {
          'Authorization': headerToken,
        }
    );

    if (response.statusCode == 200) {
      print("On-Demand Cancel Success");
      return 'Successfully Cancelled Request';
    }
    else {
      print("On-Demand Cancel Failed");
      return 'Failed to Cancel Request';
    }
  }

  Future<String> endOnDemandRequest({String headerToken}) async {
    var response = await http.post('https://heard-project.herokuapp.com/ondemand/end',
        headers: {
          'Authorization': headerToken,
        }
    );

    if (response.statusCode == 200) {
      return 'Successfully Ended Request';
    }
    else {
      return 'Failed to End Request';
    }
  }
}
