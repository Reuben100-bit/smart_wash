import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Models/order_address.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:laundry_mgmt_system/app_colors.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddNewOrder extends StatefulWidget {
  const AddNewOrder({super.key});

  @override
  State<StatefulWidget> createState() {
    return AddNewOrderState();
  }
}

class AddNewOrderState extends State<AddNewOrder> {
  List<UserOrderItem> selectedOrderItems = [];
  double totalAmount = 0;
  List<Pricing> pricing = [];
  List<UserOrderItem> userOrderItems = [];
  LaundryService? selectedLaundryService;
  Service? selectedService;
  bool isBusy = false;
  final laundryController = TextEditingController();
  final serviceController = TextEditingController();
  final locationController = TextEditingController();
  final hostelNameController = TextEditingController();
  final roomNumberController = TextEditingController();

  RequestReadyMethod _selectedReadyMethod = RequestReadyMethod.dropOff;
  RequestCompletedMethod _selectedCompletedMethod =
      RequestCompletedMethod.pickUp;
  LaundryService? checkLaundryService() {
    try {
      return ScopedModel.of<MyScopedModel>(context).laundryServices.firstWhere(
          (element) => element.laundryName == laundryController.text);
    } catch (ex) {
      return null;
    }
  }

  Future<List<LaundryService>> getLaundries() async {
    return ScopedModel.of<MyScopedModel>(context)
        .laundryServices
        .where((element) => element.laundryName
            .toLowerCase()
            .contains(laundryController.text.toLowerCase()))
        .toList();
  }

  void updateSelectedOrderItem(UserOrderItem userOrderItem, int quantity) {
    var index = selectedOrderItems.indexWhere((element) =>
        element.serviceName == userOrderItem.serviceName &&
        element.pricing == userOrderItem.pricing);
    if (index == -1) {
      userOrderItem.quantity = quantity;
      selectedOrderItems.add(userOrderItem);
    } else {
      if (quantity == 0) {
        selectedOrderItems.removeAt(index);
      } else {
        userOrderItem.quantity = quantity;
        selectedOrderItems[index] = userOrderItem;
      }
    }
    totalAmount = 0;
    for (var element in selectedOrderItems) {
      totalAmount = element.pricing.price * element.quantity;
    }
  }

