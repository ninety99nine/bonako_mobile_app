class Currency {
    Currency({
        required this.code,
        required this.symbol,
    });

    final String code;
    final String symbol;

    factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        code: json["code"],
        symbol: json["symbol"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "symbol": symbol,
    };
}