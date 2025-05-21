import 'package:get/state_manager.dart';
import 'package:wish_festivle/model/EmailModel.dart';
import 'package:wish_festivle/model/FestivalModel.dart';

class AppController extends GetxController {
  var festivals = <FestivalModel>[].obs;
  var emails = <EmailModel>[].obs;

  void addFestival(FestivalModel festival) {
    festivals.add(festival);
  }

  void addEmail(String email) {
    emails.add(EmailModel(email: email));
  }

  List<String> attachments = [];
}
