import 'package:flutter/material.dart';
import 'package:laundry_mgmt_system/Pages/create_laundry.dart';
import 'package:laundry_mgmt_system/Pages/create_user.dart';
import 'package:laundry_mgmt_system/app_colors.dart';
import 'package:laundry_mgmt_system/constant.dart';

class SelectAccountCreationType extends StatelessWidget {
  const SelectAccountCreationType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(60),
                          elevation: d.pSH(2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0))),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    const UserCreationPage())));
                      },
                      child: const Text(
                        'Sign Up As User',
                      ),
                    ),
                    const SizedBox(
                        height: 20), // Add some space between buttons
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) =>
                                    const LaundryRegistrationPage())));
                      },
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryColor,
                          minimumSize: const Size.fromHeight(60),
                          elevation: d.pSH(2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0))),
                      child: const Text('Register Your Laundry'),
                    ),
                  ],
                ))));
  }
}
