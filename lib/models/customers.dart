import './common/paginationLinks.dart';
import './common/money.dart';
import './common/link.dart';
import './common/cury.dart';
import './users.dart';
import 'dart:convert';

PaginatedCustomers paginatedCustomersFromJson(String str) => PaginatedCustomers.fromJson(json.decode(str));

String paginatedCustomersToJson(PaginatedCustomers data) => json.encode(data.toJson());

class PaginatedCustomers {
    PaginatedCustomers({
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
    final EmbeddedCustomers embedded;

    factory PaginatedCustomers.fromJson(Map<String, dynamic> json) => PaginatedCustomers(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedCustomers.fromJson(json["_embedded"]),
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

class EmbeddedCustomers {
    EmbeddedCustomers({
        required this.customers,
    });

    final List<Customer> customers;

    factory EmbeddedCustomers.fromJson(Map<String, dynamic> json) => EmbeddedCustomers(
        customers: List<Customer>.from(json["customers"].map((x) => Customer.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "customers": List<dynamic>.from(customers.map((x) => x.toJson())),
    };
}

class Customer {
    Customer({
        required this.id,
        required this.userId,
        required this.totalCouponsUsedOnCheckout,
        required this.totalInstantCartsUsedOnCheckout,
        required this.totalAdvertsUsedOnCheckout,
        required this.totalOrdersPlacedByCustomer,
        required this.totalOrdersPlacedByStore,
        required this.checkoutGrandTotal,
        required this.checkoutSubTotal,
        required this.checkoutCouponsTotal,
        required this.checkoutSaleDiscountTotal,
        required this.checkoutCouponsAndSaleDiscountTotal,
        required this.checkoutDeliveryFee,
        required this.totalFreeDeliveryOnCheckout,
        required this.checkoutTotalItems,
        required this.checkoutTotalUniqueItems,
        required this.locationId,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final int userId;
    final int totalCouponsUsedOnCheckout;
    final int totalInstantCartsUsedOnCheckout;
    final int totalAdvertsUsedOnCheckout;
    final int totalOrdersPlacedByCustomer;
    final int totalOrdersPlacedByStore;
    final Money checkoutGrandTotal;
    final Money checkoutSubTotal;
    final Money checkoutCouponsTotal;
    final Money checkoutSaleDiscountTotal;
    final Money checkoutCouponsAndSaleDiscountTotal;
    final Money checkoutDeliveryFee;
    final int totalFreeDeliveryOnCheckout;
    final int checkoutTotalItems;
    final int checkoutTotalUniqueItems;
    final int locationId;
    final DateTime createdAt;
    final DateTime updatedAt;
    final CustomerAttributes attributes;
    final CustomerLinks links;
    final EmbeddedUser embedded;

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json["id"],
        userId: json["user_id"],
        totalCouponsUsedOnCheckout: json["total_coupons_used_on_checkout"],
        totalInstantCartsUsedOnCheckout: json["total_instant_carts_used_on_checkout"],
        totalAdvertsUsedOnCheckout: json["total_adverts_used_on_checkout"],
        totalOrdersPlacedByCustomer: json["total_orders_placed_by_customer"],
        totalOrdersPlacedByStore: json["total_orders_placed_by_store"],
        checkoutGrandTotal: Money.fromJson(json["checkout_grand_total"]),
        checkoutSubTotal: Money.fromJson(json["checkout_sub_total"]),
        checkoutCouponsTotal: Money.fromJson(json["checkout_coupons_total"]),
        checkoutSaleDiscountTotal: Money.fromJson(json["checkout_sale_discount_total"]),
        checkoutCouponsAndSaleDiscountTotal: Money.fromJson(json["checkout_coupons_and_sale_discount_total"]),
        checkoutDeliveryFee: Money.fromJson(json["checkout_delivery_fee"]),
        totalFreeDeliveryOnCheckout: json["total_free_delivery_on_checkout"],
        checkoutTotalItems: json["checkout_total_items"],
        checkoutTotalUniqueItems: json["checkout_total_unique_items"],
        locationId: json["location_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: CustomerAttributes.fromJson(json["_attributes"]),
        links: CustomerLinks.fromJson(json["_links"]),
        embedded: EmbeddedUser.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "total_coupons_used_on_checkout": totalCouponsUsedOnCheckout,
        "total_instant_carts_used_on_checkout": totalInstantCartsUsedOnCheckout,
        "total_adverts_used_on_checkout": totalAdvertsUsedOnCheckout,
        "total_orders_placed_by_customer": totalOrdersPlacedByCustomer,
        "total_orders_placed_by_store": totalOrdersPlacedByStore,
        "checkout_grand_total": checkoutGrandTotal.toJson(),
        "checkout_sub_total": checkoutSubTotal.toJson(),
        "checkout_coupons_total": checkoutCouponsTotal.toJson(),
        "checkout_sale_discount_total": checkoutSaleDiscountTotal.toJson(),
        "checkout_coupons_and_sale_discount_total": checkoutCouponsAndSaleDiscountTotal.toJson(),
        "checkout_delivery_fee": checkoutDeliveryFee.toJson(),
        "total_free_delivery_on_checkout": totalFreeDeliveryOnCheckout,
        "checkout_total_items": checkoutTotalItems,
        "checkout_total_unique_items": checkoutTotalUniqueItems,
        "location_id": locationId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class CustomerAttributes {
    CustomerAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory CustomerAttributes.fromJson(Map<String, dynamic> json) => CustomerAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
    };
}

class EmbeddedUser {
    EmbeddedUser({
        required this.user,
    });

    final User user;

    factory EmbeddedUser.fromJson(Map<String, dynamic> json) => EmbeddedUser(
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user.toJson(),
    };
}

class CustomerLinks {
    CustomerLinks({
        required this.curies,
        required this.self,
        required this.bosOrders,
    });

    final List<Cury> curies;
    final Link self;
    final Link bosOrders;

    factory CustomerLinks.fromJson(Map<String, dynamic> json) => CustomerLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: Link.fromJson(json["self"]),
        bosOrders: Link.fromJson(json["bos:orders"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:orders": bosOrders.toJson(),
    };
}
