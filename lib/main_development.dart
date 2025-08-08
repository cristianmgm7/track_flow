import 'package:trackflow/config/flavor_config.dart';
import 'main.dart' as runner;

void main() {
  FlavorConfig.setFlavor(Flavor.development);
  runner.main();
}