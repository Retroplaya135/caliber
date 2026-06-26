import 'dart:convert';
import 'dart:io';

Map<String, Object?> loadGoldenFixtures() {
  final file = File('test/fixtures/golden_contracts.json');
  final decoded = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  return decoded;
}

Map<String, Object?> fixtureMap(
  Map<String, Object?> fixtures,
  String key,
) =>
    Map<String, Object?>.from(fixtures[key]! as Map<Object?, Object?>);
