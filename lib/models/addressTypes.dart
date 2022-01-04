import './common/paginationLinks.dart';
import './common/cury.dart';
import 'dart:convert';

PaginatedAddressTypes paginatedOrdersFromJson(String str) => PaginatedAddressTypes.fromJson(json.decode(str));

String paginatedOrdersToJson(PaginatedAddressTypes data) => json.encode(data.toJson());

class PaginatedAddressTypes {
    PaginatedAddressTypes({
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
    final EmbeddedAddressTypes embedded;

    factory PaginatedAddressTypes.fromJson(Map<String, dynamic> json) => PaginatedAddressTypes(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedAddressTypes.fromJson(json["_embedded"]),
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

class EmbeddedAddressTypes {
    EmbeddedAddressTypes({
        required this.paymentMethods,
    });

    final List<AddressType> paymentMethods;

    factory EmbeddedAddressTypes.fromJson(Map<String, dynamic> json) => EmbeddedAddressTypes(
        paymentMethods: List<AddressType>.from(json["address_types"].map((x) => AddressType.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "address_types": List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
    };
}

class AddressType {
    AddressType({
        required this.id,
        required this.name,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
    });

    final int id;
    final String name;
    final DateTime createdAt;
    final DateTime updatedAt;
    final AddressTypeAttributes attributes;
    final AddressTypeLinks links;

    factory AddressType.fromJson(Map<String, dynamic> json) => AddressType(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: AddressTypeAttributes.fromJson(json["_attributes"]),
        links: AddressTypeLinks.fromJson(json["_links"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
    };
}

class AddressTypeAttributes {
    AddressTypeAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory AddressTypeAttributes.fromJson(Map<String, dynamic> json) => AddressTypeAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
    };
}

class AddressTypeLinks {
    AddressTypeLinks({
        required this.curies,
    });

    final List<Cury> curies;

    factory AddressTypeLinks.fromJson(Map<String, dynamic> json) => AddressTypeLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x)))
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson()))
    };
}