class ApiResponse<T> {
  Status status;
  T data;
  String message;
  bool get hasData => data != null;

  ApiResponse.idle(this.message) : status = Status.IDLE;
  ApiResponse.loading(this.message) : status = Status.LOADING;
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
  DONE,
  ERROR
}
