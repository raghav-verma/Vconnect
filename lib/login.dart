import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'register.dart';

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

          backgroundColor: Color(0xFF0D1B2A),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: Text('             LOGIN', style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
          leading
        ),
        body: SingleChildScrollView(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
                color: Color(0xFFE0E1DD),
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey.shade100,
                      child: TextField(

                        autocorrect: false,
                        autofillHints: _loggingIn ? null : [AutofillHints.email],
                        autofocus: true,
                        controller: _usernameController,
                        decoration: InputDecoration(

                          border: const OutlineInputBorder(

                            borderRadius: BorderRadius.all(

                              Radius.circular(8),
                            ),
                          ),
                          labelText: 'Email',

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
                      color: Colors.grey.shade100,

                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: TextField(
                        autocorrect: false,
                        autofillHints: _loggingIn ? null : [AutofillHints.password],
                        controller: _passwordController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          labelText: 'Password',
                          // suffixIcon: IconButton(
                          //   icon: const Icon(Icons.cancel),
                          //   onPressed: () => _passwordController?.clear(),
                          // ),
                        ),
                        focusNode: _focusNode,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: true,
                        onEditingComplete: _login,
                        textCapitalization: TextCapitalization.none,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    SizedBox(
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
                    SizedBox(
                      height: 30,
                    ),
                    TextButton(
                      onPressed: _loggingIn ? null : _login,
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Ensures the row only takes as much space as its children need
                        children: const [
                          Icon(Icons.login, color: Colors.white), // Adds an icon
                          SizedBox(width: 10), // Adds space between the icon and the text
                          Text('Login', style: TextStyle(color: Colors.white,fontWeight: FontWeight.w900, fontSize: 17 ), ), // Text styling
                        ],
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        backgroundColor:Color(0xFF01BAEF) , // Button background color
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20) // Rounded corners
                        ),
                        elevation: 5, // Adds shadow

                      ),
                    ),
                    SizedBox(
                      height: 15,
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Ensures the row only takes as much space as its children need
                        children: const [
                          Icon(Icons.app_registration, color: Colors.white), // Adds an icon
                          SizedBox(width: 10), // Adds space between the icon and the text
                          Text('Register', style: TextStyle(color: Colors.white, fontSize: 17)), // Text styling
                        ],
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                        backgroundColor: Color(0xFFB0B2B8), // Custom blue-gray color
                        disabledForegroundColor: Color(0xFF415A77).withOpacity(0.38), // Slightly transparent for disabled state
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20) // Rounded corners
                        ),
                        elevation: 5, // Color when button is disabled
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      );
}


// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_signin_button/flutter_signin_button.dart'; // Add this package for social buttons
// import 'package:google_sign_in/google_sign_in.dart';
//
// import 'register.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   FocusNode? _focusNode;
//   bool _loggingIn = false;
//   TextEditingController? _passwordController;
//   TextEditingController? _usernameController;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//     _passwordController = TextEditingController();
//     _usernameController = TextEditingController();
//   }
//
//   void _login() async {
//     FocusScope.of(context).unfocus();
//     setState(() {
//       _loggingIn = true;
//     });
//     try {
//       await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: _usernameController!.text,
//         password: _passwordController!.text,
//       );
//       if (!mounted) return;
//       Navigator.of(context).pop();
//     } catch (e) {
//       setState(() {
//         _loggingIn = false;
//       });
//       await _showErrorDialog(e.toString());
//     }
//   }
//
//   Future<void> _showErrorDialog(String message) async {
//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('OK'),
//           ),
//         ],
//         content: Text(message),
//         title: const Text('Error'),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _focusNode?.dispose();
//     _passwordController?.dispose();
//     _usernameController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         systemOverlayStyle: SystemUiOverlayStyle.light,
//         title: const Text('Login'),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           height: MediaQuery.of(context).size.height,
//           padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topRight,
//               end: Alignment.bottomLeft,
//               colors: [
//                 Colors.blueGrey.shade800,
//                 Colors.blueGrey.shade200,
//               ],
//             ),
//           ),
//           child: Column(
//             children: [
//               TextField(
//                 autocorrect: false,
//                 autofillHints: _loggingIn ? null : [AutofillHints.email],
//                 autofocus: true,
//                 controller: _usernameController,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.white.withOpacity(0.8),
//                   labelText: 'Email',
//                   prefixIcon: Icon(Icons.email),
//                   suffixIcon: IconButton(
//                     icon: Icon(Icons.cancel),
//                     onPressed: () => _usernameController?.clear(),
//                   ),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//                 onEditingComplete: () => _focusNode?.requestFocus(),
//                 readOnly: _loggingIn,
//                 textCapitalization: TextCapitalization.none,
//                 textInputAction: TextInputAction.next,
//               ),
//               Container(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: TextField(
//                   autocorrect: false,
//                   autofillHints: _loggingIn ? null : [AutofillHints.password],
//                   controller: _passwordController,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white.withOpacity(0.8),
//                     labelText: 'Password',
//                     prefixIcon: Icon(Icons.lock),
//                     suffixIcon: IconButton(
//                       icon: Icon(Icons.cancel),
//                       onPressed: () => _passwordController?.clear(),
//                     ),
//                   ),
//                   focusNode: _focusNode,
//                   obscureText: true,
//                   onEditingComplete: _login,
//                   textCapitalization: TextCapitalization.none,
//                   textInputAction: TextInputAction.done,
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _loggingIn ? null : _login,
//                 child: Text('Login'),
//                 style: ElevatedButton.styleFrom(
//                   // primary: Colors.deepPurple,
//                     shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(18.0),
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
//                 ),
//               ),
//               SignInButton(
//                 Buttons.Google,
//                 text: "Sign in with Google",
//                 onPressed: () async {
//                     FocusScope.of(context).unfocus();
//                     setState(() {
//                       _loggingIn = true;
//                     });
//                     try {
//                       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//
//                       // Obtain the auth details from the request
//                       final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
//
//                       // Create a new credential
//                       final credential = GoogleAuthProvider.credential(
//                         accessToken: googleAuth?.accessToken,
//                         idToken: googleAuth?.idToken,
//                       );
//
//                       // Once signed in, return the UserCredential
//                       await FirebaseAuth.instance.signInWithCredential(credential);
//                       // await FirebaseAuth.instance.signInWithGoogle(
//                       //   email: _usernameController!.text,
//                       //   password: _passwordController!.text,
//                       // );
//
//                       if (!mounted) return;
//                       Navigator.of(context).pop();
//                     } catch (e) {
//                       setState(() {
//                         _loggingIn = false;
//                       });
//                       await _showErrorDialog(e.toString());
//                     }
//                 }
//               ),
//               TextButton(
//                 onPressed: _loggingIn
//                     ? null
//                     : () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const RegisterPage(),
//                     ),
//                   );
//                 },
//                 child: const Text('Register'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
