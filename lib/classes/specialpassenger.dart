class SpecialPassenger {
  late String username;
  late String userType;
  late String purpose;
  late bool chargeMoney;
  late DateTime dateTime;

  SpecialPassenger({
    required this.username,
    required this.userType,
    required this.purpose,
    required this.chargeMoney,
    required this.dateTime,
  });

  // Method to convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'userType': userType,
      'purpose': purpose,
      'chargeMoney': chargeMoney,
      'dateTime': dateTime,
    };
  }
}
