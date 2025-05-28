import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/magic_link/domain/usecases/validate_magic_link_use_case.dart';
import 'package:trackflow/features/magic_link/domain/usecases/consume_magic_link_use_case.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class MagicLinkHandlerScreen extends StatefulWidget {
  final String token;
  const MagicLinkHandlerScreen({super.key, required this.token});

  @override
  State<MagicLinkHandlerScreen> createState() => _MagicLinkHandlerScreenState();
}

class _MagicLinkHandlerScreenState extends State<MagicLinkHandlerScreen> {
  String? _statusMessage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _handleMagicLink();
  }

  Future<void> _handleMagicLink() async {
    setState(() {
      _loading = true;
      _statusMessage = null;
    });
    try {
      // 1. Validar el magic link
      final validateUseCase = context.read<ValidateMagicLinkUseCase>();
      final validateResult = await validateUseCase(
        ValidateMagicLinkParams(linkId: widget.token),
      );
      if (validateResult.isLeft()) {
        setState(() {
          _statusMessage = 'El enlace no es válido o ya fue usado.';
          _loading = false;
        });
        return;
      }
      final magicLink = validateResult.getOrElse(() => throw Exception());
      // 2. Verificar autenticación
      final authRepo = context.read<AuthRepository>();
      final userIdOrFailure = await authRepo.getSignedInUserId();
      if (userIdOrFailure.isLeft()) {
        setState(() {
          _statusMessage = 'Debes iniciar sesión para unirte al proyecto.';
          _loading = false;
        });
        // Aquí podrías redirigir a login automáticamente si quieres
        return;
      }
      final userId = userIdOrFailure.getOrElse(() => '');
      // 3. Consumir el magic link
      final consumeUseCase = context.read<ConsumeMagicLinkUseCase>();
      final consumeResult = await consumeUseCase(
        ConsumeMagicLinkParams(linkId: widget.token),
      );
      if (consumeResult.isLeft()) {
        setState(() {
          _statusMessage = 'No se pudo consumir el enlace.';
          _loading = false;
        });
        return;
      }
      // 4. Agregar usuario al proyecto
      final addCollaboratorUseCase = context.read<AddCollaboratorUseCase>();
      final addResult = await addCollaboratorUseCase(
        AddCollaboratorParams(
          projectId: UniqueId.fromUniqueString(magicLink.projectId),
          userId: UserId.fromUniqueString(userId),
        ),
      );
      if (addResult.isLeft()) {
        setState(() {
          _statusMessage = 'No se pudo agregar al proyecto.';
          _loading = false;
        });
        return;
      }
      setState(() {
        _statusMessage = '¡Te has unido al proyecto exitosamente!';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Ocurrió un error inesperado.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a proyecto')),
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : Text(_statusMessage ?? ''),
      ),
    );
  }
}
