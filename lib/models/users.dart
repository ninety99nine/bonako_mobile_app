import './common/paginationLinks.dart';
import './common/mobileNumber.dart';
import './common/status.dart';
import './common/link.dart';
import './common/cury.dart';
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

    int count;
    final int total;
    int currentPage;
    final int perPage;
    final int totalPages;
    final EmbeddedUsers embedded;
    final PaginationLinks links;

    factory PaginatedUsers.fromJson(Map<String, dynamic> json) => PaginatedUsers(
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        embedded: EmbeddedUsers.fromJson(json["_embedded"]),
        perPage: int.parse(json["per_page"].toString()),
        links: PaginationLinks.fromJson(json["_links"]),
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

class EmbeddedUsers {
    EmbeddedUsers({
        required this.users,
    });

    final List<User> users;

    factory EmbeddedUsers.fromJson(Map<String, dynamic> json) => EmbeddedUsers(
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
    final Status acceptedTermsAndConditions;
    final DateTime createdAt;
    final DateTime updatedAt;
    final UserAttributes attributes;
    final UserLinks links;
    final List<dynamic> embedded;

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        mobileNumber: MobileNumber.fromJson(json["mobile_number"]),
        acceptedTermsAndConditions: Status.fromJson(json["accepted_terms_and_conditions"]),
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
        "mobile_number": mobileNumber.toJson(),
        "accepted_terms_and_conditions": acceptedTermsAndConditions,
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
        required this.userLocation,
    });

    final String name;
    final UserLocation? userLocation;

    factory UserAttributes.fromJson(Map<String, dynamic> json) => UserAttributes(
        name: json["name"],
        userLocation: json["user_location"] == null ? null : UserLocation.fromJson(json["user_location"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "user_location": userLocation == null ? null : userLocation!.toJson(),
    };
}

class UserLocation {
    UserLocation({
        required this.type,
        required this.locationId,
    });

    final String type;
    final int locationId;

    factory UserLocation.fromJson(Map<String, dynamic> json) => UserLocation(
        type: json["type"],
        locationId: json["location_id"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "location_id": locationId,
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
    final Link self;
    final Link bosAddresses;
    final Link bosSubscriptions;
    final Link? bosStores;
    final Link? bosFavouriteStores;
    final Link? bosSharedStores;
    final Link? bosCreatedStores;
    final Link? bosAcceptTermsAndConditions;

    factory UserLinks.fromJson(Map<String, dynamic> json) => UserLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: Link.fromJson(json["self"]),
        bosAddresses: Link.fromJson(json["bos:addresses"]),
        bosSubscriptions: Link.fromJson(json["bos:subscriptions"]),
        bosStores: json["bos:stores"] == null ? null : Link.fromJson(json["bos:stores"]),
        bosFavouriteStores: json["bos:favourite-stores"] == null ? null : Link.fromJson(json["bos:favourite-stores"]),
        bosSharedStores: json["bos:shared-stores"] == null ? null : Link.fromJson(json["bos:shared-stores"]),
        bosCreatedStores: json["bos:created-stores"] == null ? null : Link.fromJson(json["bos:created-stores"]),
        bosAcceptTermsAndConditions: json["bos:accept-terms-and-conditions"] == null ? null : Link.fromJson(json["bos:accept-terms-and-conditions"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:addresses": bosAddresses.toJson(),
        "bos:subscriptions": bosSubscriptions.toJson(),
        "bos:stores": bosStores == null ? null : bosStores!.toJson(),
        "bos:favourite-stores": bosFavouriteStores == null ? null : bosFavouriteStores!.toJson(),
        "bos:shared-stores": bosSharedStores == null ? null : bosSharedStores!.toJson(),
        "bos:created-stores": bosCreatedStores == null ? null : bosCreatedStores!.toJson(),
        "bos:accept-terms-and-conditions": bosAcceptTermsAndConditions == null ? null : bosAcceptTermsAndConditions!.toJson(),
    };
}
