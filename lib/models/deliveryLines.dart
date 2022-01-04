import './common/paginationLinks.dart';
import './addressTypes.dart';
import './common/cury.dart';
import 'dart:convert';

PaginatedDeliveryLines paginatedDeliveryLinesFromJson(String str) => PaginatedDeliveryLines.fromJson(json.decode(str));

String paginatedDeliveryLinesToJson(PaginatedDeliveryLines data) => json.encode(data.toJson());

class PaginatedDeliveryLines {
    PaginatedDeliveryLines({
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
    final PaginatedDeliveryLinesEmbedded embedded;

    factory PaginatedDeliveryLines.fromJson(Map<String, dynamic> json) => PaginatedDeliveryLines(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: PaginatedDeliveryLinesEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "_links": links.toJson(),
        "total": total,
        "count": count,
        "per_page": perPage,
        "total_pages": totalPages,
        "current_page": currentPage,
        "_embedded": embedded.toJson(),
    };
}

class PaginatedDeliveryLinesEmbedded {
    PaginatedDeliveryLinesEmbedded({
        required this.couponLines,
    });

    final List<DeliveryLine> couponLines;

    factory PaginatedDeliveryLinesEmbedded.fromJson(Map<String, dynamic> json) => PaginatedDeliveryLinesEmbedded(
        couponLines: List<DeliveryLine>.from(json["delivery_lines"].map((x) => DeliveryLine.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "delivery_lines": List<dynamic>.from(couponLines.map((x) => x.toJson())),
    };
}

class DeliveryLine {
    DeliveryLine({
        required this.id,
        required this.name,
        required this.mobileNumber,
        required this.physicalAddress,
        required this.deliveryType,
        required this.day,
        required this.time,
        required this.destination,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final String mobileNumber;
    final String physicalAddress;
    final String deliveryType;
    final String day;
    final String time;
    final String destination;
    final DateTime createdAt;
    final DateTime updatedAt;
    final DeliveryLineAttributes attributes;
    final AddressTypeLinks links;
    final DeliveryLineEmbedded embedded;

    factory DeliveryLine.fromJson(Map<String, dynamic> json) => DeliveryLine(
        id: json["id"],
        name: json["name"],
        mobileNumber: json["mobile_number"],
        physicalAddress: json["physical_address"],
        deliveryType: json["delivery_type"],
        day: json["day"],
        time: json["time"],
        destination: json["destination"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: DeliveryLineAttributes.fromJson(json["_attributes"]),
        links: AddressTypeLinks.fromJson(json["_links"]),
        embedded: DeliveryLineEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mobile_number": mobileNumber,
        "physical_address": physicalAddress,
        "delivery_type": deliveryType,
        "day": day,
        "time": time,
        "destination": destination,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class DeliveryLineAttributes {
    DeliveryLineAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory DeliveryLineAttributes.fromJson(Map<String, dynamic> json) => DeliveryLineAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
    };
}

class DeliveryLineLinks {
    DeliveryLineLinks({
        required this.curies,
    });

    final List<Cury> curies;

    factory DeliveryLineLinks.fromJson(Map<String, dynamic> json) => DeliveryLineLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
    };
}

class DeliveryLineEmbedded {
    DeliveryLineEmbedded({
        required this.addressType,
    });

    final AddressType addressType;

    factory DeliveryLineEmbedded.fromJson(Map<String, dynamic> json) => DeliveryLineEmbedded(
        addressType: AddressType.fromJson(json["address_type"]),
    );

    Map<String, dynamic> toJson() => {
        "address_type": addressType.toJson(),
    };
}