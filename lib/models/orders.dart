import './common/attributes/shortCodeAttribute.dart';
import './common/paginationLinks.dart';
import './deliveryLines.dart';
import './transactions.dart';
import './common/link.dart';
import './common/cury.dart';
import './customers.dart';
import './statuses.dart';
import './carts.dart';
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

    final PaginationLinks links;
    int count;
    final int total;
    int currentPage;
    final int perPage;
    final int totalPages;
    final EmbeddedOrders embedded;

    factory PaginatedOrders.fromJson(Map<String, dynamic> json) => PaginatedOrders(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedOrders.fromJson(json["_embedded"]),
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

class EmbeddedOrders {
    EmbeddedOrders({
        required this.orders,
    });

    final List<Order> orders;

    factory EmbeddedOrders.fromJson(Map<String, dynamic> json) => EmbeddedOrders(
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
    final DateTime? deliveryVerifiedAt;
    final int? customerId;
    final int? locationId;
    final String? cancellationReason;
    final DateTime? requestCustomerRatingAt;
    final DateTime? createdAt;
    final DateTime? updatedAt;
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
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
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
    final ShortCodeAttribute? paymentShortCode;

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

    final StatusModel status;
    final StatusModel paymentStatus;
    final StatusModel deliveryStatus;
    final Cart activeCart;
    final DeliveryLine? deliveryLine;
    final Transaction? transaction;
    final Customer customer;

    factory OrderEmbedded.fromJson(Map<String, dynamic> json) => OrderEmbedded(
        status: StatusModel.fromJson(json["status"]),
        paymentStatus: StatusModel.fromJson(json["payment_status"]),
        deliveryStatus: StatusModel.fromJson(json["delivery_status"]),
        activeCart: Cart.fromJson(json["active_cart"]),
        deliveryLine: json["delivery_line"] == null ? null : DeliveryLine.fromJson(json["delivery_line"]),
        transaction: json["transaction"] == null ? null : Transaction.fromJson(json["transaction"]),
        customer: Customer.fromJson(json["customer"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status.toJson(),
        "payment_status": paymentStatus.toJson(),
        "delivery_status": deliveryStatus.toJson(),
        "active_cart": activeCart.toJson(),
        "delivery_line": deliveryLine == null ? null : deliveryLine!.toJson(),
        "transaction": transaction == null ? null : transaction!.toJson(),
        "customer": customer.toJson(),
    };
}