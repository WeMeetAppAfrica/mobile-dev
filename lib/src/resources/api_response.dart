class ApiResponse<T> {
  Status status;
  T data;
  String message;
  bool get hasData => data != null;

  ApiResponse.idle(this.message) : status = Status.IDLE;
  ApiResponse.addFB(this.message) : status = Status.ADDFB;
  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.proImageLoading(this.message) : status = Status.PROIMAGELOADING;
  ApiResponse.proImageDone(this.data) : status = Status.PROIMAGEDONE;
  ApiResponse.addImageLoading(this.message)
      : status = Status.ADDIMAGELOADING;
  ApiResponse.addImageDone(this.message, this.data)
      : status = Status.ADDIMAGEDONE;
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
  ApiResponse.proImageUpdateLoading(this.message)
      : status = Status.PROIMAGEUPDATELOADING;
  ApiResponse.proImageUpdateDone(this.data)
      : status = Status.PROIMAGEUPDATEDONE;
  ApiResponse.addImageUpdate1Loading(this.message)
      : status = Status.ADDIMAGEUPDATE1LOADING;
  ApiResponse.addImageUpdate1Done(this.data)
      : status = Status.ADDIMAGEUPDATE1DONE;
  ApiResponse.addImageUpdate2Loading(this.message)
      : status = Status.ADDIMAGEUPDATE2LOADING;
  ApiResponse.addImageUpdate2Done(this.data)
      : status = Status.ADDIMAGEUPDATE2DONE;
  ApiResponse.addImageUpdate3Loading(this.message)
      : status = Status.ADDIMAGEUPDATE3LOADING;
  ApiResponse.addImageUpdate3Done(this.data)
      : status = Status.ADDIMAGEUPDATE3DONE;
  ApiResponse.addImageUpdate4Loading(this.message)
      : status = Status.ADDIMAGEUPDATE4LOADING;
  ApiResponse.addImageUpdate4Done(this.data)
      : status = Status.ADDIMAGEUPDATE4DONE;
  ApiResponse.addImageUpdate5Loading(this.message)
      : status = Status.ADDIMAGEUPDATE5LOADING;
  ApiResponse.addImageUpdate5Done(this.data)
      : status = Status.ADDIMAGEUPDATE5DONE;
  ApiResponse.getProfile(this.data) : status = Status.GETPROFILE;
  ApiResponse.getEmailToken(this.data) : status = Status.GETEMAILTOKEN;
  ApiResponse.done(this.data) : status = Status.DONE;
  ApiResponse.activated(this.data) : status = Status.ACTIVATED;
  ApiResponse.error(this.message) : status = Status.ERROR;
  ApiResponse.logout(this.message) : status = Status.LOGOUT;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status {
  IDLE,
  ADDFB,
  LOADING,
  PROIMAGELOADING,
  PROIMAGEDONE,
  ADDIMAGEDONE,
  ADDIMAGELOADING,
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
  PROIMAGEUPDATELOADING,
  PROIMAGEUPDATEDONE,
  ADDIMAGEUPDATE1LOADING,
  ADDIMAGEUPDATE1DONE,
  ADDIMAGEUPDATE2LOADING,
  ADDIMAGEUPDATE2DONE,
  ADDIMAGEUPDATE3LOADING,
  ADDIMAGEUPDATE3DONE,
  ADDIMAGEUPDATE4LOADING,
  ADDIMAGEUPDATE4DONE,
  ADDIMAGEUPDATE5LOADING,
  ADDIMAGEUPDATE5DONE,
  GETPROFILE,
  DONE,
  ACTIVATED,
  ERROR,
  LOGOUT
}
