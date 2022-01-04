class Link {
    Link({
        required this.href,
        required this.title,
    });

    final String? href;
    final String title;

    factory Link.fromJson(Map<String, dynamic> json) => Link(
        href: json["href"] == null ? null : json["href"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "href": href == null ? null : href,
        "title": title,
    };
}