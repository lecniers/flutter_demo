import 'dart:async';

import 'package:_env/env.dart';
import 'package:api_repo/api_repo.dart';
import 'package:demo_app/app/app.dart';
import 'package:demo_app/todos/todos.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:powersync_repo/powersync_repo.dart';

final getIt = GetIt.instance;

FutureOr<void> initializeDependencies({
  required AppFlavor appFlavor,
}) async {
  getIt.registerSingleton<AppFlavor>(appFlavor);
  await _initPowersync(appFlavor);
  await _initFirebase();
  getIt
    ..registerLazySingleton<ApiRepo>(() => const ApiRepo())
    ..registerFactory<TodosCubit>(() => TodosCubit(getIt<ApiRepo>()));
}

Future<void> _initPowersync(AppFlavor appFlavor) async {
  final powersyncRepo = PowersyncRepo(env: appFlavor.getEnv);
  await powersyncRepo.initialize();

  getIt.registerLazySingleton(() => powersyncRepo);
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // // Only log errors on release builds
  // if (kReleaseMode) {
  //   // Pass all uncaught "fatal" errors from the framework to Crashlytics
  //   FlutterError.onError = (errorDetails) {
  //     FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  //   };
  //   // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  //   PlatformDispatcher.instance.onError = (error, stack) {
  //     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //     return true;
  //   };
  // }

  // final remoteConfig = FirebaseRemoteConfig.instance;
  // await remoteConfig.setConfigSettings(
  //   RemoteConfigSettings(
  //     fetchTimeout: const Duration(minutes: 1),
  //     minimumFetchInterval: const Duration(hours: 1),
  //   ),
  // );
  // try {
  //   await remoteConfig.fetch();
  // } catch (e) {
  //   debugPrint(e.toString());
  // }

  // sl
  //   ..registerLazySingleton(() => FirebaseFirestore.instance)
  //   ..registerLazySingleton(() => FirebaseRemoteConfig.instance);
}
