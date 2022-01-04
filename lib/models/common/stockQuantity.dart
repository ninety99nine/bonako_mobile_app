class StockQuantity {
    StockQuantity({
        required this.value,
        required this.description,
    });

    final int value;
    final String description;

    factory StockQuantity.fromJson(Map<String, dynamic> json) => StockQuantity(
        value: json["value"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "value": value,
        "description": description,
    };
}