import 'gateway_client_config.dart';
import 'gateway_http_response.dart';

export 'gateway_http_transport_stub.dart'
    if (dart.library.io) 'gateway_http_transport_io.dart'
    if (dart.library.html) 'gateway_http_transport_web.dart';

typedef GatewayPostJson =
    Future<GatewayHttpResponse> Function(
      GatewayClientConfig config,
      Map<String, Object?> jsonBody,
    );
