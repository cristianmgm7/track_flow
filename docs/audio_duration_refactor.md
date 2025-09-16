# Audio Duration Calculation Refactor

## Problem

The audio duration calculation was being performed in the UI layer (`UploadTrackForm` widget) using the `_getAudioDuration` method. This violated clean architecture principles:

- **UI Layer Responsibility**: UI should only handle presentation and user interaction
- **Business Logic in Wrong Place**: Duration calculation is business logic that belongs in the domain layer
- **Tight Coupling**: UI was directly dependent on audio processing libraries
- **Testability**: Business logic in UI is harder to test

## Solution

### 1. Created Domain Service: `AudioMetadataService`

**Location**: `lib/features/audio_track/domain/services/audio_metadata_service.dart`

**Responsibilities**:
- Extract audio duration from files
- Validate audio file properties
- Handle audio processing errors
- Provide domain-specific failure types

**Key Methods**:
- `extractDuration(File audioFile)` - Extracts duration with proper error handling
- `validateAudioFile(File audioFile)` - Validates file size, format, and basic properties

### 2. Updated Use Case: `UploadAudioTrackUseCase`

**Changes**:
- Removed `duration` parameter from `UploadAudioTrackParams`
- Added `AudioMetadataService` dependency
- Duration calculation now happens in domain layer before project track service call

**Before**:
```dart
class UploadAudioTrackParams {
  final ProjectId projectId;
  final File file;
  final String name;
  final Duration duration; // ❌ UI calculated this
}
```

**After**:
```dart
class UploadAudioTrackParams {
  final ProjectId projectId;
  final File file;
  final String name;
  // ✅ Duration calculated in domain layer
}
```

### 3. Updated BLoC Event: `UploadAudioTrackEvent`

**Changes**:
- Removed `duration` parameter from event
- Simplified event structure

### 4. Updated UI Layer: `UploadTrackForm`

**Changes**:
- Removed `_getAudioDuration` method
- Removed duration calculation from `_submit` method
- Removed `just_audio` import (no longer needed in UI)
- Simplified upload flow

## Benefits

### ✅ Clean Architecture
- **Separation of Concerns**: UI only handles presentation
- **Domain Layer**: Business logic (duration calculation) in correct layer
- **Dependency Direction**: UI depends on domain, not vice versa

### ✅ Better Error Handling
- **Domain-Specific Failures**: `AudioProcessingFailure` for audio-related errors
- **Proper Error Propagation**: Errors flow through domain layer to UI
- **Validation**: File existence, size, and format validation

### ✅ Improved Testability
- **Unit Tests**: Domain service can be tested independently
- **Mocking**: Easy to mock audio metadata service for UI tests
- **Isolation**: UI tests don't need audio file processing

### ✅ Maintainability
- **Single Responsibility**: Each layer has clear responsibilities
- **Reusability**: Audio metadata service can be used elsewhere
- **Consistency**: Follows project's clean architecture patterns

## Migration Guide

### For Existing Code
If you have code that calculates audio duration in UI layer:

1. **Remove UI-level duration calculation**
2. **Use `AudioMetadataService` directly** or through use cases
3. **Update event/parameter structures** to remove duration parameters
4. **Handle domain failures** properly in UI

### For New Features
- **Always use domain services** for audio processing
- **Keep UI layer thin** - only presentation logic
- **Use proper error handling** with domain-specific failures

## Testing

### Domain Service Tests
- **Location**: `test/features/audio_track/domain/services/audio_metadata_service_test.dart`
- **Coverage**: File validation, error handling, duration extraction
- **Isolation**: No UI dependencies

### Integration Tests
- **Verify**: Upload flow works end-to-end
- **Check**: Error handling in UI layer
- **Ensure**: No regressions in existing functionality

## Future Enhancements

### Potential Improvements
1. **Audio Format Detection**: Add format validation and metadata extraction
2. **Caching**: Cache duration calculations for performance
3. **Batch Processing**: Handle multiple files efficiently
4. **Advanced Validation**: Bitrate, sample rate, and quality checks

### Performance Considerations
- **Async Processing**: Duration extraction is async and non-blocking
- **Timeout Handling**: 10-second timeout prevents hanging
- **Resource Management**: Proper disposal of audio players

## Related Files

### Modified Files
- `lib/features/audio_track/domain/services/audio_metadata_service.dart` (new)
- `lib/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart`
- `lib/features/audio_track/presentation/bloc/audio_track_event.dart`
- `lib/features/audio_track/presentation/bloc/audio_track_bloc.dart`
- `lib/features/project_detail/presentation/widgets/up_load_track_form.dart`
- `lib/features/audio_track/utils/audio_utils.dart`

### Test Files
- `test/features/audio_track/domain/services/audio_metadata_service_test.dart` (new)

This refactor successfully moves audio duration calculation from the UI layer to the domain layer, following clean architecture principles and improving the overall code quality and maintainability of the TrackFlow application.
