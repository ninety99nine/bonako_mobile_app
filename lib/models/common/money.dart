class Money {
    Money({
        required this.currencyMoney,
        required this.money,
        required this.amount,
    });

    final String currencyMoney;
    final String money;
    final String amount;

    factory Money.fromJson(Map<String, dynamic> json) => Money(
        currencyMoney: json["currency_money"],
        money: json["money"],
        amount: json["amount"].toString(),
    );

    Map<String, dynamic> toJson() => {
        "currency_money": currencyMoney,
        "money": money,
        "amount": amount,
    };
}