class BookingRequest {
  String bookingId;
  String uid;
  String userName;
  String sliName;
  String sliId;
  String date;
  String time;
  String notes;
  String status;
  String hospitalName;
  String userProfilePicture;
  String createdAt;
  String updatedAt;

  BookingRequest(
      {this.bookingId,
        this.uid,
        this.userName,
        this.sliName,
        this.sliId,
        this.date,
        this.time,
        this.notes,
        this.status,
        this.hospitalName,
        this.userProfilePicture,
        this.createdAt,
        this.updatedAt});

  BookingRequest.fromJson(Map<String, dynamic> json) {
    bookingId = json['booking_id'];
    uid = json['uid'];
    userName = json['user_name'];
    sliName = json['sli_name'];
    sliId = json['sli_id'];
    date = json['date'].toString().substring(0, 10); // get date only
    time = json['time'].toString().substring(0, 5); // get hour & minute only
    formatDateTime(); // format time to have am and pm displayed, and date
    userProfilePicture = json['user_profile_pic'] == 'test1' ? null : json['user_profile_pic'];
    notes = json['notes'];
    status = json['status'];
    hospitalName = json['hospital_name'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['booking_id'] = this.bookingId;
    data['uid'] = this.uid;
    data['user_name'] = this.userName;
    data['sli_name'] = this.sliName;
    data['sli_id'] = this.sliId;
    data['date'] = this.date;
    data['time'] = this.time;
    data['notes'] = this.notes;
    data['status'] = this.status;
    data['hospital_name'] = this.hospitalName;
    data['user_profile_pic'] = this.userProfilePicture;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }

  void formatDateTime() {
    if (time != null) {
      String hour = time.split(':')[0];
      bool isAM = true;
      if (int.parse(hour) > 12) {
        hour = (int.parse(hour) - 12).toString();
        isAM = false;
      }
      time = hour + time.substring(2) + '${isAM ? 'am' : 'pm'}';
    }
    if (date != null) {
      // before: 2020-09-07
      // after: 07-09-2020
      date = date.split('-').reversed.join('-');
    }
  }
}
