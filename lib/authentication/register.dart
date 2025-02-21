import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lego/components/app_styles.dart';
import 'package:lottie/lottie.dart';

import 'login.dart';
// import 'model.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  _RegisterState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  var options = [
    'Permanent',
    'Non-Permanent',
  ];
  final _currentItemSelected = "Permanent";
  var rool = "Non-Permanent";

  int activeIndex = 0; // Declare _timer here

  @override
  void initState() {
    super.initState();

    // Store a reference to the timer so you can cancel it in dispose
  }

  @override
  void dispose() {
    // Cancel the timer in the dispose method to prevent further calls

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 300,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 50,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Lottie.asset(
                                  'assets/bus.json', // Path to your JSON animation file
                                  height: 250,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Register Now...",
                            style: ralewayStyle.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 40,
                              // Customize font style here:
                              // Change to your desired font style
                              letterSpacing:
                                  2.0, // Change to your desired letter spacing
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        TextFormField(
                          controller: userNameController,
                          textInputAction: TextInputAction.next,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true, // Ensure the background is filled
                            fillColor: Colors
                                .white, // Set the background color to white
                            contentPadding: const EdgeInsets.all(0.0),
                            labelText: 'Username',
                            hintText: 'Username or Full Name',
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            prefixIcon: const Icon(
                              Icons.man_2_outlined,
                              color: Colors.black,
                              size: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            floatingLabelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Username cannot be empty";
                            }
                            // Add any other validation rules for username
                            return null; // Return null to indicate no error
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: emailController,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            filled: true, // Ensure the background is filled
                            fillColor: Colors
                                .white, // Set the background color to white
                            contentPadding: const EdgeInsets.all(0.0),
                            labelText: 'Email',
                            hintText: 'User Email',
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_sharp,
                              color: Colors.black,
                              size: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            floatingLabelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Email cannot be empty";
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0.9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please enter a valid email");
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {},
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          obscureText: _isObscure,
                          controller: passwordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(_isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                }),
                            filled: true, // Ensure the background is filled
                            fillColor: Colors
                                .white, // Set the background color to white
                            contentPadding: const EdgeInsets.all(0.0),
                            labelText: 'Password',
                            hintText: 'Password',
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            prefixIcon: const Icon(
                              Icons.key,
                              color: Colors.black,
                              size: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            floatingLabelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) {
                            RegExp regex = RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return "Password cannot be empty";
                            }
                            if (!regex.hasMatch(value)) {
                              return ("please enter valid password min. 6 characters");
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {},
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          obscureText: _isObscure2,
                          controller: confirmpassController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(_isObscure2
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isObscure2 = !_isObscure2;
                                  });
                                }),
                            filled: true, // Ensure the background is filled
                            fillColor: Colors
                                .white, // Set the background color to white
                            contentPadding: const EdgeInsets.all(0.0),
                            labelText: 'Confirm Password',
                            hintText: 'Confirm Password',
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14.0,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.black,
                              size: 18,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            floatingLabelStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) {
                            if (confirmpassController.text !=
                                passwordController.text) {
                              return "Password did not match";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {},
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: rool == "Permanent",
                              onChanged: (bool? value) {
                                setState(() {
                                  rool = value! ? "Permanent" : "Non-Permanent";
                                });
                              },
                            ),
                            const Text(
                              "Permanent",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                                width:
                                    20), // Add some space between the checkboxes
                            Checkbox(
                              value: rool == "Non-Permanent",
                              onChanged: (bool? value) {
                                setState(() {
                                  rool = value! ? "Non-Permanent" : "Permanent";
                                });
                              },
                            ),
                            const Text(
                              "Non-Permanent",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MaterialButton(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0))),
                              height: 40,
                              onPressed: () {
                                setState(() {
                                  showProgress = true;
                                });
                                signUp(
                                  emailController.text,
                                  passwordController.text,
                                  rool,
                                  userNameController.text,
                                );
                              },
                              color: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 50),
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: "You already have an account? ",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Login",
                                    style: TextStyle(
                                        color: Colors
                                            .black, // Change the color to your desired color
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signUp(
      String email, String password, String rool, String username) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        if (userCredential.user != null) {
          // User registration successful, now post details to Firestore
          await postDetailsToFirestore(email, rool, username);
        } else {
          // Handle the case where userCredential.user is null
          // This should not typically happen, but you can add error handling here
        }
      } catch (e) {
        // Handle registration errors
        if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
          // The email address is already in use
          print('Email address is already in use.');

          // Display a SnackBar with the error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email address is already in use.'),
              duration: Duration(seconds: 3), // Adjust the duration as needed
            ),
          );
        } else {
          // Handle other registration errors
          print('Registration Error: ${e.toString()}');
          // You can display a generic error message or handle specific errors
        }
      }
    }
  }

  postDetailsToFirestore(String email, String rool, String username) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({
      'email': emailController.text,
      'rool': rool,
      'username': userNameController.text, // Add the username field
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }
}
