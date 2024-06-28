import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user.dart';
import 'package:laundry_mgmt_system/Pages/laundry_bottom_navigation.dart';
import 'package:laundry_mgmt_system/app_colors.dart';
import 'package:laundry_mgmt_system/components/error_dialog.dart';
import 'package:laundry_mgmt_system/components/information_dialog.dart';
import 'package:laundry_mgmt_system/constant.dart';
import 'package:scoped_model/scoped_model.dart';

class LaundryRegistrationPage extends StatefulWidget {
  const LaundryRegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LaundryRegistrationPageState createState() =>
      _LaundryRegistrationPageState();
}

class _LaundryRegistrationPageState extends State<LaundryRegistrationPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();
  String addressCoordinates = "";
  bool isBusy = false;
  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    addressCoordinates = position.toString();
    Placemark place = placemarks[0];
    setState(() {
      _addressController.text =
          "${place.name}, ${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Set Up Laundry'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email)),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone),
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      keyboardType: TextInputType.phone,
                      readOnly: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.location_city),
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60), // NEW
                          elevation: d.pSH(2),
                          backgroundColor: AppColors.greenColorTwo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                          padding:  EdgeInsets.all(d.pSH(0.5))),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isBusy = true;
                          });

                          await ScopedModel.of<MyScopedModel>(context)
                              .signUp(_emailController.text,
                                  _passwordController.text)
                              .then((value1) async {
                            if (value1 != null) {
                              UserProfile userProfile = UserProfile(
                                  id: value1.user!.uid,
                                  firstName: _firstNameController.text,
                                  lastName: "",
                                  address: addressCoordinates,
                                  dob: DateTime.now(),
                                  email: _emailController.text,
                                  phoneNumber: _phoneNumberController.text,
                                  role: "manager");
                              await ScopedModel.of<MyScopedModel>(context)
                                  .addUserProfile(userProfile)
                                  .then((value) {
                                setState(() {
                                  isBusy = false;
                                });
                                if (value != "Success") {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        const ErrorDialog(
                                      message:
                                          'Couldn\'t not create account please try again ',
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        const InformationDialog(
                                      message: 'Account Created Successfully',
                                    ),
                                  ).then((value) => {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const LaundryBottomNavigation()))
                                      });
                                }
                              });
                            } else {
                              setState(() {
                                isBusy = false;
                              });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    const ErrorDialog(
                                  message:
                                      'Couldn\'t not create account please try again ',
                                ),
                              );
                            }
                          });
                        }
                      },
                      child: isBusy
                          ? const SizedBox(
                              height: 30,
                              width: 30,
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: Colors.white,
                              )),
                            )
                          : const Text('Add Laundry'),
                    ),
                  ],
                ),
              ),
            )));
  }
}
