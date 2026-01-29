class LocalSessionModel {
  final bool isLoggedIn;
  final String? userId;
  final String? email;
  final String? username;

  const LocalSessionModel({
    required this.isLoggedIn,
    this.userId,
    this.email,
    this.username,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isLoggedIn': isLoggedIn,
      'userId': userId,
      'email': email,
      'username': username,
    };
  }

  factory LocalSessionModel.fromJson(Map<String, dynamic> json) {
    return LocalSessionModel(
      isLoggedIn: json['isLoggedIn'] == true,
      userId: json['userId']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
    );
  }
}
