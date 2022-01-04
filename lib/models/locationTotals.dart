import 'dart:convert';

LocationTotals locationTotalsFromJson(String str) => LocationTotals.fromJson(json.decode(str));

String locationTotalsToJson(LocationTotals data) => json.encode(data.toJson());

class LocationTotals {
    LocationTotals({
        required this.userTotals,
        required this.productTotals,
        required this.orderTotals,
        required this.couponTotals,
        required this.customerTotals,
        required this.instantCartTotals,
    });

    final UserTotals userTotals;
    final ProductTotals productTotals;
    final OrderTotals orderTotals;
    final CouponTotals couponTotals;
    final CustomerTotals customerTotals;
    final InstantCartTotals instantCartTotals;

    factory LocationTotals.fromJson(Map<String, dynamic> json) => LocationTotals(
        userTotals: UserTotals.fromJson(json["users"]),
        productTotals: ProductTotals.fromJson(json["products"]),
        orderTotals: OrderTotals.fromJson(json["orders"]),
        couponTotals: CouponTotals.fromJson(json["coupons"]),
        customerTotals: CustomerTotals.fromJson(json["customers"]),
        instantCartTotals: InstantCartTotals.fromJson(json["instant_carts"]),
    );

    Map<String, dynamic> toJson() => {
        "users": userTotals.toJson(),
        "products": productTotals.toJson(),
        "orders": orderTotals.toJson(),
        "coupons": couponTotals.toJson(),
        "customers": customerTotals.toJson(),
        "instant_carts": instantCartTotals.toJson(),
    };
}

class InstantCartTotals {
    InstantCartTotals({
        required this.statuses,
        required this.total,
    });

    final InstantCartStatusTotals statuses;
    final int total;

    factory InstantCartTotals.fromJson(Map<String, dynamic> json) => InstantCartTotals(
        statuses: InstantCartStatusTotals.fromJson(json["statuses"]),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "statuses": statuses.toJson(),
        "total": total,
    };
}

class InstantCartStatusTotals {
    InstantCartStatusTotals({
        required this.active,
        required this.inactive,
        required this.freeDelivery
    });

    final int active;
    final int inactive;
    final int freeDelivery;

    factory InstantCartStatusTotals.fromJson(Map<String, dynamic> json) => InstantCartStatusTotals(
        active: json["active"],
        inactive: json["inactive"],
        freeDelivery: json["free delivery"]
    );

    Map<String, dynamic> toJson() => {
        "active": active,
        "inactive": inactive,
        "free delivery": freeDelivery
    };
}

class CouponTotals {
    CouponTotals({
        required this.statuses,
        required this.total,
    });

    final CouponStatusTotals statuses;
    final int total;

    factory CouponTotals.fromJson(Map<String, dynamic> json) => CouponTotals(
        statuses: CouponStatusTotals.fromJson(json["statuses"]),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "statuses": statuses.toJson(),
        "total": total,
    };
}

class CouponStatusTotals {
    CouponStatusTotals({
        required this.active,
        required this.inactive,
        required this.freeDelivery
    });

    final int active;
    final int inactive;
    final int freeDelivery;

    factory CouponStatusTotals.fromJson(Map<String, dynamic> json) => CouponStatusTotals(
        active: json["active"],
        inactive: json["inactive"],
        freeDelivery: json["free delivery"]
    );

    Map<String, dynamic> toJson() => {
        "active": active,
        "inactive": inactive,
        "free delivery": freeDelivery
    };
}

class CustomerTotals {
    CustomerTotals({
        required this.statuses,
        required this.total,
    });

    final CustomerStatusTotals statuses;
    final int total;

    factory CustomerTotals.fromJson(Map<String, dynamic> json) => CustomerTotals(
        statuses: CustomerStatusTotals.fromJson(json["statuses"]),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "statuses": statuses.toJson(),
        "total": total,
    };
}

class CustomerStatusTotals {
    CustomerStatusTotals({
        required this.hasOrderTotalsPlacedByCustomerTotal,
        required this.hasOrderTotalsPlacedByStore,
        required this.usedCouponTotals,
        required this.usedInstantCarts,
        required this.usedAdverts,
    });

    final int hasOrderTotalsPlacedByCustomerTotal;
    final int hasOrderTotalsPlacedByStore;
    final int usedCouponTotals;
    final int usedInstantCarts;
    final int usedAdverts;

    factory CustomerStatusTotals.fromJson(Map<String, dynamic> json) => CustomerStatusTotals(
        hasOrderTotalsPlacedByCustomerTotal: json["has orders placed by customer"],
        hasOrderTotalsPlacedByStore: json["has orders placed by store"],
        usedCouponTotals: json["used coupons"],
        usedInstantCarts: json["used instant carts"],
        usedAdverts: json["used adverts"],
    );

