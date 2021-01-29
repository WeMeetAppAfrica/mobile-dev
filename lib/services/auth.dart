import 'package:wemeet/utils/api.dart';

class AuthService {

  static Future postLogin(dynamic body) => api.post("backend-service/v1/auth/login", data: body);

  static Future postRegister(dynamic body) => api.post("backend-service/v1/auth/register", data: body);

  static Future postForgotPassword(dynamic body) => api.post("backend-service/v1/auth/register", data: body);

  static Future postResetPassword(dynamic body) => api.post("backend-service/v1/auth/register", data: body);
}