import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/core/router/app_routes.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_bloc.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_events.dart';
import 'package:trackflow/features/magic_link/presentation/blocs/magic_link_states.dart';

class MagicLinkHandlerScreen extends StatelessWidget {
  final String token;
  const MagicLinkHandlerScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    // Dispatch the event once the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MagicLinkBloc>().add(MagicLinkHandleRequested(token: token));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a proyecto')),
      body: BlocConsumer<MagicLinkBloc, MagicLinkState>(
        listener: (context, state) {
          if (state is MagicLinkHandleSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Te has unido al proyecto!')),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.go(AppRoutes.projects);
              }
            });
          } else if (state is MagicLinkHandleErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error.message)));
          }
        },
        builder: (context, state) {
          if (state is MagicLinkHandling) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MagicLinkHandleSuccessState) {
            return const Center(child: Text('¡Te has unido exitosamente!'));
          } else if (state is MagicLinkHandleErrorState) {
            return Center(child: Text(state.error.message));
          } else {
            return const Center(child: Text('Procesando enlace...'));
          }
        },
      ),
    );
  }
}
