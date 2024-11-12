class User {
  String? userName;
  String? token;
  List authenticated_features;

  User({
    required this.userName,
    required this.token,
    required this.authenticated_features,
  }) {}

  factory User.fromJsonFile(Map<String, dynamic> responseData) {
    return User(
      userName: responseData["value"]["userName"],
      token: responseData["value"]["token"],
      authenticated_features: responseData["value"]["authentication"],
    );
  }

  // sending data to our server
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'token': token,
      'authentication': authenticated_features,
    };
  }

  Map<String, dynamic> toJsonFile() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['userName'] = userName;
    data['token'] = token;
    data["authentication"] = authenticated_features;

    return data;
  }
}
