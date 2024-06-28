import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:laundry_mgmt_system/Pages/chat.dart';
import 'package:laundry_mgmt_system/app_colors.dart';
import 'package:laundry_mgmt_system/constant.dart';
import 'package:scoped_model/scoped_model.dart';

class OrderManagement extends StatefulWidget {
  final UserOrder userOrder;
  const OrderManagement({super.key, required this.userOrder});
  @override
  State<StatefulWidget> createState() {
    return OrderManagementState();
  }
}

class OrderManagementState extends State<OrderManagement> {
  UserOrder? userOrder;
  String? selectedValue;

  List<String> returnOrderStatusesToDisplay() {
    switch (userOrder!.status) {
      
      case OrderStatus.pendingConfirmation:
        return ["Awaiting Confirmation", "Accept", "Put On Hold", "Cancel"];
      case OrderStatus.isOnHold:
        return ["Put On Hold", "Accept", "Cancel"];
      case OrderStatus.processing:
        return ["Accept", "Mark As Complete", "Cancel"];
      case OrderStatus.requestCompleted:
        return ["Mark As Complete"];
      case OrderStatus.cancelled:
        return ["Cancel"];
    }
  }

  @override
  void initState() {
    userOrder = UserOrder(
        id: widget.userOrder.id,
        senderId: widget.userOrder.senderId,
        receiverId: widget.userOrder.receiverId,
        senderName: widget.userOrder.senderName,
        laundryName: widget.userOrder.laundryName,
        items: List.from(widget.userOrder.items),
        status: widget.userOrder.status,
        requestReadyMethod: widget.userOrder.requestReadyMethod,
        requestCompletedMethod: widget.userOrder.requestCompletedMethod,
        orderPlacementTime: widget.userOrder.orderPlacementTime,
        messages: widget.userOrder.messages,
        orderAddress: widget.userOrder.orderAddress,
        );
    selectedValue = humanizeOrderStatus(widget.userOrder.status);
    super.initState();
  }
   
  OrderStatus reverseHumanizeOrderStatus(String statusString) {
    switch (statusString) {
      case "Awaiting Confirmation":
        return OrderStatus.pendingConfirmation;
      case "Put On Hold":
        return OrderStatus.isOnHold;
      case "Laundry Done":
      case "Mark As Complete":
        return OrderStatus.requestCompleted;
      case "Accept":
      case "In Progress":
        return OrderStatus.processing;
      case "Cancel":
        return OrderStatus.cancelled;
      default:
        return OrderStatus.cancelled;
    }
  }

  String humanizeOrderStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingConfirmation:
        return "Awaiting Confirmation";
      case OrderStatus.isOnHold:
        return "Put On Hold";
      case OrderStatus.requestCompleted:
        return "Mark As Complete";
      case OrderStatus.processing:
        return "Accept";
      case OrderStatus.cancelled:
        return "Cancel";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MyScopedModel>(
        builder: (context, child, state) {
      return Scaffold(
          body: SafeArea(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Stack(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.close)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Customer: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            userOrder!.senderName,
                            style: const TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Date: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            DateFormat('dd-MM-yyyy hh:mma')
                                .format(userOrder!.orderPlacementTime),
                            style:const  TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(children: [
                        const Text(
                          "Status: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Select Item',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            items: returnOrderStatusesToDisplay()
                                .map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            value: selectedValue,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  selectedValue = value;
                                  userOrder!.status =
                                      reverseHumanizeOrderStatus(value);
                                });
                              }
                            },
                            buttonStyleData: const ButtonStyleData(
                              padding:
                                   EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              width: 140,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Pick-up Method: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            UserOrder.mapRequestReadyMethodToFirestore(
                                userOrder!.requestReadyMethod),
                            style: const TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Drop-off Method: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            UserOrder.mapRequestCompletedMethodToFirestore(
                                userOrder!.requestCompletedMethod),
                            style: const TextStyle(fontSize: 17),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // Text("LAUNDRY ITEMS"),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // const SizedBox(
                      //     height: 300,
                      //     child: ListView.builder(
                      //         itemCount: userOrder!.items.length,
                      //         itemBuilder: ((context, index) => Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Text(
                      //                     userOrder!
                      //                         .items[index].pricing.itemName,
                      //                     style: TextStyle(fontSize: 17),
                      //                   ),
                      //                   Text(
                      //                     userOrder!.items[index].serviceName,
                      //                     style: TextStyle(fontSize: 14),
                      //                   )
                      //                 ])))),
                    ],
                  ),
                )
              ]),
              Positioned(
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
                        child: const Icon(Icons.chat_outlined,
                            color: Colors.white)),
                  ))
            ]),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60), // NEW
                    elevation: d.pSH(2),
                    backgroundColor:
                        userOrder!.status != widget.userOrder.status
                            ? AppColors.greenColorTwo
                            : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                    padding:  EdgeInsets.all(d.pSH(0.5))),
                onPressed: () async {
                  if (userOrder!.status != widget.userOrder.status) {
                    await state
                        .addUserOrder(userOrder!, false)
                        .then((value) => Navigator.of(context).pop());
                  }
                },
                child: const Text("Update"))
          ])));
    });
  }
}
