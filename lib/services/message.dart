import 'package:wemeet/utils/api.dart';

import 'package:wemeet/providers/data.dart';

class MessageService {
  static Future getChats() => api.get("messaging-service/v1/chats", reqToken: DataProvider().messageToken);
}