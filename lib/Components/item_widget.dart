import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';

class ItemWidget extends StatefulWidget {
  final UserOrderItem userOrderItem;
  final Function(UserOrderItem) userOrderItemChanged;

  const ItemWidget(
      {Key? key,
      required this.userOrderItem,
      required this.userOrderItemChanged})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  UserOrderItem? userOrderItem;
  @override
  void initState() {
    userOrderItem = widget.userOrderItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(userOrderItem!.serviceName),
            Text('\$${userOrderItem!.pricing.price.toStringAsFixed(2)}'),
            Text(
                '\$${(userOrderItem!.pricing.price * userOrderItem!.quantity).toStringAsFixed(2)}'),
          ],
        ),
        Column(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (userOrderItem!.quantity > 0) {
                  setState(() {
                    userOrderItem!.quantity--;
                  });

                  widget.userOrderItemChanged(userOrderItem!);
                }
              },
            ),
            Text(userOrderItem!.quantity.toString()),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  userOrderItem!.quantity++;
                });
                widget.userOrderItemChanged(userOrderItem!);
              },
            ),
          ],
        )
      ],
    );
  }
}
