import 'package:wemeet/utils/api.dart';

// import 'package:wemeet/providers/data.dart';

class UserService {
  
  static Future getProfile() => api.get("backend-service/v1/user/profile");

  static Future postUpdateDevice(dynamic data) => api.post("backend-service/v1/auth/device", data: data);
}