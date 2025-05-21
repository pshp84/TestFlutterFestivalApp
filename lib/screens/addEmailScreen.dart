import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wish_festivle/controller/appController.dart';

class AddEmailScreen extends StatelessWidget {
  final emailController = TextEditingController();

  void _submitEmail() {
    final email = emailController.text.trim();
    if (GetUtils.isEmail(email)) {
      Get.find<AppController>().addEmail(email);
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        content: Text('email address added successfully'),
        behavior: SnackBarBehavior.floating,
      ));
      emailController.clear();
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        content: Text('Please enter a valid email address'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _submitEmail,
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Add Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
