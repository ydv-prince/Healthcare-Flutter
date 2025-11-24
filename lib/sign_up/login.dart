import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare/AdminPanel/adminpage.dart';
import 'package:healthcare/index/home.dart';
import 'package:healthcare/sign_up/forget.dart';
import 'package:healthcare/sign_up/sign_up.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _isLoading = false; 

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; 
    }
    setState(() {
      _isLoading = true; 
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      if (email == 'admin@gmail.com') {
        // Successful Admin Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Adminpage()),
        );
        _showSnackbar('Admin login successful!', isError: false);
      } else {
        // ✅ CRITICAL FIX: Use pushReplacement to set Home as the new root 
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
        _showSnackbar('Login successful!', isError: false);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') message = 'Wrong password provided for that user.';
      else message = 'An error occurred during login. Please try again.';
      _showSnackbar(message);
    } catch (e) {
      _showSnackbar('An unexpected error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters long';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Center(child: Text("Sign In", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: "Enter your email", prefixIcon: const Icon(Icons.email_outlined), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(hintText: 'Enter your password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: () => setState(() => _obscureText = !_obscureText)), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    validator: _validatePassword,
                  ),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Forget())), child: const Text("Forgot password?", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)))),
                  const SizedBox(height: 20),
                  Center(child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _login, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))),
                  const SizedBox(height: 20),
                  Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Don't have an account? "), GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp())), child: const Text("Sign up", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)))]))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}