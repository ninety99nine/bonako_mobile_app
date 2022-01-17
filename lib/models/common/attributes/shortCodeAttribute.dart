class ShortCodeAttribute {
    ShortCodeAttribute({
        required this.expiresAt,
        required this.updatedAt,
        required this.dialingCode,
    });

    final DateTime updatedAt;
    final DateTime expiresAt;
    final String dialingCode;

    factory ShortCodeAttribute.fromJson(Map<String, dynamic> json) => ShortCodeAttribute(
        expiresAt: DateTime.parse(json["expires_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        dialingCode: json["dialing_code"],
    );

    Map<String, dynamic> toJson() => {
        "expires_at": expiresAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "dialing_code": dialingCode,
    };
}