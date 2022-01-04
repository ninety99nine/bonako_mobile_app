import './common/attributes/subscriptionAttribute.dart';
import './common/attributes/shortCodeAttribute.dart';
import './common/paginationLinks.dart';
import './common/stockQuantity.dart';
import './common/status.dart';
import './common/cury.dart';
import './common/link.dart';
import 'dart:convert';
import 'carts.dart';

PaginatedInstantCarts paginatedInstantCartsFromJson(String str) => PaginatedInstantCarts.fromJson(json.decode(str));

String paginatedInstantCartsToJson(PaginatedInstantCarts data) => json.encode(data.toJson());

class PaginatedInstantCarts {
    PaginatedInstantCarts({
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
    final EmbeddedInstantCarts embedded;

    factory PaginatedInstantCarts.fromJson(Map<String, dynamic> json) => PaginatedInstantCarts(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedInstantCarts.fromJson(json["_embedded"]),
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

class EmbeddedInstantCarts {
    EmbeddedInstantCarts({
        required this.instantCarts,
    });

    final List<InstantCart> instantCarts;

    factory EmbeddedInstantCarts.fromJson(Map<String, dynamic> json) => EmbeddedInstantCarts(
        instantCarts: List<InstantCart>.from(json["instant_carts"].map((x) => InstantCart.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "instant_carts": List<dynamic>.from(instantCarts.map((x) => x.toJson())),
    };
}

class InstantCart {
    InstantCart({
        required this.id,
        required this.active,
        required this.name,
        required this.description,
        required this.locationId,
        required this.allowFreeDelivery,
        required this.allowStockManagement,
        required this.stockQuantity,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final Status active;
    final String name;
    final String? description;
    final int locationId;
    final Status allowFreeDelivery;
    final Status allowStockManagement;
    final StockQuantity stockQuantity;
    final DateTime createdAt;
    final DateTime updatedAt;
    final InstantCartStatus attributes;
    final InstantCartLinks links;
    final InstantCartEmbedded embedded;

    factory InstantCart.fromJson(Map<String, dynamic> json) => InstantCart(
        id: json["id"],
        active: Status.fromJson(json["active"]),
        name: json["name"],
        description: json["description"],
        locationId: json["location_id"],
        allowFreeDelivery: Status.fromJson(json["allow_free_delivery"]),
        allowStockManagement: Status.fromJson(json["allow_stock_management"]),
        stockQuantity: StockQuantity.fromJson(json["stock_quantity"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: InstantCartStatus.fromJson(json["_attributes"]),
        links: InstantCartLinks.fromJson(json["_links"]),
        embedded: InstantCartEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "active": active.toJson(),
        "name": name,
        "description": description,
        "location_id": locationId,
        "allow_free_delivery": allowFreeDelivery.toJson(),
        "allow_stock_management": allowStockManagement.toJson(),
        "stock_quantity": stockQuantity.toJson(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class InstantCartStatus {
    InstantCartStatus({
        required this.resourceType,
        this.visitShortCode,
        required this.hasVisitShortCode,
        this.paymentShortCode,
        required this.hasPaymentShortCode,
        this.subscription,
        required this.hasSubscription,
        required this.hasStock,
    });

    final String resourceType;
    final ShortCodeAttribute? visitShortCode;
    final bool hasVisitShortCode;
    final ShortCodeAttribute? paymentShortCode;
    final bool hasPaymentShortCode;
    final SubscriptionAttribute? subscription;
    final bool hasSubscription;
    final Status hasStock;

    factory InstantCartStatus.fromJson(Map<String, dynamic> json) => InstantCartStatus(
        resourceType: json["resource_type"],
        visitShortCode: json["visit_short_code"] == null ? null : ShortCodeAttribute.fromJson(json["visit_short_code"]),
        hasVisitShortCode: json["has_visit_short_code"],
        paymentShortCode: json["payment_short_code"] == null ? null : ShortCodeAttribute.fromJson(json["payment_short_code"]),
        hasPaymentShortCode: json["has_payment_short_code"],
        subscription: json["subscription"] == null ? null : SubscriptionAttribute.fromJson(json["subscription"]),
        hasSubscription: json["has_subscription"],
        hasStock: Status.fromJson(json["has_stock"]),
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
        "visit_short_code": visitShortCode == null ? null : visitShortCode!.toJson(),
        "has_visit_short_code": hasVisitShortCode,
        "payment_short_code": paymentShortCode!.toJson(),
        "has_payment_short_code": hasPaymentShortCode,
        "subscription": subscription == null ? null : subscription!.toJson(),
        "has_subscription": hasSubscription,
        "has_stock": hasStock.toJson(),
    };
}

class InstantCartEmbedded {
    InstantCartEmbedded({
        required this.cart,
    });

    final Cart cart;

    factory InstantCartEmbedded.fromJson(Map<String, dynamic> json) => InstantCartEmbedded(
        cart: Cart.fromJson(json["cart"]),
    );

    Map<String, dynamic> toJson() => {
        "cart": cart.toJson(),
    };
}

class InstantCartLinks {
    InstantCartLinks({
        required this.curies,
        required this.self,
        required this.bosLocation,
        required this.bosSubscribe,
        required this.bosGeneratePaymentShortcode,
    });

    final List<Cury> curies;
    final Link self;
    final Link bosLocation;
    final Link bosSubscribe;
    final Link bosGeneratePaymentShortcode;

    factory InstantCartLinks.fromJson(Map<String, dynamic> json) => InstantCartLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: Link.fromJson(json["self"]),
        bosLocation: Link.fromJson(json["bos:location"]),
        bosSubscribe: Link.fromJson(json["bos:subscribe"]),
        bosGeneratePaymentShortcode: Link.fromJson(json["bos:generate-payment-shortcode"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:location": bosLocation.toJson(),
        "bos:subscribe": bosSubscribe.toJson(),
        "bos:generate-payment-shortcode": bosGeneratePaymentShortcode.toJson(),
    };
}