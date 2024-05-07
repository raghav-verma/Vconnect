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
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  TextEditingController? _firstNameController;
  TextEditingController? _lastNameController;
  bool _registering = false;

  @override
  void initState() {
    super.initState();
    final faker = Faker();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
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
        email: _emailController!.text,
        password: _passwordController!.text,
      );
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: _firstNameController?.text,
          id: credential.user!.uid,
          imageUrl: 'https://i.pravatar.cc/300?u=${_emailController!.text}',
          lastName: _lastNameController?.text,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _registering = false;
      });
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _showErrorDialog(String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
        content: Text(message),
        title: const Text('Error'),
      ),
    );
  }

  @override
  void dispose() {
    _emailController?.dispose();
    _passwordController?.dispose();
    _firstNameController?.dispose();
    _lastNameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          // backgroundColor: Color(0xFF0D1B2A),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          title: const Text('REGISTER', style: TextStyle(color: Colors.white),),
          leading: ,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  icon: Icons.lock,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                _buildTextField(
                  controller: _firstNameController,
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
                  icon: Icons.person,
                  textInputAction: TextInputAction.next,
                ),
                _buildTextField(
                  controller: _lastNameController,
                  labelText: 'Last Name',
                  hintText: 'Enter your last name',
                  icon: Icons.person_outline,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: _register,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registering ? null : _register,
                  child: const Text('Register',style: TextStyle(fontSize: 17),),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFF01BAEF), // Button text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildTextField({
    required TextEditingController? controller,
    required String labelText,
    String? hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    Function? onEditingComplete,
  }) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          onEditingComplete: onEditingComplete as void Function()?,
        ),
      );
}
