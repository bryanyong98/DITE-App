class OnDemandRequest {
  String onDemandId;
  String sliId;
  String uid;
  String hospital;
  String hospitalDepartment;
  bool emergency;
  bool onBehalf;
  String gender;
  String patientName;
  String note;
  String userProfilePicture;
  String status;

  OnDemandRequest(
      {this.onDemandId,
        this.sliId,
        this.uid,
        this.hospital,
        this.hospitalDepartment,
        this.emergency,
        this.onBehalf,
        this.gender,
        this.patientName,
        this.note,
        this.userProfilePicture,
        this.status});

  OnDemandRequest.fromJson(Map<String, dynamic> json) {
    onDemandId = json['on_demand_id'];
    sliId = json['sli_id'];
    uid = json['uid'];
    hospital = json['hospital'];
    hospitalDepartment = json['hospital_department'];
    emergency = json['emergency'];
    onBehalf = json['on_behalf'];
    gender = json['gender'];
    patientName = json['patient_name'];
    note = json['note'];
    userProfilePicture = json['user_profile_pic'] == 'test1' ? null : json['user_profile_pic'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['on_demand_id'] = this.onDemandId;
    data['sli_id'] = this.sliId;
    data['uid'] = this.uid;
    data['hospital'] = this.hospital;
    data['hospital_department'] = this.hospitalDepartment;
    data['emergency'] = this.emergency;
    data['on_behalf'] = this.onBehalf;
    data['gender'] = this.gender;
    data['patient_name'] = this.patientName;
    data['note'] = this.note;
    data['user_profile_pic'] = this.userProfilePicture;
    data['status'] = this.status;
    return data;
  }
}
