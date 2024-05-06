import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _email;
  String? _firstName;

  String? _lastName;
  TextEditingController? _passwordController;
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  bool _registering = false;
  TextEditingController? _usernameController;

  @override
  void initState() {
    super.initState();
    final faker = Faker();
    _firstName = faker.person.firstName();
    _lastName = faker.person.lastName();
    _email =
        '${_firstName!.toLowerCase()}.${_lastName!.toLowerCase()}@${faker.internet.domainName()}';

    _passwordController = TextEditingController();
    _usernameController = TextEditingController(

    );
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();

  }

  void _register() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _registering = true;
    });

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _usernameController!.text,
        password: _passwordController!.text,

      );
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: _firstNameController?.text,
          id: credential.user!.uid,
          imageUrl: 'https://i.pravatar.cc/300?u=$_email',
          lastName: _lastNameController?.text,
        ),
      );

      if (!mounted) return;
      Navigator.of(context)
        ..pop()
        ..pop();
    } catch (e) {
      setState(() {
        _registering = false;
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

    _passwordController?.dispose();
    _usernameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('Register'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
            child: Column(
              children: [
                TextField(
                  autocorrect: false,
                  autofillHints: _registering ? null : [AutofillHints.email],
                  autofocus: true,
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    labelText: 'Email',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.cancel),
                      onPressed: () => _usernameController?.clear(),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onEditingComplete: () {

                  },
                  readOnly: _registering,
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.next,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    autocorrect: false,
                    autofillHints:
                        _registering ? null : [AutofillHints.password],
                    controller: _passwordController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => _passwordController?.clear(),
                      ),
                    ),

                    keyboardType: TextInputType.emailAddress,
                    obscureText: true,
                    onEditingComplete: _register,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    autocorrect: false,
                    // autofillHints:
                    // _registering ? null : [AutofillHints.password],
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      labelText: 'First Name',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => _firstNameController?.clear(),
                      ),
                    ),

                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    onEditingComplete: _register,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    autocorrect: false,
                    // autofillHints:
                    // _registering ? null : [AutofillHints.password],
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                      labelText: 'Last Name',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => _lastNameController?.clear(),
                      ),
                    ),

                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.done,
                  ),
                ),

                TextButton(
                  onPressed: _registering ? null : _register,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      );
}
