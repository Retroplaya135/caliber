import 'dart:core';

import 'environment_values.dart';

final class GatewayClientConfig {
  const GatewayClientConfig({
    required this.baseUrl,
    this.apiKey,
    this.timeout = const Duration(seconds: 20),
    int retries = 0,
    this.endpointPath = '/v1/judge/interview',
    this.role = 'candidate',
  }) : assert(timeout > Duration.zero, 'timeout must be positive'),
       assert(retries >= 0, 'retries must be non-negative'),
       retries = 0;

  factory GatewayClientConfig.fromEnvironment({
    Map<String, String>? environment,
    Uri? baseUrl,
    String apiKeyVariable = 'CALIBER_AI_GATEWAY_API_KEY',
    Duration timeout = const Duration(seconds: 20),
    int? retries,
    String endpointPath = '/v1/judge/interview',
    String role = 'candidate',
  }) {
    final values = environment ?? environmentValues();
    final envBaseUrl = values['CALIBER_AI_GATEWAY_BASE_URL'];
    final rawBaseUrl = envBaseUrl?.trim();
    final resolvedBaseUrl = baseUrl ??
        (rawBaseUrl == null || rawBaseUrl.isEmpty
            ? throw StateError(
                'CALIBER_AI_GATEWAY_BASE_URL is required for gateway mode',
              )
            : Uri.parse(rawBaseUrl));
    final apiKey = values[apiKeyVariable];
    return GatewayClientConfig(
      baseUrl: resolvedBaseUrl,
      apiKey: apiKey == null || apiKey.trim().isEmpty ? null : apiKey,
      timeout: timeout,
      retries:
          retries ?? _nonNegativeInt(values['CALIBER_AI_GATEWAY_RETRIES']) ?? 0,
      endpointPath: endpointPath,
      role: role,
    );
  }

  final Uri baseUrl;
  final String? apiKey;
  final Duration timeout;
  final int retries;
  final String endpointPath;
  final String role;

  Uri get endpoint {
    final normalizedBase = baseUrl.path.endsWith('/')
        ? baseUrl
        : baseUrl.replace(path: '${baseUrl.path}/');
    final normalizedPath = endpointPath.startsWith('/')
        ? endpointPath.substring(1)
        : endpointPath;
    return normalizedBase.resolve(normalizedPath);
  }
}

int? _nonNegativeInt(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < 0) {
    return null;
  }
  return parsed;
}
