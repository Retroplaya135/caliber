import 'runtime_gateway_config_loader.dart'
    if (dart.library.html) 'runtime_gateway_config_loader_web.dart';
import 'runtime_gateway_config_model.dart';
export 'runtime_gateway_config_model.dart';

Future<RuntimeGatewayConfig> loadRuntimeGatewayConfig() {
  return loadPlatformRuntimeGatewayConfig();
}
