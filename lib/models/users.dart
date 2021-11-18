import 'dart:convert';

PaginatedUsers paginatedUsersFromJson(String str) => PaginatedUsers.fromJson(json.decode(str));

String paginatedUsersToJson(PaginatedUsers data) => json.encode(data.toJson());

class PaginatedUsers {
    PaginatedUsers({
      required this.links,
      required this.total,
      required this.count,
      required this.perPage,
      required this.currentPage,
      required this.totalPages,
      required this.embedded,
    });

    final PaginatedUsersLinks links;
    final int total;
    final int count;
    final int perPage;
    final int currentPage;
    final int totalPages;
    final Embedded embedded;

    factory PaginatedUsers.fromJson(Map<String, dynamic> json) => PaginatedUsers(
        links: PaginatedUsersLinks.fromJson(json["_links"]),
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
        required this.users,
    });

    final List<User> users;

    factory Embedded.fromJson(Map<String, dynamic> json) => Embedded(
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
    };
}

class User {
    User({
        required this.id,
        required this.firstName,
        required this.lastName,
        required this.mobileNumber,
        required this.acceptedTermsAndConditions,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String firstName;
    final String lastName;
    final MobileNumber mobileNumber;
    final BooleanStatus acceptedTermsAndConditions;
    final DateTime createdAt;
    final DateTime updatedAt;
    final Attributes attributes;
    final UserLinks links;
    final List<dynamic> embedded;

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        mobileNumber: MobileNumber.fromJson(json["mobile_number"]),
        acceptedTermsAndConditions: BooleanStatus.fromJson(json["accepted_terms_and_conditions"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: Attributes.fromJson(json["_attributes"]),
        links: UserLinks.fromJson(json["_links"]),
        embedded: List<dynamic>.from(json["_embedded"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "mobile_number": mobileNumber.toJson(),
        "accepted_terms_and_conditions": acceptedTermsAndConditions,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": List<dynamic>.from(embedded.map((x) => x)),
    };
}

class Attributes {
    Attributes({
        required this.name,
    });

    final String name;

    factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}

class BooleanStatus {
    BooleanStatus({
        required this.name,
        required this.status,
        required this.description,
    });

    final bool status;
    final String name;
    final String description;

    factory BooleanStatus.fromJson(Map<String, dynamic> json) => BooleanStatus(
        name: json["name"],
        status: json["status"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "status": status,
        "description": description,
    };
}

class UserLinks {
    UserLinks({
        required this.curies,
        required this.self,
        required this.bosAddresses,
        required this.bosSubscriptions,
        required this.bosStores,
        required this.bosFavouriteStores,
        required this.bosSharedStores,
        required this.bosCreatedStores,
        required this.bosAcceptTermsAndConditions,
    });

    final List<Cury> curies;
    final ResourceLink self;
    final ResourceLink bosAddresses;
    final ResourceLink bosSubscriptions;
    final ResourceLink bosStores;
    final ResourceLink bosFavouriteStores;
    final ResourceLink bosSharedStores;
    final ResourceLink bosCreatedStores;
    final ResourceLink bosAcceptTermsAndConditions;

    factory UserLinks.fromJson(Map<String, dynamic> json) => UserLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: ResourceLink.fromJson(json["self"]),
        bosAddresses: ResourceLink.fromJson(json["bos:addresses"]),
        bosSubscriptions: ResourceLink.fromJson(json["bos:subscriptions"]),
        bosStores: ResourceLink.fromJson(json["bos:stores"]),
        bosFavouriteStores: ResourceLink.fromJson(json["bos:favourite-stores"]),
        bosSharedStores: ResourceLink.fromJson(json["bos:shared-stores"]),
        bosCreatedStores: ResourceLink.fromJson(json["bos:created-stores"]),
        bosAcceptTermsAndConditions: ResourceLink.fromJson(json["bos:accept-terms-and-conditions"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:addresses": bosAddresses.toJson(),
        "bos:subscriptions": bosSubscriptions.toJson(),
        "bos:stores": bosStores.toJson(),
        "bos:favourite-stores": bosFavouriteStores.toJson(),
        "bos:shared-stores": bosSharedStores.toJson(),
        "bos:created-stores": bosCreatedStores.toJson(),
        "bos:accept-terms-and-conditions": bosAcceptTermsAndConditions.toJson(),
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

class PaginatedUsersLinks {
    PaginatedUsersLinks({
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

    factory PaginatedUsersLinks.fromJson(Map<String, dynamic> json) => PaginatedUsersLinks(
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
