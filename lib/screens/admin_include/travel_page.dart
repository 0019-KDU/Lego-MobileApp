import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lego/classes/specialpassenger.dart';
import 'package:lego/screens/admin_include/specil_history.dart';

class TravelForm extends StatefulWidget {
  const TravelForm(List<int> list, {Key? key}) : super(key: key);

  @override
  _TravelFormState createState() => _TravelFormState();
}

class _TravelFormState extends State<TravelForm> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _userType = '';
  late String _purpose;
  bool? _charge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Travel Form',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(
            color: Colors.white, // Change the color of the leading icon
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select User Type:',
                    style: TextStyle(fontSize: 16),
                  ),
                  RadioListTile(
                    title: const Text('Military'),
                    value: 'Military',
                    groupValue: _userType,
                    onChanged: (value) {
                      setState(() {
                        _userType = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Dayscholar'),
                    value: 'Dayscholar',
                    groupValue: _userType,
                    onChanged: (value) {
                      setState(() {
                        _userType = value.toString();
                      });
                    },
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the purpose of travel';
                  }
                  return null;
                },
                onSaved: (value) {
                  _purpose = value!;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Charge Money',
                    style: TextStyle(fontSize: 16),
                  ),
                  Checkbox(
                    value: _charge ?? false,
                    onChanged: (value) {
                      setState(() {
                        _charge = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _submitForm(context);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle the history button press (navigate to history screen, for example)
          // Navigate to the SpecialHistoryPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SpecialHistoryPage()),
          );
        },
        child: const Icon(Icons.history),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save to Firestore with date and time
      final specialPassenger = SpecialPassenger(
        username: _username,
        userType: _userType,
        purpose: _purpose,
        chargeMoney: _charge ?? false,
        dateTime: DateTime.now(),
      );

      FirebaseFirestore.instance
          .collection('SpeacialPassenger')
          .add(specialPassenger.toMap())
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data saved successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        _formKey.currentState!.reset();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving data: $error',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }
}
