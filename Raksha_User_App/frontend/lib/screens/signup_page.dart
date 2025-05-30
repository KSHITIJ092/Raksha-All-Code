import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart'; // Import your login page

class SignupPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                _inputFields(),
                _signupButton(context),
                _loginLink(context), // Link to navigate to login page
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      children: [
        SizedBox(height: 60.0),
        Text(
          "Sign Up",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.purple),
        ),
      ],
    );
  }

  Widget _inputFields() {
    return Column(
      children: [
        TextFormField(
          controller: usernameController,
          decoration: const InputDecoration(
            hintText: "Username",
            prefixIcon: Icon(Icons.person, color: Colors.purple),
          ),
          validator: (value) => value!.isEmpty ? 'Enter a username' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            hintText: "Email",
            prefixIcon: Icon(Icons.email, color: Colors.purple),
          ),
          validator: (value) => value!.isEmpty ? 'Enter an email' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: "Password",
            prefixIcon: Icon(Icons.lock, color: Colors.purple),
          ),
          validator: (value) => value!.isEmpty ? 'Enter a password' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: mobileController,
          decoration: const InputDecoration(
            hintText: "Mobile Number",
            prefixIcon: Icon(Icons.phone, color: Colors.purple),
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Enter a mobile number';
            } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
              return 'Enter a valid 10-digit mobile number';
            }
            return null;
          },
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _signupButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState?.validate() ?? false) {
          // Call signup API
          final response = await http.post(
            Uri.parse(
                'http://192.168.93.176:5000/api/signup'), // Replace with your backend URL
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': usernameController.text,
              'email': emailController.text,
              'password': passwordController.text,
              'mobile': mobileController.text,
            }),
          );

          if (response.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signup Successful')),
            );
            // Redirect to login page after successful signup
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signup Failed')),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.purple,
      ),
      child: const Text(
        "Sign Up",
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  // Link to navigate to the login page
  Widget _loginLink(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        child: const Text(
          "Already have an account? Login",
          style: TextStyle(color: Colors.purple),
        ),
      ),
    );
  }
}
