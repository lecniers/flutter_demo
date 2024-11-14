import 'package:_env/env.dart';
import 'package:demo_app/app/app.dart';
import 'package:demo_app/bootstrap.dart';

void main() {
  bootstrap(
    () => const App(),
    appFlavor: AppFlavor.staging(),
  );
}
