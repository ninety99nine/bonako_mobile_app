import './common/paginationLinks.dart';
import './common/currency.dart';
import './common/status.dart';
import './common/money.dart';
import './common/cury.dart';
import './common/link.dart';
import './common/type.dart';
import 'dart:convert';

PaginatedCoupons paginatedCouponsFromJson(String str) => PaginatedCoupons.fromJson(json.decode(str));

String paginatedCouponsToJson(PaginatedCoupons data) => json.encode(data.toJson());

class PaginatedCoupons {
    PaginatedCoupons({
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
    final EmbeddedCoupons embedded;

    factory PaginatedCoupons.fromJson(Map<String, dynamic> json) => PaginatedCoupons(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedCoupons.fromJson(json["_embedded"]),
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

class EmbeddedCoupons {
    EmbeddedCoupons({
        required this.coupons,
    });

    final List<Coupon> coupons;

    factory EmbeddedCoupons.fromJson(Map<String, dynamic> json) => EmbeddedCoupons(
        coupons: List<Coupon>.from(json["coupons"].map((x) => Coupon.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "coupons": List<dynamic>.from(coupons.map((x) => x.toJson())),
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
    final String? description;
    final Status active;
    final Status applyDiscount;
    final Type activationType;
    final String? code;
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
    final DateTime? discountOnStartDatetime;
    final Status allowDiscountOnEndDatetime;
    final DateTime? discountOnEndDatetime;
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
    final CouponAttributes attributes;
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
        discountOnStartDatetime: json["discount_on_start_datetime"] == null ? null : DateTime.parse(json["discount_on_start_datetime"]),
        allowDiscountOnEndDatetime: Status.fromJson(json["allow_discount_on_end_datetime"]),
        discountOnEndDatetime: json["discount_on_end_datetime"] == null ? null : DateTime.parse(json["discount_on_end_datetime"]),
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
        attributes: CouponAttributes.fromJson(json["_attributes"]),
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
        "discount_on_start_datetime": discountOnStartDatetime == null ? null : discountOnStartDatetime!.toIso8601String(),
        "allow_discount_on_end_datetime": allowDiscountOnEndDatetime.toJson(),
        "discount_on_end_datetime": discountOnEndDatetime == null ? null : discountOnEndDatetime!.toIso8601String(),
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

class CouponAttributes {
    CouponAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory CouponAttributes.fromJson(Map<String, dynamic> json) => CouponAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
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