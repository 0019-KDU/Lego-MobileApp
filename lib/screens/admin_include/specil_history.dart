import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpecialHistoryPage extends StatelessWidget {
  const SpecialHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Special History Page',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(
            color: Colors.white, // Change the color of the leading icon
          )),
      body: FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('SpeacialPassenger').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Process the data and display only name and user type
            List<DocumentSnapshot> documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    documents[index].data() as Map<String, dynamic>;

                // Add 'return' here
                return ListTile(
                  title: Text(
                    data['username'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'User Type: ${data['userType']}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  leading: const Icon(
                    Icons.person,
                    color: Colors.blue, // Customize the icon color
                  ),
                  trailing: const Icon(
                    Icons
                        .arrow_forward, // You can replace this with your preferred icon
                    color: Colors.green, // Customize the icon color
                  ),
                  onTap: () {
                    // Display full details on item click
                    _showDetailsDialog(context, data);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    print('Showing details for ${data['username']} - ${data['userType']}');
    // Format the date
    // Check if the 'dateTime' field exists and is not null
    DateTime? dateTime = data['dateTime']?.toDate();

    // Format the date
    String formattedDate =
        dateTime != null ? DateFormat('dd/MM/yyyy').format(dateTime) : 'N/A';

    showDialog(
      context: context,
      builder: (context) {
        print('Building details dialog');

        return AlertDialog(
          title: const Text('Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${data['username']}'),
              Text('User Type: ${data['userType']}'),
              Text('Purpose: ${data['purpose']}'),
              Text('Date: $formattedDate'),
              // Add more fields as needed
            ],
          ),
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
  }
}
