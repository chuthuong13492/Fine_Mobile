import 'package:intl/intl.dart';

String formatDateType(String date) {
  DateTime format = DateTime.parse(date.replaceAll('T', ' '));

  return DateFormat('dd/MM/yyyy').format(format);
}

String formatTimeType(String date) {
  DateTime format = DateTime.parse(date.replaceAll('T', ' '));

  return DateFormat.jm().format(format);
}

String formatTime(String inputTime) {
  DateTime dateTime = DateFormat('HH:mm:ss').parse(inputTime);
  String formattedTime = DateFormat('h:mm').format(dateTime);
  return formattedTime;
}
