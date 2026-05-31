import 'package:caliber_gateway_client/caliber_gateway_client.dart';

import 'runtime_gateway_config_model.dart';

RuntimeGatewayConfig runtimeGatewayConfigFromJson(
  Map<String, Object?> json, {
  bool allowInsecureGateway = false,
}) {
  if (json.containsKey('api_key')) {
    throw const FormatException('runtime config must not contain api_key');
  }
  return runtimeGatewayConfigFromValues(
    interviewJudge: (json['interview_judge'] as String? ?? '').trim(),
    gatewayBaseUrl: (json['gateway_base_url'] as String? ?? '').trim(),
    funnelEndpoint: (json['funnel_endpoint'] as String? ?? '').trim(),
    allowInsecureGateway: allowInsecureGateway,
  );
}

RuntimeGatewayConfig runtimeGatewayConfigFromValues({
  required String interviewJudge,
  required String gatewayBaseUrl,
  String funnelEndpoint = '',
  bool allowInsecureGateway = false,
}) {
  if (interviewJudge.trim() != 'gateway') {
    return const RuntimeGatewayConfig.disabled();
  }

  final baseUrl = _parseGatewayUri(
    gatewayBaseUrl,
    allowInsecureGateway: allowInsecureGateway,
  );
  if (baseUrl == null) {
    return const RuntimeGatewayConfig.disabled();
  }

  final resolvedFunnelEndpoint = funnelEndpoint.trim().isEmpty
      ? baseUrl.resolve('/funnel')
      : _parseGatewayUri(
          funnelEndpoint,
          allowInsecureGateway: allowInsecureGateway,
        );
  if (resolvedFunnelEndpoint == null) {
    return const RuntimeGatewayConfig.disabled();
  }

  return RuntimeGatewayConfig.gateway(
    gatewayClientConfig: GatewayClientConfig(baseUrl: baseUrl),
    funnelEndpoint: resolvedFunnelEndpoint,
  );
}

Uri? _parseGatewayUri(String raw, {required bool allowInsecureGateway}) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return null;
  }
  if (uri.scheme == 'https') {
    return uri;
  }
  if (allowInsecureGateway && uri.scheme == 'http') {
    return uri;
  }
  return null;
}
