class LoginRequestModel {
  final String email;
  final String password;
  final String deviceName;

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.deviceName = 'Steriqore Mobile App',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'device_name': deviceName,
    };
  }
}
