import 'package:caliber_app_runner/src/runtime_gateway_config_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'native runtime config stays disabled unless gateway mode is explicit',
    () {
      final config = runtimeGatewayConfigFromValues(
        interviewJudge: '',
        gatewayBaseUrl: 'https://api.caliber.example',
      );

      expect(config.useGatewayJudge, isFalse);
      expect(config.gatewayClientConfig, isNull);
      expect(config.funnelEndpoint, isNull);
    },
  );

  test('native runtime config requires HTTPS by default', () {
    final config = runtimeGatewayConfigFromValues(
      interviewJudge: 'gateway',
      gatewayBaseUrl: 'http://127.0.0.1:8000',
    );

    expect(config.useGatewayJudge, isFalse);
  });

  test('native runtime config enables gateway with HTTPS public backend', () {
    final config = runtimeGatewayConfigFromValues(
      interviewJudge: 'gateway',
      gatewayBaseUrl: 'https://api.caliber.example',
    );

    expect(config.useGatewayJudge, isTrue);
    expect(
      config.gatewayClientConfig?.baseUrl,
      Uri.parse('https://api.caliber.example'),
    );
    expect(
      config.funnelEndpoint,
      Uri.parse('https://api.caliber.example/funnel'),
    );
    expect(config.gatewayClientConfig?.apiKey, isNull);
  });

  test('runtime config supports explicit HTTPS funnel endpoint', () {
    final config = runtimeGatewayConfigFromValues(
      interviewJudge: 'gateway',
      gatewayBaseUrl: 'https://api.caliber.example',
      funnelEndpoint: 'https://events.caliber.example/funnel',
    );

    expect(
      config.funnelEndpoint,
      Uri.parse('https://events.caliber.example/funnel'),
    );
  });

  test('runtime JSON rejects API key fields before building client config', () {
    expect(
      () => runtimeGatewayConfigFromJson(<String, Object?>{
        'interview_judge': 'gateway',
        'gateway_base_url': 'https://api.caliber.example',
        'api_key': 'must-not-ship',
      }),
      throwsFormatException,
    );
  });

  test('web/local test mode may explicitly allow an insecure gateway', () {
    final config = runtimeGatewayConfigFromValues(
      interviewJudge: 'gateway',
      gatewayBaseUrl: 'http://127.0.0.1:8000',
      allowInsecureGateway: true,
    );

    expect(config.useGatewayJudge, isTrue);
    expect(config.funnelEndpoint, Uri.parse('http://127.0.0.1:8000/funnel'));
  });
}
