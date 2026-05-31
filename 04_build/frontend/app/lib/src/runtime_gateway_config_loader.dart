import 'runtime_gateway_config_model.dart';
import 'runtime_gateway_config_parser.dart';

const _interviewJudge = String.fromEnvironment('CALIBER_INTERVIEW_JUDGE');
const _gatewayBaseUrl = String.fromEnvironment('CALIBER_PUBLIC_GATEWAY_URL');
const _funnelEndpoint = String.fromEnvironment('CALIBER_FUNNEL_ENDPOINT');
const _allowInsecureGateway = bool.fromEnvironment(
  'CALIBER_ALLOW_INSECURE_GATEWAY',
);

Future<RuntimeGatewayConfig> loadPlatformRuntimeGatewayConfig() async {
  return runtimeGatewayConfigFromValues(
    interviewJudge: _interviewJudge,
    gatewayBaseUrl: _gatewayBaseUrl,
    funnelEndpoint: _funnelEndpoint,
    allowInsecureGateway: _allowInsecureGateway,
  );
}
