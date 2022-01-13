import './common/paginationLinks.dart';
import './common/currency.dart';
import './common/status.dart';
import './common/money.dart';
import './common/cury.dart';
import './common/link.dart';
import './products.dart';
import 'dart:convert';

PaginatedItemLines paginatedItemLinesFromJson(String str) => PaginatedItemLines.fromJson(json.decode(str));

String paginatedItemLinesToJson(PaginatedItemLines data) => json.encode(data.toJson());

class PaginatedItemLines {
    PaginatedItemLines({
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
    final EmbeddedItemLines embedded;

    factory PaginatedItemLines.fromJson(Map<String, dynamic> json) => PaginatedItemLines(
        links: PaginationLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: EmbeddedItemLines.fromJson(json["_embedded"]),
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

class EmbeddedItemLines {
    EmbeddedItemLines({
        required this.itemLines,
    });

    final List<ItemLine> itemLines;

    factory EmbeddedItemLines.fromJson(Map<String, dynamic> json) => EmbeddedItemLines(
        itemLines: List<ItemLine>.from(json["item_lines"].map((x) => ItemLine.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "item_lines": List<dynamic>.from(itemLines.map((x) => x.toJson())),
    };
}

class ItemLine {
    ItemLine({
        required this.id,
        required this.name,
        required this.description,
        required this.sku,
        required this.barcode,
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
    final dynamic sku;
    final dynamic barcode;
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
    final List<dynamic> detectedChanges;
    final DateTime createdAt;
    final DateTime updatedAt;
    final ItemLineAttributes attributes;
    final ItemLineLinks links;
    final ItemLineEmbedded embedded;

    factory ItemLine.fromJson(Map<String, dynamic> json) => ItemLine(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        sku: json["sku"],
        barcode: json["barcode"],
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
        detectedChanges: List<dynamic>.from(json["detected_changes"].map((x) => x)),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        attributes: ItemLineAttributes.fromJson(json["_attributes"]),
        links: ItemLineLinks.fromJson(json["_links"]),
        embedded: ItemLineEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "sku": sku,
        "barcode": barcode,
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
        "detected_changes": List<dynamic>.from(detectedChanges.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class ItemLineAttributes {
    ItemLineAttributes({
        required this.onSale,
        required this.resourceType,
    });

    final Status onSale;
    final String resourceType;

    factory ItemLineAttributes.fromJson(Map<String, dynamic> json) => ItemLineAttributes(
        onSale: Status.fromJson(json["on_sale"]),
        resourceType: json["resource_type"],
    );

    Map<String, dynamic> toJson() => {
        "on_sale": onSale.toJson(),
        "resource_type": resourceType,
    };
}

class ItemLineLinks {
    ItemLineLinks({
        required this.curies,
    });

    final List<Cury> curies;

    factory ItemLineLinks.fromJson(Map<String, dynamic> json) => ItemLineLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x)))
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson()))
    };
}

class ItemLineEmbedded {
    ItemLineEmbedded({
        required this.product,
    });

    final Product product;

    factory ItemLineEmbedded.fromJson(Map<String, dynamic> json) => ItemLineEmbedded(
        product: Product.fromJson(json["product"]),
    );

    Map<String, dynamic> toJson() => {
        "product": product.toJson(),
    };
}