

class OrderStatusModel {
  OrderStatusModel({
    this.id,
    this.name,
  });

  final int? id;
  final String? name;

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      id: json['id'],
      name: json['name_ar'],

    );
  }
}
