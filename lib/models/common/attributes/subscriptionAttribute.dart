class SubscriptionAttribute {
    SubscriptionAttribute({
        required this.id,
        required this.subscriptionPlanId,
        required this.startAt,
        required this.endAt,
    });

    final int id;
    final int subscriptionPlanId;
    final DateTime startAt;
    final DateTime endAt;

    factory SubscriptionAttribute.fromJson(Map<String, dynamic> json) => SubscriptionAttribute(
        id: json["id"],
        subscriptionPlanId: json["subscription_plan_id"],
        startAt: DateTime.parse(json["start_at"]),
        endAt: DateTime.parse(json["end_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "subscription_plan_id": subscriptionPlanId,
        "start_at": startAt.toIso8601String(),
        "end_at": endAt.toIso8601String(),
    };
}