import 'dart:convert';

LocationTotals locationTotalsFromJson(String str) => LocationTotals.fromJson(json.decode(str));

String locationTotalsToJson(LocationTotals data) => json.encode(data.toJson());

class LocationTotals {
    LocationTotals({
        required this.users,
        required this.products,
        required this.orders,
        required this.coupons,
        required this.customers,
        required this.instantCarts,
    });

    final Users users;
    final Products products;
    final Orders orders;
    final Coupons coupons;
    final Customers customers;
    final Coupons instantCarts;

    factory LocationTotals.fromJson(Map<String, dynamic> json) => LocationTotals(
        users: Users.fromJson(json["users"]),
        products: Products.fromJson(json["products"]),
        orders: Orders.fromJson(json["orders"]),
        coupons: Coupons.fromJson(json["coupons"]),
        customers: Customers.fromJson(json["customers"]),
        instantCarts: Coupons.fromJson(json["instant_carts"]),
    );

    Map<String, dynamic> toJson() => {
        "users": users.toJson(),
        "products": products.toJson(),
        "orders": orders.toJson(),
        "coupons": coupons.toJson(),
        "customers": customers.toJson(),
        "instant_carts": instantCarts.toJson(),
    };
}

class Coupons {
    Coupons({
        required this.statuses,
        required this.total,
    });

    final CouponsStatuses statuses;
    final int total;

    factory Coupons.fromJson(Map<String, dynamic> json) => Coupons(
        statuses: CouponsStatuses.fromJson(json["statuses"]),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "statuses": statuses.toJson(),
        "total": total,
    };
}

class CouponsStatuses {
    CouponsStatuses({
        required this.active,
        required this.inactive,
        required this.freeDelivery
    });

    final int active;
    final int inactive;
    final int freeDelivery;

    factory CouponsStatuses.fromJson(Map<String, dynamic> json) => CouponsStatuses(
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

class Customers {
    Customers({
        required this.statuses,
        required this.total,
    });

    final CustomersStatuses statuses;
    final int total;

    factory Customers.fromJson(Map<String, dynamic> json) => Customers(
        statuses: CustomersStatuses.fromJson(json["statuses"]),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "statuses": statuses.toJson(),
        "total": total,
    };
}

class CustomersStatuses {
    CustomersStatuses({
        required this.hasOrdersPlacedByCustomer,
        required this.hasOrdersPlacedByStore,
        required this.usedCoupons,
        required this.usedInstantCarts,
        required this.usedAdverts,
    });

    final int hasOrdersPlacedByCustomer;
    final int hasOrdersPlacedByStore;
    final int usedCoupons;
    final int usedInstantCarts;
    final int usedAdverts;

    factory CustomersStatuses.fromJson(Map<String, dynamic> json) => CustomersStatuses(
        hasOrdersPlacedByCustomer: json["has orders placed by customer"],
        hasOrdersPlacedByStore: json["has orders placed by store"],
        usedCoupons: json["used coupons"],
        usedInstantCarts: json["used instant carts"],
        usedAdverts: json["used adverts"],
    );

    Map<String, dynamic> toJson() => {
        "has orders placed by customer": hasOrdersPlacedByCustomer,
        "has orders placed by store": hasOrdersPlacedByStore,
        "used coupons": usedCoupons,
        "used instant carts": usedInstantCarts,
        "used adverts": usedAdverts,
    };
}

class Orders {
    Orders({
        required this.sent,
        required this.shared,
        required this.received,
    });

    final Received sent;
    final Received shared;
    final Received received;

    factory Orders.fromJson(Map<String, dynamic> json) => Orders(
        sent: Received.fromJson(json["sent"]),
        shared: Received.fromJson(json["shared"]),
        received: Received.fromJson(json["received"]),
    );

    Map<String, dynamic> toJson() => {
        "sent": sent.toJson(),
        "shared": shared.toJson(),
        "received": received.toJson(),
    };
}

class Received {
    Received({
        required this.statuses,
        required this.total,
    });

    final ReceivedStatuses statuses;
    final int total;

    factory Received.fromJson(Map<String, dynamic> json) => Received(
        statuses: ReceivedStatuses.fromJson(json["statuses"]),
        total: json["total"] == null ? null : json["total"],
    );

    Map<String, dynamic> toJson() => {
        "statuses": statuses.toJson(),
        "total": total,
    };
}

class ReceivedStatuses {
    ReceivedStatuses({
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

    factory ReceivedStatuses.fromJson(Map<String, dynamic> json) => ReceivedStatuses(
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

class Products {
    Products({
        required this.statuses,
        required this.total,
    });

    final ProductsStatuses statuses;
    final int total;

    factory Products.fromJson(Map<String, dynamic> json) => Products(
        statuses: ProductsStatuses.fromJson(json["statuses"]),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "statuses": statuses.toJson(),
        "total": total,
    };
}

class ProductsStatuses {
    ProductsStatuses({
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

    factory ProductsStatuses.fromJson(Map<String, dynamic> json) => ProductsStatuses(
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

class Users {
    Users({
        required this.roles,
        required this.total,
    });

    final Roles roles;
    final int total;

    factory Users.fromJson(Map<String, dynamic> json) => Users(
        roles: Roles.fromJson(json["roles"]),
        total: json["total"],
    );

    Map<String, dynamic> toJson() => {
        "roles": roles.toJson(),
        "total": total,
    };
}

class Roles {
    Roles({
        required this.admin,
    });

    final int admin;

    factory Roles.fromJson(Map<String, dynamic> json) => Roles(
        admin: json["admin"],
    );

    Map<String, dynamic> toJson() => {
        "admin": admin,
    };
}
