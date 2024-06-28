import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_mgmt_system/Models/notification.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Pages/manageorderuser.dart';
import 'package:scoped_model/scoped_model.dart';

class UserNotifications extends StatefulWidget {
  const UserNotifications({super.key});

  @override
  State<StatefulWidget> createState() {
    return UserNotificationsState();
  }
}

class UserNotificationsState extends State<UserNotifications> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<NotificationModel> notifications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ScopedModelDescendant<MyScopedModel>(
            builder: (context, child, model) => SafeArea(
                    child: Stack(children: [
                  Column(children: [
                    Container(
                      margin:
                          const EdgeInsets.only(top: 30, bottom: 10, left: 20),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'NOTIFICATIONS',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('userData')
                                .doc(model.authenticatedUser!.id)
                                .collection("notifications")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.docs.isEmpty) {
                                  return const SizedBox();
                                }

                                final notificationsJson = snapshot.data!.docs;
                                notifications = notificationsJson
                                    .map((doc) => NotificationModel.fromJson(
                                        doc.data() as Map<String, dynamic>))
                                    .toList();
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: ListView.builder(
                                              itemCount: notifications.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                    onTap: () {
                                                      try {
                                                        notifications[index]
                                                            .isRead = true;
                                                        model
                                                            .updateNotification(
                                                                notifications[
                                                                    index]);
                                                        var userOrderObject = model
                                                            .userOrders
                                                            .firstWhere((element) =>
                                                                element.id ==
                                                                notifications[
                                                                        index]
                                                                    .id);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: ((context) =>
                                                                    ManageOrderByUser(
                                                                        userOrder:
                                                                            userOrderObject))));
                                                      } catch (ex) {
                                                        print(ex);
                                                      }
                                                    },
                                                    child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10,
                                                                horizontal: 20),
                                                        decoration: const BoxDecoration(
                                                            border: Border.symmetric(
                                                                vertical:
                                                                    BorderSide
                                                                        .none,
                                                                horizontal:
                                                                    BorderSide(
                                                                        width:
                                                                            1))),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    notifications[
                                                                            index]
                                                                        .title,
                                                                    style: TextStyle(
                                                                        fontWeight: notifications[index].isRead
                                                                            ? FontWeight.normal
                                                                            : FontWeight.bold),
                                                                  ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.6,
                                                                    child: Text(
                                                                      notifications[
                                                                              index]
                                                                          .content,
                                                                      style: TextStyle(
                                                                          fontWeight: notifications[index].isRead
                                                                              ? FontWeight.normal
                                                                              : FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Text(
                                                                      DateFormat(
                                                                              'dd-MM-yyyy')
                                                                          .format(
                                                                              DateTime.parse(notifications[index].dateTime)),
                                                                      style: TextStyle(
                                                                          fontWeight: notifications[index].isRead
                                                                              ? FontWeight.normal
                                                                              : FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                      DateFormat(
                                                                              'hh:mma')
                                                                          .format(
                                                                              DateTime.parse(notifications[index].dateTime)),
                                                                      style: TextStyle(
                                                                          fontWeight: notifications[index].isRead
                                                                              ? FontWeight.normal
                                                                              : FontWeight.bold),
                                                                    ),
                                                                  ])
                                                            ])));
                                              }))
                                    ]);
                              } else {
                                return const SizedBox();
                              }
                            }))
                  ]),
                ]))));
  }
}
