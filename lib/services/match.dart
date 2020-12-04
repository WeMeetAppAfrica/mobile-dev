import 'package:wemeet/utils/api.dart';

class MatchService {
  static Future getMatches() => api.get("backend-service/v1/swipe/matches");
}