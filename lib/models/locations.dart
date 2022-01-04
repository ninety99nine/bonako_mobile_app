import './common/attributes/shortCodeAttribute.dart';
import './common/paginationLinks.dart';
import './common/currency.dart';
import './common/money.dart';
import './common/status.dart';
import './paymentMethods.dart';
import './deliveryLines.dart';
import './transactions.dart';
import './common/link.dart';
import './common/cury.dart';
import './customers.dart';
import './statuses.dart';
import './carts.dart';
import 'dart:convert';

PaginatedLocations paginatedLocationsFromJson(String str) => PaginatedLocations.fromJson(json.decode(str));

String paginatedLocationsToJson(PaginatedLocations data) => json.encode(data.toJson());

class PaginatedLocations {
    PaginatedLocations({
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
    final EmbeddedLocations embedded;

    factory PaginatedLocations.fromJson(Map<String, dynamic> json) => PaginatedLocations(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedLocations.fromJson(json["_embedded"]),
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

class EmbeddedLocations {
    EmbeddedLocations({
        required this.locations,
    });

    final List<Location> locations;

    factory EmbeddedLocations.fromJson(Map<String, dynamic> json) => EmbeddedLocations(
        locations: List<Location>.from(json["locations"].map((x) => Location.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "locations": List<dynamic>.from(locations.map((x) => x.toJson())),
    };
}

class Location {
    Location({
        required this.id,
        required this.name,
        required this.abbreviation,
        required this.currency,
        required this.aboutUs,
        required this.contactUs,
        required this.callToAction,
        required this.online,
        required this.offlineMessage,
        required this.allowDelivery,
        required this.deliveryNote,
        required this.allowFreeDelivery,
        required this.deliveryFlatFee,
        required this.deliveryDestinations,
        required this.deliveryDays,
        required this.deliveryTimes,
        required this.allowPickups,
        required this.pickupNote,
        required this.pickupDestinations,
        required this.pickupDays,
        required this.pickupTimes,
        required this.allowPayments,
        required this.orangeMoneyMerchantCode,
        required this.minimumStockQuantity,
        required this.allowSendingMerchantSms,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final String abbreviation;
    final Currency currency;
    final String aboutUs;
    final String contactUs;
    final String callToAction;
    final Status online;
    final String offlineMessage;
    final Status allowDelivery;
    final String deliveryNote;
    final Status allowFreeDelivery;
    final Money deliveryFlatFee;
    final List<DeliveryDestination> deliveryDestinations;
    final List<String> deliveryDays;
    final List<String> deliveryTimes;
    final Status allowPickups;
    final String pickupNote;
    final List<PickupDestination> pickupDestinations;
    final List<String> pickupDays;
    final List<String> pickupTimes;
    final Status allowPayments;
    final String orangeMoneyMerchantCode;
    final int minimumStockQuantity;
    final Status allowSendingMerchantSms;
    final DateTime createdAt;
    final DateTime updatedAt;
    final LocationAttributes attributes;
    final LocationLinks links;
    final LocationEmbedded embedded;

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json["id"],
        name: json["name"],
        abbreviation: json["abbreviation"] == null ? '' : json["abbreviation"],
        currency: Currency.fromJson(json["currency"]),
        aboutUs: json["about_us"] == null ? '' : json["about_us"],
        contactUs: json["contact_us"] == null ? '' : json["contact_us"],
        callToAction: json["call_to_action"],
        online: Status.fromJson(json["online"]),
        offlineMessage: json["offline_message"] == null ? '' : json["offline_message"],
        allowDelivery: Status.fromJson(json["allow_delivery"]),
        deliveryNote: json["delivery_note"] == null ? '' : json["delivery_note"],
        allowFreeDelivery: Status.fromJson(json["allow_free_delivery"]),
        deliveryFlatFee: Money.fromJson(json["delivery_flat_fee"]),
        deliveryDestinations: List<DeliveryDestination>.from(json["delivery_destinations"].map((x) => DeliveryDestination.fromJson(x))),
        deliveryDays: List<String>.from(json["delivery_days"].map((x) => x)),
        deliveryTimes: List<String>.from(json["delivery_times"].map((x) => x)),
        allowPickups: Status.fromJson(json["allow_pickups"]),
        pickupNote: json["pickup_note"] == null ? '' : json["pickup_note"],
        pickupDestinations: List<PickupDestination>.from(json["pickup_destinations"].map((x) => x)),
        pickupDays: List<String>.from(json["pickup_days"].map((x) => x)),
        pickupTimes: List<String>.from(json["pickup_times"].map((x) => x)),
        allowPayments: Status.fromJson(json["allow_payments"]),
        orangeMoneyMerchantCode: json["orange_money_merchant_code"] == null ? '' : json["orange_money_merchant_code"],
        minimumStockQuantity: json["minimum_stock_quantity"],
        allowSendingMerchantSms: Status.fromJson(json["allow_sending_merchant_sms"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: LocationAttributes.fromJson(json["_attributes"]),
        links: LocationLinks.fromJson(json["_links"]),
        embedded: LocationEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "abbreviation": abbreviation,
        "currency": currency.toJson(),
        "about_us": aboutUs,
        "contact_us": contactUs,
        "call_to_action": callToAction,
        "online": online.toJson(),
        "offline_message": offlineMessage,
        "allow_delivery": allowDelivery.toJson(),
        "delivery_note": deliveryNote,
        "allow_free_delivery": allowFreeDelivery.toJson(),
        "delivery_flat_fee": deliveryFlatFee.toJson(),
        "delivery_destinations": List<dynamic>.from(deliveryDestinations.map((x) => x.toJson())),
        "delivery_days": List<dynamic>.from(deliveryDays.map((x) => x)),
        "delivery_times": List<dynamic>.from(deliveryTimes.map((x) => x)),
        "allow_pickups": allowPickups.toJson(),
        "pickup_note": pickupNote,
        "pickup_destinations": List<dynamic>.from(pickupDestinations.map((x) => x)),
        "pickup_days": List<dynamic>.from(pickupDays.map((x) => x)),
        "pickup_times": List<dynamic>.from(pickupTimes.map((x) => x)),
        "allow_payments": allowPayments.toJson(),
        "orange_money_merchant_code": orangeMoneyMerchantCode,
        "minimum_stock_quantity": minimumStockQuantity,
        "allow_sending_merchant_sms": allowSendingMerchantSms.toJson(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class DeliveryDestination {
    DeliveryDestination({
        required this.name,
        required this.cost,
        required this.allowFreeDelivery,
    });

    final String name;
    final Money cost;
    final Status allowFreeDelivery;

    factory DeliveryDestination.fromJson(Map<String, dynamic> json) => DeliveryDestination(
        name: json["name"],
        cost: Money.fromJson(json["cost"]),
        allowFreeDelivery: Status.fromJson(json["allow_free_delivery"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "cost": cost.toJson(),
        "allow_free_delivery": allowFreeDelivery.toJson(),
    };
}

class PickupDestination {
    PickupDestination({
        required this.name,
    });

    final String name;

    factory PickupDestination.fromJson(Map<String, dynamic> json) => PickupDestination(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}

class LocationAttributes {
    LocationAttributes({
        required this.resourceType,
    });

    final String resourceType;

    factory LocationAttributes.fromJson(Map<String, dynamic> json) => LocationAttributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
    };
}

class LocationEmbedded {
    LocationEmbedded({
        required this.onlinePaymentMethods,
        required this.offlinePaymentMethods,
    });

    final List<PaymentMethod> onlinePaymentMethods;
    final List<PaymentMethod> offlinePaymentMethods;

    factory LocationEmbedded.fromJson(Map<String, dynamic> json) => LocationEmbedded(
        onlinePaymentMethods: List<PaymentMethod>.from(json["online_payment_methods"].map((x) => PaymentMethod.fromJson(x))),
        offlinePaymentMethods: List<PaymentMethod>.from(json["offline_payment_methods"].map((x) => PaymentMethod.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "online_payment_methods": List<dynamic>.from(onlinePaymentMethods.map((x) => x.toJson())),
        "offline_payment_methods": List<dynamic>.from(offlinePaymentMethods.map((x) => x.toJson())),
    };
}

class LocationLinks {
    LocationLinks({
        required this.curies,
        required this.self,
        required this.bosStore,
        required this.bosTotals,
        required this.bosUsers,
        required this.bosOrders,
        required this.bosInstantCarts,
        required this.bosCoupons,
        required this.bosProducts,
        required this.bosCustomers,
        required this.bosProductArrangement,
        required this.bosFavouriteStatus,
        required this.bosToggleFavourite,
        required this.bosReportStatistics,
        required this.bosMyPermissions,
        required this.bosUserPermissions,
        required this.bosAvailablePermissions,
        required this.bosUpdateUserPermissions
    });

    final List<Cury> curies;
    final Link self;
    final Link bosStore;
    final Link bosTotals;
    final Link bosUsers;
    final Link bosOrders;
    final Link bosInstantCarts;
    final Link bosCoupons;
    final Link bosProducts;
    final Link bosCustomers;
    final Link bosProductArrangement;
    final Link bosFavouriteStatus;
    final Link bosToggleFavourite;
    final Link bosReportStatistics;
    final Link bosMyPermissions;
    final Link bosUserPermissions;
    final Link bosAvailablePermissions;
    final Link bosUpdateUserPermissions;

    factory LocationLinks.fromJson(Map<String, dynamic> json) => LocationLinks(
      curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
      self: Link.fromJson(json["self"]),
      bosStore: Link.fromJson(json["bos:store"]),
      bosTotals: Link.fromJson(json["bos:totals"]),
      bosUsers: Link.fromJson(json["bos:users"]),
      bosOrders: Link.fromJson(json["bos:orders"]),
      bosInstantCarts: Link.fromJson(json["bos:instant_carts"]),
      bosCoupons: Link.fromJson(json["bos:coupons"]),
      bosProducts: Link.fromJson(json["bos:products"]),
      bosCustomers: Link.fromJson(json["bos:customers"]),
      bosProductArrangement: Link.fromJson(json["bos:product_arrangement"]),
      bosFavouriteStatus: Link.fromJson(json["bos:favourite_status"]),
      bosToggleFavourite: Link.fromJson(json["bos:toggle_favourite"]),
      bosReportStatistics: Link.fromJson(json["bos:report_statistics"]),
      bosMyPermissions: Link.fromJson(json["bos:my_permissions"]),
      bosUserPermissions: Link.fromJson(json["bos:user_permissions"]),
      bosAvailablePermissions: Link.fromJson(json["bos:available_permissions"]),
      bosUpdateUserPermissions: Link.fromJson(json["bos:update_user_permissions"]),
    );

    Map<String, dynamic> toJson() => {
      "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
      "self": self.toJson(),
      "bos:store": bosStore.toJson(),
      "bos:totals": bosTotals.toJson(),
      "bos:users": bosUsers.toJson(),
      "bos:orders": bosOrders.toJson(),
      "bos:instant_carts": bosInstantCarts.toJson(),
      "bos:coupons": bosCoupons.toJson(),
      "bos:products": bosProducts.toJson(),
      "bos:customers": bosCustomers.toJson(),
      "bos:product_arrangement": bosProductArrangement.toJson(),
      "bos:favourite_status": bosFavouriteStatus.toJson(),
      "bos:toggle_favourite": bosToggleFavourite.toJson(),
      "bos:report_statistics": bosReportStatistics.toJson(),
      "bos:my_permissions": bosMyPermissions.toJson(),
      "bos:user_permissions": bosUserPermissions.toJson(),
      "bos:available_permissions": bosAvailablePermissions.toJson(),
      "bos:update_user_permissions": bosUpdateUserPermissions.toJson(),
    };
}