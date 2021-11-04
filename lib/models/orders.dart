import 'dart:convert';

PaginatedOrders paginatedOrdersFromJson(String str) => PaginatedOrders.fromJson(json.decode(str));

String paginatedOrdersToJson(PaginatedOrders data) => json.encode(data.toJson());

class PaginatedOrders {
    PaginatedOrders({
        required this.links,
        required this.total,
        required this.count,
        required this.perPage,
        required this.currentPage,
        required this.totalPages,
        required this.embedded,
    });

    final PaginatedOrdersLinks links;
    final int total;
    final int count;
    final int perPage;
    final int currentPage;
    final int totalPages;
    final PaginatedOrdersEmbedded embedded;

    factory PaginatedOrders.fromJson(Map<String, dynamic> json) => PaginatedOrders(
        links: PaginatedOrdersLinks.fromJson(json["_links"]),
        total: json["total"],
        count: json["count"],
        perPage: json["per_page"],
        currentPage: json["current_page"],
        totalPages: json["total_pages"],
        embedded: PaginatedOrdersEmbedded.fromJson(json["_embedded"]),
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

class PaginatedOrdersEmbedded {
    PaginatedOrdersEmbedded({
        required this.orders,
    });

    final List<Order> orders;

    factory PaginatedOrdersEmbedded.fromJson(Map<String, dynamic> json) => PaginatedOrdersEmbedded(
        orders: List<Order>.from(json["orders"].map((x) => Order.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "orders": List<dynamic>.from(orders.map((x) => x.toJson())),
    };
}

class Order {
    Order({
        required this.id,
        required this.number,
        required this.deliveryVerified,
        required this.deliveryVerifiedAt,
        required this.customerId,
        required this.locationId,
        required this.cancellationReason,
        required this.requestCustomerRatingAt,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String number;
    final bool deliveryVerified;
    final dynamic deliveryVerifiedAt;
    final int customerId;
    final dynamic locationId;
    final dynamic cancellationReason;
    final dynamic requestCustomerRatingAt;
    final dynamic createdAt;
    final dynamic updatedAt;
    final OrderAttributes attributes;
    final OrderLinks links;
    final OrderEmbedded embedded;

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        number: json["number"],
        deliveryVerified: json["delivery_verified"],
        deliveryVerifiedAt: json["delivery_verified_at"],
        customerId: json["customer_id"],
        locationId: json["location_id"],
        cancellationReason: json["cancellation_reason"],
        requestCustomerRatingAt: json["request_customer_rating_at"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["created_at"] == null ? null : DateTime.parse(json["updated_at"]),
        attributes: OrderAttributes.fromJson(json["_attributes"]),
        links: OrderLinks.fromJson(json["_links"]),
        embedded: OrderEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "number": number,
        "delivery_verified": deliveryVerified,
        "delivery_verified_at": deliveryVerifiedAt,
        "customer_id": customerId,
        "location_id": locationId,
        "cancellation_reason": cancellationReason,
        "request_customer_rating_at": requestCustomerRatingAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class OrderAttributes {
    OrderAttributes({
        required this.isPaid,
        required this.isDelivered,
        required this.requiresDeliveryConfirmationCode,
        required this.resourceType,
        required this.deliveryVerifiedDescription,
        required this.paymentShortCode,
    });

    final bool isPaid;
    final bool isDelivered;
    final bool requiresDeliveryConfirmationCode;
    final String resourceType;
    final String deliveryVerifiedDescription;
    final dynamic paymentShortCode;

    factory OrderAttributes.fromJson(Map<String, dynamic> json) => OrderAttributes(
        isPaid: json["is_paid"],
        isDelivered: json["is_delivered"],
        requiresDeliveryConfirmationCode: json["requires_delivery_confirmation_code"],
        resourceType: json["resource_type"],
        deliveryVerifiedDescription: json["delivery_verified_description"],
        paymentShortCode: json["payment_short_code"],
    );

    Map<String, dynamic> toJson() => {
        "is_paid": isPaid,
        "is_delivered": isDelivered,
        "requires_delivery_confirmation_code": requiresDeliveryConfirmationCode,
        "resource_type": resourceType,
        "delivery_verified_description": deliveryVerifiedDescription,
        "payment_short_code": paymentShortCode,
    };
}

class OrderEmbedded {
    OrderEmbedded({
        required this.status,
        required this.paymentStatus,
        required this.deliveryStatus,
        required this.activeCart,
        required this.deliveryLine,
        required this.transaction,
        required this.customer,
    });

    final OrderStatus status;
    final OrderStatus paymentStatus;
    final OrderStatus deliveryStatus;
    final ActiveCart activeCart;
    final dynamic deliveryLine;
    final dynamic transaction;
    final Customer customer;

    factory OrderEmbedded.fromJson(Map<String, dynamic> json) => OrderEmbedded(
        status: OrderStatus.fromJson(json["status"]),
        paymentStatus: OrderStatus.fromJson(json["payment_status"]),
        deliveryStatus: OrderStatus.fromJson(json["delivery_status"]),
        activeCart: ActiveCart.fromJson(json["active_cart"]),
        deliveryLine: json["delivery_line"],
        transaction: json["transaction"],
        customer: Customer.fromJson(json["customer"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status.toJson(),
        "payment_status": paymentStatus.toJson(),
        "delivery_status": deliveryStatus.toJson(),
        "active_cart": activeCart.toJson(),
        "delivery_line": deliveryLine,
        "transaction": transaction,
        "customer": customer.toJson(),
    };
}

class ActiveCart {
    ActiveCart({
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
    final int totalUniqueItems;
    final List<ProductsArrangement> productsArrangement;
    final List<DetectedChange> detectedChanges;
    final Status abandonedStatus;
    final dynamic instantCartId;
    final dynamic createdAt;
    final dynamic updatedAt;
    final ActiveCartAttributes attributes;
    final ActiveCartLinks links;
    final ActiveCartEmbedded embedded;

    factory ActiveCart.fromJson(Map<String, dynamic> json) => ActiveCart(
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
        totalUniqueItems: json["total_unique_items"],
        productsArrangement: List<ProductsArrangement>.from(json["products_arrangement"].map((x) => ProductsArrangement.fromJson(x))),
        detectedChanges: List<DetectedChange>.from(json["detected_changes"].map((x) => DetectedChange.fromJson(x))),
        abandonedStatus: Status.fromJson(json["abandoned_status"]),
        instantCartId: json["instant_cart_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["created_at"] == null ? null : DateTime.parse(json["updated_at"]),
        attributes: ActiveCartAttributes.fromJson(json["_attributes"]),
        links: ActiveCartLinks.fromJson(json["_links"]),
        embedded: ActiveCartEmbedded.fromJson(json["_embedded"]),
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
        "total_unique_items": totalUniqueItems,
        "products_arrangement": List<dynamic>.from(productsArrangement.map((x) => x.toJson())),
        "detected_changes": List<dynamic>.from(detectedChanges.map((x) => x.toJson())),
        "abandoned_status": abandonedStatus.toJson(),
        "instant_cart_id": instantCartId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class Status {
    Status({
        required this.name,
        required this.type,
        required this.status,
        required this.description,
    });

    final String name;
    final dynamic type;
    final bool status;
    final String description;

    factory Status.fromJson(Map<String, dynamic> json) => Status(
        name: json["name"],
        type: json["type"],
        status: json["status"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "name": name,
        "status": status,
        "description": description,
    };
}

class ActiveCartAttributes {
    ActiveCartAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory ActiveCartAttributes.fromJson(Map<String, dynamic> json) => ActiveCartAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
    };
}

class Money {
    Money({
        required this.currencyMoney,
        required this.money,
        required this.amount,
    });

    final String currencyMoney;
    final String money;
    final double amount;

    factory Money.fromJson(Map<String, dynamic> json) => Money(
        currencyMoney: json["currency_money"],
        money: json["money"],
        amount: json["amount"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "currency_money": currencyMoney,
        "money": money,
        "amount": amount,
    };
}

class Currency {
    Currency({
        required this.code,
        required this.symbol,
    });

    final String code;
    final String symbol;

    factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        code: json["code"],
        symbol: json["symbol"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "symbol": symbol,
    };
}

class DetectedChange {
    DetectedChange({
        required this.type,
        required this.message,
        required this.notifiedUser,
    });

    final String type;
    final String message;
    final bool notifiedUser;

    factory DetectedChange.fromJson(Map<String, dynamic> json) => DetectedChange(
        type: json["type"],
        message: json["message"],
        notifiedUser: json["notified_user"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "message": message,
        "notified_user": notifiedUser,
    };
}

class ActiveCartEmbedded {
    ActiveCartEmbedded({
        required this.couponLines,
        required this.itemLines,
    });

    final List<CouponLine> couponLines;
    final List<ItemLine> itemLines;

    factory ActiveCartEmbedded.fromJson(Map<String, dynamic> json) => ActiveCartEmbedded(
        couponLines: List<CouponLine>.from(json["coupon_lines"].map((x) => CouponLine.fromJson(x))),
        itemLines: List<ItemLine>.from(json["item_lines"].map((x) => ItemLine.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "coupon_lines": List<dynamic>.from(couponLines.map((x) => x.toJson())),
        "item_lines": List<dynamic>.from(itemLines.map((x) => x.toJson())),
    };
}

class CouponLine {
    CouponLine({
        required this.id,
        required this.name,
        required this.description,
        required this.applyDiscount,
        required this.activationType,
        required this.code,
        required this.allowFreeDelivery,
        required this.currency,
        required this.discountRateType,
        required this.fixedRate,
        required this.percentageRate,
        required this.allowDiscountOnMinimumTotal,
        required this.discountOnMinimumTotal,
        required this.allowDiscountOnTotalItems,
        required this.discountOnTotalItems,
        required this.allowDiscountOnTotalUniqueItems,
        required this.discountOnTotalUniqueItems,
        required this.allowDiscountOnStartDatetime,
        required this.discountOnStartDatetime,
        required this.allowDiscountOnEndDatetime,
        required this.discountOnEndDatetime,
        required this.allowUsageLimit,
        required this.usageLimit,
        required this.allowDiscountOnTimes,
        required this.discountOnTimes,
        required this.allowDiscountOnDaysOfTheWeek,
        required this.discountOnDaysOfTheWeek,
        required this.allowDiscountOnDaysOfTheMonth,
        required this.discountOnDaysOfTheMonth,
        required this.allowDiscountOnMonthsOfTheYear,
        required this.discountOnMonthsOfTheYear,
        required this.allowDiscountOnNewCustomer,
        required this.allowDiscountOnExistingCustomer,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final String description;
    final Status applyDiscount;
    final Type activationType;
    final String code;
    final Status allowFreeDelivery;
    final Currency currency;
    final Type discountRateType;
    final Money fixedRate;
    final int percentageRate;
    final Status allowDiscountOnMinimumTotal;
    final Money discountOnMinimumTotal;
    final Status allowDiscountOnTotalItems;
    final int discountOnTotalItems;
    final Status allowDiscountOnTotalUniqueItems;
    final int discountOnTotalUniqueItems;
    final Status allowDiscountOnStartDatetime;
    final DateTime discountOnStartDatetime;
    final Status allowDiscountOnEndDatetime;
    final DateTime discountOnEndDatetime;
    final Status allowUsageLimit;
    final int usageLimit;
    final Status allowDiscountOnTimes;
    final List<String> discountOnTimes;
    final Status allowDiscountOnDaysOfTheWeek;
    final List<String> discountOnDaysOfTheWeek;
    final Status allowDiscountOnDaysOfTheMonth;
    final List<int> discountOnDaysOfTheMonth;
    final Status allowDiscountOnMonthsOfTheYear;
    final List<String> discountOnMonthsOfTheYear;
    final Status allowDiscountOnNewCustomer;
    final Status allowDiscountOnExistingCustomer;
    final DateTime createdAt;
    final DateTime updatedAt;
    final ActiveCartAttributes attributes;
    final CouponLineLinks links;
    final CouponLineEmbedded embedded;

    factory CouponLine.fromJson(Map<String, dynamic> json) => CouponLine(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        applyDiscount: Status.fromJson(json["apply_discount"]),
        activationType: Type.fromJson(json["activation_type"]),
        code: json["code"],
        allowFreeDelivery: Status.fromJson(json["allow_free_delivery"]),
        currency: Currency.fromJson(json["currency"]),
        discountRateType: Type.fromJson(json["discount_rate_type"]),
        fixedRate: Money.fromJson(json["fixed_rate"]),
        percentageRate: json["percentage_rate"],
        allowDiscountOnMinimumTotal: Status.fromJson(json["allow_discount_on_minimum_total"]),
        discountOnMinimumTotal: Money.fromJson(json["discount_on_minimum_total"]),
        allowDiscountOnTotalItems: Status.fromJson(json["allow_discount_on_total_items"]),
        discountOnTotalItems: json["discount_on_total_items"],
        allowDiscountOnTotalUniqueItems: Status.fromJson(json["allow_discount_on_total_unique_items"]),
        discountOnTotalUniqueItems: json["discount_on_total_unique_items"],
        allowDiscountOnStartDatetime: Status.fromJson(json["allow_discount_on_start_datetime"]),
        discountOnStartDatetime: DateTime.parse(json["discount_on_start_datetime"]),
        allowDiscountOnEndDatetime: Status.fromJson(json["allow_discount_on_end_datetime"]),
        discountOnEndDatetime: DateTime.parse(json["discount_on_end_datetime"]),
        allowUsageLimit: Status.fromJson(json["allow_usage_limit"]),
        usageLimit: json["usage_limit"],
        allowDiscountOnTimes: Status.fromJson(json["allow_discount_on_times"]),
        discountOnTimes: List<String>.from(json["discount_on_times"].map((x) => x)),
        allowDiscountOnDaysOfTheWeek: Status.fromJson(json["allow_discount_on_days_of_the_week"]),
        discountOnDaysOfTheWeek: List<String>.from(json["discount_on_days_of_the_week"].map((x) => x)),
        allowDiscountOnDaysOfTheMonth: Status.fromJson(json["allow_discount_on_days_of_the_month"]),
        discountOnDaysOfTheMonth: List<int>.from(json["discount_on_days_of_the_month"].map((x) => x)),
        allowDiscountOnMonthsOfTheYear: Status.fromJson(json["allow_discount_on_months_of_the_year"]),
        discountOnMonthsOfTheYear: List<String>.from(json["discount_on_months_of_the_year"].map((x) => x)),
        allowDiscountOnNewCustomer: Status.fromJson(json["allow_discount_on_new_customer"]),
        allowDiscountOnExistingCustomer: Status.fromJson(json["allow_discount_on_existing_customer"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: ActiveCartAttributes.fromJson(json["_attributes"]),
        links: CouponLineLinks.fromJson(json["_links"]),
        embedded: CouponLineEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "apply_discount": applyDiscount.toJson(),
        "activation_type": activationType.toJson(),
        "code": code,
        "allow_free_delivery": allowFreeDelivery.toJson(),
        "currency": currency.toJson(),
        "discount_rate_type": discountRateType.toJson(),
        "fixed_rate": fixedRate.toJson(),
        "percentage_rate": percentageRate,
        "allow_discount_on_minimum_total": allowDiscountOnMinimumTotal.toJson(),
        "discount_on_minimum_total": discountOnMinimumTotal.toJson(),
        "allow_discount_on_total_items": allowDiscountOnTotalItems.toJson(),
        "discount_on_total_items": discountOnTotalItems,
        "allow_discount_on_total_unique_items": allowDiscountOnTotalUniqueItems.toJson(),
        "discount_on_total_unique_items": discountOnTotalUniqueItems,
        "allow_discount_on_start_datetime": allowDiscountOnStartDatetime.toJson(),
        "discount_on_start_datetime": discountOnStartDatetime.toIso8601String(),
        "allow_discount_on_end_datetime": allowDiscountOnEndDatetime.toJson(),
        "discount_on_end_datetime": discountOnEndDatetime.toIso8601String(),
        "allow_usage_limit": allowUsageLimit.toJson(),
        "usage_limit": usageLimit,
        "allow_discount_on_times": allowDiscountOnTimes.toJson(),
        "discount_on_times": List<dynamic>.from(discountOnTimes.map((x) => x)),
        "allow_discount_on_days_of_the_week": allowDiscountOnDaysOfTheWeek.toJson(),
        "discount_on_days_of_the_week": List<dynamic>.from(discountOnDaysOfTheWeek.map((x) => x)),
        "allow_discount_on_days_of_the_month": allowDiscountOnDaysOfTheMonth.toJson(),
        "discount_on_days_of_the_month": List<dynamic>.from(discountOnDaysOfTheMonth.map((x) => x)),
        "allow_discount_on_months_of_the_year": allowDiscountOnMonthsOfTheYear.toJson(),
        "discount_on_months_of_the_year": List<dynamic>.from(discountOnMonthsOfTheYear.map((x) => x)),
        "allow_discount_on_new_customer": allowDiscountOnNewCustomer.toJson(),
        "allow_discount_on_existing_customer": allowDiscountOnExistingCustomer.toJson(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class Type {
    Type({
        required this.type,
        required this.name,
        required this.description,
    });

    final String type;
    final String name;
    final String description;

    factory Type.fromJson(Map<String, dynamic> json) => Type(
        type: json["type"],
        name: json["name"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "name": name,
        "description": description,
    };
}

class CouponLineEmbedded {
    CouponLineEmbedded({
        required this.coupon,
    });

    final Coupon coupon;

    factory CouponLineEmbedded.fromJson(Map<String, dynamic> json) => CouponLineEmbedded(
        coupon: Coupon.fromJson(json["coupon"]),
    );

    Map<String, dynamic> toJson() => {
        "coupon": coupon.toJson(),
    };
}

class Coupon {
    Coupon({
        required this.id,
        required this.name,
        required this.description,
        required this.active,
        required this.applyDiscount,
        required this.activationType,
        required this.code,
        required this.allowFreeDelivery,
        required this.currency,
        required this.discountRateType,
        required this.fixedRate,
        required this.percentageRate,
        required this.allowDiscountOnMinimumTotal,
        required this.discountOnMinimumTotal,
        required this.allowDiscountOnTotalItems,
        required this.discountOnTotalItems,
        required this.allowDiscountOnTotalUniqueItems,
        required this.discountOnTotalUniqueItems,
        required this.allowDiscountOnStartDatetime,
        required this.discountOnStartDatetime,
        required this.allowDiscountOnEndDatetime,
        required this.discountOnEndDatetime,
        required this.allowUsageLimit,
        required this.usageLimit,
        required this.usageQuantity,
        required this.quantityRemaining,
        required this.hasQuantityRemaining,
        required this.allowDiscountOnTimes,
        required this.discountOnTimes,
        required this.allowDiscountOnDaysOfTheWeek,
        required this.discountOnDaysOfTheWeek,
        required this.allowDiscountOnDaysOfTheMonth,
        required this.discountOnDaysOfTheMonth,
        required this.allowDiscountOnMonthsOfTheYear,
        required this.discountOnMonthsOfTheYear,
        required this.allowDiscountOnNewCustomer,
        required this.allowDiscountOnExistingCustomer,
        required this.locationId,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final String description;
    final Status active;
    final Status applyDiscount;
    final Type activationType;
    final String code;
    final Status allowFreeDelivery;
    final Currency currency;
    final Type discountRateType;
    final Money fixedRate;
    final int percentageRate;
    final Status allowDiscountOnMinimumTotal;
    final Money discountOnMinimumTotal;
    final Status allowDiscountOnTotalItems;
    final int discountOnTotalItems;
    final Status allowDiscountOnTotalUniqueItems;
    final int discountOnTotalUniqueItems;
    final Status allowDiscountOnStartDatetime;
    final DateTime discountOnStartDatetime;
    final Status allowDiscountOnEndDatetime;
    final DateTime discountOnEndDatetime;
    final Status allowUsageLimit;
    final int usageLimit;
    final int usageQuantity;
    final int quantityRemaining;
    final Status hasQuantityRemaining;
    final Status allowDiscountOnTimes;
    final List<String> discountOnTimes;
    final Status allowDiscountOnDaysOfTheWeek;
    final List<String> discountOnDaysOfTheWeek;
    final Status allowDiscountOnDaysOfTheMonth;
    final List<int> discountOnDaysOfTheMonth;
    final Status allowDiscountOnMonthsOfTheYear;
    final List<String> discountOnMonthsOfTheYear;
    final Status allowDiscountOnNewCustomer;
    final Status allowDiscountOnExistingCustomer;
    final int locationId;
    final DateTime createdAt;
    final DateTime updatedAt;
    final ActiveCartAttributes attributes;
    final CouponLinks links;
    final List<dynamic> embedded;

    factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        active: Status.fromJson(json["active"]),
        applyDiscount: Status.fromJson(json["apply_discount"]),
        activationType: Type.fromJson(json["activation_type"]),
        code: json["code"],
        allowFreeDelivery: Status.fromJson(json["allow_free_delivery"]),
        currency: Currency.fromJson(json["currency"]),
        discountRateType: Type.fromJson(json["discount_rate_type"]),
        fixedRate: Money.fromJson(json["fixed_rate"]),
        percentageRate: json["percentage_rate"],
        allowDiscountOnMinimumTotal: Status.fromJson(json["allow_discount_on_minimum_total"]),
        discountOnMinimumTotal: Money.fromJson(json["discount_on_minimum_total"]),
        allowDiscountOnTotalItems: Status.fromJson(json["allow_discount_on_total_items"]),
        discountOnTotalItems: json["discount_on_total_items"],
        allowDiscountOnTotalUniqueItems: Status.fromJson(json["allow_discount_on_total_unique_items"]),
        discountOnTotalUniqueItems: json["discount_on_total_unique_items"],
        allowDiscountOnStartDatetime: Status.fromJson(json["allow_discount_on_start_datetime"]),
        discountOnStartDatetime: DateTime.parse(json["discount_on_start_datetime"]),
        allowDiscountOnEndDatetime: Status.fromJson(json["allow_discount_on_end_datetime"]),
        discountOnEndDatetime: DateTime.parse(json["discount_on_end_datetime"]),
        allowUsageLimit: Status.fromJson(json["allow_usage_limit"]),
        usageLimit: json["usage_limit"],
        usageQuantity: json["usage_quantity"],
        quantityRemaining: json["quantity_remaining"],
        hasQuantityRemaining: Status.fromJson(json["has_quantity_remaining"]),
        allowDiscountOnTimes: Status.fromJson(json["allow_discount_on_times"]),
        discountOnTimes: List<String>.from(json["discount_on_times"].map((x) => x)),
        allowDiscountOnDaysOfTheWeek: Status.fromJson(json["allow_discount_on_days_of_the_week"]),
        discountOnDaysOfTheWeek: List<String>.from(json["discount_on_days_of_the_week"].map((x) => x)),
        allowDiscountOnDaysOfTheMonth: Status.fromJson(json["allow_discount_on_days_of_the_month"]),
        discountOnDaysOfTheMonth: List<int>.from(json["discount_on_days_of_the_month"].map((x) => x)),
        allowDiscountOnMonthsOfTheYear: Status.fromJson(json["allow_discount_on_months_of_the_year"]),
        discountOnMonthsOfTheYear: List<String>.from(json["discount_on_months_of_the_year"].map((x) => x)),
        allowDiscountOnNewCustomer: Status.fromJson(json["allow_discount_on_new_customer"]),
        allowDiscountOnExistingCustomer: Status.fromJson(json["allow_discount_on_existing_customer"]),
        locationId: json["location_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: ActiveCartAttributes.fromJson(json["_attributes"]),
        links: CouponLinks.fromJson(json["_links"]),
        embedded: List<dynamic>.from(json["_embedded"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "active": active.toJson(),
        "apply_discount": applyDiscount.toJson(),
        "activation_type": activationType.toJson(),
        "code": code,
        "allow_free_delivery": allowFreeDelivery.toJson(),
        "currency": currency.toJson(),
        "discount_rate_type": discountRateType.toJson(),
        "fixed_rate": fixedRate.toJson(),
        "percentage_rate": percentageRate,
        "allow_discount_on_minimum_total": allowDiscountOnMinimumTotal.toJson(),
        "discount_on_minimum_total": discountOnMinimumTotal.toJson(),
        "allow_discount_on_total_items": allowDiscountOnTotalItems.toJson(),
        "discount_on_total_items": discountOnTotalItems,
        "allow_discount_on_total_unique_items": allowDiscountOnTotalUniqueItems.toJson(),
        "discount_on_total_unique_items": discountOnTotalUniqueItems,
        "allow_discount_on_start_datetime": allowDiscountOnStartDatetime.toJson(),
        "discount_on_start_datetime": discountOnStartDatetime.toIso8601String(),
        "allow_discount_on_end_datetime": allowDiscountOnEndDatetime.toJson(),
        "discount_on_end_datetime": discountOnEndDatetime.toIso8601String(),
        "allow_usage_limit": allowUsageLimit.toJson(),
        "usage_limit": usageLimit,
        "usage_quantity": usageQuantity,
        "quantity_remaining": quantityRemaining,
        "has_quantity_remaining": hasQuantityRemaining.toJson(),
        "allow_discount_on_times": allowDiscountOnTimes.toJson(),
        "discount_on_times": List<dynamic>.from(discountOnTimes.map((x) => x)),
        "allow_discount_on_days_of_the_week": allowDiscountOnDaysOfTheWeek.toJson(),
        "discount_on_days_of_the_week": List<dynamic>.from(discountOnDaysOfTheWeek.map((x) => x)),
        "allow_discount_on_days_of_the_month": allowDiscountOnDaysOfTheMonth.toJson(),
        "discount_on_days_of_the_month": List<dynamic>.from(discountOnDaysOfTheMonth.map((x) => x)),
        "allow_discount_on_months_of_the_year": allowDiscountOnMonthsOfTheYear.toJson(),
        "discount_on_months_of_the_year": List<dynamic>.from(discountOnMonthsOfTheYear.map((x) => x)),
        "allow_discount_on_new_customer": allowDiscountOnNewCustomer.toJson(),
        "allow_discount_on_existing_customer": allowDiscountOnExistingCustomer.toJson(),
        "location_id": locationId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": List<dynamic>.from(embedded.map((x) => x)),
    };
}

class CouponLinks {
    CouponLinks({
        required this.curies,
        required this.self,
    });

    final List<Cury> curies;
    final Link self;

    factory CouponLinks.fromJson(Map<String, dynamic> json) => CouponLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: Link.fromJson(json["self"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
    };
}

class Cury {
    Cury({
        required this.name,
        required this.href,
        required this.templated,
    });

    final String name;
    final String href;
    final bool templated;

    factory Cury.fromJson(Map<String, dynamic> json) => Cury(
        name: json["name"],
        href: json["href"],
        templated: json["templated"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "href": href,
        "templated": templated,
    };
}

class Link {
    Link({
        required this.href,
        required this.title,
    });

    final dynamic href;
    final dynamic title;

    factory Link.fromJson(Map<String, dynamic> json) => Link(
        href: json["href"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "href": href,
        "title": title,
    };
}

class CouponLineLinks {
    CouponLineLinks({
        required this.curies,
    });

    final List<Cury> curies;

    factory CouponLineLinks.fromJson(Map<String, dynamic> json) => CouponLineLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
    };
}

class ItemLine {
    ItemLine({
        required this.id,
        required this.name,
        required this.description,
        required this.isFree,
        required this.isCancelled,
        required this.cancellationReason,
        required this.currency,
        required this.unitRegularPrice,
        required this.unitSalePrice,
        required this.unitPrice,
        required this.unitSaleDiscount,
        required this.subTotal,
        required this.saleDiscountTotal,
        required this.grandTotal,
        required this.quantity,
        required this.originalQuantity,
        required this.productId,
        required this.detectedChanges,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final dynamic description;
    final Status isFree;
    final Status isCancelled;
    final dynamic cancellationReason;
    final Currency currency;
    final Money unitRegularPrice;
    final Money unitSalePrice;
    final Money unitPrice;
    final Money unitSaleDiscount;
    final Money subTotal;
    final Money saleDiscountTotal;
    final Money grandTotal;
    final int quantity;
    final int originalQuantity;
    final int productId;
    final List<DetectedChange> detectedChanges;
    final DateTime createdAt;
    final DateTime updatedAt;
    final ActiveCartAttributes attributes;
    final CouponLineLinks links;
    final ItemLineEmbedded embedded;

    factory ItemLine.fromJson(Map<String, dynamic> json) => ItemLine(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        isFree: Status.fromJson(json["is_free"]),
        isCancelled: Status.fromJson(json["is_cancelled"]),
        cancellationReason: json["cancellation_reason"],
        currency: Currency.fromJson(json["currency"]),
        unitRegularPrice: Money.fromJson(json["unit_regular_price"]),
        unitSalePrice: Money.fromJson(json["unit_sale_price"]),
        unitPrice: Money.fromJson(json["unit_price"]),
        unitSaleDiscount: Money.fromJson(json["unit_sale_discount"]),
        subTotal: Money.fromJson(json["sub_total"]),
        saleDiscountTotal: Money.fromJson(json["sale_discount_total"]),
        grandTotal: Money.fromJson(json["grand_total"]),
        quantity: json["quantity"],
        originalQuantity: json["original_quantity"],
        productId: json["product_id"],
        detectedChanges: List<DetectedChange>.from(json["detected_changes"].map((x) => DetectedChange.fromJson(x))),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: ActiveCartAttributes.fromJson(json["_attributes"]),
        links: CouponLineLinks.fromJson(json["_links"]),
        embedded: ItemLineEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "is_free": isFree.toJson(),
        "is_cancelled": isCancelled.toJson(),
        "cancellation_reason": cancellationReason,
        "currency": currency.toJson(),
        "unit_regular_price": unitRegularPrice.toJson(),
        "unit_sale_price": unitSalePrice.toJson(),
        "unit_price": unitPrice.toJson(),
        "unit_sale_discount": unitSaleDiscount.toJson(),
        "sub_total": subTotal.toJson(),
        "sale_discount_total": saleDiscountTotal.toJson(),
        "grand_total": grandTotal.toJson(),
        "quantity": quantity,
        "original_quantity": originalQuantity,
        "product_id": productId,
        "detected_changes": List<dynamic>.from(detectedChanges.map((x) => x.toJson())),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class ItemLineEmbedded {
    ItemLineEmbedded({
        required this.product,
    });

    final Product? product;

    factory ItemLineEmbedded.fromJson(Map<String, dynamic> json) => ItemLineEmbedded(
        product: json["product"] == null ? null : Product.fromJson(json["product"]),
    );

    Map<String, dynamic> toJson() => {
        "product": product == null ? null : product!.toJson(),
    };
}

class Product {
    Product({
        required this.id,
        required this.name,
        required this.description,
        required this.showDescription,
        required this.sku,
        required this.barcode,
        required this.visible,
        required this.productTypeId,
        required this.allowVariants,
        required this.variantAttributes,
        required this.isFree,
        required this.currency,
        required this.unitRegularPrice,
        required this.unitSalePrice,
        required this.unitCost,
        required this.allowMultipleQuantityPerOrder,
        required this.allowMaximumQuantityPerOrder,
        required this.maximumQuantityPerOrder,
        required this.allowStockManagement,
        required this.autoManageStock,
        required this.stockQuantity,
        required this.parentProductId,
        required this.userId,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final dynamic description;
    final Status showDescription;
    final dynamic sku;
    final dynamic barcode;
    final Status visible;
    final int productTypeId;
    final Status allowVariants;
    final List<VariantAttribute> variantAttributes;
    final Status isFree;
    final Currency currency;
    final Money unitRegularPrice;
    final Money unitSalePrice;
    final Money unitCost;
    final Status allowMultipleQuantityPerOrder;
    final Status allowMaximumQuantityPerOrder;
    final int maximumQuantityPerOrder;
    final Status allowStockManagement;
    final Status autoManageStock;
    final StockQuantity stockQuantity;
    final dynamic parentProductId;
    final int userId;
    final dynamic createdAt;
    final dynamic updatedAt;
    final ProductAttributes attributes;
    final ProductLinks links;
    final ProductEmbedded embedded;

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        showDescription: Status.fromJson(json["show_description"]),
        sku: json["sku"],
        barcode: json["barcode"],
        visible: Status.fromJson(json["visible"]),
        productTypeId: json["product_type_id"],
        allowVariants: Status.fromJson(json["allow_variants"]),
        variantAttributes: List<VariantAttribute>.from(json["variant_attributes"].map((x) => VariantAttribute.fromJson(x))),
        isFree: Status.fromJson(json["is_free"]),
        currency: Currency.fromJson(json["currency"]),
        unitRegularPrice: Money.fromJson(json["unit_regular_price"]),
        unitSalePrice: Money.fromJson(json["unit_sale_price"]),
        unitCost: Money.fromJson(json["unit_cost"]),
        allowMultipleQuantityPerOrder: Status.fromJson(json["allow_multiple_quantity_per_order"]),
        allowMaximumQuantityPerOrder: Status.fromJson(json["allow_maximum_quantity_per_order"]),
        maximumQuantityPerOrder: json["maximum_quantity_per_order"],
        allowStockManagement: Status.fromJson(json["allow_stock_management"]),
        autoManageStock: Status.fromJson(json["auto_manage_stock"]),
        stockQuantity: StockQuantity.fromJson(json["stock_quantity"]),
        parentProductId: json["parent_product_id"],
        userId: json["user_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        attributes: ProductAttributes.fromJson(json["_attributes"]),
        links: ProductLinks.fromJson(json["_links"]),
        embedded: ProductEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "show_description": showDescription.toJson(),
        "sku": sku,
        "barcode": barcode,
        "visible": visible.toJson(),
        "product_type_id": productTypeId,
        "allow_variants": allowVariants.toJson(),
        "variant_attributes": List<dynamic>.from(variantAttributes.map((x) => x.toJson())),
        "is_free": isFree.toJson(),
        "currency": currency.toJson(),
        "unit_regular_price": unitRegularPrice.toJson(),
        "unit_sale_price": unitSalePrice.toJson(),
        "unit_cost": unitCost.toJson(),
        "allow_multiple_quantity_per_order": allowMultipleQuantityPerOrder.toJson(),
        "allow_maximum_quantity_per_order": allowMaximumQuantityPerOrder.toJson(),
        "maximum_quantity_per_order": maximumQuantityPerOrder,
        "allow_stock_management": allowStockManagement.toJson(),
        "auto_manage_stock": autoManageStock.toJson(),
        "stock_quantity": stockQuantity.toJson(),
        "parent_product_id": parentProductId,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class ProductAttributes {
    ProductAttributes({
        required this.onSale,
        required this.hasPrice,
        required this.unitPrice,
        required this.unitLoss,
        required this.unitProfit,
        required this.unitSaleDiscount,
        required this.unitSalePercentage,
        required this.hasStock,
    });

    final Status onSale;
    final Status hasPrice;
    final Money unitPrice;
    final Money unitLoss;
    final Money unitProfit;
    final Money unitSaleDiscount;
    final dynamic unitSalePercentage;
    final Status hasStock;

    factory ProductAttributes.fromJson(Map<String, dynamic> json) => ProductAttributes(
        onSale: Status.fromJson(json["on_sale"]),
        hasPrice: Status.fromJson(json["has_price"]),
        unitPrice: Money.fromJson(json["unit_price"]),
        unitLoss: Money.fromJson(json["unit_loss"]),
        unitProfit: Money.fromJson(json["unit_profit"]),
        unitSaleDiscount: Money.fromJson(json["unit_sale_discount"]),
        unitSalePercentage: json["unit_sale_percentage"],
        hasStock: Status.fromJson(json["has_stock"]),
    );

    Map<String, dynamic> toJson() => {
        "on_sale": onSale.toJson(),
        "has_price": hasPrice.toJson(),
        "unit_price": unitPrice.toJson(),
        "unit_loss": unitLoss.toJson(),
        "unit_profit": unitProfit.toJson(),
        "unit_sale_discount": unitSaleDiscount.toJson(),
        "unit_sale_percentage": unitSalePercentage,
        "has_stock": hasStock.toJson(),
    };
}

class ProductEmbedded {
    ProductEmbedded({
        required this.variables,
    });

    final List<Variable> variables;

    factory ProductEmbedded.fromJson(Map<String, dynamic> json) => ProductEmbedded(
        variables: List<Variable>.from(json["variables"].map((x) => Variable.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "variables": List<dynamic>.from(variables.map((x) => x.toJson())),
    };
}

class Variable {
    Variable({
        required this.id,
        required this.name,
        required this.value,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
    });

    final int id;
    final String name;
    final String value;
    final dynamic createdAt;
    final dynamic updatedAt;
    final ActiveCartAttributes attributes;
    final CouponLineLinks links;

    factory Variable.fromJson(Map<String, dynamic> json) => Variable(
        id: json["id"],
        name: json["name"],
        value: json["value"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        attributes: ActiveCartAttributes.fromJson(json["_attributes"]),
        links: CouponLineLinks.fromJson(json["_links"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "value": value,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
    };
}

class ProductLinks {
    ProductLinks({
        required this.curies,
        required this.self,
        required this.bosLocations,
        required this.bosVariations,
    });

    final List<Cury> curies;
    final Link self;
    final Link bosLocations;
    final Link bosVariations;

    factory ProductLinks.fromJson(Map<String, dynamic> json) => ProductLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: Link.fromJson(json["self"]),
        bosLocations: Link.fromJson(json["bos:locations"]),
        bosVariations: Link.fromJson(json["bos:variations"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:locations": bosLocations.toJson(),
        "bos:variations": bosVariations.toJson(),
    };
}

class StockQuantity {
    StockQuantity({
        required this.value,
        required this.description,
    });

    final int value;
    final String description;

    factory StockQuantity.fromJson(Map<String, dynamic> json) => StockQuantity(
        value: json["value"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "value": value,
        "description": description,
    };
}

class VariantAttribute {
    VariantAttribute({
        required this.name,
        required this.values,
        required this.instruction,
    });

    final String name;
    final List<String> values;
    final String instruction;

    factory VariantAttribute.fromJson(Map<String, dynamic> json) => VariantAttribute(
        name: json["name"],
        values: List<String>.from(json["values"].map((x) => x)),
        instruction: json["instruction"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "values": List<dynamic>.from(values.map((x) => x)),
        "instruction": instruction,
    };
}

class ActiveCartLinks {
    ActiveCartLinks({
        required this.curies,
        required this.self,
        required this.bosRefresh,
        required this.bosReset,
    });

    final List<Cury> curies;
    final Link self;
    final Link bosRefresh;
    final Link bosReset;

    factory ActiveCartLinks.fromJson(Map<String, dynamic> json) => ActiveCartLinks(
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
    final ActiveCartAttributes attributes;
    final CustomerLinks links;
    final CustomerEmbedded embedded;

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
        attributes: ActiveCartAttributes.fromJson(json["_attributes"]),
        links: CustomerLinks.fromJson(json["_links"]),
        embedded: CustomerEmbedded.fromJson(json["_embedded"]),
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

class CustomerEmbedded {
    CustomerEmbedded({
        required this.user,
    });

    final User user;

    factory CustomerEmbedded.fromJson(Map<String, dynamic> json) => CustomerEmbedded(
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user.toJson(),
    };
}

class User {
    User({
        required this.id,
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.mobileNumber,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String firstName;
    final String lastName;
    final String email;
    final MobileNumber mobileNumber;
    final DateTime createdAt;
    final DateTime updatedAt;
    final UserAttributes attributes;
    final UserLinks links;
    final List<dynamic> embedded;

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        mobileNumber: MobileNumber.fromJson(json["mobile_number"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: UserAttributes.fromJson(json["_attributes"]),
        links: UserLinks.fromJson(json["_links"]),
        embedded: List<dynamic>.from(json["_embedded"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile_number": mobileNumber.toJson(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": List<dynamic>.from(embedded.map((x) => x)),
    };
}

class UserAttributes {
    UserAttributes({
        required this.name,
    });

    final String name;

    factory UserAttributes.fromJson(Map<String, dynamic> json) => UserAttributes(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}

class UserLinks {
    UserLinks({
        required this.self
    });
    
    final Link self;

    factory UserLinks.fromJson(Map<String, dynamic> json) => UserLinks(
        self: Link.fromJson(json["self"]),
    );

    Map<String, dynamic> toJson() => {
        "self": self.toJson()
    };
}

class MobileNumber {
    MobileNumber({
        required this.number,
        required this.code,
        required this.numberWithCode,
        required this.callingNumber,
    });

    final String number;
    final String code;
    final String numberWithCode;
    final String callingNumber;

    factory MobileNumber.fromJson(Map<String, dynamic> json) => MobileNumber(
        number: json["number"],
        code: json["code"],
        numberWithCode: json["number_with_code"],
        callingNumber: json["calling_number"],
    );

    Map<String, dynamic> toJson() => {
        "number": number,
        "code": code,
        "number_with_code": numberWithCode,
        "calling_number": callingNumber,
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

class OrderStatus {
    OrderStatus({
        required this.id,
        required this.name,
        required this.description,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final String description;
    final ActiveCartAttributes attributes;
    final CouponLineLinks links;
    final List<dynamic> embedded;

    factory OrderStatus.fromJson(Map<String, dynamic> json) => OrderStatus(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        attributes: ActiveCartAttributes.fromJson(json["_attributes"]),
        links: CouponLineLinks.fromJson(json["_links"]),
        embedded: List<dynamic>.from(json["_embedded"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": List<dynamic>.from(embedded.map((x) => x)),
    };
}

class OrderLinks {
    OrderLinks({
        required this.curies,
        required this.self,
        required this.bosDeliver,
        required this.bosCancel,
        required this.bosPaymentRequest,
        required this.bosPay,
        required this.bosSharedLocations,
        required this.bosReceivedLocation,
        required this.bosStore,
        required this.bosTransactions,
    });

    final List<Cury> curies;
    final Link self;
    final Link bosDeliver;
    final Link bosCancel;
    final Link bosPaymentRequest;
    final Link bosPay;
    final Link bosSharedLocations;
    final Link bosReceivedLocation;
    final Link bosStore;
    final Link bosTransactions;

    factory OrderLinks.fromJson(Map<String, dynamic> json) => OrderLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: Link.fromJson(json["self"]),
        bosDeliver: Link.fromJson(json["bos:deliver"]),
        bosCancel: Link.fromJson(json["bos:cancel"]),
        bosPaymentRequest: Link.fromJson(json["bos:payment_request"]),
        bosPay: Link.fromJson(json["bos:pay"]),
        bosSharedLocations: Link.fromJson(json["bos:shared-locations"]),
        bosReceivedLocation: Link.fromJson(json["bos:received-location"]),
        bosStore: Link.fromJson(json["bos:store"]),
        bosTransactions: Link.fromJson(json["bos:transactions"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:deliver": bosDeliver.toJson(),
        "bos:cancel": bosCancel.toJson(),
        "bos:payment_request": bosPaymentRequest.toJson(),
        "bos:pay": bosPay.toJson(),
        "bos:shared-locations": bosSharedLocations.toJson(),
        "bos:received-location": bosReceivedLocation.toJson(),
        "bos:store": bosStore.toJson(),
        "bos:transactions": bosTransactions.toJson(),
    };
}

class PaginatedOrdersLinks {
    PaginatedOrdersLinks({
        required this.self,
        required this.first,
        required this.prev,
        required this.next,
        required this.last,
        required this.search,
    });

    final Link self;
    final Link first;
    final Link prev;
    final Link next;
    final Link last;
    final Search search;

    factory PaginatedOrdersLinks.fromJson(Map<String, dynamic> json) => PaginatedOrdersLinks(
        self: Link.fromJson(json["self"]),
        first: Link.fromJson(json["first"]),
        prev: Link.fromJson(json["prev"]),
        next: Link.fromJson(json["next"]),
        last: Link.fromJson(json["last"]),
        search: Search.fromJson(json["search"]),
    );

    Map<String, dynamic> toJson() => {
        "self": self.toJson(),
        "first": first.toJson(),
        "prev": prev.toJson(),
        "next": next.toJson(),
        "last": last.toJson(),
        "search": search.toJson(),
    };
}

class Search {
    Search({
        required this.href,
        required this.templated,
    });

    final String href;
    final bool templated;

    factory Search.fromJson(Map<String, dynamic> json) => Search(
        href: json["href"],
        templated: json["templated"],
    );

    Map<String, dynamic> toJson() => {
        "href": href,
        "templated": templated,
    };
}