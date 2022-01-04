class Type {
    Type({
        required this.type,
        required this.name,
        required this.description,
    });

    final String type;
    final String name;
    final String description;

    factory Type.fromJson(Map<String, dynamic> json) => Type(
        type: json["type"],
        name: json["name"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "name": name,
        "description": description,
    };
}