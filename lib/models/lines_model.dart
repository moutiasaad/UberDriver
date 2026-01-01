import 'dart:convert';


class LinesModel {
  final int id;
  final String driverOrderId;
  final String name;
  final String desc;
  final double unitPrice;
  final String quantity;
  final double totalPrice;
  final double deliveryCost;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String imageUrl;

  LinesModel({
    required this.id,
    required this.driverOrderId,
    required this.name,
    required this.desc,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    required this.deliveryCost,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
  });

  factory LinesModel.fromJson(Map<String, dynamic> json) {
    return LinesModel(
      id: int.parse(json['id'].toString()),
      driverOrderId: json['driver_order_id'] != null
          ? json['driver_order_id'].toString()
          : '',
      name: json['name'] ?? '',
      desc: json['description'] ?? '',
      unitPrice:
          json['unit_price'] != null ? double.parse(json['unit_price']) : 0.0,
      quantity: json['quantity'] != null ? json['quantity'].toString() : '0',
      totalPrice:
          json['total_price'] != null ? double.parse(json['total_price']) : 0.0,
      deliveryCost: json['delivery_cost'] != null
          ? double.parse(json['delivery_cost'])
          : 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      imageUrl: json['image'] != null
          ? json['image'].toString()
          : '',


    );
  }
}
