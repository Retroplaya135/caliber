sealed class GatewayClientException implements Exception {
  const GatewayClientException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class GatewayTransportException extends GatewayClientException {
  const GatewayTransportException(
    super.message, {
    required this.attempts,
    this.cause,
  });

  final int attempts;
  final Object? cause;
}

final class GatewayHttpException extends GatewayClientException {
  const GatewayHttpException(
    super.message, {
    required this.statusCode,
    required this.body,
    required this.attempts,
  });

  final int statusCode;
  final String body;
  final int attempts;
}

final class GatewayDecodeException extends GatewayClientException {
  const GatewayDecodeException(
    super.message, {
    required this.body,
    this.cause,
  });

  final String body;
  final Object? cause;
}

