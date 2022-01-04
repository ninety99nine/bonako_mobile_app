import './search.dart';
import './link.dart';

class PaginationLinks {
    PaginationLinks({
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

    factory PaginationLinks.fromJson(Map<String, dynamic> json) => PaginationLinks(
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