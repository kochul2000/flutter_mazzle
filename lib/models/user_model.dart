class UserData {
  final String mazzle_auth_token;
  final String firebase_auth_token;

  final String user_fcm_token;
  final String user_uid;
  final String user_cafe_nick;
  final int user_mazzle_cash;
  final int user_mazzle_point;

  UserData({
    this.mazzle_auth_token,
    this.firebase_auth_token,

    this.user_fcm_token,
    this.user_uid,
    this.user_cafe_nick,
    this.user_mazzle_cash,
    this.user_mazzle_point,
    }
  );

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      mazzle_auth_token: json['mazzle_auth_token'],
      firebase_auth_token: json['firebase_auth_token'],

      user_fcm_token: json['user']['fcm_token'],
      user_uid: json['user']['uid'],
      user_cafe_nick: json['user']['cafe_nick'],
      user_mazzle_cash: json['user']['mazzle_cash'],
      user_mazzle_point: json['user']['mazzle_point'],
    );
  }
}