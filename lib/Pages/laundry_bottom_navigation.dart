import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Pages/LaundryManagerPages/dashboard.dart';
import 'package:laundry_mgmt_system/Pages/LaundryManagerPages/orders.dart';
import 'package:laundry_mgmt_system/Pages/LaundryManagerPages/services.dart';

class LaundryBottomNavigation extends StatefulWidget {
  const LaundryBottomNavigation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LaundryBottomNavigationState createState() =>
      _LaundryBottomNavigationState();
}

class _LaundryBottomNavigationState extends State<LaundryBottomNavigation> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    LaundryManagerDashboard(),
    const LaundryManagerOrders(),
    const LaundryManagerServices()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20), bottom: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: const Color(0xff0e004b),
                selectedItemColor: const Color(0xff067f89),
                unselectedItemColor: Colors.white,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt_sharp),
                    label: 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.aod_sharp),
                    label: 'Services',
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  const PlaceholderWidget(this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: const Center(
        child: Text(
          'Tab Content',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
