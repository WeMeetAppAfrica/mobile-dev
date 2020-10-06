class ApiResponse<T> {
  Status status;
  T data;
  String message;
  bool get hasData => data != null;

  ApiResponse.idle(this.message) : status = Status.IDLE;
  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.proImageLoading(this.message) : status = Status.PROIMAGELOADING;
  ApiResponse.proImageDone(this.data) : status = Status.PROIMAGEDONE;
  ApiResponse.addImage1Loading(this.message) : status = Status.ADDIMAGE1LOADING;
  ApiResponse.addImage1Done(this.data) : status = Status.ADDIMAGE1DONE;
  ApiResponse.addImage2Loading(this.message) : status = Status.ADDIMAGE2LOADING;
  ApiResponse.addImage2Done(this.data) : status = Status.ADDIMAGE2DONE;
  ApiResponse.addImage3Loading(this.message) : status = Status.ADDIMAGE3LOADING;
  ApiResponse.addImage3Done(this.data) : status = Status.ADDIMAGE3DONE;
  ApiResponse.addImage4Loading(this.message) : status = Status.ADDIMAGE4LOADING;
  ApiResponse.addImage4Done(this.data) : status = Status.ADDIMAGE4DONE;
  ApiResponse.addImage5Loading(this.message) : status = Status.ADDIMAGE5LOADING;
  ApiResponse.addImage5Done(this.data) : status = Status.ADDIMAGE5DONE;
  ApiResponse.getProfile(this.data) : status = Status.GETPROFILE;
  ApiResponse.getEmailToken(this.data) : status = Status.GETEMAILTOKEN;
  ApiResponse.done(this.data) : status = Status.DONE;
  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status {
  IDLE,
  LOADING,
  PROIMAGELOADING,
  PROIMAGEDONE,
  ADDIMAGE1LOADING,
  ADDIMAGE1DONE,
  ADDIMAGE2LOADING,
  ADDIMAGE2DONE,
  ADDIMAGE3LOADING,
  ADDIMAGE3DONE,
  GETEMAILTOKEN,
  ADDIMAGE4LOADING,
  ADDIMAGE4DONE,
  ADDIMAGE5LOADING,
  ADDIMAGE5DONE,
  GETPROFILE,
  DONE,
  ERROR
}
