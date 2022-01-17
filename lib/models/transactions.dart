import 'package:bonako_mobile_app/models/common/attributes/shortCodeAttribute.dart';
import 'package:bonako_mobile_app/models/users.dart';

import './common/paginationLinks.dart';
import './common/currency.dart';
import './paymentMethods.dart';
import './common/money.dart';
import './common/cury.dart';
import './statuses.dart';
import 'dart:convert';

PaginatedTransactions paginatedOrdersFromJson(String str) => PaginatedTransactions.fromJson(json.decode(str));

String paginatedOrdersToJson(PaginatedTransactions data) => json.encode(data.toJson());

class PaginatedTransactions {
    PaginatedTransactions({
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
    final EmbeddedTransactions embedded;

    factory PaginatedTransactions.fromJson(Map<String, dynamic> json) => PaginatedTransactions(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedTransactions.fromJson(json["_embedded"]),
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

class EmbeddedTransactions {
    EmbeddedTransactions({
        required this.transactions,
    });

    final List<Transaction> transactions;

    factory EmbeddedTransactions.fromJson(Map<String, dynamic> json) => EmbeddedTransactions(
        transactions: List<Transaction>.from(json["transactions"].map((x) => Transaction.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "transactions": List<dynamic>.from(transactions.map((x) => x.toJson())),
    };
}

class Transaction {
    Transaction({
        required this.id,
        required this.type,
        required this.number,
        required this.currency,
        required this.amount,
        required this.percentageRate,
        required this.userId,
        required this.payerId,
        required this.description,
        required this.paymentMethodId,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String type;
    final String number;
    final Currency currency;
    final Money amount;
    final int? percentageRate;
    final int userId;
    final int payerId;
    final String description;
    final String? paymentMethodId;
    final DateTime createdAt;
    final DateTime updatedAt;
    final TransactionAttributes attributes;
    final TransactionLinks links;
    final TransactionEmbedded embedded;

    factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json["id"],
        type: json["type"],
        number: json["number"],
        currency: Currency.fromJson(json["currency"]),
        amount: Money.fromJson(json["amount"]),
        percentageRate: json["percentage_rate"] == null ? null : json["percentage_rate"], 
        userId: json["user_id"],
        payerId: json["payer_id"],
        description: json["description"],
        paymentMethodId: json["payment_method_id"] == null ? null : json["payment_method_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: TransactionAttributes.fromJson(json["_attributes"]),
        links: TransactionLinks.fromJson(json["_links"]),
        embedded: TransactionEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "number": number,
        "currency": currency.toJson(),
        "amount": amount.toJson(),
        "percentage_rate": percentageRate,
        "user_id": userId,
        "payer_id": payerId,
        "description": description,
        "payment_method_id": paymentMethodId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class TransactionAttributes {
    TransactionAttributes({
        required this.resourceType,
        this.paymentShortCode,
        required this.hasPaymentShortCode,
    });

    final String resourceType;
    final ShortCodeAttribute? paymentShortCode;
    final bool hasPaymentShortCode;

    factory TransactionAttributes.fromJson(Map<String, dynamic> json) => TransactionAttributes(
        resourceType: json["resource_type"],
        paymentShortCode: json["payment_short_code"] == null ? null : ShortCodeAttribute.fromJson(json["payment_short_code"]),
        hasPaymentShortCode: json["has_payment_short_code"],
    );

    Map<String, dynamic> toJson() => {
        "resource_type": resourceType,
        "payment_short_code": paymentShortCode == null ? null : paymentShortCode!.toJson(),
        "has_payment_short_code": hasPaymentShortCode,
    };
}

class TransactionLinks {
    TransactionLinks({
        required this.curies,
    });

    final List<Cury> curies;

    factory TransactionLinks.fromJson(Map<String, dynamic> json) => TransactionLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x)))
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson()))
    };
}

class TransactionEmbedded {
    TransactionEmbedded({
        required this.status,
        required this.paymentMethod,
        required this.payer,
        required this.user,
    });

    final User? user;
    final User? payer;
    final StatusModel status;
    final PaymentMethod? paymentMethod;

    factory TransactionEmbedded.fromJson(Map<String, dynamic> json) => TransactionEmbedded(
        status: StatusModel.fromJson(json["status"]),
        paymentMethod: json["payment_method"] == null ? null : PaymentMethod.fromJson(json["payment_method"]),
        payer: json["payer"] == null ? null : User.fromJson(json["payer"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status.toJson(),
        "user": user == null ? null : user!.toJson(),
        "payer": payer == null ? null : payer!.toJson(),
        "payment_method": paymentMethod == null ? null : paymentMethod!.toJson(),
    };
}