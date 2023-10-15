import 'package:cloud_firestore/cloud_firestore.dart';

class HistoricalRequest {
  final int requestedSeats;
  final String purpose;
  final String status;
  final Timestamp timestamp;

  HistoricalRequest({
    required this.requestedSeats,
    required this.purpose,
    required this.status,
    required this.timestamp,
  });

  // Convert HistoricalRequest to a Map
  Map<String, dynamic> toMap() {
    return {
      'requestedSeats': requestedSeats,
      'purpose': purpose,
      'status': status,
      'timestamp': timestamp,
    };
  }

  // Create a HistoricalRequest object from a Map
  factory HistoricalRequest.fromMap(Map<String, dynamic> map) {
    return HistoricalRequest(
      requestedSeats: map['requestedSeats'],
      purpose: map['purpose'],
      status: map['status'],
      timestamp: map['timestamp'],
    );
  }
}
