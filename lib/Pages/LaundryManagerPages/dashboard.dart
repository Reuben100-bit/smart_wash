import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_mgmt_system/Components/order_card.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user_order.dart';
import 'package:laundry_mgmt_system/Pages/LaundryManagerPages/profile.dart';
import 'package:laundry_mgmt_system/Pages/login.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LaundryManagerDashboard extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  LaundryManagerDashboard({Key? key}) : super(key: key);

  @override
  LaundryManagerDashboardState createState() => LaundryManagerDashboardState();
}

class LaundryManagerDashboardState extends State<LaundryManagerDashboard> {
  List<SalesData> data = [];

  double getTotalPricingForDay(List<UserOrder> orders, String dayOfWeek) {
    double totalPricing = 0;

    for (var order in orders) {
      if (order.isRequestCompleted) {
        String orderDay = DateFormat('EEE')
            .format(order.orderPlacementTime); // Get day abbreviation
        if (orderDay == dayOfWeek) {
          totalPricing += order.calculateTotal();
        }
      }
    }

    return totalPricing;
  }

  @override
  void initState() {
    data = [
      SalesData(
          'Mon',
          getTotalPricingForDay(
              ScopedModel.of<MyScopedModel>(context).userOrders, 'Mon')),
      SalesData(
          'Tue',
          getTotalPricingForDay(
              ScopedModel.of<MyScopedModel>(context).userOrders, 'Tue')),
      SalesData(
          'Wed',
          getTotalPricingForDay(
              ScopedModel.of<MyScopedModel>(context).userOrders, 'Wed')),
      SalesData(
          'Thu',
          getTotalPricingForDay(
              ScopedModel.of<MyScopedModel>(context).userOrders, 'Thu')),
      SalesData(
          'Fri',
          getTotalPricingForDay(
              ScopedModel.of<MyScopedModel>(context).userOrders, 'Fri')),
      SalesData(
          'Sat',
          getTotalPricingForDay(
              ScopedModel.of<MyScopedModel>(context).userOrders, 'Sat')),
      SalesData(
          'Sun',
          getTotalPricingForDay(
              ScopedModel.of<MyScopedModel>(context).userOrders, 'Sun'))
    ];
    super.initState();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<UserOrder> userOrders = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Dashboard'),
          actions: [
            PopupMenuButton<String>(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              icon: const Icon(Icons.person),
              onSelected: (String result) {
                if (result == 'Profile') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LaundryManagerProfile()),
                  );
                } else if (result == 'Logout') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'Profile',
                  child: Text('Profile'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'Logout',
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                          stream: _firestore
                              .collection('userData')
                              .doc(ScopedModel.of<MyScopedModel>(context)
                                  .authenticatedUser!
                                  .id)
                              .collection("orders")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.docs.isEmpty) {
                                return SfCartesianChart(
                                    primaryXAxis: const CategoryAxis(),
                                    // Chart title
                                    title:
                                        const ChartTitle(text: 'Daily Orders'),
                                    // Enable legend
                                    legend: const Legend(isVisible: true),
                                    // Enable tooltip
                                    tooltipBehavior:
                                        TooltipBehavior(enable: true),
                                    series: <CartesianSeries<SalesData,
                                        String>>[
                                      LineSeries<SalesData, String>(
                                          dataSource: data,
                                          xValueMapper: (SalesData sales, _) =>
                                              sales.day,
                                          yValueMapper: (SalesData sales, _) =>
                                              sales.sales,
                                          name: 'Sales',
                                          // Enable data label
                                          dataLabelSettings:
                                              const DataLabelSettings(
                                                  isVisible: true))
                                    ]);
                              }

                              final userOrdersJson = snapshot.data!.docs;
                              userOrders = userOrdersJson
                                  .map((doc) => UserOrder.fromJson(
                                      doc.data() as Map<String, dynamic>))
                                  .toList();
                              userOrders.sort((a, b) => b.orderPlacementTime
                                  .compareTo(a.orderPlacementTime));
                              ScopedModel.of<MyScopedModel>(context)
                                  .userOrders = userOrders;
                              userOrders.sort((a, b) => b.orderPlacementTime
                                  .compareTo(a.orderPlacementTime));

                              var unapprovedOrders = userOrders.where(
                                (element) =>
                                    element.status ==
                                        OrderStatus.pendingConfirmation ||
                                    element.status == OrderStatus.isOnHold,
                              );
                              if (unapprovedOrders.isNotEmpty) {
                                ScopedModel.of<MyScopedModel>(context)
                                    .currentOrder = unapprovedOrders.first;
                              } else {
                                ScopedModel.of<MyScopedModel>(context)
                                    .currentOrder = null;
                              }
                              data = [
                                SalesData(
                                    'Mon',
                                    getTotalPricingForDay(
                                        ScopedModel.of<MyScopedModel>(context)
                                            .userOrders,
                                        'Mon')),
                                SalesData(
                                    'Tue',
                                    getTotalPricingForDay(
                                        ScopedModel.of<MyScopedModel>(context)
                                            .userOrders,
                                        'Tue')),
                                SalesData(
                                    'Wed',
                                    getTotalPricingForDay(
                                        ScopedModel.of<MyScopedModel>(context)
                                            .userOrders,
                                        'Wed')),
                                SalesData(
                                    'Thu',
                                    getTotalPricingForDay(
                                        ScopedModel.of<MyScopedModel>(context)
                                            .userOrders,
                                        'Thu')),
                                SalesData(
                                    'Fri',
                                    getTotalPricingForDay(
                                        ScopedModel.of<MyScopedModel>(context)
                                            .userOrders,
                                        'Fri')),
                                SalesData(
                                    'Sat',
                                    getTotalPricingForDay(
                                        ScopedModel.of<MyScopedModel>(context)
                                            .userOrders,
                                        'Sat')),
                                SalesData(
                                    'Sun',
                                    getTotalPricingForDay(
                                        ScopedModel.of<MyScopedModel>(context)
                                            .userOrders,
                                        'Sun'))
                              ];
                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (ScopedModel.of<MyScopedModel>(
                                                      context)
                                                  .currentOrder !=
                                              null)
                                            Column(children: [
                                              const Text(
                                                "Order Awaiting Confirmation",
                                                style: TextStyle(fontSize: 17),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 4),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: OrderCard(
                                                      userOrder: ScopedModel.of<
                                                                  MyScopedModel>(
                                                              context)
                                                          .currentOrder!)),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                            ]),
                                          SfCartesianChart(
                                              primaryXAxis:
                                                  const CategoryAxis(),
                                              // Chart title
                                              title: const ChartTitle(
                                                  text: 'Daily Orders'),
                                              // Enable legend
                                              legend:
                                                  const Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior:
                                                  TooltipBehavior(enable: true),
                                              series: <CartesianSeries<
                                                  SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                    dataSource: data,
                                                    xValueMapper:
                                                        (SalesData sales, _) =>
                                                            sales.day,
                                                    yValueMapper:
                                                        (SalesData sales, _) =>
                                                            sales.sales,
                                                    name: 'Sales',
                                                    // Enable data label
                                                    dataLabelSettings:
                                                        const DataLabelSettings(
                                                            isVisible: true))
                                              ]),
                                        ])
                                  ]);
                            } else {
                              return const SizedBox();
                            }
                          })),
                ]))));
  }
}

class SalesData {
  SalesData(this.day, this.sales);

  final String day;
  final double sales;
}
