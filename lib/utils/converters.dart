double ensureDouble(dynamic val){
  if(val is double){
    return val;
  }

  if (val is int){
    return val.toDouble();
  }

  if (val is String) {
    return double.tryParse(val) ?? 0.0;
  }

  return 0.0;
}

int ensureInt(dynamic val){
  if(val is int){
    return val;
  }

  if (val is double){
    return val.toInt();
  }

  if (val is String) {
    return int.tryParse(val) ?? 0;
  }

  return 0;
}

String ensureMp3(String val) {
  if(val == null || val.isEmpty) {
    return "";
  }

  if(val.length > 5) {
    List<String> ss = val.split(".");
    if(ss.isEmpty) {
      return val + ".mp3";
    }

    // make sure it is an audio file
    List<String> formats = ["mp3", "wav", "m3u"];
    if(!formats.contains(ss.last.toLowerCase())) {
      return val + ".mp3";
    }
  }

  return val;
}

bool isMp3 (String val) {
  if(val == null) {
    return false;
  }

  List<bool> matches = [];
  List<String> formats = ["mp3", "wav", "m3u"];

  List<String> ss = val.split(".");
  if(ss.isEmpty) {
    return false;
  }

  formats.forEach((i){
    if(i == ss.last.toLowerCase()) {
      matches.add(true);
    }
  });

  return matches.contains(true);
}