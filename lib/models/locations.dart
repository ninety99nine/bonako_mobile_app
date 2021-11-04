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

    final PaginatedLocationsLinks links;
    final int total;
    final int count;
    final int perPage;
    final int currentPage;
    final int totalPages;
    final Embedded embedded;

    factory PaginatedLocations.fromJson(Map<String, dynamic> json) => PaginatedLocations(
        links: PaginatedLocationsLinks.fromJson(json["_links"]),
        total: json["total"] ?? 0,
        count: json["count"] ?? 0,
        perPage: json["per_page"],
        currentPage: json["current_page"] ?? 0,
        totalPages: json["total_pages"] ?? 0,
        embedded: Embedded.fromJson(json["_embedded"]),
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

class Embedded {
    Embedded({
        required this.locations,
    });

    final List<Location> locations;

    factory Embedded.fromJson(Map<String, dynamic> json) => Embedded(
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
        this.abbreviation,
        required this.currency,
        this.aboutUs,
        this.contactUs,
        required this.callToAction,
        required this.online,
        this.offlineMessage,
        required this.allowDelivery,
        this.deliveryNote,
        required this.allowFreeDelivery,
        required this.deliveryFlatFee,
        required this.deliveryDestinations,
        required this.deliveryDays,
        required this.deliveryTimes,
        required this.allowPickups,
        this.pickupNote,
        required this.pickupDestinations,
        required this.pickupDays,
        required this.pickupTimes,
        required this.allowPayments,
        this.orangeMoneyMerchantCode,
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
    final dynamic abbreviation;
    final Currency currency;
    final dynamic aboutUs;
    final dynamic contactUs;
    final String callToAction;
    final AllowDelivery online;
    final dynamic offlineMessage;
    final AllowDelivery allowDelivery;
    final dynamic deliveryNote;
    final AllowDelivery allowFreeDelivery;
    final Money deliveryFlatFee;
    final List<DeliveryDestination> deliveryDestinations;
    final List<String> deliveryDays;
    final List<String> deliveryTimes;
    final AllowDelivery allowPickups;
    final dynamic pickupNote;
    final List<String> pickupDestinations;
    final List<String> pickupDays;
    final List<String> pickupTimes;
    final AllowDelivery allowPayments;
    final dynamic orangeMoneyMerchantCode;
    final int minimumStockQuantity;
    final AllowDelivery allowSendingMerchantSms;
    final DateTime createdAt;
    final DateTime updatedAt;
    final Attributes attributes;
    final LocationLinks links;
    final LocationEmbedded embedded;

    factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json["id"],
        name: json["name"],
        abbreviation: json["abbreviation"],
        currency: Currency.fromJson(json["currency"]),
        aboutUs: json["about_us"],
        contactUs: json["contact_us"],
        callToAction: json["call_to_action"],
        online: AllowDelivery.fromJson(json["online"]),
        offlineMessage: json["offline_message"],
        allowDelivery: AllowDelivery.fromJson(json["allow_delivery"]),
        deliveryNote: json["delivery_note"],
        allowFreeDelivery: AllowDelivery.fromJson(json["allow_free_delivery"]),
        deliveryFlatFee: Money.fromJson(json["delivery_flat_fee"]),
        deliveryDestinations: List<DeliveryDestination>.from(json["delivery_destinations"].map((x) => DeliveryDestination.fromJson(x))),
        deliveryDays: List<String>.from(json["delivery_days"].map((x) => x)),
        deliveryTimes: List<String>.from(json["delivery_times"].map((x) => x)),
        allowPickups: AllowDelivery.fromJson(json["allow_pickups"]),
        pickupNote: json["pickup_note"],
        pickupDestinations: List<String>.from(json["pickup_destinations"].map((x) => x)),
        pickupDays: List<String>.from(json["pickup_days"].map((x) => x)),
        pickupTimes: List<String>.from(json["pickup_times"].map((x) => x)),
        allowPayments: AllowDelivery.fromJson(json["allow_payments"]),
        orangeMoneyMerchantCode: json["orange_money_merchant_code"],
        minimumStockQuantity: json["minimum_stock_quantity"],
        allowSendingMerchantSms: AllowDelivery.fromJson(json["allow_sending_merchant_sms"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: Attributes.fromJson(json["_attributes"]),
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

class AllowDelivery {
    AllowDelivery({
        required this.status,
        required this.name,
        required this.description,
    });

    final bool status;
    final String name;
    final String description;

    factory AllowDelivery.fromJson(Map<String, dynamic> json) => AllowDelivery(
        status: json["status"],
        name: json["name"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "name": name,
        "description": description,
    };
}

class Attributes {
    Attributes({
        required this.resourceType,
    });

    final String resourceType;

    factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
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
        code: json["code"] == null ? null : json["code"],
        symbol: json["symbol"] == null ? null : json["symbol"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "symbol": symbol,
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
    final AllowDelivery allowFreeDelivery;

    factory DeliveryDestination.fromJson(Map<String, dynamic> json) => DeliveryDestination(
        name: json["name"],
        cost: Money.fromJson(json["cost"]),
        allowFreeDelivery: AllowDelivery.fromJson(json["allow_free_delivery"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "cost": cost.toJson(),
        "allow_free_delivery": allowFreeDelivery.toJson(),
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
    final int amount;

    factory Money.fromJson(Map<String, dynamic> json) => Money(
        currencyMoney: json["currency_money"],
        money: json["money"],
        amount: json["amount"],
    );

    Map<String, dynamic> toJson() => {
        "currency_money": currencyMoney,
        "money": money,
        "amount": amount,
    };
}

class LocationEmbedded {
    LocationEmbedded({
        required this.onlinePaymentMethods,
        required this.offlinePaymentMethods,
    });

    final List<LinePaymentMethod> onlinePaymentMethods;
    final List<LinePaymentMethod> offlinePaymentMethods;

    factory LocationEmbedded.fromJson(Map<String, dynamic> json) => LocationEmbedded(
        onlinePaymentMethods: List<LinePaymentMethod>.from(json["online_payment_methods"].map((x) => LinePaymentMethod.fromJson(x))),
        offlinePaymentMethods: List<LinePaymentMethod>.from(json["offline_payment_methods"].map((x) => LinePaymentMethod.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "online_payment_methods": List<dynamic>.from(onlinePaymentMethods.map((x) => x.toJson())),
        "offline_payment_methods": List<dynamic>.from(offlinePaymentMethods.map((x) => x.toJson())),
    };
}

class LinePaymentMethod {
    LinePaymentMethod({
        required this.id,
        required this.name,
        required this.type,
        required this.description,
        required this.usedOnline,
        required this.usedOffline,
        required this.active,
        required this.attributes,
        required this.links,
    });

    final int id;
    final String name;
    final String type;
    final String description;
    final bool usedOnline;
    final bool usedOffline;
    final bool active;
    final Attributes attributes;
    final OfflinePaymentMethodLinks links;

    factory LinePaymentMethod.fromJson(Map<String, dynamic> json) => LinePaymentMethod(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        description: json["description"],
        usedOnline: json["used_online"],
        usedOffline: json["used_offline"],
        active: json["active"],
        attributes: Attributes.fromJson(json["_attributes"]),
        links: OfflinePaymentMethodLinks.fromJson(json["_links"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "description": description,
        "used_online": usedOnline,
        "used_offline": usedOffline,
        "active": active,
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
    };
}

class OfflinePaymentMethodLinks {
    OfflinePaymentMethodLinks({
        required this.curies,
    });

    final List<Cury> curies;

    factory OfflinePaymentMethodLinks.fromJson(Map<String, dynamic> json) => OfflinePaymentMethodLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
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
    });

    final List<Cury> curies;
    final ResourceLink self;
    final ResourceLink bosStore;
    final ResourceLink bosTotals;
    final ResourceLink bosUsers;
    final ResourceLink bosOrders;
    final ResourceLink bosInstantCarts;
    final ResourceLink bosCoupons;
    final ResourceLink bosProducts;
    final ResourceLink bosCustomers;
    final ResourceLink bosProductArrangement;
    final ResourceLink bosFavouriteStatus;
    final ResourceLink bosToggleFavourite;
    final ResourceLink bosReportStatistics;

    factory LocationLinks.fromJson(Map<String, dynamic> json) => LocationLinks(
      curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
      self: ResourceLink.fromJson(json["self"]),
      bosStore: ResourceLink.fromJson(json["bos:store"]),
      bosTotals: ResourceLink.fromJson(json["bos:totals"]),
      bosUsers: ResourceLink.fromJson(json["bos:users"]),
      bosOrders: ResourceLink.fromJson(json["bos:orders"]),
      bosInstantCarts: ResourceLink.fromJson(json["bos:instant_carts"]),
      bosCoupons: ResourceLink.fromJson(json["bos:coupons"]),
      bosProducts: ResourceLink.fromJson(json["bos:products"]),
      bosCustomers: ResourceLink.fromJson(json["bos:customers"]),
      bosProductArrangement: ResourceLink.fromJson(json["bos:product_arrangement"]),
      bosFavouriteStatus: ResourceLink.fromJson(json["bos:favourite_status"]),
      bosToggleFavourite: ResourceLink.fromJson(json["bos:toggle_favourite"]),
      bosReportStatistics: ResourceLink.fromJson(json["bos:report_statistics"]),
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
    };
}

class ResourceLink {
    ResourceLink({
        required this.href,
        required this.title,
    });

    final String href;
    final String title;

    factory ResourceLink.fromJson(Map<String, dynamic> json) => ResourceLink(
        href: json["href"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "href": href,
        "title": title,
    };
}

class PaginatedLocationsLinks {
    PaginatedLocationsLinks({
        required this.self,
        required this.first,
        required this.prev,
        required this.next,
        required this.last,
        required this.search,
    });

    final ResourceLink self;
    final ResourceLink first;
    final ResourceLink prev;
    final ResourceLink next;
    final ResourceLink last;
    final Search search;

    factory PaginatedLocationsLinks.fromJson(Map<String, dynamic> json) => PaginatedLocationsLinks(
        self: ResourceLink.fromJson(json["self"]),
        first: ResourceLink.fromJson(json["first"]),
        prev: ResourceLink.fromJson(json["prev"]),
        next: ResourceLink.fromJson(json["next"]),
        last: ResourceLink.fromJson(json["last"]),
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
