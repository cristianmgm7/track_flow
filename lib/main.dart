import 'package:flutter/material.dart';
import 'package:trackflow/core/di/injection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trackflow/core/app/my_app.dart';
import 'package:trackflow/core/services/dynamic_link_service.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/audio_comment/data/models/audio_comment_dto.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await configureDependencies();
  await DynamicLinkService().init();
  await Hive.initFlutter();
  // SOLO EN DESARROLLO: Borra el box antes de abrirlo
  //await Hive.deleteBoxFromDisk('projectsBox');
  await Hive.openBox<ProjectDTO>('projectsBox');
  await Hive.openBox<UserProfileDTO>('userProfilesBox');
  await Hive.openBox<AudioCommentDTO>('audioCommentsBox');
  await Hive.openBox<AudioTrackDTO>('audioTracksBox');

  runApp(MyApp());
}
