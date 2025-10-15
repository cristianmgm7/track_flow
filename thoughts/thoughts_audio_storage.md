Audio File Repository Refactor — Architectural Analysis and Proposal

This document outlines an architectural refactor related to how audio files are uploaded, downloaded, deleted, and cached across the TrackFlow codebase. The main goal is to unify scattered logic and enforce proper abstraction boundaries, ensuring the app follows SOLID principles and a clean architecture approach.

⸻

🔍 Current Situation

Currently, several classes and services handle audio operations (upload, download, delete, and cache management) independently, leading to:
	•	Code duplication
	•	Tight coupling between features and Firebase
	•	Lack of a centralized contract for audio operations
	•	Improper local directory handling inside repositories

⸻

⚠️ Files Involved and Observations

1. firebase_audio_upload_service.dart
	•	Handles upload, download, and delete operations for audio files.
	•	This service already represents the correct level of abstraction for cloud-related operations.
	•	However, it is being used directly throughout the app, which causes coupling.

Action:
Create an abstract interface (e.g., AudioFileRepository) that defines the expected behaviors for managing audio files.
Then, rename or refactor this service into a concrete implementation, e.g.:


```dart
abstract class AudioFileRepository {
  Future<String> uploadAudioFile(File file, {required String feature, required String id});
  Future<File> downloadAudioFile(String url, {required String feature, required String id});
  Future<void> deleteAudioFile(String url);
}

class FirebaseAudioFileRepository implements AudioFileRepository {
  // Uses Firebase storage + caching logic
}
```

All existing dependencies that rely on FirebaseAudioUploadService should now depend on the AudioFileRepository abstraction instead.

2. cache_storage_remote_data_source.dart
	•	This data source overlaps in responsibility with the Firebase upload service.
	•	Its logic should be merged or replaced by the new unified AudioFileRepository.

Action:
Deprecate or delete this file.
Redirect any dependencies to use AudioFileRepository.

⸻

3. audio_download_repository.dart and audio_download_repository_impl.dart
	•	These files also duplicate functionality already covered by FirebaseAudioUploadService.
	•	They should be removed in favor of the new unified repository interface.

Action:
Delete these files and migrate dependencies to use AudioFileRepository.

⸻

📁 Local Directory Management Issue

Currently, repositories directly handle filesystem paths using helper methods such as _getCacheDirectory().
This is not ideal, as it breaks the single-responsibility principle and couples repositories to storage details.

⸻

✅ Proposed Solution — Local Directory Service

Introduce a dedicated service to manage local directory paths and structure.
This will centralize all filesystem operations and make them easier to maintain, test, and reuse.

New Service:

``` dart 

class LocalDirectoryService {
  Future<Directory> getTrackAudioDirectory(String trackId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/trackflow/audio/$trackId');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> clearAudioCache() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/trackflow/audio');
    if (await cacheDir.exists()) await cacheDir.delete(recursive: true);
  }
}

```
Action:
Search for all methods like _getCacheDirectory() and replace their usage with calls to LocalDirectoryService, injected via dependency injection (get_it / injectable).

⸻

🧠 Expected Benefits

✅ Single, unified entry point for all audio file operations
✅ Better abstraction and reduced coupling
✅ Consistent caching and directory management
✅ Easier testing (mockable interfaces)
✅ Future scalability (voice memos, AI-generated audio, etc.)

