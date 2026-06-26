import 'package:caliber_shared/caliber_shared.dart';
import 'package:test/test.dart';

import '../fixtures/fixture_loader.dart';

void main() {
  group('DSAinDart-derived data structures', () {
    test('RetrievalIndexShape buckets hits by term with deterministic order', () {
      final fixtures = loadGoldenFixtures();
      final hit = CorpusHit.fromJson(fixtureMap(fixtures, 'corpus_hit'));
      final tied = hit.copyWith(recordId: 'record-0', score: hit.score);
      final weaker = hit.copyWith(
        recordId: 'record-2',
        score: 0.5,
        metadata: <String, Object?>{
          'terms': <String>['api'],
        },
      );

      final index = RetrievalIndexShape(<CorpusHit>[hit, weaker, tied]);
      final postings = index.postingsFor('api');

      expect(postings.map((hit) => hit.recordId), <String>[
        'record-0',
        'record-1',
        'record-2',
      ]);
    });

    test('EvidenceLedger returns immutable atom lookup by id', () {
      final atom = EvidenceAtomView.fromJson(
        fixtureMap(loadGoldenFixtures(), 'evidence_atom_view'),
      );
      final ledger = EvidenceLedger(<EvidenceAtomView>[]).add(atom);

      expect(ledger.byAtomId('atom-1'), atom);
      expect(() => ledger.atoms.add(atom), throwsUnsupportedError);
    });

    test('TranscriptSegmentTree resolves segment intervals', () {
      final segment = TranscriptSegment.fromJson(
        fixtureMap(loadGoldenFixtures(), 'transcript_segment'),
      );
      final later = segment.copyWith(
        segmentId: 'seg-2',
        startMs: 2000,
        endMs: 3000,
        text: 'Scaled workers',
      );
      final tree = TranscriptSegmentTree(<TranscriptSegment>[later, segment]);

      expect(tree.segmentAt(400)?.segmentId, 'seg-1');
      expect(tree.segmentAt(2500)?.segmentId, 'seg-2');
      expect(tree.segmentAt(1900), isNull);
    });

    test('ProviderRegistry selects lower priority first and rejects mutation', () {
      final registry = ProviderRegistry<String>()
        ..register(providerId: 'fallback', provider: 'cloud', priority: 50)
        ..register(providerId: 'primary', provider: 'local', priority: 10);

      expect(registry.primary, 'local');
      expect(registry.provider('fallback'), 'cloud');
      expect(
        () => registry.register(
          providerId: 'primary',
          provider: 'replacement',
        ),
        throwsStateError,
      );
    });
  });
}
