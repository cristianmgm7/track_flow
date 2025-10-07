#!/bin/bash
export PATH="$HOME/flutter/bin:$PATH"
export JAVA_HOME="$HOME/java/jdk-21.0.2.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_SDK_ROOT="$HOME/android-sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

# Accept all licenses
yes | sdkmanager --licenses

