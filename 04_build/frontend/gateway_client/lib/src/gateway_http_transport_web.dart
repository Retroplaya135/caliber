// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'gateway_client_config.dart';
import 'gateway_client_error.dart';
import 'gateway_http_response.dart';

Future<GatewayHttpResponse> postGatewayJson(
  GatewayClientConfig config,
  Map<String, Object?> jsonBody,
) async {
  final headers = <String, String>{
    'accept': 'application/json',
    'content-type': 'application/json',
  };
  if (config.apiKey case final apiKey? when apiKey.trim().isNotEmpty) {
    headers['authorization'] = 'Bearer $apiKey';
  }

  try {
    final request = await html.HttpRequest.request(
      config.endpoint.toString(),
      method: 'POST',
      requestHeaders: headers,
      sendData: jsonEncode(jsonBody),
    ).timeout(config.timeout);
    final statusCode = request.status ?? 0;
    final body = request.responseText ?? '';
    if (statusCode >= 200 && statusCode < 300) {
      return GatewayHttpResponse(statusCode: statusCode, body: body);
    }
    throw GatewayHttpException(
      'AI Gateway returned HTTP $statusCode',
      statusCode: statusCode,
      body: body,
      attempts: 1,
    );
  } on GatewayHttpException {
    rethrow;
  } on Object catch (error) {
    throw GatewayTransportException(
      'AI Gateway browser request failed',
      attempts: 1,
      cause: error,
    );
  }
}
