import 'gateway_client_config.dart';
import 'gateway_client_error.dart';
import 'gateway_http_response.dart';

Future<GatewayHttpResponse> postGatewayJson(
  GatewayClientConfig config,
  Map<String, Object?> jsonBody,
) {
  throw GatewayTransportException(
    'AI Gateway transport is unavailable on this platform',
    attempts: 1,
  );
}
