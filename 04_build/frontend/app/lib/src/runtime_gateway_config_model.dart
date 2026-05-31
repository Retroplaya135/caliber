import 'package:caliber_gateway_client/caliber_gateway_client.dart';

final class RuntimeGatewayConfig {
  const RuntimeGatewayConfig.disabled()
    : useGatewayJudge = false,
      gatewayClientConfig = null,
      funnelEndpoint = null;

  const RuntimeGatewayConfig.gateway({
    required GatewayClientConfig this.gatewayClientConfig,
    required Uri this.funnelEndpoint,
  }) : useGatewayJudge = true;

  final bool useGatewayJudge;
  final GatewayClientConfig? gatewayClientConfig;
  final Uri? funnelEndpoint;
}
