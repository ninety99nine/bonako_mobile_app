class StatusType {
    StatusType({
        required this.name,
        required this.type,
        required this.status,
        required this.description,
    });

    final bool status;
    final String type;
    final String name;
    final String description;

    factory StatusType.fromJson(Map<String, dynamic> json) => StatusType(
        name: json["name"],
        type: json["type"],
        status: json["status"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "type": type,
        "status": status,
        "description": description,
    };
}