// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'runtime_gateway_config_model.dart';
import 'runtime_gateway_config_parser.dart';

const _runtimeConfigPath = 'caliber_runtime_config.json';

Future<RuntimeGatewayConfig> loadPlatformRuntimeGatewayConfig() async {
  try {
    final raw = await html.HttpRequest.getString(
      _runtimeConfigPath,
    ).timeout(const Duration(seconds: 2));
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return const RuntimeGatewayConfig.disabled();
    }
    return runtimeGatewayConfigFromJson(decoded, allowInsecureGateway: true);
  } on Object {
    return const RuntimeGatewayConfig.disabled();
  }
}
