
class ChatItem {
  String chatroomId;
  String sliName;
  String userName;
  String userProfilePicture;
  String sliProfilePicture;

  ChatItem({this.chatroomId, this.sliName, this.userName, this.userProfilePicture, this.sliProfilePicture});

  ChatItem.fromJson(Map<String, dynamic> json) {
    chatroomId = json['chatroom_id'];
    sliName = json['sli_name'];
    userName = json['user_name'];
    userProfilePicture = json['user_profile_pic'] == 'test1' ? null : json['user_profile_pic'];
    sliProfilePicture = json['sli_profile_pic'] == 'test1' ? null : json['sli_profile_pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatroom_id'] = this.chatroomId;
    data['sli_name'] = this.sliName;
    data['user_name'] = this.userName;
    data['user_profile_pic'] = this.userProfilePicture;
    data['sli_profile_pic'] = this.sliProfilePicture;
    return data;
  }
}
