import './common/paginationLinks.dart';
import './common/currency.dart';
import './common/status.dart';
import './common/money.dart';
import './common/cury.dart';
import './common/link.dart';
import './couponLines.dart';
import './itemLines.dart';
import 'dart:convert';

PaginatedCarts paginatedCartsFromJson(String str) => PaginatedCarts.fromJson(json.decode(str));

String paginatedCartsToJson(PaginatedCarts data) => json.encode(data.toJson());

class PaginatedCarts {
    PaginatedCarts({
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
    final EmbeddedCarts embedded;

    factory PaginatedCarts.fromJson(Map<String, dynamic> json) => PaginatedCarts(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedCarts.fromJson(json["_embedded"]),
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

class EmbeddedCarts {
    EmbeddedCarts({
        required this.couponLines,
    });

    final List<Cart> couponLines;

    factory EmbeddedCarts.fromJson(Map<String, dynamic> json) => EmbeddedCarts(
        couponLines: List<Cart>.from(json["carts"].map((x) => Cart.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "carts": List<dynamic>.from(couponLines.map((x) => x.toJson())),
    };
}

class Cart {
    Cart({
        required this.id,
        required this.active,
        required this.currency,
        required this.subTotal,
        required this.couponTotal,
        required this.saleDiscountTotal,
        required this.couponAndSaleDiscountTotal,
        required this.allowFreeDelivery,
        required this.deliveryFee,
        required this.grandTotal,
        required this.totalItems,
        required this.totalCoupons,
        required this.totalUniqueItems,
        required this.productsArrangement,
        required this.detectedChanges,
        required this.abandonedStatus,
        required this.instantCartId,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final Status active;
    final Currency currency;
    final Money subTotal;
    final Money couponTotal;
    final Money saleDiscountTotal;
    final Money couponAndSaleDiscountTotal;
    final Status allowFreeDelivery;
    final Money deliveryFee;
    final Money grandTotal;
    final int totalItems;
    final int totalCoupons;
    final int totalUniqueItems;
    final List<ProductsArrangement> productsArrangement;
    final List<dynamic> detectedChanges;
    final Status abandonedStatus;
    final int? instantCartId;
    final DateTime createdAt;
    final DateTime updatedAt;
    final CartAttributes attributes;
    final CartLinks links;
    final CartEmbedded embedded;

    factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["id"],
        active: Status.fromJson(json["active"]),
        currency: Currency.fromJson(json["currency"]),
        subTotal: Money.fromJson(json["sub_total"]),
        couponTotal: Money.fromJson(json["coupon_total"]),
        saleDiscountTotal: Money.fromJson(json["sale_discount_total"]),
        couponAndSaleDiscountTotal: Money.fromJson(json["coupon_and_sale_discount_total"]),
        allowFreeDelivery: Status.fromJson(json["allow_free_delivery"]),
        deliveryFee: Money.fromJson(json["delivery_fee"]),
        grandTotal: Money.fromJson(json["grand_total"]),
        totalItems: json["total_items"],
        totalCoupons: json["total_coupons"],
        totalUniqueItems: json["total_unique_items"],
        productsArrangement: List<ProductsArrangement>.from(json["products_arrangement"].map((x) => ProductsArrangement.fromJson(x))),
        detectedChanges: List<dynamic>.from(json["detected_changes"].map((x) => x)),
        abandonedStatus: Status.fromJson(json["abandoned_status"]),
        instantCartId: json["instant_cart_id"] == null ? null : json["instant_cart_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: CartAttributes.fromJson(json["_attributes"]),
        links: CartLinks.fromJson(json["_links"]),
        embedded: CartEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "active": active.toJson(),
        "currency": currency.toJson(),
        "sub_total": subTotal.toJson(),
        "coupon_total": couponTotal.toJson(),
        "sale_discount_total": saleDiscountTotal.toJson(),
        "coupon_and_sale_discount_total": couponAndSaleDiscountTotal.toJson(),
        "allow_free_delivery": allowFreeDelivery.toJson(),
        "delivery_fee": deliveryFee.toJson(),
        "grand_total": grandTotal.toJson(),
        "total_items": totalItems,
        "total_coupons": totalCoupons,
        "total_unique_items": totalUniqueItems,
        "products_arrangement": List<dynamic>.from(productsArrangement.map((x) => x.toJson())),
        "detected_changes": List<dynamic>.from(detectedChanges.map((x) => x)),
        "abandoned_status": abandonedStatus.toJson(),
        "instant_cart_id": instantCartId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class ProductsArrangement {
    ProductsArrangement({
        required this.id,
        required this.arrangement,
    });

    final int id;
    final int arrangement;

    factory ProductsArrangement.fromJson(Map<String, dynamic> json) => ProductsArrangement(
        id: json["id"],
        arrangement: json["arrangement"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "arrangement": arrangement,
    };
}

class CartAttributes {
    CartAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory CartAttributes.fromJson(Map<String, dynamic> json) => CartAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
    };
}

class CartLinks {
    CartLinks({
        required this.curies,
        required this.self,
        required this.bosRefresh,
        required this.bosReset,
    });

    final List<Cury> curies;
    final Link self;
    final Link bosRefresh;
    final Link bosReset;

    factory CartLinks.fromJson(Map<String, dynamic> json) => CartLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: Link.fromJson(json["self"]),
        bosRefresh: Link.fromJson(json["bos:refresh"]),
        bosReset: Link.fromJson(json["bos:reset"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:refresh": bosRefresh.toJson(),
        "bos:reset": bosReset.toJson(),
    };
}

class CartEmbedded {
    CartEmbedded({
        required this.couponLines,
        required this.itemLines,
    });

    final List<CouponLine> couponLines;
    final List<ItemLine> itemLines;

    factory CartEmbedded.fromJson(Map<String, dynamic> json) => CartEmbedded(
        couponLines: List<CouponLine>.from(json["coupon_lines"].map((x) => CouponLine.fromJson(x))),
        itemLines: List<ItemLine>.from(json["item_lines"].map((x) => ItemLine.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "coupon_lines": List<dynamic>.from(couponLines.map((x) => x.toJson())),
        "item_lines": List<dynamic>.from(itemLines.map((x) => x.toJson())),
    };
}