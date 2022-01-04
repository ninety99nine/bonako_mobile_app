import './common/paginationLinks.dart';
import './common/cury.dart';
import 'dart:convert';

PaginatedStatuses paginatedStatusesFromJson(String str) => PaginatedStatuses.fromJson(json.decode(str));

String paginatedStatusesToJson(PaginatedStatuses data) => json.encode(data.toJson());

class PaginatedStatuses {
    PaginatedStatuses({
        required this.links,
        required this.total,
        required this.count,
        required this.perPage,
        required this.currentPage,
        required this.totalPages,
        required this.embedded,
    });

    final PaginationLinks links;
    int count;
    final int total;
    int currentPage;
    final int perPage;
    final int totalPages;
    final EmbeddedStatuses embedded;

    factory PaginatedStatuses.fromJson(Map<String, dynamic> json) => PaginatedStatuses(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedStatuses.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "_links": links.toJson(),
        "total": total,
        "count": count,
        "per_page": perPage,
        "current_page": currentPage,
        "total_pages": totalPages,
        "_embedded": embedded.toJson(),
    };
}

class EmbeddedStatuses {
    EmbeddedStatuses({
        required this.statuses,
    });

    final List<StatusModel> statuses;

    factory EmbeddedStatuses.fromJson(Map<String, dynamic> json) => EmbeddedStatuses(
        statuses: List<StatusModel>.from(json["statuses"].map((x) => StatusModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "statuses": List<dynamic>.from(statuses.map((x) => x.toJson())),
    };
}

class StatusModel {
    StatusModel({
        required this.id,
        required this.name,
        required this.description,
        required this.attributes,
        required this.links,
    });

    final int id;
    final String name;
    final String description;
    final StatusAttributes attributes;
    final StatusLinks links;

    factory StatusModel.fromJson(Map<String, dynamic> json) => StatusModel(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        attributes: StatusAttributes.fromJson(json["_attributes"]),
        links: StatusLinks.fromJson(json["_links"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
    };
}

class StatusAttributes {
    StatusAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory StatusAttributes.fromJson(Map<String, dynamic> json) => StatusAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
    };
}

class StatusLinks {
    StatusLinks({
        required this.curies,
    });

    final List<Cury> curies;

    factory StatusLinks.fromJson(Map<String, dynamic> json) => StatusLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
    };
}