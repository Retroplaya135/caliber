import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'gateway_client_config.dart';
import 'gateway_client_error.dart';
import 'gateway_http_response.dart';

Future<GatewayHttpResponse> postGatewayJson(
  GatewayClientConfig config,
  Map<String, Object?> jsonBody,
) async {
  Object? lastError;
  final maxAttempts = config.retries + 1;
  for (var attempt = 1; attempt <= maxAttempts; attempt += 1) {
    final client = HttpClient()..connectionTimeout = config.timeout;
    try {
      final request = await client
          .postUrl(config.endpoint)
          .timeout(config.timeout);
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, ContentType.json.mimeType);
      if (config.apiKey case final apiKey? when apiKey.trim().isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      }
      request.write(jsonEncode(jsonBody));
      final response = await request.close().timeout(config.timeout);
      final body = await utf8.decodeStream(response).timeout(config.timeout);
      final statusCode = response.statusCode;
      if (statusCode >= 200 && statusCode < 300) {
        return GatewayHttpResponse(statusCode: statusCode, body: body);
      }
      if (!_isRetryableStatus(statusCode) || attempt == maxAttempts) {
        throw GatewayHttpException(
          'AI Gateway returned HTTP $statusCode',
          statusCode: statusCode,
          body: body,
          attempts: attempt,
        );
      }
    } on GatewayHttpException {
      rethrow;
    } on SocketException catch (error) {
      lastError = error;
    } on TimeoutException catch (error) {
      lastError = error;
    } on IOException catch (error) {
      lastError = error;
    } finally {
      client.close(force: true);
    }

    if (attempt < maxAttempts) {
      await Future<void>.delayed(_retryDelay(attempt));
    }
  }
  throw GatewayTransportException(
    'AI Gateway request failed after $maxAttempts attempts',
    attempts: maxAttempts,
    cause: lastError,
  );
}

bool _isRetryableStatus(int statusCode) {
  return statusCode == HttpStatus.tooManyRequests ||
      statusCode >= HttpStatus.internalServerError;
}

Duration _retryDelay(int attempt) => Duration(milliseconds: 100 * attempt);
