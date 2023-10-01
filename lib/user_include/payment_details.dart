import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late User _currentUser;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
  }

  Future<void> _handleTap() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<String?> uploadImageToStorage(
      XFile imageFile, String paymentId) async {
    String? imageUrl;
    try {
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('payments/$paymentId')
          .putFile(File(imageFile.path));
      imageUrl = await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
    }
    return imageUrl;
  }

  void savePaymentData() async {
    try {
      if (_selectedImage == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: const Text(
                  'Are you sure you want to make a payment without adding a photo?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _performPayment();
                  },
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        );
      } else {
        _performPayment();
      }
    } catch (e) {
      print(e);
    }
  }

  void _performPayment() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();

      // Convert userDoc data to a Map
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      if (userDoc.exists && userData['username'] != null) {
        String userName = userData['username'];
        DocumentReference paymentRef =
            await FirebaseFirestore.instance.collection('payments').add({
          'status': 'pending',
          'userName': userName,
        });

        if (_selectedImage != null) {
          String? imageUrl =
              await uploadImageToStorage(_selectedImage!, paymentRef.id);
          if (imageUrl != null) {
            await FirebaseFirestore.instance
                .collection('payments')
                .doc(paymentRef.id)
                .update({'imageUrl': imageUrl});
          }
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Payment Pending'),
              content: const Text('Your payment is pending approval.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      } else {
        print("User document not found or username is null");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: _handleTap,
              child: Container(
                width: 150,
                height: 150,
                color: Colors.grey, // Placeholder color
                child: _selectedImage != null
                    ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
                    : const Icon(Icons.add_a_photo,
                        size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: savePaymentData,
              child: const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