    Map<String, dynamic> toJson() => {
        "has orders placed by customer": hasOrderTotalsPlacedByCustomerTotal,
        "has orders placed by store": hasOrderTotalsPlacedByStore,
        "used coupons": usedCouponTotals,
        "used instant carts": usedInstantCarts,
        "used adverts": usedAdverts,
    };
}

class OrderTotals {
    OrderTotals({
        required this.sent,
        required this.shared,
        required this.received,
    });

    final SubOrderTotals sent;
    final SubOrderTotals shared;
    final SubOrderTotals received;

    factory OrderTotals.fromJson(Map<String, dynamic> json) => OrderTotals(
        sent: SubOrderTotals.fromJson(json["sent"]),
        shared: SubOrderTotals.fromJson(json["shared"]),
        received: SubOrderTotals.fromJson(json["received"]),
    );

    Map<String, dynamic> toJson() => {
        "sent": sent.toJson(),
        "shared": shared.toJson(),
        "received": received.toJson(),
    };
}

class SubOrderTotals {
    SubOrderTotals({
        required this.statuses,
        required this.total,
    });

    final OrderStatusTotals statuses;
    final int total;

    factory SubOrderTotals.fromJson(Map<String, dynamic> json) => SubOrderTotals(
        statuses: OrderStatusTotals.fromJson(json["statuses"]),
        total: json["total"] == null ? null : json["total"],
    );

    Map<String, dynamic> toJson() => {
        "statuses": statuses.toJson(),
        "total": total,
    };
}

class OrderStatusTotals {
    OrderStatusTotals({
        required this.open,
        required this.draft,
        required this.archieved,
        required this.cancelled,
        required this.paid,
        required this.unpaid,
        required this.refunded,
        required this.failed,
        required this.delivered,
        required this.undelivered,
    });

    final int open;
    final int draft;
    final int archieved;
    final int cancelled;
    final int paid;
    final int unpaid;
    final int refunded;
    final int failed;
    final int delivered;
    final int undelivered;

    factory OrderStatusTotals.fromJson(Map<String, dynamic> json) => OrderStatusTotals(
        open: json["open"],
        draft: json["draft"],
        archieved: json["archieved"],
        cancelled: json["cancelled"],
        paid: json["paid"],
        unpaid: json["unpaid"],
        refunded: json["refunded"],
        failed: json["failed"],
        delivered: json["delivered"],
        undelivered: json["undelivered"],
    );

    Map<String, dynamic> toJson() => {
        "open": open,
        "draft": draft,
        "archieved": archieved,
        "cancelled": cancelled,
        "paid": paid,
        "unpaid": unpaid,
        "refunded": refunded,
        "failed": failed,
        "delivered": delivered,
        "undelivered": undelivered,
    };
}

class ProductTotals {
    ProductTotals({
        required this.statuses,
        required this.total,
    });

    final ProductStatusTotals statuses;
    final int total;

    factory ProductTotals.fromJson(Map<String, dynamic> json) => ProductTotals(
        statuses: ProductStatusTotals.fromJson(json["statuses"]),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "statuses": statuses.toJson(),
        "total": total,
    };
}

class ProductStatusTotals {
    ProductStatusTotals({
        required this.visible,
        required this.hidden,
        required this.limitedStock,
        required this.unlimitedStock,
        required this.outOfStock,
    });

    final int visible;
    final int hidden;
    final int limitedStock;
    final int unlimitedStock;
    final int outOfStock;

    factory ProductStatusTotals.fromJson(Map<String, dynamic> json) => ProductStatusTotals(
        visible: json["visible"],
        hidden: json["hidden"],
        limitedStock: json["limited stock"],
        unlimitedStock: json["unlimited stock"],
        outOfStock: json["out of stock"],
    );

    Map<String, dynamic> toJson() => {
        "visible": visible,
        "hidden": hidden,
        "limited stock": limitedStock,
        "unlimited stock": unlimitedStock,
        "out of stock": outOfStock,
    };
}

class UserTotals {
    UserTotals({
        required this.roles,
        required this.total,
    });

    final UserRoleTotals roles;
    final int total;

    factory UserTotals.fromJson(Map<String, dynamic> json) => UserTotals(
        roles: UserRoleTotals.fromJson(json["roles"]),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "roles": roles.toJson(),
        "total": total,
    };
}

class UserRoleTotals {
    UserRoleTotals({
        required this.member,
        required this.owner,
    });

    final int member;
    final int owner;

    factory UserRoleTotals.fromJson(Map<String, dynamic> json) => UserRoleTotals(
        member: json["member"],
        owner: json["owner"],
    );

    Map<String, dynamic> toJson() => {
        "member": member,
        "owner": owner,
    };
}
