import 'dart:async';
import 'dart:developer';

import 'package:_core/core.dart';
import 'package:_env/env.dart';
import 'package:bloc/bloc.dart';
import 'package:demo_app/app/dependencies/injection_container.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    logD('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    logD('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  required AppFlavor appFlavor,
}) async {
  FlutterError.onError = (details) {
    logE(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await initializeDependencies(appFlavor: appFlavor);

      runApp(await builder());
    },
    (error, stackTrace) {
      logE(error, stackTrace: stackTrace);
    },
  );
}
