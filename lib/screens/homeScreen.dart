import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:wish_festivle/controller/appController.dart';
import 'package:wish_festivle/model/FestivalModel.dart';
import 'package:wish_festivle/screens/addEmailScreen.dart';
import 'package:wish_festivle/screens/addFestivalScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;
  FestivalModel? todayFestival;

  Future<void> _prepareTodayFestivalAttachment() async {
    final controller = Get.find<AppController>();
    final today = DateTime.now();

    final festival = controller.festivals.firstWhereOrNull(
      (f) => DateUtils.isSameDay(f.date, today),
    );

    if (festival != null) {
      setState(() {
        todayFestival = festival;
      });
    }
  }

  Future<void> sendEmailDirectly({
    required List<String> recipients,
    required String subject,
    required String body,
    required String imagePath,
  }) async {
    setState(() {
      isLoading = true;
    });
    final smtpServer = gmail(
      'academy.qb@gmail.com',
      "xbefiedbeeodyofl",
    );

    final attachmentFile = File(imagePath);
    final attachmentSize = await attachmentFile.length();

    final message = Message()
      ..from = Address('academy.qb@gmail.com', 'Festival Wishes')
      ..recipients.addAll(recipients)
      ..subject = subject
      ..html = '''
        <div>
          <img src="cid:uniqueImage" style="height:50vh; max-height:400px; width:auto; display:block; margin:auto;" />
          <p style="font-family:sans-serif; font-size:14px; line-height:1.5;">
            ${body.replaceAll('\n', '<br>')}
          </p>
        </div>
      '''
      ..attachments = [
        FileAttachment(attachmentFile)
          ..location = Location.inline
          ..cid = 'uniqueImage',
      ];

    print('📧 Sending Email...');
    print('📝 Subject: $subject');
    print('🗒️ Body: $body');
    print('👥 Recipients: $recipients');
    print('📎 Attachment Path: ${attachmentFile.path}');
    print('📦 Attachment Size: ${attachmentSize ~/ 1024} KB');

    try {
      final sendReport = await send(message, smtpServer);
      print('Email sent: ' + sendReport.toString());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email sent successfully!'),
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Email failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send email'),
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _prepareTodayFestivalAttachment();
    return GetBuilder<AppController>(
      init: AppController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text("Home")),
          drawer: Drawer(
            child: ListView(
              children: [
                SizedBox(height: 50),
                Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ).paddingOnly(left: 15),
                Divider(),
                ListTile(
                  title: Text('Add Festival Details'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Get.to(() => AddFestivalScreen())?.then((val) {
                      _prepareTodayFestivalAttachment();
                    });
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('Add Email'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Get.to(() => AddEmailScreen())?.then((val) {
                      setState(() {});
                    });
                  },
                ),
                Divider(),
              ],
            ),
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: todayFestival != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                SizedBox(width: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(todayFestival!.imagePath),
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _infoText(
                                          "Festival Date : ",
                                          DateFormat('dd MMM yyyy')
                                              .format(todayFestival!.date)),
                                      _infoText("Festival Name : ",
                                          todayFestival!.name),
                                      _infoText(
                                          "Subject : ", todayFestival!.details),
                                      _infoText(
                                          "Wishes : ", todayFestival!.wishes),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text("No Festival Found Today"),
                            ),
                          ),
                  ),
                  SizedBox(height: 20),
                  Obx(() {
                    if (controller.emails.isNotEmpty) {
                      return Text("Select Emails:",
                          style: TextStyle(fontWeight: FontWeight.bold));
                    }
                    return SizedBox();
                  }),
                  Obx(() {
                    return Column(
                      children: controller.emails.map((email) {
                        return CheckboxListTile(
                          title: Text(email.email),
                          value: email.isSelected,
                          activeColor: Colors.blue,
                          onChanged: (val) {
                            email.isSelected = val!;
                            controller.update();
                          },
                        );
                      }).toList(),
                    );
                  }),
                ],
              ),
              if (isLoading == true) ...[
                Center(child: CircularProgressIndicator())
              ],
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GestureDetector(
              onTap: () async {
                if (todayFestival == null) return;

                final selectedEmails = controller.emails
                    .where((e) => e.isSelected)
                    .map((e) => e.email)
                    .toList();

                if (selectedEmails.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please select at least one email'),
                    behavior: SnackBarBehavior.floating,
                  ));
                  return;
                }

                String subject = todayFestival!.name;
                String body = '${todayFestival!.wishes}';
                String? selectedImagePath = todayFestival!.imagePath;

                TextEditingController subjectController =
                    TextEditingController(text: subject);
                TextEditingController bodyController =
                    TextEditingController(text: body);

                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 16,
                          right: 16,
                          top: 16),
                      child: StatefulBuilder(builder: (context, setModalState) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Edit Email Details",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 16),
                              TextFormField(
                                controller: subjectController,
                                decoration:
                                    InputDecoration(labelText: 'Subject'),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: bodyController,
                                maxLines: 5,
                                decoration: InputDecoration(labelText: 'Body'),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 50);
                                  if (pickedFile != null) {
                                    setModalState(() {
                                      selectedImagePath = pickedFile.path;
                                    });
                                  }
                                },
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: selectedImagePath == null
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              File(selectedImagePath!),
                                              height: 150,
                                              fit: BoxFit.fitHeight,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                  await sendEmailDirectly(
                                    recipients: selectedEmails,
                                    subject: subjectController.text,
                                    body: bodyController.text,
                                    imagePath: selectedImagePath!,
                                  );

                                  for (var e in controller.emails) {
                                    e.isSelected = false;
                                  }
                                  controller.update();
                                },
                                child: Container(
                                  height: 50,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Send Email",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Send Wishes",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: "$label\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: "$value\n"),
        ],
      ),
    );
  }
}
