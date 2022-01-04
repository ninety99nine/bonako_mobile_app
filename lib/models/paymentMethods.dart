import './common/paginationLinks.dart';
import './common/cury.dart';
import 'dart:convert';

PaginatedPaymentMethods paginatedOrdersFromJson(String str) => PaginatedPaymentMethods.fromJson(json.decode(str));

String paginatedOrdersToJson(PaginatedPaymentMethods data) => json.encode(data.toJson());

class PaginatedPaymentMethods {
    PaginatedPaymentMethods({
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
    final EmbeddedPaymentMethods embedded;

    factory PaginatedPaymentMethods.fromJson(Map<String, dynamic> json) => PaginatedPaymentMethods(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedPaymentMethods.fromJson(json["_embedded"]),
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

class EmbeddedPaymentMethods {
    EmbeddedPaymentMethods({
        required this.paymentMethods,
    });

    final List<PaymentMethod> paymentMethods;

    factory EmbeddedPaymentMethods.fromJson(Map<String, dynamic> json) => EmbeddedPaymentMethods(
        paymentMethods: List<PaymentMethod>.from(json["payment_methods"].map((x) => PaymentMethod.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "payment_methods": List<dynamic>.from(paymentMethods.map((x) => x.toJson())),
    };
}

class PaymentMethod {
    PaymentMethod({
        required this.id,
        required this.name,
        required this.type,
        required this.description,
        required this.usedOnline,
        required this.usedOffline,
        required this.active,
        required this.attributes,
        required this.links,
    });

    final int id;
    final String name;
    final String type;
    final String description;
    final bool usedOnline;
    final bool usedOffline;
    final bool active;
    final PaymentMethodAttributes attributes;
    final PaymentMethodLinks links;

    factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        description: json["description"],
        usedOnline: json["used_online"],
        usedOffline: json["used_offline"],
        active: json["active"],
        attributes: PaymentMethodAttributes.fromJson(json["_attributes"]),
        links: PaymentMethodLinks.fromJson(json["_links"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "description": description,
        "used_online": usedOnline,
        "used_offline": usedOffline,
        "active": active,
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
    };
}

class PaymentMethodAttributes {
    PaymentMethodAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory PaymentMethodAttributes.fromJson(Map<String, dynamic> json) => PaymentMethodAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
    };
}

class PaymentMethodLinks {
    PaymentMethodLinks({
        required this.curies,
    });

    final List<Cury> curies;

    factory PaymentMethodLinks.fromJson(Map<String, dynamic> json) => PaymentMethodLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x)))
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson()))
    };
}