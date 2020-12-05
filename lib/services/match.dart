import 'package:wemeet/utils/api.dart';

class MatchService {
  static Future getMatches() => api.get("backend-service/v1/swipe/matches");
  static Future getSwipes() => api.get("backend-service/v1/swipe/suggest?locationFilter=false");
}