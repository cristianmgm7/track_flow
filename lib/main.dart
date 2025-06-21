import 'package:flutter/material.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_document.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_document.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_document.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies();
  await DynamicLinkService().init();

  runApp(MyApp());
}
