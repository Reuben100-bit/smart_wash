import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Api/firebase_api.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Pages/login.dart';
import 'package:laundry_mgmt_system/Pages/notifications_page.dart';
import 'package:laundry_mgmt_system/firebase_options.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';

final navigatorKey = GlobalKey<NavigatorState>();
String? firebaseMessagingToken;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  MyScopedModel? myModel;
  @override
  void initState() {
    myModel = MyScopedModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MyScopedModel>(
        model: myModel!,
        child: ScopedModelDescendant<MyScopedModel>(
            builder: (context, child, state) {
          return MaterialApp(
            title: 'Flutter Demo',
            navigatorKey: navigatorKey,
            routes: {'/notification_screen': (context) => const NotificationsPage()},
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const Login(),
          );
        }));
  }
}

String formatCurrency(double value) {
  // Create NumberFormat instance for currency formatting
  final NumberFormat format = NumberFormat.currency(
    locale: 'en_US', // Specify locale for currency formatting
    symbol: 'GH₵', // Specify currency symbol
    decimalDigits: 2, // Specify the number of decimal digits
  );

  // Format the value and return as a string
  return format.format(value);
}
