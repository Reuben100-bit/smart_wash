import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:laundry_mgmt_system/app_colors.dart';
import 'package:laundry_mgmt_system/main.dart';
import 'package:scoped_model/scoped_model.dart';

class LaundryManagerServices extends StatefulWidget {
  const LaundryManagerServices({super.key});

  @override
  State<StatefulWidget> createState() {
    return LaundryManagerServicesState();
  }
}

class LaundryManagerServicesState extends State<LaundryManagerServices> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Service? selectedService;

  @override
  void initState() {
    if (ScopedModel.of<MyScopedModel>(context).services.isNotEmpty) {
      selectedService = ScopedModel.of<MyScopedModel>(context).services[0];
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MyScopedModel>(
        builder: ((context, child, model) => Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("Services"),
              leading: const SizedBox(),
            ),
            body: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('userData')
                        .doc(model.authenticatedUser!.id)
                        .collection("services")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isEmpty) {
                          return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text("You haven't added services yet"),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const ManageServiceDialog(
                                            service: null,
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 100,
                                      color: AppColors.primaryColor,
                                      margin: const EdgeInsets.all(8),
                                      child: const Center(
                                          child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      )),
                                    ),
                                  )
                                ],
                              ));
                        }

                        final servicesJson = snapshot.data!.docs;
                        model.services = servicesJson
                            .map((doc) => Service.fromJson(
                                doc.data() as Map<String, dynamic>))
                            .toList();
                        selectedService ??= model.services[0];
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child:  SizedBox(
                                  height: 50,
                                  child: ListView.builder(
                                    itemCount: model.services.length,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      return Container(
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                selectedService =
                                                    model.services[index];
                                              });
                                            },
                                            style: selectedService != null &&
                                                    selectedService!.name ==
                                                        model.services[index]
                                                            .name
                                                ? ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.primaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                    ),
                                                  )
                                                : ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    side: BorderSide(
                                                      color: AppColors
                                                          .primaryColor,
                                                      width: 1.0,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                    ),
                                                  ),
                                            child: Text(
                                              model.services[index].name,
                                              style: TextStyle(
                                                  color: selectedService !=
                                                              null &&
                                                          selectedService!
                                                                  .name ==
                                                              model
                                                                  .services[
                                                                      index]
                                                                  .name
                                                      ? Colors.white
                                                      : AppColors.primaryColor),
                                            ),
                                          ));
                                    },
                                  ),
                                )),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const ManageServiceDialog(
                                          service: null,
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 100,
                                    color: AppColors.primaryColor,
                                    child: const Center(
                                        child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    )),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [ const  Text(
                                  "Pricing",
                                  style: TextStyle(fontSize: 18),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(),
                                    backgroundColor: selectedService == null
                                        ? Colors.grey.shade200
                                        : AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    if (selectedService != null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return ItemPriceDialog(
                                            pricing: null,
                                            selectedService: selectedService!,
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Add New Item',
                                  ),
                                ),
                              ],
                            ),
                            // if (selectedService != null) Text("selectedService: ${selectedService!.name}" ),
                            Flexible(
                              child: ListView.builder(
                                itemCount: selectedService != null
                                    ? selectedService!.pricing.length
                                    : 0,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) =>
                                                ItemPriceDialog(
                                                  pricing: selectedService!
                                                      .pricing[index],
                                                  selectedService:
                                                      selectedService!,
                                                ));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 7),
                                        child: Card(
                                            elevation: 5,
                                            shape: BeveledRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(0)),
                                            surfaceTintColor: Colors.white,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 20),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      selectedService!
                                                          .pricing[index]
                                                          .itemName,
                                                      style:const   TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      formatCurrency(
                                                        selectedService!
                                                            .pricing[index]
                                                            .price,
                                                      ),
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: AppColors
                                                              .primaryColor),
                                                    ),
                                                  ]),
                                            )),
                                      ));

                                  // ListTile(
                                  //   trailing: Text(formatCurrency(
                                  //       selectedService!.pricing[index].price)),
                                  //   title: Text(selectedService!
                                  //       .pricing[index].itemName),
                                  //   onTap: () {
                                  //     showDialog(
                                  //         context: context,
                                  //         builder: (context) => ItemPriceDialog(
                                  //               pricing: selectedService!
                                  //                   .pricing[index],
                                  //               selectedService:
                                  //                   selectedService!,
                                  //             ));
                                  //   },
                                  // );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox();
                    })))));
  }
}

class ItemPriceDialog extends StatefulWidget {
  final Pricing? pricing;
  final Service selectedService;
  const ItemPriceDialog(
      {super.key, required this.pricing, required this.selectedService});
  @override
  // ignore: library_private_types_in_public_api
  _ItemPriceDialogState createState() => _ItemPriceDialogState();
}

class _ItemPriceDialogState extends State<ItemPriceDialog> {
  TextEditingController itemController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    if (widget.pricing != null) {
      itemController.text = widget.pricing!.itemName;
      priceController.text = widget.pricing!.price.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      surfaceTintColor: Colors.white,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(0)),
      title: const Text('Add Item and Price'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: itemController,
            decoration: const InputDecoration(labelText: 'Item'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          style: ElevatedButton.styleFrom(
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: BorderSide(width: 1, color: AppColors.primaryColor)),
            foregroundColor: AppColors.primaryColor,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(0)),
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
              surfaceTintColor: AppColors.primaryColor),
          onPressed: () {
            if (widget.pricing == null) {
              Pricing pricing = Pricing(
                  id: UniqueKey().toString(),
                  itemName: itemController.text,
                  price: double.parse(priceController.text));
              widget.selectedService.pricing.add(pricing);
            } else {
              Pricing pricing = Pricing(
                  id: widget.pricing!.id,
                  itemName: itemController.text,
                  price: double.parse(priceController.text));
              int index = ScopedModel.of<MyScopedModel>(context)
                  .services
                  .indexWhere((element) => element.id == widget.pricing!.id);
              widget.selectedService.pricing[index] = pricing;
            }
            ScopedModel.of<MyScopedModel>(context)
                .addLaundryService(widget.selectedService, false);

            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    itemController.dispose();
    priceController.dispose();
    super.dispose();
  }
}

class ManageServiceDialog extends StatefulWidget {
  final Service? service;
  const ManageServiceDialog({super.key, required this.service});
  @override
  ManageServiceDialogState createState() => ManageServiceDialogState();
}

class ManageServiceDialogState extends State<ManageServiceDialog> {
  TextEditingController itemController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    if (widget.service != null) {
      itemController.text = widget.service!.name;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0,
      surfaceTintColor: Colors.white,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(0)),
      title: widget.service == null
          ? const Text('Add New Service')
          : const Text("Manage Service"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: itemController,
            decoration: const InputDecoration(labelText: 'Service'),
          ),
        ],
      ),
      actions: [
        TextButton(
          style: ElevatedButton.styleFrom(
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.circular(0),
                side: BorderSide(width: 1, color: AppColors.primaryColor)),
            foregroundColor: AppColors.primaryColor,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(0)),
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryColor,
              surfaceTintColor: AppColors.primaryColor),
          onPressed: () {
            Service? service;
            if (widget.service == null) {
              service = Service(
                  id: UniqueKey().toString(),
                  name: itemController.text,
                  pricing: []);
            } else {
              service = Service(
                  id: widget.service!.id,
                  name: itemController.text,
                  pricing: widget.service!.pricing);
            }
            ScopedModel.of<MyScopedModel>(context)
                .addLaundryService(service, widget.service == null);

            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    itemController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
