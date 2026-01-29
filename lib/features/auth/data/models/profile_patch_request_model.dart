class ProfilePatchRequestModel {
  final String? fullName;
  final String? username;
  final String? phoneNumber;
  final String? location;
  final String? profilePicture;

  const ProfilePatchRequestModel({
    this.fullName,
    this.username,
    this.phoneNumber,
    this.location,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (fullName != null) 'name': fullName,
      if (username != null) 'username': username,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (location != null) 'location': location,
      if (profilePicture != null) 'profilePicture': profilePicture,
    };
  }
}
