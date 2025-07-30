import 'config/flavor_config.dart';
import 'main.dart' as runner;

void main() {
  FlavorConfig.setFlavor(Flavor.staging);
  runner.main();
}