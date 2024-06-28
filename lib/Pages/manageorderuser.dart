import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:laundry_mgmt_system/Pages/chat.dart';
import 'package:laundry_mgmt_system/app_colors.dart';
import 'package:laundry_mgmt_system/constant.dart';
import 'package:scoped_model/scoped_model.dart';

class ManageOrderByUser extends StatefulWidget {
  const ManageOrderByUser({super.key, required this.userOrder});
  final UserOrder userOrder;

  @override
  State<StatefulWidget> createState() {
    return ManageOrderByUserState();
  }
}

class ManageOrderByUserState extends State<ManageOrderByUser> {
  final laundryController = TextEditingController();
  final serviceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MyScopedModel>(
        builder: ((context, child, model) => Scaffold(
            floatingActionButton: Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatPage(userOrder: widget.userOrder)));
                  },
                  icon: CircleAvatar(
                      backgroundColor: AppColors.primaryColor,
                      child:const  Icon(
                        Icons.chat_outlined,
                        color: Colors.white,
                      )),
                )),
            body: SafeArea(
                child: Stack(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close)),
                     const  Text("Select Laundry:", style: TextStyle(fontSize: 17)),
                      const SizedBox(height: 4),
                      Text(widget.userOrder.laundryName),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Drop-off your clothes or request pick up?',
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(widget.userOrder.requestReadyMethod ==
                                RequestReadyMethod.dropOff
                            ? "Drop Off"
                            : "Pick Up"),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Delivered when done or you'd pick up",
                        style: TextStyle(fontSize: 17),
                      ),
                      Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(widget.userOrder.requestCompletedMethod ==
                                RequestCompletedMethod.delivery
                            ? "Delivery"
                            : "Pick Up"),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Price (${widget.userOrder.items.length} ${widget.userOrder.items.length == 1 ? "item" : "items"})",
                            style: const TextStyle(fontSize: 17),
                          ),
                          Text(
                            formatAsGhanaianCedis(
                                widget.userOrder.calculateTotal()),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title:const  Text('Confirmation'),
                                content:const  Text(
                                    'Are you sure you want to cancel the order?'),
                                actions: <Widget>[
                                  ElevatedButton(
                                    onPressed: () async {
                                      var userOrder = widget.userOrder;
                                      userOrder.status = OrderStatus.cancelled;
                                      await model
                                          .addUserOrder(userOrder, false)
                                          .then((value) =>
                                              Navigator.of(context).pop());
                                    },
                                    child:const  Text('Yes'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Dismiss the dialog
                                      Navigator.of(context).pop();
                                    },
                                    child:const  Text('No'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            minimumSize: const Size.fromHeight(60),
                            elevation: d.pSH(2),
                            shape: RoundedRectangleBorder(
                                side:const  BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(0))),
                        child: const Text('Cancel Order'),
                      ),
                    ]),
              ),
            ])))));
  }
}
