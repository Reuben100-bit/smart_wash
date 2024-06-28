import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:laundry_mgmt_system/Pages/manage_order.dart';
import 'package:laundry_mgmt_system/Pages/manageorderuser.dart';
import 'package:scoped_model/scoped_model.dart';

class OrderCard extends StatefulWidget {
  final UserOrder userOrder;
  const OrderCard({super.key, required this.userOrder});
  @override
  State<StatefulWidget> createState() {
    return OrderCardState();
  }
}

class OrderCardState extends State<OrderCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => widget.userOrder.senderId == ScopedModel.of<MyScopedModel>(context) .authenticatedUser!.id ? ManageOrderByUser(userOrder: widget.userOrder) : OrderManagement(
                        userOrder: widget.userOrder,
                      ))));
        },
        child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getServiceNames(widget.userOrder.items),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(widget.userOrder.orderPlacementTime),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            )
                          ],
                        ),
                        Container(
                          color: Colors.blue.shade100,
                          child: Text(orderCardText(widget.userOrder.status)),
                        ),
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.userOrder.senderName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      formatAsGhanaianCedis(widget.userOrder.calculateTotal()),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )
                  ],
                )
              ],
            )));
  }
}
