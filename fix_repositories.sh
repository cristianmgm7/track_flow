#!/bin/bash

# Function to fix triggerUpstreamSync calls
fix_triggerUpstreamSync() {
    local file="$1"
    sed -i '' 's/unawaited([[:space:]]*_backgroundSyncCoordinator\.triggerUpstreamSync([[:space:]]*syncKey:[[:space:]]*[^,]*,[[:space:]]*)[[:space:]]*)/unawaited(_backgroundSyncCoordinator.pushUpstream())/g' "$file"
}

# Function to fix triggerBackgroundSync calls in get/watch methods
fix_triggerBackgroundSync() {
    local file="$1"
    sed -i '' 's/unawaited([[:space:]]*_backgroundSyncCoordinator\.triggerBackgroundSync([[:space:]]*syncKey:[[:space:]]*[^,]*,[[:space:]]*)[[:space:]]*)/\/\/ No sync in get\/watch methods - just return local data/g' "$file"
}

# List of repository files
files=(
    "lib/features/playlist/data/repositories/playlist_repository_impl.dart"
    "lib/features/track_version/data/repositories/track_version_repository_impl.dart"
    "lib/features/waveform/data/repositories/waveform_repository_impl.dart"
    "lib/features/audio_track/data/repositories/audio_track_repository_impl.dart"
)

# Fix each file
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "Fixing $file"
        fix_triggerUpstreamSync "$file"
        fix_triggerBackgroundSync "$file"
    else
        echo "File not found: $file"
    fi
done

echo "All repository files have been fixed!"
