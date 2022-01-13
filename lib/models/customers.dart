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
        required this.totalOrdersPlacedByCustomerOnCheckout,
        required this.totalOrdersPlacedByStoreOnCheckout,
        required this.totalFreeDeliveryOnCheckout,
        required this.grandTotalOnCheckout,
        required this.subTotalOnCheckout,
        required this.couponTotalOnCheckout,
        required this.saleDiscountTotalOnCheckout,
        required this.couponAndSaleDiscountTotalOnCheckout,
        required this.deliveryFeeOnCheckout,
        required this.totalItemsOnCheckout,
        required this.totalUniqueItemsOnCheckout,

        required this.totalCouponsUsedOnConversion,
        required this.totalInstantCartsUsedOnConversion,
        required this.totalAdvertsUsedOnConversion,
        required this.totalOrdersPlacedByCustomerOnConversion,
        required this.totalOrdersPlacedByStoreOnConversion,
        required this.totalFreeDeliveryOnConversion,
        required this.grandTotalOnConversion,
        required this.subTotalOnConversion,
        required this.couponTotalOnConversion,
        required this.saleDiscountTotalOnConversion,
        required this.couponAndSaleDiscountTotalOnConversion,
        required this.deliveryFeeOnConversion,
        required this.totalItemsOnConversion,
        required this.totalUniqueItemsOnConversion,

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
    final int totalOrdersPlacedByCustomerOnCheckout;
    final int totalOrdersPlacedByStoreOnCheckout;
    final int totalFreeDeliveryOnCheckout;
    final Money grandTotalOnCheckout;
    final Money subTotalOnCheckout;
    final Money couponTotalOnCheckout;
    final Money saleDiscountTotalOnCheckout;
    final Money couponAndSaleDiscountTotalOnCheckout;
    final Money deliveryFeeOnCheckout;
    final int totalItemsOnCheckout;
    final int totalUniqueItemsOnCheckout;

    final int totalCouponsUsedOnConversion;
    final int totalInstantCartsUsedOnConversion;
    final int totalAdvertsUsedOnConversion;
    final int totalOrdersPlacedByCustomerOnConversion;
    final int totalOrdersPlacedByStoreOnConversion;
    final int totalFreeDeliveryOnConversion;
    final Money grandTotalOnConversion;
    final Money subTotalOnConversion;
    final Money couponTotalOnConversion;
    final Money saleDiscountTotalOnConversion;
    final Money couponAndSaleDiscountTotalOnConversion;
    final Money deliveryFeeOnConversion;
    final int totalItemsOnConversion;
    final int totalUniqueItemsOnConversion;

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
        totalOrdersPlacedByCustomerOnCheckout: json["total_orders_placed_by_customer_on_checkout"],
        totalOrdersPlacedByStoreOnCheckout: json["total_orders_placed_by_store_on_checkout"],
        totalFreeDeliveryOnCheckout: json["total_free_delivery_on_checkout"],
        grandTotalOnCheckout: Money.fromJson(json["grand_total_on_checkout"]),
        subTotalOnCheckout: Money.fromJson(json["sub_total_on_checkout"]),
        couponTotalOnCheckout: Money.fromJson(json["coupon_total_on_checkout"]),
        saleDiscountTotalOnCheckout: Money.fromJson(json["sale_discount_total_on_checkout"]),
        couponAndSaleDiscountTotalOnCheckout: Money.fromJson(json["coupon_and_sale_discount_total_on_checkout"]),
        deliveryFeeOnCheckout: Money.fromJson(json["delivery_fee_on_checkout"]),
        totalItemsOnCheckout: json["total_items_on_checkout"],
        totalUniqueItemsOnCheckout: json["total_unique_items_on_checkout"],

        totalCouponsUsedOnConversion: json["total_coupons_used_on_conversion"],
        totalInstantCartsUsedOnConversion: json["total_instant_carts_used_on_conversion"],
        totalAdvertsUsedOnConversion: json["total_adverts_used_on_conversion"],
        totalOrdersPlacedByCustomerOnConversion: json["total_orders_placed_by_customer_on_conversion"],
        totalOrdersPlacedByStoreOnConversion: json["total_orders_placed_by_store_on_conversion"],
        totalFreeDeliveryOnConversion: json["total_free_delivery_on_conversion"],
        grandTotalOnConversion: Money.fromJson(json["grand_total_on_conversion"]),
        subTotalOnConversion: Money.fromJson(json["sub_total_on_conversion"]),
        couponTotalOnConversion: Money.fromJson(json["coupon_total_on_conversion"]),
        saleDiscountTotalOnConversion: Money.fromJson(json["sale_discount_total_on_conversion"]),
        couponAndSaleDiscountTotalOnConversion: Money.fromJson(json["coupon_and_sale_discount_total_on_conversion"]),
        deliveryFeeOnConversion: Money.fromJson(json["delivery_fee_on_conversion"]),
        totalItemsOnConversion: json["total_items_on_conversion"],
        totalUniqueItemsOnConversion: json["total_unique_items_on_conversion"],

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
        "total_orders_placed_by_customer_on_checkout": totalOrdersPlacedByCustomerOnCheckout,
        "total_orders_placed_by_store_on_checkout": totalOrdersPlacedByStoreOnCheckout,
        "grand_total_on_checkout": grandTotalOnCheckout.toJson(),
        "sub_total_on_checkout": subTotalOnCheckout.toJson(),
        "coupon_total_on_checkout": couponTotalOnCheckout.toJson(),
        "sale_discount_total_on_checkout": saleDiscountTotalOnCheckout.toJson(),
        "coupon_and_sale_discount_total_on_checkout": couponAndSaleDiscountTotalOnCheckout.toJson(),
        "delivery_fee_on_checkout": deliveryFeeOnCheckout.toJson(),
        "total_free_delivery_on_checkout": totalFreeDeliveryOnCheckout,
        "total_items_on_checkout": totalItemsOnCheckout,
        "total_unique_items_on_checkout": totalUniqueItemsOnCheckout,

        "total_coupons_used_on_conversion": totalCouponsUsedOnConversion,
        "total_instant_carts_used_on_conversion": totalInstantCartsUsedOnConversion,
        "total_adverts_used_on_conversion": totalAdvertsUsedOnConversion,
        "total_orders_placed_by_customer_on_conversion": totalOrdersPlacedByCustomerOnConversion,
        "total_orders_placed_by_store_on_conversion": totalOrdersPlacedByStoreOnConversion,
        "grand_total_on_conversion": grandTotalOnConversion.toJson(),
        "sub_total_on_conversion": subTotalOnConversion.toJson(),
        "coupon_total_on_conversion": couponTotalOnConversion.toJson(),
        "sale_discount_total_on_conversion": saleDiscountTotalOnConversion.toJson(),
        "coupon_and_sale_discount_total_on_conversion": couponAndSaleDiscountTotalOnConversion.toJson(),
        "delivery_fee_on_conversion": deliveryFeeOnConversion.toJson(),
        "total_free_delivery_on_conversion": totalFreeDeliveryOnConversion,
        "total_items_on_conversion": totalItemsOnConversion,
        "total_unique_items_on_conversion": totalUniqueItemsOnConversion,

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
        required this.totalOrdersPlacedOnCheckout,
        required this.totalOrdersPlacedOnConversion,
    });

    final String resourceType;
    final int totalOrdersPlacedOnCheckout;
    final int totalOrdersPlacedOnConversion;

    factory CustomerAttributes.fromJson(Map<String, dynamic> json) => CustomerAttributes(
        resourceType: json["resource_type"],
        totalOrdersPlacedOnCheckout: json["total_orders_placed_on_checkout"],
        totalOrdersPlacedOnConversion: json["total_orders_placed_on_conversion"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
        "total_orders_placed_on_checkout": totalOrdersPlacedOnCheckout,
        "total_orders_placed_on_conversion": totalOrdersPlacedOnConversion,
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
