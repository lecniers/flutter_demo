import 'package:_env/app_flavor.dart';
import 'package:demo_app/app/app.dart';
import 'package:demo_app/bootstrap.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';

void main() {
  if (!kIsWeb) {
    bootstrap(
      () => const App(),
      appFlavor: AppFlavor.development(),
    );
    return;
  }
  bootstrap(
    () => DevicePreview(
      builder: (context) => const App(),
    ),
    appFlavor: AppFlavor.development(),
  );
}
