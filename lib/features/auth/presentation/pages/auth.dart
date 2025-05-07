import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackflow/core/constants/theme.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _googleSignIn = GoogleSignIn();

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
  var _isLoading = true;

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    print('Signing in with Google');
    setState(() {
      _isLoading = true;
    });
    try {
      // First, try to sign out to clear any existing state
      await _googleSignIn.signOut();

      // Then attempt to sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In was cancelled by the user.'),
          ),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google Auth tokens');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: ${e.toString()}'),
          duration: const Duration(seconds: 5),
        ),
      );
      print('Google Sign-In Error: $e'); // For debugging
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            children: [
              Image.asset('assets/images/logo.png', height: 100),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF1F1F1F),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: Size(200, 50),
                ),
                onPressed: _submit,
                child: Text(_isLogin ? "Sign in" : "Sign up"),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _signInWithGoogle,
                child: Image.asset(
                  _isLogin
                      ? 'assets/images/ios_dark_sq_SI@1x.png'
                      : 'assets/images/ios_dark_sq_SU@1x.png',
                  height: 50, // Adjust as needed for your UI
                  fit: BoxFit.contain,
                ),
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
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
