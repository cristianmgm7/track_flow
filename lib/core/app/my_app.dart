import 'package:flutter/material.dart';
import 'package:trackflow/core/constants/theme.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:trackflow/core/router/app_router.dart';
import 'package:trackflow/features/auth/domain/usecases/get_auth_state_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/google_sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:trackflow/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trackflow/features/auth/presentation/bloc/auth_event.dart';
import 'package:trackflow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:trackflow/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_use_case.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/core/app/app_flow_cubit.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    debugPrint('MyApp constructor called');
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppFlowCubit>(
          create:
              (context) => AppFlowCubit(
                authRepository: sl(),
                onboardingRepository: sl(),
              ),
        ),
        BlocProvider<AuthBloc>(
          create:
              (context) => AuthBloc(
                signIn: sl<SignInUseCase>(),
                signUp: sl<SignUpUseCase>(),
                signOut: sl<SignOutUseCase>(),
                googleSignIn: sl<GoogleSignInUseCase>(),
                getAuthState: sl<GetAuthStateUseCase>(),
              )..add(AuthCheckRequested()),
        ),
        BlocProvider<ProjectsBloc>(
          create:
              (context) => ProjectsBloc(
                createProject: sl<CreateProjectUseCase>(),
                updateProject: sl<UpdateProjectUseCase>(),
                deleteProject: sl<DeleteProjectUseCase>(),
                getProjectById: sl<GetProjectByIdUseCase>(),
                watchAllProjects: sl<WatchAllProjectsUseCase>(),
              ),
        ),
        BlocProvider<OnboardingBloc>(
          create:
              (context) =>
                  OnboardingBloc(sl<OnboardingRepository>())
                    ..add(OnboardingCheckRequested()),
        ),
      ],
      child: _App(),
    );
  }
}

class _App extends StatelessWidget {
  _App() {
    debugPrint('App constructor called');
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TrackFlow',
      theme: AppTheme.theme,
      routerConfig: AppRouter.router(context),
    );
  }
}
