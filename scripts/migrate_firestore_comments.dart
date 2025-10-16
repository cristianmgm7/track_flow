#!/usr/bin/env dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Simple debug print for migration scripts.
// In production, replace with appropriate logging if needed.
void debugPrint(Object? message) {
  // ignore: avoid_print
  print(message);
}

/// Firestore migration script to add audio comment fields to existing comments
///
/// This script adds the following fields to all existing audio comments:
/// - commentType: 'text' (default for existing comments)
/// - audioStorageUrl: null
/// - audioDurationMs: null
///
/// Run this script ONCE after deploying the audio comment feature to production.
///
/// Usage:
/// dart scripts/migrate_firestore_comments.dart

Future<void> main() async {
  debugPrint('🔄 Starting Firestore migration for audio comments...\n');

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully\n');
  } catch (e) {
    debugPrint('❌ Error initializing Firebase: $e');
    debugPrint('Make sure you have a valid firebase_options.dart file configured.');
    exit(1);
  }

  final firestore = FirebaseFirestore.instance;

  // Query all audio comment documents
  debugPrint('📋 Fetching all audio comment documents...');

  try {
    final projectsSnapshot = await firestore.collection('projects').get();
    debugPrint('Found ${projectsSnapshot.docs.length} projects\n');

    int totalComments = 0;
    int migratedComments = 0;
    int skippedComments = 0;
    int errorComments = 0;

    // Process each project
    for (final projectDoc in projectsSnapshot.docs) {
      final projectId = projectDoc.id;
      debugPrint('Processing project: $projectId');

      // Get all track versions in this project
      final versionsSnapshot = await firestore
          .collection('projects')
          .doc(projectId)
          .collection('track_versions')
          .get();

      debugPrint('  Found ${versionsSnapshot.docs.length} track versions');

      // Process each track version
      for (final versionDoc in versionsSnapshot.docs) {
        final versionId = versionDoc.id;

        // Get all comments for this track version
        final commentsSnapshot = await firestore
            .collection('projects')
            .doc(projectId)
            .collection('track_versions')
            .doc(versionId)
            .collection('audio_comments')
            .get();

        if (commentsSnapshot.docs.isEmpty) continue;

        debugPrint('    Processing ${commentsSnapshot.docs.length} comments in version $versionId');
        totalComments += commentsSnapshot.docs.length;

        // Batch update (max 500 operations per batch)
        WriteBatch batch = firestore.batch();
        int batchCount = 0;

        for (final commentDoc in commentsSnapshot.docs) {
          final data = commentDoc.data();

          // Skip if already migrated (has commentType field)
          if (data.containsKey('commentType')) {
            skippedComments++;
            debugPrint('      ⏭️  Skipping comment ${commentDoc.id} (already migrated)');
            continue;
          }

          try {
            // Add migration fields
            batch.update(commentDoc.reference, {
              'commentType': 'text',
              'audioStorageUrl': null,
              'audioDurationMs': null,
            });

            batchCount++;
            migratedComments++;

            // Commit batch if we reach 500 operations
            if (batchCount >= 500) {
              await batch.commit();
              debugPrint('      ✅ Committed batch of $batchCount updates');
              batch = firestore.batch();
              batchCount = 0;
            }
          } catch (e) {
            errorComments++;
            debugPrint('      ❌ Error updating comment ${commentDoc.id}: $e');
          }
        }

        // Commit remaining operations in batch
        if (batchCount > 0) {
          await batch.commit();
          debugPrint('      ✅ Committed final batch of $batchCount updates');
        }
      }
    }

    // Print summary
    debugPrint('\n${'=' * 60}');
    debugPrint('MIGRATION SUMMARY');
    debugPrint('=' * 60);
    debugPrint('Total comments found:    $totalComments');
    debugPrint('Migrated successfully:   $migratedComments');
    debugPrint('Skipped (already done):  $skippedComments');
    debugPrint('Errors:                  $errorComments');
    debugPrint('=' * 60);

    if (errorComments > 0) {
      debugPrint('\n⚠️  Migration completed with errors. Please review the logs above.');
      exit(1);
    } else {
      debugPrint('\n✅ Migration completed successfully!');
      exit(0);
    }

  } catch (e) {
    debugPrint('\n❌ Migration failed: $e');
    exit(1);
  }
}
