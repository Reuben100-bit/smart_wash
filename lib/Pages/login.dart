// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Models/scoped_model.dart';
import 'package:laundry_mgmt_system/Pages/laundry_bottom_navigation.dart';
import 'package:laundry_mgmt_system/Pages/select_account_creation_type.dart';
import 'package:laundry_mgmt_system/Pages/user_bottom_navigation.dart';
import 'package:laundry_mgmt_system/app_colors.dart';
import 'package:laundry_mgmt_system/components/error_dialog.dart';
import 'package:laundry_mgmt_system/constant.dart';
import 'package:scoped_model/scoped_model.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isBusy = false;
  final _formKey = GlobalKey<FormState>();
  bool hidePassword = true;
  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    d.init(context);

    return ScopedModelDescendant<MyScopedModel>(
        builder: ((context, child, model) {
      return Scaffold(
          body: ScopedModelDescendant<MyScopedModel>(
        builder: (context, child, model) => SafeArea(
            child:  SizedBox(
          height: d.getPhoneScreenHeight(),
          child: Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding:  EdgeInsets.only(top: d.pSW(20)),
                          alignment: Alignment.center,
                          // child: Image.asset(
                          //   'assets/images/$loginPng',
                          //   width: d.pSW(220),
                          //   height: d.pSH(220),
                          // ),
                        ),
                         SizedBox(
                          height: d.pSH(15),
                        ),
                        Container(
                          padding:
                               EdgeInsets.symmetric(horizontal: d.pSW(20)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Sign In",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    height: d.pSH(1),
                                    color: AppColors.primaryColor,
                                    fontSize: d.pSH(25)),
                              ),
                              Container(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    "Enter your credentials to get started",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        height: d.pSH(1),
                                        color: Colors.black,
                                        fontSize: d.pSH(20)),
                                  )),
                               SizedBox(
                                height: d.pSH(25),
                              ),
                              Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: emailController,
                                        decoration: const InputDecoration(
                                          prefixIcon: Icon(Icons.email),
                                          labelText: 'Email',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                       SizedBox(
                                        height: d.pSH(15),
                                      ),
                                      TextFormField(
                                        controller: passwordController,
                                        obscureText: hidePassword,
                                        decoration: InputDecoration(
                                          prefixIcon:const  Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  hidePassword = !hidePassword;
                                                });
                                              },
                                              icon: Icon(hidePassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off)),
                                          labelText: 'Password',
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                      /* TextButton(
                                          onPressed: () {},
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/$googleSvg',
                                                width: d.pSW(24),
                                                height: d.pSH(24),
                                              ),
                                               const SizedBox(
                                                width: d.pSH(5),
                                              ),
                                              Text(
                                                "Login with Google",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height: d.pSH(1),
                                                    color:
                                                        AppColors.blackColorOne,
                                                    fontSize: d.pSH(16)),
                                              ),
                                            ],
                                          )),*/
                                       SizedBox(
                                        height: d.pSH(25),
                                      ),
                                       SizedBox(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            setState(() {
                                              isBusy = true;
                                            });
                                            if (emailController.text ==
                                                "appadmin@gmail.com") {
                                              await model
                                                  .adminSignIn(
                                                      emailController.text,
                                                      passwordController.text)
                                                  .then((value) {
                                                if (value == true) {
                                                  setState(() {
                                                    isBusy = false;
                                                  });
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        const ErrorDialog(
                                                      message:
                                                          'Incorrect Password!',
                                                    ),
                                                  ).then((value) {
                                                    setState(() {
                                                      isBusy = false;
                                                    });
                                                  });
                                                }
                                              });
                                            } else {
                                              await model
                                                  .signIn(emailController.text,
                                                      passwordController.text)
                                                  .then((value) async {
                                                if (value != null) {
                                                  if (value.role == "user") {
                                                    var profiles = await model
                                                        .getLaundryProfiles();
                                                    profiles.forEach(
                                                        (element) async {
                                                      final laundryService =
                                                          await model
                                                              .getLaundryServicesForLaundry(
                                                                  element.id,
                                                                  element
                                                                      .firstName);
                                                      model.laundryServices
                                                          .add(laundryService);
                                                    });
                                                    Navigator.pushReplacement(
                                                        // ignore: use_build_context_synchronously
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              const UserBottomNavigation(),
                                                        ));
                                                  } else {
                                                    await model
                                                        .getCurrentOrder(true);
                                                    setState(() {
                                                      isBusy = false;
                                                    });
                                                    Navigator.pushReplacement(
                                                        // ignore: use_build_context_synchronously
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const LaundryBottomNavigation()));
                                                  }
                                                } else {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        const ErrorDialog(
                                                      message:
                                                          'Invalid Username or Password!',
                                                    ),
                                                  ).then((value) {
                                                    setState(() {
                                                      isBusy = false;
                                                    });
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(60),
                                              elevation: d.pSH(2),
                                              backgroundColor:
                                                  AppColors.greenColorTwo,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          d.pSH(5))),
                                              padding:  EdgeInsets.all(
                                                  d.pSH(0.5))),
                                          child: isBusy == true
                                              ?  SizedBox(
                                                  height: d.pSH(18),
                                                  width: d.pSH(18),
                                                  child:  const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ),
                                                  ))
                                              : Text(
                                                  "Login",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: d.pSH(18),
                                                      color: AppColors
                                                          .whiteColorOne),
                                                ),
                                        ),
                                      ),
                                       SizedBox(
                                        height: d.pSH(35),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SelectAccountCreationType(),
                                                ));
                                          },
                                          child: Text.rich(TextSpan(
                                              style: TextStyle(
                                                  color:
                                                      AppColors.blackColorOne),
                                              text: "Don't have an account? ",
                                              children: [
                                                TextSpan(
                                                  text: "Sign Up",
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .blueColorOne),
                                                )
                                              ]))),
                                      /*   TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddDoctorPage(),
                                                ));
                                          },
                                          child: Text.rich(TextSpan(
                                              style: TextStyle(
                                                  color:
                                                      AppColors.blackColorOne),
                                              text: "Create doctor account? ",
                                              children: [
                                                TextSpan(
                                                  text: "Sign Up",
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .blueColorOne),
                                                )
                                              ]))),*/
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ]),
                ),
              ),
              Positioned(
                top: d.pSH(10),
                left: d.pSH(10),
                child:  SizedBox(
                  height: d.pSH(60),
                  // child: Image.asset(
                  //   'assets/images/$knustLogoPng',
                  //   width: d.pSW(30),
                  //   height: d.pSH(30),
                  // ),
                ),
              ),
            ],
          ),
        )),
      ));
    }));
  }
}

class FormCardTextFeild extends StatelessWidget {
  const FormCardTextFeild(
      {super.key,
      required this.hintText,
      required this.emailController,
      required this.iconData});

  final TextEditingController emailController;
  final String hintText;
  final IconData iconData;
  @override
  Widget build(BuildContext context) {
    return Card(
        color: AppColors.whiteColorOne,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(d.pSH(5))),
        child: Padding(
          padding:  EdgeInsets.symmetric(
              horizontal: d.pSH(10), vertical: d.pSH(3)),
          child: TextFormField(
            controller: emailController,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ));
  }
}
