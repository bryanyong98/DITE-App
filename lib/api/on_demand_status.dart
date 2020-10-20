class OnDemandStatus {
  String status;
  Details details;

  OnDemandStatus({this.status, this.details});

  OnDemandStatus.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    details =
    json['details'] != null ? new Details.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.details != null) {
      data['details'] = this.details.toJson();
    }
    return data;
  }
}

class Details {
  String uid;
  String userName;
  String userPhone;
  String onDemandId;
  String hospital;
  String hospitalDepartment;
  bool emergency;
  bool onBehalf;
  String userProfilePicture;
  String patientName;
  String note;
  String requestedAt;
  String sliID;
  String sliName;
  String sliGender;
  String sliPhone;
  String sliDesc;
  String sliProfilePicture;


  Details(
      {this.uid,
        this.userName,
        this.userPhone,
        this.onDemandId,
        this.hospital,
        this.hospitalDepartment,
        this.emergency,
        this.onBehalf,
        this.userProfilePicture,
        this.patientName,
        this.note,
        this.requestedAt,
        this.sliID,
        this.sliName,
        this.sliGender,
        this.sliPhone,
        this.sliDesc,
        this.sliProfilePicture
      });

  Details.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    userName = json['user_name'];
    userPhone = json['user_phone'];
    onDemandId = json['on_demand_id'];
    hospital = json['hospital'];
    hospitalDepartment = json['hospital_department'];
    emergency = json['emergency'];
    onBehalf = json['on_behalf'];
    patientName = json['patient_name'];
    note = json['note'];
    requestedAt = json['requested_at'];
    userProfilePicture = json['user_profile_pic'] == 'test1' ? null : json['user_profile_pic'];
    // sli details
    sliID = json['sli_id'];
    sliName = json['sli_name'];
    sliGender = json['sli_gender'];
    sliPhone = json['sli_phone'];
    sliDesc = json['sli_desc'];
    sliProfilePicture = json['sli_profile_pic'] == 'test1' ? null : json['sli_profile_pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['user_name'] = this.userName;
    data['user_phone'] = this.userPhone;
    data['on_demand_id'] = this.onDemandId;
    data['hospital'] = this.hospital;
    data['hospital_department'] = this.hospitalDepartment;
    data['emergency'] = this.emergency;
    data['on_behalf'] = this.onBehalf;
    data['user_profile_pic'] = this.userProfilePicture;
    data['patient_name'] = this.patientName;
    data['note'] = this.note;
    data['requested_at'] = this.requestedAt;
    data['sli_id'] = this.sliID;
    data['sli_name'] = this.sliName;
    data['sli_gender'] = this.sliGender;
    data['sli_phone'] = this.sliPhone;
    data['sli_desc'] = this.sliDesc;
    data['sli_profile_pic'] = this.sliProfilePicture;
    return data;
  }
}
