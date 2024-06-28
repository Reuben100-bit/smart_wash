import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Components/order_card.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:laundry_mgmt_system/Pages/UserPages/add_new_order.dart';
import 'package:laundry_mgmt_system/app_colors.dart';
import 'package:laundry_mgmt_system/constant.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class UserOrdersPage extends StatefulWidget {
  const UserOrdersPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return UserOrdersPageState();
  }
}

class UserOrdersPageState extends State<UserOrdersPage>
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
            child: OrderCard(userOrder: orders[index]));
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
                    margin: EdgeInsets.symmetric(
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
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                              "You haven't placed an order yet"),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: ((context) =>
                                                          const AddNewOrder())));
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
                                      );
                                    }

                                    final userOrdersJson = snapshot.data!.docs;
                                    userOrders = userOrdersJson
                                        .map((doc) => UserOrder.fromJson(
                                            doc.data() as Map<String, dynamic>))
                                        .toList();
                                    userOrders.sort((a, b) => b
                                        .orderPlacementTime
                                        .compareTo(a.orderPlacementTime));
                                    if (userOrders.isNotEmpty) {
                                      model.currentOrder = userOrders.first;
                                    }
                                    ScopedModel.of<MyScopedModel>(context)
                                        .userOrders = userOrders;
                                    userOrders.sort((a, b) => b
                                        .orderPlacementTime
                                        .compareTo(a.orderPlacementTime));
                                    model.currentOrder = userOrders.first;
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
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(60),
                              elevation: d.pSH(2),
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              padding: EdgeInsets.all(d.pSH(0.5)),
                            ),
                            onPressed: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          const AddNewOrder())));
                            },
                            child: const Text('Add New Order'),
                          ),
                        ),
                      )
                    ])))));
  }
}


// class TypeAheadExample extends StatefulWidget {
//   @override
//   _TypeAheadExampleState createState() => _TypeAheadExampleState();
// }

// class _TypeAheadExampleState extends State<TypeAheadExample> {
//   final TextEditingController _controller1 = TextEditingController();
//   final TextEditingController _controller2 = TextEditingController();

//   // Mock data for demonstration
//   final List<String> items = [
//     'Apple',
//     'Banana',
//     'Cherry',
//     'Date',
//     'Elderberry',
//     'Fig',
//     'Grape',
//     'Honeydew',
//     'Kiwi',
//     'Lemon',
//     'Mango',
//     'Nectarine',
//     'Orange',
//     'Peach',
//     'Quince',
//     'Raspberry',
//     'Strawberry',
//     'Tomato',
//     'Ugli fruit',
//     'Watermelon',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('TypeAhead Example'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TypeAheadFormField(
//               textFieldConfiguration: TextFieldConfiguration(
//                 controller: _controller1,
//                 decoration: InputDecoration(
//                   labelText: 'Typeahead 1',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               suggestionsCallback: (pattern) {
//                 return _getSuggestions(pattern);
//               },
//               itemBuilder: (context, suggestion) {
//                 return ListTile(
//                   title: Text(suggestion),
//                 );
//               },
//               onSuggestionSelected: (suggestion) {
//                 _controller1.text = suggestion;
//               },
//             ),
//             const SizedBox(height: 20),
//             TypeAheadFormField(
//               textFieldConfiguration: TextFieldConfiguration(
//                 controller: _controller2,
//                 decoration: InputDecoration(
//                   labelText: 'Typeahead 2',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               suggestionsCallback: (pattern) {
//                 return _getSuggestions(pattern);
//               },
//               itemBuilder: (context, suggestion) {
//                 return ListTile(
//                   title: Text(suggestion),
//                 );
//               },
//               onSuggestionSelected: (suggestion) {
//                 _controller2.text = suggestion;
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<String> _getSuggestions(String query) {
//     List<String> matches = List();
//     matches.addAll(items);
//     matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
//     return matches;
//   }
// }
