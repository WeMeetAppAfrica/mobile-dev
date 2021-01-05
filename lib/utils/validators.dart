class PhoneValidator{
  static String validate(String value, [String message]) {

    print(value);

    RegExp _phone = new RegExp(r"^[0-9]{2,3}[0-9]{10,11}$");

    if(value.isEmpty) {
      return  message ?? "Please enter phone number" ;
    }

    if(value.length < 10) {
      return  'Phone no should be at least 10 digits' ;
    }

    if(!_phone.hasMatch(value)){
      return "Please enter a valid phone no e.g 2348012345678";
    }

    return null;
  } 
}

class EmailValidator{

  static String validate(String val, [String message]){

    RegExp _email = new RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\/[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");

    if(val.isEmpty){
      return message ?? "Email cannot be empty";
    }

    if(!_email.hasMatch(val.toLowerCase())){
      return "Please enter a valid email";
    }

    return null;
  }
    
}

class PasswordValidator {

  static String validate(String value, [String password]) {
    // RegExp _password = new RegExp(r"^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,15}$");

    if(value.isEmpty) {
      return  password ?? "Password cannot be empty";
    }
    if(value.length < 4) {
      return  'Password must be at least 4 characters long';
    }

    // if(!_password.hasMatch(value)){
    //   return "At least one upper and lower letter, one number and min of 8 characters";
    // }

    return null;
  }
}

class ConfirmPasswordValidator {
  
  static String validate(String value, String val) {
    if(value.isEmpty) {
      return  'Password field can not be empty';
    }
    if(value != val) {
      return  'Passwords do not match';
    }
    return null;
  }
}

class NotEmptyValidator {
  
  static String validate(String value, [String message]) {
    if(value.isEmpty) {
      return  message ?? "Field can not be empty";
    }
    return null;
  }
}