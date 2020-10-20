import 'dart:convert';
import 'dart:io';
import 'package:heard/api/user.dart';
import 'package:heard/landing/user_details.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class SLIServices {

  Future<User> getSLI({String headerToken}) async {
    var response = await http
        .get('https://heard-project.herokuapp.com/sli/me', headers: {
      'Authorization': headerToken,
    });

    print('Get SLI response: ${response.statusCode}, body: ${response.body}');

    User sli;
    if (response.statusCode == 200) {
      Map<String, dynamic> sliBody = jsonDecode(response.body);
      sli = User.fromJson(sliBody);
    }

    return sli;
  }

  Future<void> createSLI({String headerToken, UserDetails sliDetails}) async {
    var response = await http
        .post('https://heard-project.herokuapp.com/sli/create', headers: {
      'Authorization': headerToken,
    }, body: {
      'name': sliDetails.fullName.text,
      'phone_no': sliDetails.phoneNumber.text,
      'profile_pic': 'test1',
      'gender': sliDetails.gender.toString().split('.').last,
      'description': 'test1',
      'experienced_medical': sliDetails.hasExperience.toString(),
      'experienced_bim': sliDetails.isFluent.toString(),
    });
    print('Create SLI response: ${response.statusCode}, body: ${response.body}');
  }

  Future<void> editSLI({String headerToken, String key, dynamic value}) async {
    var response = await http
        .post('https://heard-project.herokuapp.com/sli/edit', headers: {
      'Authorization': headerToken,
    }, body: {
      key: value
    });

    print('Edit SLI response: ${response.statusCode}, body: ${response.body}');
  }

  Future<void> uploadProfilePicture({String headerToken, File image}) async {
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        image.path,
      ),
    });

    Dio dio = Dio();
    var response = await dio.post('https://heard-project.herokuapp.com/sli/profile_pic',
      data: formData,
      options: Options(
        headers: {
          'Authorization': headerToken, // set content-length
        },
      ),);

    print('SLI Upload Profile Picture: ${response.statusCode}, body: ${response.data}');
  }

  Future<bool> doesSLIExist({String headerToken}) async {
    var response = await http
        .get('https://heard-project.herokuapp.com/sli/exists', headers: {
      'Authorization': headerToken,
    });

    print('Does SLI Exists response: ${response.statusCode}, body: ${response.body}');

    Map<String, dynamic> sliBody = jsonDecode(response.body);
    return sliBody['exists'];
  }

  Future<void> deleteSLI({String headerToken, String phoneNumber}) async {
    var response = await http
        .post('https://heard-project.herokuapp.com/sli/delete', headers: {
      'Authorization': headerToken,
    }, body: {
      'phone': phoneNumber
    });

    print('Delete SLI response: ${response.statusCode}, body: ${response.body}');
  }
}