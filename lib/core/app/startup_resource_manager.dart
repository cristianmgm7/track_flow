import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/syn_audio_comment_usecase.dart';

@lazySingleton
class StartupResourceManager {
  final SyncAudioCommentsUseCase syncAudioComments;

  StartupResourceManager(this.syncAudioComments);

  Future<void> initializeAppData() async {
    await Future.wait([
      syncAudioComments(),
      // Agrega aquí otros módulos (ej: syncProjects(), syncUserProfiles(), etc.)
    ]);
  }

  Future<void> refreshAppData() async {
    // Si necesitas lógica especial para forzar refresco, agrégala aquí
    await initializeAppData();
  }
}
