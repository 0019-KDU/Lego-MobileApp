import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  var _currentItemSelected = "Permanent";
  var rool = "Non-Permanent";

  int activeIndex = 0;
  late Timer _timer; // Declare _timer here

  @override
  void initState() {
    super.initState();

    // Store a reference to the timer so you can cancel it in dispose
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          activeIndex++;

          if (activeIndex == 4) activeIndex = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer in the dispose method to prevent further calls
    _timer.cancel();

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
                          height: 420,
                          child: Stack(children: [
                            Positioned(
                              top: 50,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: AnimatedOpacity(
                                opacity: activeIndex == 0 ? 1 : 0,
                                duration: const Duration(
                                  seconds: 1,
                                ),
                                curve: Curves.linear,
                                child: Image.network(
                                  'https://ouch-cdn2.icons8.com/As6ct-Fovab32SIyMatjsqIaIjM9Jg1PblII8YAtBtQ/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNTg4/LzNmMDU5Mzc0LTky/OTQtNDk5MC1hZGY2/LTA2YTkyMDZhNWZl/NC5zdmc.png',
                                  height: 250,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 50,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: AnimatedOpacity(
                                opacity: activeIndex == 1 ? 1 : 0,
                                duration: const Duration(seconds: 1),
                                curve: Curves.linear,
                                child: Image.network(
                                  'https://ouch-cdn2.icons8.com/vSx9H3yP2D4DgVoaFPbE4HVf6M4Phd-8uRjBZBnl83g/rs:fit:784:784/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvNC84/MzcwMTY5OS1kYmU1/LTQ1ZmEtYmQ1Ny04/NTFmNTNjMTlkNTcu/c3Zn.png',
                                  height: 250,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 50,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: AnimatedOpacity(
                                opacity: activeIndex == 2 ? 1 : 0,
                                duration: const Duration(seconds: 1),
                                curve: Curves.linear,
                                child: Image.asset(
                                  'assets/signup.png',
                                  height: 250,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 50,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: AnimatedOpacity(
                                opacity: activeIndex == 3 ? 1 : 0,
                                duration: const Duration(seconds: 1),
                                curve: Curves.linear,
                                child: Image.network(
                                  'https://ouch-cdn2.icons8.com/AVdOMf5ui4B7JJrNzYULVwT1z8NlGmlRYZTtg1F6z9E/rs:fit:784:767/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9zdmcvOTY5/L2NlMTY1MWM5LTRl/ZjUtNGRmZi05MjQ3/LWYzNGQ1MzhiOTQ0/Mi5zdmc.png',
                                  height: 250,
                                ),
                              ),
                            )
                          ]),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Register Now...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 40,
                              // Customize font style here:
                              fontFamily:
                                  'YourFontFamily', // Change to your desired font family
                              fontStyle: FontStyle
                                  .italic, // Change to your desired font style
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
                            const Text(
                              "Role : ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            DropdownButton<String>(
                              dropdownColor: Colors.blue[900],
                              isDense: true,
                              isExpanded: false,
                              iconEnabledColor: Colors.black,
                              focusColor: Colors.black,
                              items: options.map((String dropDownStringItem) {
                                return DropdownMenuItem<String>(
                                  value: dropDownStringItem,
                                  child: Text(
                                    dropDownStringItem,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                setState(() {
                                  _currentItemSelected = newValueSelected!;
                                  rool = newValueSelected;
                                });
                              },
                              value: _currentItemSelected,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MaterialButton(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0))),
                              elevation: 5.0,
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
                                            .greenAccent, // Change the color to your desired color
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
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
