import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Models/user.dart';
import 'package:laundry_mgmt_system/Pages/user_bottom_navigation.dart';
import 'package:laundry_mgmt_system/app_colors.dart';
import 'package:laundry_mgmt_system/components/error_dialog.dart';
import 'package:laundry_mgmt_system/components/information_dialog.dart';
import 'package:laundry_mgmt_system/constant.dart';
import 'package:scoped_model/scoped_model.dart';

class UserCreationPage extends StatefulWidget {
  const UserCreationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserCreationPageState createState() => _UserCreationPageState();
}

class _UserCreationPageState extends State<UserCreationPage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _dobController;
  final _formKey = GlobalKey<FormState>();
  bool isBusy = false;
  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _dobController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Create An Account'),
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
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
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
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_month)),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _dobController.text =
                                DateFormat('yyyy-MM-dd').format(picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(60),
                          elevation: d.pSH(2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0))),
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
                                  lastName: _lastNameController.text,
                                  address: "",
                                  dob: DateTime.parse(_dobController.text),
                                  email: _emailController.text,
                                  phoneNumber: _phoneNumberController.text,
                                  role: "user");
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
                                                    const UserBottomNavigation()))
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
                          : const Text('Create Account'),
                    ),
                  ],
                ),
              ),
            )));
  }
}
