class Payment {
  final String imageURL;
  final List<String> months;
  final String userId;

  Payment(this.imageURL, this.months, this.userId);

  // Create a method to convert the payment data to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'imageURL': imageURL,
      'months': months,
      'userId': userId,
    };
  }
}
