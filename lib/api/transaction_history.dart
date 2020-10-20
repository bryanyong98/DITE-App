class TransactionHistory {
  String id;
  String type;
  String counterpartName;
  String profilePicture;
  String date;
  String time;
  String status;

  TransactionHistory(
      {this.id,
        this.type,
        this.counterpartName,
        this.date,
        this.time,
        this.profilePicture,
        this.status});

  TransactionHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    counterpartName = json['counterpart_name'];
    profilePicture = json['counterpart_profile_pic'] == 'test1' ? null : json['counterpart_profile_pic'];
    date = json['date'];
    time = json['time'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['counterpart_name'] = this.counterpartName;
    data['counterpart_profile_pic'] = this.profilePicture;
    data['date'] = this.date;
    data['time'] = this.time;
    data['status'] = this.status;
    return data;
  }
}
