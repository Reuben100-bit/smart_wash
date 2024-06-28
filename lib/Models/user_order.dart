// order_model.dart

// service_model.dart

import 'package:laundry_mgmt_system/Models/message.dart';
import 'package:laundry_mgmt_system/Models/order_address.dart';

class Service {
  final String id;
  final String name;
  final List<Pricing> pricing;
  Service({required this.id, required this.name, required this.pricing});

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
        id: json['id'],
        name: json['name'],
        pricing: Pricing.fromJsonList(json['pricing']));
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'pricing': Pricing.toJsonList(pricing)};
  }
}

// pricing_model.dart

class Pricing {
  final String id;
  final double price;
  final String itemName;

  Pricing({required this.id, required this.price, required this.itemName});

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      id: json['id'],
      price: double.parse(json['price'].toString()),
      itemName: json['itemName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'price': price, 'itemName': itemName};
  }

  static List<Pricing> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Pricing.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<Pricing> pricings) {
    return pricings.map((pricing) => pricing.toJson()).toList();
  }
}

class UserOrderItem {
  String serviceName;
  Pricing pricing;
  int quantity;

  UserOrderItem({
    required this.serviceName,
    required this.pricing,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'service': serviceName,
      'pricing': pricing.toJson(),
      'quantity': quantity,
    };
  }
}

enum OrderStatus {
  pendingConfirmation,
  isOnHold,
  processing,
  requestCompleted,
  cancelled
}

enum RequestCompletedMethod { pickUp, delivery }

enum RequestReadyMethod { dropOff, pickUp }

String getServiceNames(List<UserOrderItem> items) {
  // Extract service names from each item
  List<String> serviceNames = items.map((item) => item.serviceName).toList();
  // Join the service names with comma
  return serviceNames.join(', ');
}

class UserOrder {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String laundryName;
  final List<UserOrderItem> items;
  OrderStatus status;
  final RequestReadyMethod requestReadyMethod;
  final RequestCompletedMethod requestCompletedMethod;
  final DateTime orderPlacementTime;
  final List<Message> messages;
  final OrderAddress? orderAddress;
  UserOrder(
      {required this.id,
      required this.senderId,
      required this.senderName,
      required this.laundryName,
      required this.receiverId,
      required this.items,
      required this.status,
      required this.requestReadyMethod,
      required this.requestCompletedMethod,
      required this.orderPlacementTime,
      required this.messages,
      required this.orderAddress});

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonItems = json['items'];
    List<UserOrderItem> orderItems = jsonItems.map((itemJson) {
      return UserOrderItem(
        serviceName: itemJson['service'],
        pricing: Pricing.fromJson(itemJson['pricing']),
        quantity: itemJson['quantity'],
      );
    }).toList();

    return UserOrder(
        id: json['id'],
        senderId: json['senderId'],
        senderName: json['senderName'],
        laundryName: json['laundryName'],
        receiverId: json['receiverId'],
        items: orderItems,
        status: mapFirestoreToStatus(json['status']),
        requestReadyMethod:
            mapFirestoreToRequestReadyMethod(json['requestReadyMethod']),
        requestCompletedMethod: mapFirestoreToRequestCompletedMethod(
            json['requestCompletedMethod']),
        orderPlacementTime: DateTime.parse(json['orderPlacementTime']),
        messages: json['messages'] == null
            ? []
            : Message.fromJsonList(json['messages']),
            orderAddress: json['orderAddress'] =="null" || json['orderAddress'] ==null ? null : OrderAddress.fromJson(json['orderAddress'])
            );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'laundryName': laundryName,
      'items': items.map((item) => item.toJson()).toList(),
      'status': mapStatusToFirestore(status),
      'requestReadyMethod':
          mapRequestReadyMethodToFirestore(requestReadyMethod),
      'requestCompletedMethod':
          mapRequestCompletedMethodToFirestore(requestCompletedMethod),
      'orderPlacementTime': orderPlacementTime.toString(),
      'messages': messages.map((e) => e.toMap()),
'orderAddress': orderAddress == null ? "null" : orderAddress!.toJson()

    };
  }

  static const String firestorePendingConfirmation = 'PendingConfirmation';
  static const String firestoreIsOnHold = 'IsOnHold';
  static const String firestoreProcessing = 'Processing';
  static const String firestoreRequestCompleted = 'Request Completed';
  static const String firestoreCancelled = 'Cancelled';

  bool get isProcessing => status == OrderStatus.processing;
  bool get isRequestCompleted => status == OrderStatus.requestCompleted;
  bool get isCancelled => status == OrderStatus.cancelled;

  static String mapStatusToFirestore(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingConfirmation:
        return firestorePendingConfirmation;
      case OrderStatus.isOnHold:
        return firestoreIsOnHold;
      case OrderStatus.requestCompleted:
        return firestoreRequestCompleted;
      case OrderStatus.processing:
        return firestoreProcessing;
      case OrderStatus.cancelled:
        return firestoreCancelled;
    }
  }

  static OrderStatus mapFirestoreToStatus(String firestoreValue) {
    switch (firestoreValue) {
      case firestorePendingConfirmation:
        return OrderStatus.pendingConfirmation;
      case firestoreIsOnHold:
        return OrderStatus.isOnHold;
      case firestoreProcessing:
        return OrderStatus.processing;
      case firestoreCancelled:
        return OrderStatus.cancelled;
      case firestoreRequestCompleted:
        return OrderStatus.requestCompleted;
      default:
        return OrderStatus.pendingConfirmation;
    }
  }

  static const String firestorePickUp = 'Pick Up';
  static const String firestoreDelivery = 'Delivery';
  static const String firestoreDropOff = 'Drop Off';

  static String mapRequestCompletedMethodToFirestore(
      RequestCompletedMethod method) {
    switch (method) {
      case RequestCompletedMethod.pickUp:
        return firestorePickUp;
      case RequestCompletedMethod.delivery:
        return firestoreDelivery;
    }
  }

  static String mapRequestReadyMethodToFirestore(RequestReadyMethod method) {
    switch (method) {
      case RequestReadyMethod.dropOff:
        return firestoreDropOff;
      case RequestReadyMethod.pickUp:
        return firestorePickUp;
    }
  }

  static RequestCompletedMethod mapFirestoreToRequestCompletedMethod(
      String firestoreValue) {
    switch (firestoreValue) {
      case firestorePickUp:
        return RequestCompletedMethod.pickUp;
      case firestoreDelivery:
        return RequestCompletedMethod.delivery;
      default:
        throw Exception(
            'Unsupported Firestore value for requestCompletedMethod: $firestoreValue');
    }
  }

  static RequestReadyMethod mapFirestoreToRequestReadyMethod(
      String firestoreValue) {
    switch (firestoreValue) {
      case firestoreDropOff:
        return RequestReadyMethod.dropOff;
      case firestorePickUp:
        return RequestReadyMethod.pickUp;
      default:
        throw Exception(
            'Unsupported Firestore value for requestReadyMethod: $firestoreValue');
    }
  }

  double calculateTotal() {
    double total = 0;
    for (var item in items) {
      total += item.pricing.price * item.quantity;
    }
    return total;
  }
}
