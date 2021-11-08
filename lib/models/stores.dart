import 'dart:convert';

PaginatedStores paginatedStoresFromJson(String str) => PaginatedStores.fromJson(json.decode(str));

String paginatedStoresToJson(PaginatedStores data) => json.encode(data.toJson());

class PaginatedStores {
    PaginatedStores({
        required this.links,
        required this.total,
        required this.count,
        required this.perPage,
        required this.currentPage,
        required this.totalPages,
        required this.embedded,
    });

    final PaginatedStoresLinks links;
    int count;
    final int total;
    int currentPage;
    final int perPage;
    final int totalPages;
    final Embedded embedded;

    factory PaginatedStores.fromJson(Map<String, dynamic> json) => PaginatedStores(
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        embedded: Embedded.fromJson(json["_embedded"]),
        perPage: int.parse(json["per_page"].toString()),
        links: PaginatedStoresLinks.fromJson(json["_links"]),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
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
        required this.stores,
    });

    final List<Store> stores;

    factory Embedded.fromJson(Map<String, dynamic> json) => Embedded(
        stores: List<Store>.from(json["stores"].map((x) => Store.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "stores": List<dynamic>.from(stores.map((x) => x.toJson())),
    };
}

class Store {
    Store({
        required this.id,
        required this.name,
        required this.online,
        required this.offlineMessage,
        required this.allowSendingMerchantSms,
        required this.hexColor,
        required this.isFavourite,
        required this.totalFavouriteLocations,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final Online online;
    final dynamic offlineMessage;
    final bool allowSendingMerchantSms;
    final String hexColor;
    final bool isFavourite;
    final int totalFavouriteLocations;
    final DateTime createdAt;
    final DateTime updatedAt;
    final Attributes attributes;
    final StoreLinks links;
    final List<dynamic> embedded;

    factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json["id"],
        name: json["name"],
        online: Online.fromJson(json["online"]),
        offlineMessage: json["offline_message"],
        allowSendingMerchantSms: json["allow_sending_merchant_sms"],
        hexColor: json["hex_color"],
        isFavourite: json["is_favourite"],
        totalFavouriteLocations: json["total_favourite_locations"] ?? 0,
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: Attributes.fromJson(json["_attributes"]),
        links: StoreLinks.fromJson(json["_links"]),
        embedded: List<dynamic>.from(json["_embedded"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "online": online.toJson(),
        "offline_message": offlineMessage,
        "allow_sending_merchant_sms": allowSendingMerchantSms,
        "hex_color": hexColor,
        "is_favourite": isFavourite,
        "total_favourite_locations": totalFavouriteLocations,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": List<dynamic>.from(embedded.map((x) => x)),
    };
}

class Attributes {
    Attributes({
        required this.resourceType,
        this.visitShortCode,
        required this.hasVisitShortCode,
        this.paymentShortCode,
        required this.hasPaymentShortCode,
        this.subscription,
        required this.hasSubscription,
    });

    final String resourceType;
    final ShortCode? visitShortCode;
    final bool hasVisitShortCode;
    final ShortCode? paymentShortCode;
    final bool hasPaymentShortCode;
    final Subscription? subscription;
    final bool hasSubscription;

    factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        resourceType: json["resource_type"],
        visitShortCode: json["visit_short_code"] == null ? null : ShortCode.fromJson(json["visit_short_code"]),
        hasVisitShortCode: json["has_visit_short_code"],
        paymentShortCode: json["payment_short_code"] == null ? null : ShortCode.fromJson(json["payment_short_code"]),
        hasPaymentShortCode: json["has_payment_short_code"],
        subscription: json["subscription"] == null ? null : Subscription.fromJson(json["subscription"]),
        hasSubscription: json["has_subscription"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
        "visit_short_code": visitShortCode == null ? null : visitShortCode!.toJson(),
        "has_visit_short_code": hasVisitShortCode,
        "payment_short_code": paymentShortCode!.toJson(),
        "has_payment_short_code": hasPaymentShortCode,
        "subscription": subscription == null ? null : subscription!.toJson(),
        "has_subscription": hasSubscription,
    };
}

class ShortCode {
    ShortCode({
        required this.expiresAt,
        required this.dialingCode,
    });

    final DateTime expiresAt;
    final String dialingCode;

    factory ShortCode.fromJson(Map<String, dynamic> json) => ShortCode(
        expiresAt: DateTime.parse(json["expires_at"]),
        dialingCode: json["dialing_code"],
    );

    Map<String, dynamic> toJson() => {
        "expires_at": expiresAt.toIso8601String(),
        "dialing_code": dialingCode,
    };
}

class Subscription {
    Subscription({
        required this.id,
        required this.subscriptionPlanId,
        required this.startAt,
        required this.endAt,
    });

    final int id;
    final int subscriptionPlanId;
    final DateTime startAt;
    final DateTime endAt;

    factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json["id"],
        subscriptionPlanId: json["subscription_plan_id"],
        startAt: DateTime.parse(json["start_at"]),
        endAt: DateTime.parse(json["end_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "subscription_plan_id": subscriptionPlanId,
        "start_at": startAt.toIso8601String(),
        "end_at": endAt.toIso8601String(),
    };
}

class StoreLinks {
    StoreLinks({
        required this.curies,
        required this.self,
        required this.bosMyStoreLocations,
        required this.bosMyStoreLocation,
        required this.bosLocations,
        required this.bosSubscribe,
        required this.bosGeneratePaymentShortcode,
    });

    final List<Cury> curies;
    final StoreLink self;
    final StoreLink bosMyStoreLocations;
    final StoreLink bosMyStoreLocation;
    final StoreLink bosLocations;
    final StoreLink bosSubscribe;
    final StoreLink bosGeneratePaymentShortcode;

    factory StoreLinks.fromJson(Map<String, dynamic> json) => StoreLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: StoreLink.fromJson(json["self"]),
        bosMyStoreLocations: StoreLink.fromJson(json["bos:my-store-locations"]),
        bosMyStoreLocation: StoreLink.fromJson(json["bos:my-store-default-location"]),
        bosLocations: StoreLink.fromJson(json["bos:locations"]),
        bosSubscribe: StoreLink.fromJson(json["bos:subscribe"]),
        bosGeneratePaymentShortcode: StoreLink.fromJson(json["bos:generate-payment-shortcode"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:my-store-locations": bosMyStoreLocations.toJson(),
        "bos:my-store-default-location": bosMyStoreLocation.toJson(),
        "bos:locations": bosLocations.toJson(),
        "bos:subscribe": bosSubscribe.toJson(),
        "bos:generate-payment-shortcode": bosGeneratePaymentShortcode.toJson(),
    };
}

class StoreLink {
    StoreLink({
        required this.href,
        required this.title,
    });

    final dynamic href;
    final dynamic title;

    factory StoreLink.fromJson(Map<String, dynamic> json) => StoreLink(
        href: json["href"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "href": href,
        "title": title,
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

class Online {
    Online({
        required this.status,
        required this.name,
        required this.description,
    });

    final bool status;
    final String name;
    final String description;

    factory Online.fromJson(Map<String, dynamic> json) => Online(
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

class PaginatedStoresLinks {
    PaginatedStoresLinks({
        required this.self,
        required this.first,
        required this.prev,
        required this.next,
        required this.last,
        required this.search,
    });

    final StoreLink self;
    final StoreLink first;
    final StoreLink prev;
    final StoreLink next;
    final StoreLink last;
    final Search search;

    factory PaginatedStoresLinks.fromJson(Map<String, dynamic> json) => PaginatedStoresLinks(
        self: StoreLink.fromJson(json["self"]),
        first: StoreLink.fromJson(json["first"]),
        prev: StoreLink.fromJson(json["prev"]),
        next: StoreLink.fromJson(json["next"]),
        last: StoreLink.fromJson(json["last"]),
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
