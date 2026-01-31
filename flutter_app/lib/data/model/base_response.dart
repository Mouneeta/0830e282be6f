class BaseResponse {
  BaseResponse({
    this.message,
    this.errorList,
  });

  String? message;
  List<String>? errorList;

  factory BaseResponse.fromJson(Map<String, dynamic> json) => BaseResponse(
    message: json["message"],
    errorList: List<String>.from(json["errors"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "errors": List<dynamic>.from(errorList!.map((x) => x)),
  };

  String getFormattedErrorMsg() {
    var msg = '';

    if (errorList == null || errorList!.isEmpty) {
      msg = message ?? '';
      return msg.trimRight();
    }

    errorList?.forEach((element) {
      msg = "$msg $element\n";
    });

    return msg.trimRight();
  }
}
