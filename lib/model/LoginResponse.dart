class LoginResponse {
  String token;
  String userEmail;
  String userNicename;
  String userDisplayName;
  String firstName;
  String lastName;

  //List<String> userRole;
  int userId;
  String avatar;
  String profileImage;

  LoginResponse(
      {this.token,
      this.userEmail,
      this.userNicename,
      this.userDisplayName,
      this.firstName,
      this.lastName,
      //  this.userRole,
      this.userId,
      this.avatar,
      this.profileImage});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    userEmail = json['user_email'];
    userNicename = json['user_nicename'];
    userDisplayName = json['user_display_name'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    userId = json['user_id'];
    avatar = json['avatar'];
    profileImage = json['profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['user_email'] = this.userEmail;
    data['user_nicename'] = this.userNicename;
    data['user_display_name'] = this.userDisplayName;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['user_id'] = this.userId;
    data['avatar'] = this.avatar;
    data['profile_image'] = this.profileImage;
    return data;
  }
}
