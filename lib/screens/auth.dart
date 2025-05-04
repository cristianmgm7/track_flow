import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

final _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _email = '';
  var _password = '';

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    try {
      if (_isLogin) {
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        final userCredential = await _firebaseAuth
            .createUserWithEmailAndPassword(email: _email, password: _password);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        //
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'authentication error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.music_note,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 16),
              Text(
                "Welcome to TrackFlow",
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "The ultimate platform for artists, producers, and songwriters to collaborate on music projects.",
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              Card(
                color: const Color.fromARGB(198, 255, 255, 255),
                margin: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(labelText: "Email"),
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains("@")) {
                                return "Invalid email";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _email = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(labelText: "Password"),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Password is required";
                              }
                              if (value.length < 8) {
                                return "Password must be at least 8 characters long";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isLogin ? "Sign in" : "Sign up"),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? "Create an account" : "I already have an account",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
