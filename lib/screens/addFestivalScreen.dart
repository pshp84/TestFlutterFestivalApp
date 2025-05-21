import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:wish_festivle/controller/appController.dart';
import 'package:wish_festivle/model/FestivalModel.dart';

class AddFestivalScreen extends StatefulWidget {
  @override
  State<AddFestivalScreen> createState() => _AddFestivalScreenState();
}

class _AddFestivalScreenState extends State<AddFestivalScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final detailsController = TextEditingController();
  final wishesController = TextEditingController();
  final dateController = TextEditingController();
  DateTime? selectedDate;
  String? imagePath;

  final controller = Get.put(AppController());

  void _pickImage() async {
    controller.attachments.clear();
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imagePath = picked.path;
        controller.attachments.add(picked.path);
        controller.update();
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        selectedDate != null &&
        imagePath != null) {
      final festival = FestivalModel(
        name: nameController.text,
        details: detailsController.text,
        wishes: wishesController.text,
        imagePath: imagePath!,
        date: selectedDate!,
      );
      Get.find<AppController>().addFestival(festival);
      Get.back();
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        content: Text('Please fill all fields and select date/image'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Festival")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameController,
              validator: (v) => v!.isEmpty ? 'Enter festival name' : null,
              decoration: InputDecoration(hintText: 'Festival Name'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: detailsController,
              validator: (v) => v!.isEmpty ? 'Enter details' : null,
              decoration: InputDecoration(hintText: 'Festival Details'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: wishesController,
              validator: (v) => v!.isEmpty ? 'Enter wishes' : null,
              decoration: InputDecoration(hintText: 'Festival Wishes'),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: dateController,
              validator: (v) => v!.isEmpty ? 'Enter Date' : null,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                    dateController.text =
                        DateFormat('dd MMM yyyy').format(date);
                  });
                }
              },
              decoration: InputDecoration(hintText: 'Festival Date'),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: imagePath == null
                    ? Center(
                        child: Text(
                        "Pick Image",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ))
                    : Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(imagePath!),
                            height: 200,
                            fit: BoxFit.fitHeight,
                            width: double.infinity,
                          ),
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _submit,
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Add Festival",
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
