import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FrogetPasswordPage extends StatefulWidget {
  const FrogetPasswordPage({super.key});

  @override
  State<FrogetPasswordPage> createState() => _FrogetPasswordPageState();
}

class _FrogetPasswordPageState extends State<FrogetPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordRest() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Password rest link sent!check your Email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 25.0),
            child: Text(
              "Enter your Email And we will send your a password link",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10.0),
                filled: true,
                fillColor: Colors.white,
                hintText: 'Email',
                labelText: 'Email',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
                enabled: true,
                prefixIcon: const Icon(
                  Icons.email_sharp,
                  color: Colors.black,
                  size: 18,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                floatingLabelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 18.0,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Email cannot be empty";
                }
                if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0.9.-]+.[a-z]")
                    .hasMatch(value)) {
                  return ("Please enter a valid email");
                } else {
                  return null;
                }
              },
              onSaved: (value) {
                emailController.text = value!;
              },
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          MaterialButton(
            onPressed: passwordRest,
            color: Colors.deepPurple[200],
            child: const Text("Reset Password"),
          )
        ],
      ),
    );
  }
}
