import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Components/order_card.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Pages/login.dart';
import 'package:scoped_model/scoped_model.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            elevation: 0,
            icon: const Icon(Icons.person),
            onSelected: (String result) {
              if (result == 'Logout') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your spending for the month is: ",
                  style: TextStyle(fontSize: 20)),
              Text(
                "GH 40.00",
                style: TextStyle(fontSize: 17),
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Most Current Order",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Container(
                  padding: const EdgeInsets.all(8),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ScopedModel.of<MyScopedModel>(context).currentOrder ==
                          null
                      ? const Text("You have no active orders")
                      : OrderCard(
                          userOrder: ScopedModel.of<MyScopedModel>(context)
                              .currentOrder!))
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          const Text(
            "Special Orders For You",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const Text(
            "We have no offers for you at this time",
            style: TextStyle(fontSize: 17),
          ),
        ]),
      ),
    );
  }
}
