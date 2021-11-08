import 'dart:convert';

PaginatedProducts paginatedProductsFromJson(String str) => PaginatedProducts.fromJson(json.decode(str));

String paginatedProductsToJson(PaginatedProducts data) => json.encode(data.toJson());

class PaginatedProducts {
    PaginatedProducts({
        required this.links,
        required this.total,
        required this.count,
        required this.perPage,
        required this.currentPage,
        required this.totalPages,
        required this.embedded,
    });

    final PaginatedProductsLinks links;
    final int total;
    int count;
    final int perPage;
    int currentPage;
    final int totalPages;
    final PaginatedProductsEmbedded embedded;

    factory PaginatedProducts.fromJson(Map<String, dynamic> json) => PaginatedProducts(
        links: PaginatedProductsLinks.fromJson(json["_links"]),
        total: int.parse(json["total"].toString()),
        count: int.parse(json["count"].toString()),
        perPage: int.parse(json["per_page"].toString()),
        totalPages: int.parse(json["total_pages"].toString()),
        currentPage: int.parse(json["current_page"].toString()),
        embedded: PaginatedProductsEmbedded.fromJson(json["_embedded"]),
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

class PaginatedProductsEmbedded {
    PaginatedProductsEmbedded({
        required this.products,
    });

    final List<Product> products;

    factory PaginatedProductsEmbedded.fromJson(Map<String, dynamic> json) => PaginatedProductsEmbedded(
        products: List<Product>.from(json["products"].map((x) => Product.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "products": List<dynamic>.from(products.map((x) => x.toJson())),
    };
}

class Product {
    Product({
        required this.id,
        required this.name,
        required this.description,
        required this.showDescription,
        required this.sku,
        required this.barcode,
        required this.visible,
        required this.productTypeId,
        required this.allowVariants,
        required this.variantAttributes,
        required this.isFree,
        required this.currency,
        required this.unitRegularPrice,
        required this.unitSalePrice,
        required this.unitCost,
        required this.allowMultipleQuantityPerOrder,
        required this.allowMaximumQuantityPerOrder,
        required this.maximumQuantityPerOrder,
        required this.allowStockManagement,
        required this.autoManageStock,
        required this.stockQuantity,
        required this.parentProductId,
        required this.userId,
        required this.createdAt,
        required this.updatedAt,
        required this.attributes,
        required this.links,
        required this.embedded,
    });

    final int id;
    final String name;
    final dynamic description;
    final Status showDescription;
    final dynamic sku;
    final dynamic barcode;
    final Status visible;
    final int productTypeId;
    final Status allowVariants;
    final List<dynamic> variantAttributes;
    final Status isFree;
    final Currency currency;
    final Money unitRegularPrice;
    final Money unitSalePrice;
    final Money unitCost;
    final Status allowMultipleQuantityPerOrder;
    final Status allowMaximumQuantityPerOrder;
    final int maximumQuantityPerOrder;
    final Status allowStockManagement;
    final Status autoManageStock;
    final StockQuantity stockQuantity;
    final dynamic parentProductId;
    final int userId;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final Attributes attributes;
    final ProductLinks links;
    final ProductEmbedded embedded;

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        showDescription: Status.fromJson(json["show_description"]),
        sku: json["sku"],
        barcode: json["barcode"],
        visible: Status.fromJson(json["visible"]),
        productTypeId: json["product_type_id"],
        allowVariants: Status.fromJson(json["allow_variants"]),
        variantAttributes: List<dynamic>.from(json["variant_attributes"].map((x) => x)),
        isFree: Status.fromJson(json["is_free"]),
        currency: Currency.fromJson(json["currency"]),
        unitRegularPrice: Money.fromJson(json["unit_regular_price"]),
        unitSalePrice: Money.fromJson(json["unit_sale_price"]),
        unitCost: Money.fromJson(json["unit_cost"]),
        allowMultipleQuantityPerOrder: Status.fromJson(json["allow_multiple_quantity_per_order"]),
        allowMaximumQuantityPerOrder: Status.fromJson(json["allow_maximum_quantity_per_order"]),
        maximumQuantityPerOrder: json["maximum_quantity_per_order"],
        allowStockManagement: Status.fromJson(json["allow_stock_management"]),
        autoManageStock: Status.fromJson(json["auto_manage_stock"]),
        stockQuantity: StockQuantity.fromJson(json["stock_quantity"]),
        parentProductId: json["parent_product_id"],
        userId: json["user_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["created_at"] == null ? null : DateTime.parse(json["updated_at"]),
        attributes: Attributes.fromJson(json["_attributes"]),
        links: ProductLinks.fromJson(json["_links"]),
        embedded: ProductEmbedded.fromJson(json["_embedded"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "show_description": showDescription.toJson(),
        "sku": sku,
        "barcode": barcode,
        "visible": visible.toJson(),
        "product_type_id": productTypeId,
        "allow_variants": allowVariants.toJson(),
        "variant_attributes": List<dynamic>.from(variantAttributes.map((x) => x)),
        "is_free": isFree.toJson(),
        "currency": currency.toJson(),
        "unit_regular_price": unitRegularPrice.toJson(),
        "unit_sale_price": unitSalePrice.toJson(),
        "unit_cost": unitCost.toJson(),
        "allow_multiple_quantity_per_order": allowMultipleQuantityPerOrder.toJson(),
        "allow_maximum_quantity_per_order": allowMaximumQuantityPerOrder.toJson(),
        "maximum_quantity_per_order": maximumQuantityPerOrder,
        "allow_stock_management": allowStockManagement.toJson(),
        "auto_manage_stock": autoManageStock.toJson(),
        "stock_quantity": stockQuantity.toJson(),
        "parent_product_id": parentProductId,
        "user_id": userId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "_attributes": attributes.toJson(),
        "_links": links.toJson(),
        "_embedded": embedded.toJson(),
    };
}

class Status {
    Status({
        required this.status,
        required this.name,
        required this.description,
        required this.type,
    });

    final bool status;
    final String name;
    final String description;
    final dynamic type;

    factory Status.fromJson(Map<String, dynamic> json) => Status(
        status: json["status"],
        name: json["name"],
        description: json["description"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "name": name,
        "description": description,
        "type": type,
    };
}

class Attributes {
    Attributes({
        required this.onSale,
        required this.hasPrice,
        required this.unitPrice,
        required this.unitLoss,
        required this.unitProfit,
        required this.unitSaleDiscount,
        required this.unitSalePercentage,
        required this.hasStock,
    });

    final Status onSale;
    final Status hasPrice;
    final Money unitPrice;
    final Money unitLoss;
    final Money unitProfit;
    final Money unitSaleDiscount;
    final dynamic unitSalePercentage;
    final Status hasStock;

    factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        onSale: Status.fromJson(json["on_sale"]),
        hasPrice: Status.fromJson(json["has_price"]),
        unitPrice: Money.fromJson(json["unit_price"]),
        unitLoss: Money.fromJson(json["unit_loss"]),
        unitProfit: Money.fromJson(json["unit_profit"]),
        unitSaleDiscount: Money.fromJson(json["unit_sale_discount"]),
        unitSalePercentage: json["unit_sale_percentage"],
        hasStock: Status.fromJson(json["has_stock"]),
    );

    Map<String, dynamic> toJson() => {
        "on_sale": onSale.toJson(),
        "has_price": hasPrice.toJson(),
        "unit_price": unitPrice.toJson(),
        "unit_loss": unitLoss.toJson(),
        "unit_profit": unitProfit.toJson(),
        "unit_sale_discount": unitSaleDiscount.toJson(),
        "unit_sale_percentage": unitSalePercentage,
        "has_stock": hasStock.toJson(),
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
    final num amount;

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

class Currency {
    Currency({
        required this.code,
        required this.symbol,
    });

    final String code;
    final String symbol;

    factory Currency.fromJson(Map<String, dynamic> json) => Currency(
        code: json["code"],
        symbol: json["symbol"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "symbol": symbol,
    };
}

class ProductEmbedded {
    ProductEmbedded({
        required this.variables,
    });

    final List<dynamic> variables;

    factory ProductEmbedded.fromJson(Map<String, dynamic> json) => ProductEmbedded(
        variables: List<dynamic>.from(json["variables"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "variables": List<dynamic>.from(variables.map((x) => x)),
    };
}

class ProductLinks {
    ProductLinks({
        required this.curies,
        required this.self,
        required this.bosLocations,
        required this.bosVariations,
    });

    final List<Cury> curies;
    final Link self;
    final Link bosLocations;
    final Link bosVariations;

    factory ProductLinks.fromJson(Map<String, dynamic> json) => ProductLinks(
        curies: List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
        self: Link.fromJson(json["self"]),
        bosLocations: Link.fromJson(json["bos:locations"]),
        bosVariations: Link.fromJson(json["bos:variations"]),
    );

    Map<String, dynamic> toJson() => {
        "curies": List<dynamic>.from(curies.map((x) => x.toJson())),
        "self": self.toJson(),
        "bos:locations": bosLocations.toJson(),
        "bos:variations": bosVariations.toJson(),
    };
}

class Link {
    Link({
        required this.href,
        required this.title,
    });

    final dynamic href;
    final dynamic title;

    factory Link.fromJson(Map<String, dynamic> json) => Link(
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

class StockQuantity {
    StockQuantity({
        required this.value,
        required this.description,
    });

    final int value;
    final String description;

    factory StockQuantity.fromJson(Map<String, dynamic> json) => StockQuantity(
        value: json["value"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "value": value,
        "description": description,
    };
}

class PaginatedProductsLinks {
    PaginatedProductsLinks({
        required this.self,
        required this.first,
        required this.prev,
        required this.next,
        required this.last,
        required this.search,
    });

    final Link self;
    final Link first;
    final Link prev;
    final Link next;
    final Link last;
    final Search search;

    factory PaginatedProductsLinks.fromJson(Map<String, dynamic> json) => PaginatedProductsLinks(
        self: Link.fromJson(json["self"]),
        first: Link.fromJson(json["first"]),
        prev: Link.fromJson(json["prev"]),
        next: Link.fromJson(json["next"]),
        last: Link.fromJson(json["last"]),
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
