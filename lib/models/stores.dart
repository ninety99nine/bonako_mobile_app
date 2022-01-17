import 'common/attributes/subscriptionAttribute.dart';
import 'common/attributes/shortCodeAttribute.dart';
import './common/paginationLinks.dart';
import './common/status.dart';
import './common/link.dart';
import './common/cury.dart';
import 'dart:convert';

PaginatedStores paginatedStoresFromJson(String str) => PaginatedStores.fromJson(json.decode(str));

String paginatedStoresToJson(PaginatedStores data) => json.encode(data.toJson());

class PaginatedStores {
    PaginatedStores({
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
    final EmbeddedStores embedded;

    factory PaginatedStores.fromJson(Map<String, dynamic> json) => PaginatedStores(
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        embedded: EmbeddedStores.fromJson(json["_embedded"]),
        perPage: int.parse(json["per_page"].toString()),
        links: PaginationLinks.fromJson(json["_links"]),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
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

class EmbeddedStores {
    EmbeddedStores({
        required this.stores,
    });

    final List<Store> stores;

    factory EmbeddedStores.fromJson(Map<String, dynamic> json) => EmbeddedStores(
        stores: List<Store>.from(json["stores"].map((x) => Store.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "stores": List<dynamic>.from(stores.map((x) => x.toJson())),
    };
}

class Store {
    Store({
        required this.id,
        required this.name,
        required this.online,
        required this.offlineMessage,
        required this.allowSendingMerchantSms,
        required this.hexColor,
        required this.isFavourite,
        required this.totalFavouriteLocations,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final Status online;
    final dynamic offlineMessage;
    final bool allowSendingMerchantSms;
    final String hexColor;
    final bool isFavourite;
    final int totalFavouriteLocations;
    final DateTime createdAt;
    final DateTime updatedAt;
    final StoreAttributes attributes;
    final StoreLinks links;
    final List<dynamic> embedded;

    factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json["id"],
        name: json["name"],
        online: Status.fromJson(json["online"]),
        offlineMessage: json["offline_message"],
        allowSendingMerchantSms: json["allow_sending_merchant_sms"],
        hexColor: json["hex_color"],
        isFavourite: json["is_favourite"],
        totalFavouriteLocations: json["total_favourite_locations"] ?? 0,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: StoreAttributes.fromJson(json["_attributes"]),
        links: StoreLinks.fromJson(json["_links"]),
        embedded: List<dynamic>.from(json["_embedded"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "online": online.toJson(),
        "offline_message": offlineMessage,
        "allow_sending_merchant_sms": allowSendingMerchantSms,
        "hex_color": hexColor,
        "is_favourite": isFavourite,
        "total_favourite_locations": totalFavouriteLocations,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": List<dynamic>.from(embedded.map((x) => x)),
    };
}

class StoreAttributes {
    StoreAttributes({
        required this.resourceType,
        this.visitShortCode,
        required this.hasVisitShortCode,
        this.paymentShortCode,
        required this.hasPaymentShortCode,
        this.subscription,
        required this.hasSubscription,
    });

    final String resourceType;
    final ShortCodeAttribute? visitShortCode;
    final bool hasVisitShortCode;
    final ShortCodeAttribute? paymentShortCode;
    final bool hasPaymentShortCode;
    final SubscriptionAttribute? subscription;
    final bool hasSubscription;

    factory StoreAttributes.fromJson(Map<String, dynamic> json) => StoreAttributes(
        resourceType: json["resource_type"],
        visitShortCode: json["visit_short_code"] == null ? null : ShortCodeAttribute.fromJson(json["visit_short_code"]),
        hasVisitShortCode: json["has_visit_short_code"],
        paymentShortCode: json["payment_short_code"] == null ? null : ShortCodeAttribute.fromJson(json["payment_short_code"]),
        hasPaymentShortCode: json["has_payment_short_code"],
        subscription: json["subscription"] == null ? null : SubscriptionAttribute.fromJson(json["subscription"]),
        hasSubscription: json["has_subscription"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
        "visit_short_code": visitShortCode == null ? null : visitShortCode!.toJson(),
        "has_visit_short_code": hasVisitShortCode,
        "payment_short_code": paymentShortCode == null ? null : paymentShortCode!.toJson(),
        "has_payment_short_code": hasPaymentShortCode,
        "subscription": subscription == null ? null : subscription!.toJson(),
        "has_subscription": hasSubscription,
    };
}

class StoreLinks {
    StoreLinks({
        required this.curies,
        required this.self,
        required this.bosMyStoreLocations,
        required this.bosMyStoreLocation,
        required this.bosLocations,
        required this.bosSubscribe,
        required this.bosGeneratePaymentShortcode,
    });

    final List<Cury> curies;
    final Link self;
    final Link bosMyStoreLocations;
    final Link bosMyStoreLocation;
    final Link bosLocations;
    final Link bosSubscribe;
    final Link bosGeneratePaymentShortcode;

    factory StoreLinks.fromJson(Map<String, dynamic> json) => StoreLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: Link.fromJson(json["self"]),
        bosMyStoreLocations: Link.fromJson(json["bos:my-store-locations"]),
        bosMyStoreLocation: Link.fromJson(json["bos:my-store-default-location"]),
        bosLocations: Link.fromJson(json["bos:locations"]),
        bosSubscribe: Link.fromJson(json["bos:subscribe"]),
        bosGeneratePaymentShortcode: Link.fromJson(json["bos:generate-payment-shortcode"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:my-store-locations": bosMyStoreLocations.toJson(),
        "bos:my-store-default-location": bosMyStoreLocation.toJson(),
        "bos:locations": bosLocations.toJson(),
        "bos:subscribe": bosSubscribe.toJson(),
        "bos:generate-payment-shortcode": bosGeneratePaymentShortcode.toJson(),
    };
}