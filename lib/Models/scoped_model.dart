// Example: Firebase authentication using Email and Password
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_mgmt_system/Models/notification.dart';
import 'package:laundry_mgmt_system/Models/user.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:laundry_mgmt_system/main.dart';
import 'package:scoped_model/scoped_model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class MyScopedModel extends Model {
  UserProfile? authenticatedUser;
  List<UserProfile> laundries = [];
  List<LaundryService> laundryServices = [];
  List<UserOrderItem> userOrderItems = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Service> services = [];
  List<Pricing> pricing = [];
  List<UserOrder> userOrders = [];
  // Future<bool> addPricing(Pricing pricing, bool isNew) async {
  //   if (isNew) {
  //     try {
  //       if (authenticatedUser!.id != null) {
  //         final docRef = await _firestore
  //             .collection('userData')
  //             .doc(authenticatedUser!.id)
  //             .collection("services")
  //             .doc(pricing.service.id)
  //             .set(pricing.toJson());
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     } catch (ex) {
  //       return false;
  //     }
  //   } else {
  //     try {
  //       if (authenticatedUser!.id != null) {
  //         await FirebaseFirestore.instance
  //             .collection('userData')
  //             .doc(authenticatedUser!.id)
  //             .collection("services")
  //             .doc(pricing.service.id)
  //             .set(pricing.toJson());
  //         return true;
  //       } else {
  //         return false;
  //       }
  //     } catch (ex) {
  //       print('Error updating document: $ex');
  //       return false;
  //     }
  //   }
  // }

  List<Service> getPricingForService(Service service) {
    return services.where((element) => element.id == service.id).toList();
  }

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload(String message) {
    return jsonEncode({
      'token': firebaseMessagingToken,
      'data': {
        'title': 'FlutterFire Cloud Messaging!!!',
        'message': message,
      },
      'notification': {
        'title': 'Laundry Management System',
        'body': message,
      },
    });
  }

  Future<void> sendPushMessage(String message) async {
    if (firebaseMessagingToken == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(message),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  Future<bool> addUserOrder(UserOrder userOrder, bool isNew) async {
    try {
      if (isNew) {
        final docRef = _firestore
            .collection('userData')
            .doc(userOrder.senderId)
            .collection("orders")
            .doc(userOrder.id)
            .set(userOrder.toJson());

        final docRef2 = _firestore
            .collection('userData')
            .doc(userOrder.receiverId)
            .collection("orders")
            .doc(userOrder.id)
            .set(userOrder.toJson());

        NotificationModel notification = NotificationModel(
            id: userOrder.id,
            content: "${userOrder.senderName} has placed a new order.",
            title: "New Order Added",
            dateTime: DateTime.now().toString(),
            isRead: false);
        final docRef3 = _firestore
            .collection('userData')
            .doc(userOrder.receiverId)
            .collection("notifications")
            .doc(notification.id)
            .set(notification.toJson());
        await Future.wait([docRef, docRef2, docRef3]);
        return true;
      } else {
        final docRef = _firestore
            .collection('userData')
            .doc(userOrder.senderId)
            .collection("orders")
            .doc(userOrder.id)
            .update(userOrder.toJson());

        final docRef2 = _firestore
            .collection('userData')
            .doc(userOrder.receiverId)
            .collection("orders")
            .doc(userOrder.id)
            .update(userOrder.toJson());

        String message = "";
        if (userOrder.status == OrderStatus.cancelled &&
            authenticatedUser!.id == userOrder.receiverId) {
          message = "${userOrder.laundryName} has cancelled the order.";
        } else if (userOrder.status == OrderStatus.cancelled &&
            authenticatedUser!.id == userOrder.senderId) {
          message = "${userOrder.senderName} has cancelled the order.";
        } else {
          message = "${userOrder.senderName} has made changes to order.";
        }
        NotificationModel notification = NotificationModel(
            id: userOrder.id,
            content: message,
            title: "Order updated",
            dateTime: DateTime.now().toString(),
            isRead: false);
        final docRef3 = _firestore
            .collection('userData')
            .doc(authenticatedUser!.id == userOrder.senderId
                ? userOrder.receiverId
                : userOrder.senderId)
            .collection("notifications")
            .doc(notification.id)
            .set(notification.toJson());

        await Future.wait([docRef, docRef2, docRef3]);
        return true;
      }
    } catch (ex) {
      return false;
    }
  }

  void updateNotification(NotificationModel notification) {
    _firestore
        .collection('userData')
        .doc(authenticatedUser!.id)
        .collection("notifications")
        .doc(notification.id)
        .update(notification.toJson())
        .then((onValue) {
      return true;
    }).onError((err, stack) => false);
  }

  Future<bool> addLaundryService(Service service, bool isNew) async {
    try {
      if (isNew) {
        await _firestore
            .collection('userData')
            .doc(authenticatedUser!.id)
            .collection("services")
            .doc(service.id)
            .set(service.toJson());
        return true;
      } else {
        await _firestore
            .collection('userData')
            .doc(authenticatedUser!.id)
            .collection("services")
            .doc(service.id)
            .update(service.toJson());
        return true;
      }
    } catch (ex) {
      return false;
    }
  }

  // Future<bool> addUserOrder(UserOrder userOrder) async {
  //   try {
  //     if (authenticatedUser!.id != null) {
  //       final docRef = await _firestore
  //           .collection('userData')
  //           .doc(userOrder.senderId)
  //           .collection("userOrders")
  //           .add(userOrder.toJson());

  //       final docRef2 = await _firestore
  //           .collection('userData')
  //           .doc(userOrder.receiverId)
  //           .collection("userOrders")
  //           .add(userOrder.toJson());
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (ex) {
  //     return false;
  //   }
  // }

  Future<LaundryService> getLaundryServicesForLaundry(
      String laundryId, String name) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('userData')
        .doc(laundryId)
        .collection("services")
        .get();

    List<Service> services = snapshot.docs.map((doc) {
      return Service.fromJson(doc.data());
    }).toList();

    return LaundryService(
        laundryId: laundryId, laundryName: name, services: services);
  }

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      var result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<UserProfile?> getUserProfile(String id) async {
    if (id.isNotEmpty) {
      final docRef = await _firestore.collection('users').doc(id).get();
      if (docRef.exists) {
        final userData = docRef.data();

        // Assuming only one document is expected, use first to access it
        if (userData != null) {
          // Check if userData is not null
          return UserProfile.fromJson(userData);
        }
      }
    }
    return null; // User not found or no data in Firestore
  }

  Future<String> addUserProfile(UserProfile userProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userProfile.id)
          .set(userProfile.toJson());
      authenticatedUser = userProfile;
      return "Success";
    } catch (ex) {
      return ex.toString();
    }
  }

  Future<String> updateUserProfile(UserProfile userProfile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userProfile.id)
          .update(userProfile.toJson());
      authenticatedUser = userProfile;
      return "Success";
    } catch (ex) {
      return ex.toString();
    }
  }

  UserOrder? currentOrder;

  Future<void> getCurrentOrder(bool isLaundry) async {
    var ordersSnapshot = await _firestore
        .collection('userData')
        .doc(authenticatedUser!.id)
        .collection("orders")
        .get();
    if (ordersSnapshot.docs.isNotEmpty) {
      final userOrdersJson = ordersSnapshot.docs;
      userOrders =
          userOrdersJson.map((doc) => UserOrder.fromJson(doc.data())).toList();
      userOrders
          .sort((a, b) => b.orderPlacementTime.compareTo(a.orderPlacementTime));
      if (isLaundry) {
        var unapprovedOrders = userOrders.where(
          (element) =>
              element.status == OrderStatus.pendingConfirmation ||
              element.status == OrderStatus.isOnHold,
        );
        if (unapprovedOrders.isNotEmpty) {
          currentOrder = unapprovedOrders.first;
        }
      } else {
        currentOrder = userOrders.first;
      }
    }
  }

  Future<List<UserProfile>> getLaundryProfiles() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'manager')
            .get();

    List<UserProfile> userProfileList = querySnapshot.docs
        .map((doc) => UserProfile.fromJson(doc.data()))
        .toList();

    await getCurrentOrder(false);
    return userProfileList;
  }

  Future<UserProfile?> signIn(String email, String password) async {
    try {
      var result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      var res = await getUserProfile(result.user!.uid);
      authenticatedUser = res;
      return res;
    } catch (e) {
      debugPrint("Error signing in: $e");

      return null;
    }
  }

  Future<bool> isEmailExists(String email) async {
    try {
      // Query the Firestore collection to check if the email exists
      final QuerySnapshot result = await _firestore
          .collection("doctors")
          .where("email", isEqualTo: email)
          .get();

      // If there are no documents matching the query, return false
      return result.docs.isNotEmpty;
    } catch (error) {
      debugPrint("Error checking email existence: $error");
      return false; // Return false in case of an error
    }
  }

  Future<bool> adminSignIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // var res = await getUserProfile(result.user!.uid);
      //authenticatdUser = res;
      return true;
    } catch (e) {
      return false;
    }
  }
}

class LaundryService {
  final String laundryId;
  final String laundryName;
  final List<Service> services;

  LaundryService(
      {required this.laundryId,
      required this.laundryName,
      required this.services});
}

String orderCardText(OrderStatus orderStatus) {
  switch (orderStatus) {
    case OrderStatus.pendingConfirmation:
      return "Pending";
    case OrderStatus.isOnHold:
      return "On Hold";
    case OrderStatus.requestCompleted:
      return "Completed";
    case OrderStatus.cancelled:
      return "Cancelled";
    case OrderStatus.processing:
      return "In Progress";
  }
}

String formatAsGhanaianCedis(double amount) {
  NumberFormat formatter =
      NumberFormat.currency(locale: 'en_GH', symbol: 'GH₵');
  return formatter.format(amount);
}
