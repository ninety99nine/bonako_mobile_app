class Status {
    Status({
        required this.name,
        required this.status,
        required this.description,
    });

    final bool status;
    final String name;
    final String description;

    factory Status.fromJson(Map<String, dynamic> json) => Status(
        name: json["name"],
        status: json["status"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "status": status,
        "description": description,
    };
}