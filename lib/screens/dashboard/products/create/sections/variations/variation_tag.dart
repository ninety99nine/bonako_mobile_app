import 'package:flutter/material.dart';

class ProductVariationTag extends StatelessWidget {

  final String value;

  ProductVariationTag({ required this.value });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 1),
        borderRadius: const BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      child: Text(value, style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold))
    );
  }
}