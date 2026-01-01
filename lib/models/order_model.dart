import 'lines_model.dart';
import 'merchant_model.dart';

class OrderModel {
  OrderModel({
    this.id,
    this.driverId,
    this.groupName,
    this.latitudeC,
    this.longitudeC,
    this.latitudeM,
    this.longitudeM,
    this.deliveryCost,
    this.totalPrice,
    this.address,
    this.phone,
    this.merchantFullName,
    this.merchantPhone,
    this.merchantNote,
    this.clientNote,
    this.adminNote,
    this.startDeliveryDate,
    this.endDeliveryDate,
    this.isPaid,
    this.isShipped,
    this.statusId,
    this.paymentNote,
    this.merchantId,
    this.fullName,
    this.statusColor,
    this.statusName,
    this.orderStatus,
    this.lines,
    this.createdAt,
  });

  final int? id;
  final String? driverId;
  final String? groupName;
  final String? latitudeC;
  final String? longitudeC;
  final String? latitudeM;
  final String? longitudeM;
  final String? deliveryCost;
  final String? totalPrice;
  final String? address;
  final String? phone;
  final String? merchantFullName;
  final String? merchantPhone;
  final String? merchantNote;
  final String? clientNote;
  final String? adminNote;
  final String? startDeliveryDate;
  final String? endDeliveryDate;
  final bool? isPaid;
  final bool? isShipped;
  final String? statusId;
  final String? paymentNote;
  final String? merchantId;
  final String? fullName;
  final String? statusColor;
  final String? statusName;
  final List<OrderStatusC>? orderStatus;
  final List<LinesModel>? lines;
  final String? createdAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: int.parse(json['id'].toString()),
      driverId: json['driver_id'] ?? '',
      groupName: json['group_name'] ?? '',
      latitudeC: json['latitude_client'] ?? '',
      longitudeC: json['longitude_client'] ?? '',
      latitudeM: json['latitude_marchent'] ?? '',
      longitudeM: json['longitude_marchent'] ?? '',
      deliveryCost: json['delivery_cost'] != null
          ? json['delivery_cost'].toString()
          : '0.0',
      totalPrice:
          json['total_price'] != null ? json['total_price'].toString() : '0.0',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      merchantFullName:json['marchent_fullname'] ?? '',
      merchantPhone: json['marchent_phone'] ?? '',
      merchantNote: json['marchent_note'] ?? '',
      clientNote: json['client_note'] ?? '',
      adminNote: json['admin_note'] ?? '',
      startDeliveryDate: json['start_date_delivery'] ?? '',
      endDeliveryDate: json['end_date_delivery'] ?? '',
      isPaid: json['is_paid'] ?? false,
      isShipped: json['is_shipped'] ?? false,
      statusId: json['status_id'] != null ? json['status_id'].toString() : '',
      paymentNote: json['payment_note'] ?? '',
      merchantId: json['merchant_id'] ?? '',
      fullName: json['fullname'] ?? '',
      statusColor: json['status_color'] ?? '',
      statusName: json['status_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      orderStatus: json['order_status'] != null
          ? List<OrderStatusC>.from(
              (json['order_status'] as List).map(
                (item) => OrderStatusC.fromJson(item),
              ),
            )
          : null,
      lines: json['lines'] != null
          ? List<LinesModel>.from(
              (json['lines'] as List).map(
                (item) => LinesModel.fromJson(item),
              ),
            )
          : null,
    );
  }
}

class OrderStatusC {
  OrderStatusC({this.title, this.date, this.status});

  final String? title;
  final String? date;
  final String? status;

  factory OrderStatusC.fromJson(Map<String, dynamic> json) {
    return OrderStatusC(
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      status: (json['status'] ?? '').toString(),
    );
  }
}
