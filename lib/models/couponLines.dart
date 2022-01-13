import './common/paginationLinks.dart';
import './common/currency.dart';
import './common/status.dart';
import './common/money.dart';
import './common/cury.dart';
import './common/link.dart';
import './common/type.dart';
import './coupons.dart';
import 'dart:convert';

PaginatedCouponLines paginatedCouponLinesFromJson(String str) => PaginatedCouponLines.fromJson(json.decode(str));

String paginatedCouponLinesToJson(PaginatedCouponLines data) => json.encode(data.toJson());

class PaginatedCouponLines {
    PaginatedCouponLines({
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
    final EmbeddedCouponLines embedded;

    factory PaginatedCouponLines.fromJson(Map<String, dynamic> json) => PaginatedCouponLines(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedCouponLines.fromJson(json["_embedded"]),
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

class EmbeddedCouponLines {
    EmbeddedCouponLines({
        required this.couponLines,
    });

    final List<CouponLine> couponLines;

    factory EmbeddedCouponLines.fromJson(Map<String, dynamic> json) => EmbeddedCouponLines(
        couponLines: List<CouponLine>.from(json["coupon_lines"].map((x) => CouponLine.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "coupon_lines": List<dynamic>.from(couponLines.map((x) => x.toJson())),
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
        required this.quantityRemaining,
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
        required this.isCancelled,
        required this.cancellationReason,
        required this.detectedChanges,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final String? description;
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
    final int quantityRemaining;
    final Status allowDiscountOnTimes;
    final List<String> discountOnTimes;
    final Status allowDiscountOnDaysOfTheWeek;
    final List<String> discountOnDaysOfTheWeek;
    final Status allowDiscountOnDaysOfTheMonth;
    final List<String> discountOnDaysOfTheMonth;
    final Status allowDiscountOnMonthsOfTheYear;
    final List<String> discountOnMonthsOfTheYear;
    final Status allowDiscountOnNewCustomer;
    final Status allowDiscountOnExistingCustomer;
    final Status isCancelled;
    final dynamic cancellationReason;
    final List<dynamic> detectedChanges;
    final DateTime createdAt;
    final DateTime updatedAt;
    final CouponLineAttributes attributes;
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
        discountOnStartDatetime: json["discount_on_start_datetime"] == null ? null : DateTime.parse(json["discount_on_start_datetime"]),
        allowDiscountOnEndDatetime: Status.fromJson(json["allow_discount_on_end_datetime"]),
        discountOnEndDatetime: json["discount_on_end_datetime"] == null ? null : DateTime.parse(json["discount_on_end_datetime"]),
        allowUsageLimit: Status.fromJson(json["allow_usage_limit"]),
        quantityRemaining: json["quantity_remaining"],
        allowDiscountOnTimes: Status.fromJson(json["allow_discount_on_times"]),
        discountOnTimes: List<String>.from(json["discount_on_times"].map((x) => x)),
        allowDiscountOnDaysOfTheWeek: Status.fromJson(json["allow_discount_on_days_of_the_week"]),
        discountOnDaysOfTheWeek: List<String>.from(json["discount_on_days_of_the_week"].map((x) => x)),
        allowDiscountOnDaysOfTheMonth: Status.fromJson(json["allow_discount_on_days_of_the_month"]),
        discountOnDaysOfTheMonth: List<String>.from(json["discount_on_days_of_the_month"].map((x) => x.toString())),
        allowDiscountOnMonthsOfTheYear: Status.fromJson(json["allow_discount_on_months_of_the_year"]),
        discountOnMonthsOfTheYear: List<String>.from(json["discount_on_months_of_the_year"].map((x) => x)),
        allowDiscountOnNewCustomer: Status.fromJson(json["allow_discount_on_new_customer"]),
        allowDiscountOnExistingCustomer: Status.fromJson(json["allow_discount_on_existing_customer"]),
        isCancelled: Status.fromJson(json["is_cancelled"]),
        cancellationReason: json["cancellation_reason"],
        detectedChanges: List<dynamic>.from(json["detected_changes"].map((x) => x)),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: CouponLineAttributes.fromJson(json["_attributes"]),
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
        "discount_on_start_datetime": discountOnStartDatetime == null ? null : discountOnStartDatetime!.toIso8601String(),
        "allow_discount_on_end_datetime": allowDiscountOnEndDatetime.toJson(),
        "discount_on_end_datetime": discountOnEndDatetime == null ? null : discountOnEndDatetime!.toIso8601String(),
        "allow_usage_limit": allowUsageLimit.toJson(),
        "quantity_remaining": quantityRemaining,
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
        "is_cancelled": isCancelled.toJson(),
        "cancellation_reason": cancellationReason,
        "detected_changes": List<dynamic>.from(detectedChanges.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class CouponLineAttributes {
    CouponLineAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory CouponLineAttributes.fromJson(Map<String, dynamic> json) => CouponLineAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
    };
}

class CouponLineLinks {
    CouponLineLinks({
        required this.curies
    });

    final List<Cury> curies;

    factory CouponLineLinks.fromJson(Map<String, dynamic> json) => CouponLineLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x)))
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson()))
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