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
