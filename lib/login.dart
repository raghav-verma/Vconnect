import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'register.dart';
import 'rooms.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode? _focusNode;
  bool _loggingIn = false;
  TextEditingController? _passwordController;
  TextEditingController? _usernameController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _passwordController = TextEditingController();
    _usernameController = TextEditingController();
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _loggingIn = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController!.text,
        password: _passwordController!.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _loggingIn = false;
      });

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
          content: Text(
            e.toString(),
          ),
          title: const Text('Error'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _passwordController?.dispose();
    _usernameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFF0D1B2A),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed:  () {
              Navigator.of(context).pop(
                MaterialPageRoute(
                  builder: (context) => const RoomsPage(),
                ),
              );
            },
          ),
        ),
        body: SingleChildScrollView(

          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
            color: const Color(0xFFE0E1DD),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 3,
                        offset: Offset(0, 2), // Vertical offset for shadow
                      )
                    ],
                  ),
                  margin: const EdgeInsets.all(8), // Margin around the container
                  padding: const EdgeInsets.symmetric(horizontal: 4), // Padding for internal spacing
                  child: TextField(
                    autocorrect: false,
                    autofillHints: _loggingIn ? null : [AutofillHints.email],
                    autofocus: true,
                    controller: _usernameController,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true, // Adds a background color to the text field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        borderSide: BorderSide.none, // Removes default border
                      ),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Colors.blueGrey, // Stylish color for the text label
                      ),
                      prefixIcon: Icon(
                        Icons.email, // Adds an icon inside the text field
                        color: Colors.blueGrey,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onEditingComplete: () {
                      _focusNode?.requestFocus();
                    },
                    readOnly: _loggingIn,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.next,
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,  // Ensuring the background color matches
                    borderRadius: BorderRadius.circular(8),  // Same rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,  // Consistent shadow color
                        blurRadius: 3,  // Same blur radius
                        offset: Offset(0, 2),  // Consistent shadow position
                      )
                    ],
                  ),
                  margin: const EdgeInsets.all(8), // Margin around the container
                  padding: const EdgeInsets.symmetric(horizontal: 4) ,// Consistent margin with the email field
                  child: TextField(
                    autocorrect: false,
                    autofillHints: _loggingIn ? null : [AutofillHints.password],  // Appropriate autofill hints for password
                    controller: _passwordController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,  // Background color of the TextField
                      filled: true,  // Fill color enabled
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                        borderSide: BorderSide.none,  // No visible border
                      ),
                      labelText: 'Password',  // Label text
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.blueGrey),  // Icon for password
                      // suffixIcon: IconButton(
                      //   icon: const Icon(Icons.visibility_off),  // Toggle visibility icon
                      //   onPressed: () {
                      //     // Logic to toggle password visibility
                      //   },
                      // ),
                    ),
                    focusNode: _focusNode,  // Focus node for keyboard actions
                    keyboardType: TextInputType.text,  // Appropriate keyboard type for password
                    obscureText: true,  // Ensuring text is obscured for password
                    onEditingComplete: _login,  // Action on editing complete
                    textCapitalization: TextCapitalization.none,  // No text capitalization
                    textInputAction: TextInputAction.done,  // Keyboard action
                  ),
                ),


                const SizedBox(
                  height: 30,
                ),
                SignInButton(
          Buttons.Google,
          text: "Sign in with Google",
          onPressed: () async {
            FocusScope.of(context).unfocus();
            setState(() {
              _loggingIn = true;
            });
            try {
              final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

              // Obtain the auth details from the request
              final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

              // Create a new credential
              final credential = GoogleAuthProvider.credential(
                accessToken: googleAuth?.accessToken,
                idToken: googleAuth?.idToken,
              );

              // Once signed in, return the UserCredential
              await FirebaseAuth.instance.signInWithCredential(credential);
              // await FirebaseAuth.instance.signInWithGoogle(
              //   email: _usernameController!.text,
              //   password: _passwordController!.text,
              // );

              if (!mounted) return;
              Navigator.of(context).pop();
            } catch (e) {
              setState(() {
                _loggingIn = false;
              });
              // await _showErrorDialog(e.toString());
            }
          }
                      ),
                const SizedBox(
                  height: 30,
                ),
                TextButton(
                  onPressed: _loggingIn ? null : _login,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min, // Ensures the row only takes as much space as its children need
                    children: [
                      Icon(Icons.login, color: Colors.white), // Adds an icon
                      SizedBox(width: 10), // Adds space between the icon and the text
                      Text('Login', style: TextStyle(color: Colors.white,fontWeight: FontWeight.w900, fontSize: 17 ), ), // Text styling
                    ],
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    backgroundColor:const Color(0xFF01BAEF) , // Button background color
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20) // Rounded corners
                    ),
                    elevation: 5, // Adds shadow

                  ),
                ),
                const SizedBox(
                  height: 20,
                ),


                TextButton(
                  onPressed: _loggingIn
                      ? null
                      : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );

                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min, // Ensures the row only takes as much space as its children need
                    children: [
                      Icon(Icons.app_registration, color: Colors.white), // Adds an icon
                      SizedBox(width: 10), // Adds space between the icon and the text
                      Text('Register', style: TextStyle(color: Colors.white, fontSize: 17)), // Text styling
                    ],
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    backgroundColor: const Color(0xFFB0B2B8), // Custom blue-gray color
                    disabledForegroundColor: const Color(0xFF415A77).withOpacity(0.38), // Slightly transparent for disabled state
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20) // Rounded corners
                    ),
                    elevation: 5, // Color when button is disabled
                  ),
                ),

              ],
            ),
          ),
        ),
      );
}

