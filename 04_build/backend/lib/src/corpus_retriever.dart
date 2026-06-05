import 'corpus_models.dart';

abstract interface class CorpusRetriever {
  String get retrieverId;

  String get corpusBundleVersion;

  Future<CorpusRetrievalResult> retrieve(CorpusQuery query);
}

typedef CorpusRetrieverFactory = CorpusRetriever Function();

final class CorpusRetrieverRegistry {
  final Map<String, CorpusRetrieverFactory> _factories =
      <String, CorpusRetrieverFactory>{};

  void register(String retrieverId, CorpusRetrieverFactory factory) {
    final normalized = retrieverId.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(
          retrieverId, 'retrieverId', 'must not be empty');
    }
    if (_factories.containsKey(normalized)) {
      throw StateError('CorpusRetriever "$normalized" is already registered.');
    }
    _factories[normalized] = factory;
  }

  CorpusRetriever create(String retrieverId) {
    final factory = _factories[retrieverId];
    if (factory == null) {
      throw StateError('CorpusRetriever "$retrieverId" is not registered.');
    }
    return factory();
  }

  List<String> get registeredIds => _factories.keys.toList()..sort();
}
