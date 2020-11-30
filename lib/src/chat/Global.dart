
import 'SocketUtils.dart';

class G {
  // Socket
  static SocketUtils socketUtils;
  static initSocket() {
    if (null == socketUtils) {
      socketUtils = SocketUtils();
    }
  }
}
