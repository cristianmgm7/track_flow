import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/components/auth/glassmorphism_card.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_state.dart';

enum AuthStep { welcome, email, form }

class NewAuthScreen extends StatefulWidget {
  const NewAuthScreen({super.key});

  @override
  State<NewAuthScreen> createState() => _NewAuthScreenState();
}

class _NewAuthScreenState extends State<NewAuthScreen> {
  AuthStep _currentStep = AuthStep.welcome;
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _goToEmailStep() {
    setState(() {
      _currentStep = AuthStep.email;
    });
  }

  void _goToFormStep(String email) {
    setState(() {
      _email = email;
      _currentStep = AuthStep.form;
    });
  }

  void _goBack() {
    setState(() {
      switch (_currentStep) {
        case AuthStep.email:
          _currentStep = AuthStep.welcome;
          break;
        case AuthStep.form:
          _currentStep = AuthStep.email;
          break;
        case AuthStep.welcome:
          break;
      }
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_isLogin) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(email: _email, password: _password),
      );
    } else {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(email: _email, password: _password),
      );
    }
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/auth_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.grey900.withValues(alpha: 0.3),
                  AppColors.grey900.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (_currentStep != AuthStep.welcome)
                    Padding(
                      padding: EdgeInsets.all(Dimensions.space16),
                      child: Row(
                        children: [
                          GlassmorphismButton(
                            text: 'Back',
                            onPressed: _goBack,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            width: 100,
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(Dimensions.space24),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;

                            switch (_currentStep) {
                              case AuthStep.welcome:
                                return _buildWelcomeStep(isLoading);
                              case AuthStep.email:
                                return _buildEmailStep(isLoading);
                              case AuthStep.form:
                                return _buildFormStep(isLoading);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep(bool isLoading) {
    return Column(
      children: [
        // Logo y título
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            border: Border.all(
              color: AppColors.textPrimary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.music_note,
            size: 60,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: Dimensions.space24),

        Text(
          'TrackFlow',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            shadows: [
              Shadow(
                color: AppColors.grey900.withValues(alpha: 0.5),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.space12),

        Text(
          'All your team in the same place',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textPrimary.withValues(alpha: 0.9),
            fontWeight: FontWeight.w300,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: Dimensions.space64),

        // Botones de acción
        GlassmorphismCard(
          child: Column(
            children: [
              GlassmorphismButton(
                text: 'Continue with Email',
                onPressed: _goToEmailStep,
                icon: const Icon(Icons.email, color: AppColors.textPrimary),
              ),
              SizedBox(height: Dimensions.space16),
              GlassmorphismButton(
                text: 'Continue with Google',
                onPressed: isLoading ? null : _signInWithGoogle,
                isLoading: isLoading,
                icon: const Icon(
                  Icons.g_mobiledata,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep(bool isLoading) {
    final emailController = TextEditingController();

    return Column(
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            shadows: [
              Shadow(
                color: AppColors.grey900.withValues(alpha: 0.5),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.space12),

        Text(
          'Enter your email to continue',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary.withValues(alpha: 0.8),
          ),
        ),

        SizedBox(height: Dimensions.space48),

        GlassmorphismCard(
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.email,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusMedium,
                    ),
                    borderSide: BorderSide(
                      color: AppColors.textPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusMedium,
                    ),
                    borderSide: BorderSide(
                      color: AppColors.textPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Dimensions.radiusMedium,
                    ),
                    borderSide: BorderSide(
                      color: AppColors.textPrimary,
                      width: 2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textCapitalization: TextCapitalization.none,
              ),
              SizedBox(height: Dimensions.space24),
              GlassmorphismButton(
                text: 'Continue',
                onPressed: () {
                  if (emailController.text.trim().isNotEmpty) {
                    _goToFormStep(emailController.text.trim());
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormStep(bool isLoading) {
    return Column(
      children: [
        Text(
          _isLogin ? 'Welcome Back' : 'Create Account',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            shadows: [
              Shadow(
                color: AppColors.grey900.withValues(alpha: 0.5),
                offset: const Offset(0, 2),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.space12),

        Text(
          _email,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary.withValues(alpha: 0.8),
          ),
        ),

        SizedBox(height: Dimensions.space48),

        GlassmorphismCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: AppColors.textPrimary.withValues(alpha: 0.7),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Dimensions.radiusMedium,
                      ),
                      borderSide: BorderSide(
                        color: AppColors.textPrimary,
                        width: 2,
                      ),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value!,
                ),
                SizedBox(height: Dimensions.space24),
                GlassmorphismButton(
                  text: _isLogin ? 'Sign In' : 'Create Account',
                  onPressed: isLoading ? null : _handleSubmit,
                  isLoading: isLoading,
                ),
                SizedBox(height: Dimensions.space16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Need an account? Sign up'
                        : 'Already have an account? Sign in',
                    style: TextStyle(
                      color: AppColors.textPrimary.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
