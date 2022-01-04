class MobileNumber {
    MobileNumber({
        required this.number,
        required this.code,
        required this.numberWithCode,
        required this.callingNumber,
    });

    final String number;
    final String code;
    final String numberWithCode;
    final String callingNumber;

    factory MobileNumber.fromJson(Map<String, dynamic> json) => MobileNumber(
        number: json["number"],
        code: json["code"],
        numberWithCode: json["number_with_code"],
        callingNumber: json["calling_number"],
    );

    Map<String, dynamic> toJson() => {
        "number": number,
        "code": code,
        "number_with_code": numberWithCode,
        "calling_number": callingNumber,
    };
}