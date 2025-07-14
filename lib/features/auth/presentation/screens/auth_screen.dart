import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/components/auth/auth_card.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;

  void _handleSubmit(String email, String password) {
    if (_isLogin) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(email: email, password: password),
      );
    } else {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(email: email, password: password),
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AuthContainer(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuthHeader(
                  title: "Welcome to TrackFlow",
                  subtitle: "The ultimate platform for artists, producers, and songwriters to collaborate on music projects.",
                  logo: Image.asset('assets/images/logo.png', height: 100),
                ),
                SizedBox(height: Dimensions.space32),
                AuthCard(
                  child: AuthForm(
                    formKey: _formKey,
                    isLogin: _isLogin,
                    onSubmit: _handleSubmit,
                    onToggleMode: _toggleMode,
                    isLoading: isLoading,
                  ),
                ),
                SizedBox(height: Dimensions.space16),
                AuthSocialButton(
                  assetPath: _isLogin
                      ? 'assets/images/ios_dark_sq_SI@1x.png'
                      : 'assets/images/ios_dark_sq_SU@1x.png',
                  onPressed: _signInWithGoogle,
                  isLoading: isLoading,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
