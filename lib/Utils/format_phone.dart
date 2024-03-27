String formatPhoneNumberWithDots(String phoneNumber) {
  phoneNumber = phoneNumber.replaceAll(RegExp(r'\D+'), '');
  phoneNumber = phoneNumber.replaceAllMapped(
      RegExp(r'.{1,3}(?!$)'), (match) => '${match.group(0)}.');

  int lastDotIndex = phoneNumber.lastIndexOf('.');
  if (lastDotIndex != -1) {
    phoneNumber = phoneNumber.substring(0, lastDotIndex) +
        phoneNumber.substring(lastDotIndex + 1);
  }

  return phoneNumber;
}