  UserOrderItem getUserOrderItemFromPricing(Pricing pricing) {
    int quantity = 0;
    try {
      var item = selectedOrderItems.firstWhere((element) =>
          element.pricing == pricing &&
          element.serviceName == selectedService!.name);
      quantity = item.quantity;
    } catch (ex) {
      debugPrint(ex.toString());
    }
    return UserOrderItem(
        pricing: pricing,
        quantity: quantity,
        serviceName: selectedService!.name);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MyScopedModel>(
        builder: ((context, child, model) => Scaffold(
                body: SafeArea(
                    child: Stack(children: [
              SingleChildScrollView(
                child: Container(
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
                      const Text("Select Laundry:",
                          style: TextStyle(fontSize: 17)),
                      const SizedBox(height: 4),
                      TypeAheadField<LaundryService>(
                        suggestionsCallback: (value) => getLaundries(),
                        onSelected: (value) {
                          setState(() {
                            selectedLaundryService = value;
                            laundryController.text = value.laundryName;
                            selectedService = null;
                            serviceController.clear();
                            if (selectedLaundryService != value) {
                              userOrderItems = [];
                            }
                          });
                        },
                        controller: laundryController,
                        builder: (context, controller, focusNode) => TextField(
                          controller: laundryController,
                          focusNode: focusNode,
                          autofocus: true,
                          style: DefaultTextStyle.of(context)
                              .style
                              .copyWith(fontSize: 17),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Laundry",
                          ),
                        ),
                        decorationBuilder: (context, child) => Material(
                          type: MaterialType.card,
                          elevation: 4,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(0)),
                          child: child,
                        ),
                        itemBuilder: (context, laundryService) => ListTile(
                          title: Text(laundryService.laundryName),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Drop-off your clothes or request pick up?',
                        style: TextStyle(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Container(
                          decoration:
                              BoxDecoration(border: Border.all(width: 1)),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: DropdownButton<RequestReadyMethod>(
                            elevation: 0,
                            value: _selectedReadyMethod,
                            onChanged: (newValue) {
                              setState(() {
                                _selectedReadyMethod = newValue!;
                              });
                            },
                            items: RequestReadyMethod.values.map((method) {
                              return DropdownMenuItem<RequestReadyMethod>(
                                value: method,
                                child: Text(method == RequestReadyMethod.dropOff
                                    ? "Drop Off"
                                    : "Pick Up"),
                              );
                            }).toList(),
                          )),
                      if (_selectedReadyMethod == RequestReadyMethod.pickUp)
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: locationController,
                                decoration: const InputDecoration(
                                  labelText: 'Location',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: hostelNameController,
                                decoration: const InputDecoration(
                                    labelText: 'Hostel Name',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.email)),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: roomNumberController,
                                decoration: const InputDecoration(
                                    labelText: 'Room Number',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.email)),
                              )
                            ]),
                      const SizedBox(height: 20),
                      const Text(
                        "Delivered when done or you'd pick up",
                        style: TextStyle(fontSize: 17),
                      ),
                      Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<RequestCompletedMethod>(
                          underline: const SizedBox(),
                          value: _selectedCompletedMethod,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCompletedMethod = newValue!;
                            });
                          },
                          items: RequestCompletedMethod.values.map((method) {
                            return DropdownMenuItem<RequestCompletedMethod>(
                              value: method,
                              child: Text(
                                  method == RequestCompletedMethod.delivery
                                      ? "Delivery"
                                      : "Pick Up"),
                            );
                          }).toList(),
                        ),
                      ),
                      if (selectedLaundryService != null)
                        Row(children: [
                          Expanded(
                              child: Container(
                            margin: const EdgeInsets.only(top: 20),
                            height: 50,
                            child: ListView.builder(
                              itemCount:
                                  selectedLaundryService!.services.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Container(
                                    height: 50,
                                    margin: const EdgeInsets.only(right: 8),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedService =
                                              selectedLaundryService!
                                                  .services[index];
                                        });
                                        setState(() {});
                                        setState(() {});
                                      },
                                      style: selectedService != null &&
                                              selectedService!.name ==
                                                  selectedLaundryService!
                                                      .services[index].name
                                          ? ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                            )
                                          : ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              side: BorderSide(
                                                color: AppColors.primaryColor,
                                                width: 1.0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                              ),
                                            ),
                                      child: Text(
                                        selectedLaundryService!
                                            .services[index].name,
                                        style: TextStyle(
                                            color: selectedService != null &&
                                                    selectedService!.name ==
                                                        selectedLaundryService!
                                                            .services[index]
                                                            .name
                                                ? Colors.white
                                                : AppColors.primaryColor),
                                      ),
                                    ));
                              },
                            ),
                          ))
                        ]),
                      const SizedBox(
                        height: 10,
                      ),
                      if (selectedService != null)
                        SingleChildScrollView(
                            child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: ListView.builder(
                            itemCount: selectedService!.pricing.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              var userOrderItem = getUserOrderItemFromPricing(
                                  selectedService!.pricing[index]);
                              return Column(children: [
                                Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    padding: const EdgeInsets.only(left: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                          ),
                                        ]),
                                    //  color: Colors.red,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userOrderItem.pricing.itemName,
                                              style:
                                                  const TextStyle(fontSize: 17),
                                            ),
                                            Text(
                                              'GH₵${(userOrderItem.pricing.price).toStringAsFixed(2)}',
                                              style:
                                                  const TextStyle(fontSize: 17),
                                            ),
                                            Text(
                                              'GH₵${(userOrderItem.pricing.price * userOrderItem.quantity).toStringAsFixed(2)}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                if (userOrderItem.quantity >
                                                    0) {
                                                  setState(() {
                                                    userOrderItem.quantity--;
                                                    updateSelectedOrderItem(
                                                        userOrderItem,
                                                        userOrderItem.quantity);
                                                  });
                                                }
                                              },
                                            ),
                                            Text(userOrderItem.quantity
                                                .toString()),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  userOrderItem.quantity =
                                                      userOrderItem.quantity +
                                                          1;
                                                  updateSelectedOrderItem(
                                                      userOrderItem,
                                                      userOrderItem.quantity);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                if (index ==
                                    selectedService!.pricing.length - 1)
                                  Container(
                                    height: 200,
                                  )
                              ]);
                            },
                          ),
                        ))
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  child: Container(
                      height: 140,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 243, 242, 252),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Price (${selectedOrderItems.length} ${selectedOrderItems.length == 1 ? "item" : "items"})",
                              style: const TextStyle(fontSize: 17),
                            ),
                            Text(formatAsGhanaianCedis(totalAmount),
                                style: const TextStyle(fontSize: 17)),
                          ],
                        ),
                        const SizedBox(
                          height: 17,
                        ),
                        Container(
                          height: 50,
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50), // NEW
                            ),
                            onPressed: () async {
                              if (!isBusy) {
                                setState(() {
                                  isBusy = true;
                                });

                                PayWithPayStack().now(
                                    context: context,
                                    secretKey:
                                        "sk_live_bd12c82610b51cd9a788abfcc5ceaf35e1ee66ac",
                                    customerEmail: "nanapaintsil27@gmail.com",
                                    reference: DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString(),
                                    currency: "GHS",
                                    amount: convertToPesewas(2),
                                    transactionCompleted: () async {
                                      UserOrder userOrder = UserOrder(
                                          id: UniqueKey().toString(),
                                          senderId: model.authenticatedUser!.id,
                                          senderName:
                                              "${model.authenticatedUser!.firstName} ${model.authenticatedUser!.lastName}",
                                          receiverId:
                                              selectedLaundryService!.laundryId,
                                          laundryName: selectedLaundryService!
                                              .laundryName,
                                          items: selectedOrderItems,
                                          status:
                                              OrderStatus.pendingConfirmation,
                                          requestReadyMethod:
                                              _selectedReadyMethod,
                                          requestCompletedMethod:
                                              _selectedCompletedMethod,
                                          orderPlacementTime: DateTime.now(),
                                          orderAddress: _selectedReadyMethod ==
                                                  RequestReadyMethod.dropOff
                                              ? null
                                              : OrderAddress(
                                                  location:
                                                      locationController.text,
                                                  hostelName:
                                                      hostelNameController.text,
                                                  roomNumber:
                                                      roomNumberController.text,
                                                ),
                                          messages: []);
                                      await model
                                          .addUserOrder(userOrder, true)
                                          .then((value) => setState(() {
                                                isBusy = false;
                                                Navigator.pop(context);
                                              }));
                                    },
                                    callbackUrl:
                                        "https://buspassapi.azurewebsites.net/",
                                    transactionNotCompleted: () {
                                      print("Transaction Not Successful!");
                                    });
                              }
                            },
                            child: isBusy
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Place Order',
                                  ),
                          ),
                        )
                      ])))
            ])))));
  }
}

String convertToPesewas(double price) {
  var p = price * 100;
  return p.toString();
}
