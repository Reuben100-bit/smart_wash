import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Components/order_card_manager.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:scoped_model/scoped_model.dart';

class LaundryManagerOrders extends StatefulWidget {
  const LaundryManagerOrders({super.key});

  @override
  State<StatefulWidget> createState() {
    return LaundryManagerOrdersState();
  }
}

class LaundryManagerOrdersState extends State<LaundryManagerOrders>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  Widget _buildOrderSection(String title, List<UserOrder> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: OrderCardManager(userOrder: orders[index]));
      },
    );
  }

  final searchBoxController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserOrder> userOrders = [];

  List<UserOrder> getOrdersByStatus(
      List<UserOrder> userOrders, OrderStatus status) {
    return userOrders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ScopedModelDescendant<MyScopedModel>(
            builder: (context, child, model) => SafeArea(
                child: Container(
                    margin:  EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05),
                    child: Stack(children: [
                      Column(children: [
                        Container(
                          margin: const EdgeInsets.only(top: 30, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'MY ORDERS',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        TextField(
                          controller: searchBoxController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  0), // Adjust edge radius as needed
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(0),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection('userData')
                                    .doc(model.authenticatedUser!.id)
                                    .collection("orders")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.docs.isEmpty) {
                                      return const SizedBox();
                                    }

                                    final userOrdersJson = snapshot.data!.docs;
                                    userOrders = userOrdersJson
                                        .map((doc) => UserOrder.fromJson(
                                            doc.data() as Map<String, dynamic>))
                                        .toList();
                                    userOrders.sort((a, b) => b
                                        .orderPlacementTime
                                        .compareTo(a.orderPlacementTime));
                                    model.currentOrder = userOrders.first;
                                    ScopedModel.of<MyScopedModel>(context)
                                        .userOrders = userOrders;
                                    userOrders.sort((a, b) => b
                                        .orderPlacementTime
                                        .compareTo(a.orderPlacementTime));

                                    var unapprovedOrders = userOrders.where(
                                      (element) =>
                                          element.status ==
                                              OrderStatus.pendingConfirmation ||
                                          element.status ==
                                              OrderStatus.isOnHold,
                                    );
                                    if (unapprovedOrders.isNotEmpty) {
                                      model.currentOrder =
                                          unapprovedOrders.first;
                                    } else {
                                      model.currentOrder = null;
                                    }

                                    return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TabBar(
                                            tabAlignment: TabAlignment.start,
                                            controller: _tabController,
                                            isScrollable: true,
                                            tabs: const [
                                              Tab(text: "All Orders"),
                                              Tab(text: "In Progress"),
                                              Tab(text: "Completed"),
                                              Tab(text: "Cancelled"),
                                            ],
                                            labelColor: Colors.red,
                                            indicatorColor: Colors.red,
                                            indicatorWeight: 2.0,
                                            indicatorPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                          ),
                                          Expanded(
                                            child: TabBarView(
                                              controller: _tabController,
                                              children: [
                                                _buildOrderSection(
                                                    "All Orders", userOrders),
                                                _buildOrderSection(
                                                    "In Progress",
                                                    getOrdersByStatus(
                                                        userOrders,
                                                        OrderStatus
                                                            .processing)),
                                                _buildOrderSection(
                                                    "Completed",
                                                    getOrdersByStatus(
                                                        userOrders,
                                                        OrderStatus
                                                            .requestCompleted)),
                                                _buildOrderSection(
                                                    "Cancelled",
                                                    getOrdersByStatus(
                                                        userOrders,
                                                        OrderStatus.cancelled)),
                                              ],
                                            ),
                                          ),
                                        ]);
                                  } else {
                                    return const SizedBox();
                                  }
                                }))
                      ]),
                    ])))));
  }
}
