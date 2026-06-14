import 'dart:convert';
import 'dart:io';

import 'package:caliber_eval_backend/caliber_eval_backend.dart' as corpus;
import 'package:caliber_gateway_client/caliber_gateway_client.dart'
    show GatewayHttpException, GatewayTransportException;
import 'package:caliber_interview/interview.dart';
import 'package:caliber_interview/src/block10_benchmark_safety.dart';
import 'package:caliber_interview/src/block10_debug_artifact.dart';
import 'package:caliber_interview/src/block10_proof_validation.dart';

const _defaultGatewayBaseUrl = 'http://127.0.0.1:8000';
const _fixtureRelativePath =
    '04_build/_benchmark/fixtures/backend_gate0_answers.json';
const _outputRelativeDir = '04_build/_benchmark';

Future<void> main(List<String> args) async {
  final options = _BenchmarkOptions.parse(args);
  final repoRoot = _findRepoRoot(Directory.current);
  final gatewayBaseUrl =
      options.gatewayBaseUrl ??
      Platform.environment['CALIBER_AI_GATEWAY_BASE_URL'] ??
      _defaultGatewayBaseUrl;
  final gateway = _GatewayBenchmarkClient(gatewayBaseUrl);

  if (!await gateway.isReady()) {
    _gateBlocked('need provider keys + running gateway');
  }

  var answers = await _loadFixtures(
    repoRoot.file(_fixtureRelativePath),
    limit: options.limit,
    startIndex: options.startIndex,
    fixtureIds: options.fixtureIds,
    smokeDefault:
        options.caliberSmokeOnly &&
        options.fixtureIds.isEmpty &&
        options.limit == null,
    requireFullMatrix: options.requiresFullMatrix,
  );
  if (options.requiresFullMatrix && answers.length < 40) {
    throw StateError(
      'Gate 0 requires at least 40 answers; fixture has ${answers.length}.',
    );
  }
  if (options.requiresTwoBaselines && options.baselines.length != 2) {
    throw StateError(
      'Gate 0 requires exactly two baseline lanes; got ${options.baselines}.',
    );
  }
  final selectedAnswerIds = answers.map((fixture) => fixture.answerId).toSet();
  if (options.baselineOnly && options.caliberRunId == null) {
    throw StateError(
      '--baseline-only requires --caliber-run-id so the proven Caliber row '
      'cache is explicit.',
    );
  }
  _enforceCostGuard(
    rowCount: answers.length,
    caliberCallCount: block10CaliberCallsPerRow(
      baselineOnly: options.baselineOnly,
    ),
    baselineCount: options.callsBaselines ? options.baselines.length : 0,
  );

  final runId = options.resumeRunId ?? _utcStamp(DateTime.now().toUtc());
  final caliberRunId = options.caliberRunId ?? runId;
  final outputDir = _resolveOutputDir(repoRoot, options.outputDirPath)
    ..createSync(recursive: true);
  final markdownFile = outputDir.file('blind_ab_$runId.md');
  final keyFile = outputDir.file('blind_ab_${runId}_key.json');
  final costFile = outputDir.file('blind_ab_${runId}_cost.json');
  final summaryFile = outputDir.file('calibration_summary_$runId.json');
  final scoringSheetFile = outputDir.file(
    'senior_reviewer_scoring_sheet_$runId.md',
  );
  final debugSmokeFile = outputDir.file(
    'debug_smoke_${runId}_${options.debugFixtureId ?? 'caliber'}.md',
  );
  final rowCacheFile = outputDir.file('caliber_rows_$caliberRunId.jsonl');
  final blindRowCacheFile = outputDir.file('blind_rows_$runId.jsonl');
  final discrepancyFile = outputDir.file('discrepancy_packet_$runId.json');
  final cachedRows = options.resumeRunId == null && !options.baselineOnly
      ? const <Map<String, Object?>>[]
      : _loadRowCache(rowCacheFile);
  if (options.baselineOnly) {
    _assertBaselineOnlyCaliberCache(
      rowCacheFile: rowCacheFile,
      rows: cachedRows,
      answers: answers,
    );
  }
  final cachedBlindRows = options.resumeRunId == null
      ? const <Map<String, Object?>>[]
      : _loadRowCache(blindRowCacheFile);
  final cachedKeyRows = options.resumeRunId == null
      ? const <Map<String, Object?>>[]
      : _loadKeyRows(keyFile);
  final cachedBaselineCosts = options.resumeRunId == null
      ? const <Map<String, Object?>>[]
      : _loadCostRows(costFile, 'baseline_provider_costs');
  final cachedFallbackRows = options.resumeRunId == null
      ? const <Map<String, Object?>>[]
      : _loadCostRows(costFile, 'fallback_rows');
  final retryTransportAnswerIds = options.retryTransportFailuresOnly
      ? _cachedAnswerIdsByFailureClass(cachedRows, 'transport_failure')
      : const <String>{};
  final retrySelectedAnswerIds = <String>{
    ...retryTransportAnswerIds,
    if (options.resumeRunId != null) ...options.fixtureIds,
  };
  if (options.retryTransportFailuresOnly) {
    if (retryTransportAnswerIds.isEmpty) {
      throw StateError('No cached transport failures found for run_id=$runId.');
    }
    answers = answers
        .where((fixture) => retryTransportAnswerIds.contains(fixture.answerId))
        .toList(growable: false);
  }
  final caliberCacheExcludeAnswerIds = options.baselineOnly
      ? const <String>{}
      : retrySelectedAnswerIds;
  final cachedCaliberRows = _cachedCaliberRows(
    cachedRows,
    excludeAnswerIds: caliberCacheExcludeAnswerIds,
    includeAnswerIds: selectedAnswerIds,
  );
  final cachedInvalidRows = _cachedInvalidRows(
    cachedRows,
    excludeAnswerIds: retrySelectedAnswerIds,
  );
  final cachedBlindAnswerIds = _cachedValidBlindAnswerIds(
    cachedBlindRows,
    excludeAnswerIds: options.fixtureIds.toSet(),
  );

  final tokenSummaryBefore = _readGatewayTokenSummary(repoRoot);
  final judge = options.baselineOnly
      ? null
      : buildConfiguredStructuredJudge(
          environment: <String, String>{
            'CALIBER_INTERVIEW_JUDGE': 'gateway',
            'CALIBER_AI_GATEWAY_BASE_URL': gatewayBaseUrl,
            'CALIBER_AI_GATEWAY_RETRIES': '0',
          },
          clock: () => DateTime.utc(2026, 6, 5),
        );

  final cases = <_BlindCase>[];
  final caliberResults = <_CaliberLaneResult>[
    if (options.baselineOnly)
      ..._caliberResultsFromCache(cachedCaliberRows, answers: answers),
  ];
  final caliberRows = <Map<String, Object?>>[...cachedCaliberRows];
  final keyRows = <Map<String, Object?>>[];
  final baselineCosts = <Map<String, Object?>>[];
  final invalidRows = <Map<String, Object?>>[...cachedInvalidRows];
  final caliberBandsBySeedBand = <String, Map<String, int>>{};
  final caliberFixByAnswerId = <String, String>{};
  final fallbackRows = <Map<String, Object?>>[];
  final baselineConnectivitySmokeRows = <Map<String, Object?>>[];
  _restoreCachedBlindRows(
    cachedBlindRows,
    answers: answers,
    excludedAnswerIds: options.fixtureIds.toSet(),
    cachedKeyRows: cachedKeyRows,
    cachedBaselineCosts: cachedBaselineCosts,
    cachedFallbackRows: cachedFallbackRows,
    cases: cases,
    keyRows: keyRows,
    baselineCosts: baselineCosts,
    fallbackRows: fallbackRows,
  );
  final discrepancyRows = <Map<String, Object?>>[
    for (final row in cachedRows)
      if (row['status'] == 'valid' &&
          selectedAnswerIds.contains(row['answer_id']) &&
          !retrySelectedAnswerIds.contains(row['answer_id']) &&
          row['discrepancy'] is Map<String, Object?>)
        row['discrepancy']! as Map<String, Object?>,
  ];
  for (final row in cachedCaliberRows) {
    final answerId = row['answer_id'];
    final fix = row['caliber_highest_leverage_fix'];
    if (answerId is String && fix is String && fix.trim().isNotEmpty) {
      caliberFixByAnswerId[answerId] = fix;
    }
  }
  if (options.runsBaselineConnectivitySmoke) {
    baselineConnectivitySmokeRows.addAll(
      await _runBaselineConnectivitySmoke(
        gateway: gateway,
        baselines: options.baselines,
        answers: answers,
        delayMs: options.openRouterDelayMs,
      ),
    );
  }
  if (!options.baselineOnly) {
    final answerChunks = _chunkFixtures(answers, options.chunkSize);
    for (
      var chunkIndex = 0;
      chunkIndex < answerChunks.length;
      chunkIndex += 1
    ) {
      final chunk = answerChunks[chunkIndex];
      if (options.chunkSize != null) {
        stdout.writeln(
          'Caliber chunk ${chunkIndex + 1}/${answerChunks.length}: '
          '${chunk.length} rows',
        );
      }
      for (final fixture in chunk) {
        if (cachedBlindAnswerIds.contains(fixture.answerId)) {
          continue;
        }
        final question = _questionForFixture(fixture);
        InterviewContentJudgment caliberJudgment;
        try {
          caliberJudgment = await runInterviewRound(
            question,
            fixture.candidateAnswer,
            judge: judge!,
            now: DateTime.utc(2026, 6, 5),
          );
        } on Object catch (error) {
          final invalidRow = _classifiedInvalidRow(<String, Object?>{
            'answer_id': fixture.answerId,
            'reason': 'caliber_verdict_failed',
            ..._safeErrorFields(error),
          });
          invalidRows.add(invalidRow);
          _appendRowCache(rowCacheFile, invalidRow);
          if (options.caliberSmokeOnly && !options.keepGoingSmoke) {
            break;
          }
          continue;
        }
        final caliberValidationFailures = _validateCaliberJudgment(
          fixture,
          question,
          caliberJudgment,
        );
        if (caliberValidationFailures.isNotEmpty) {
          final invalidRow = _classifiedInvalidRow(<String, Object?>{
            'answer_id': fixture.answerId,
            'reason': 'caliber_verdict_failed_proof_invariants',
            'failures': caliberValidationFailures,
          });
          invalidRows.add(invalidRow);
          _appendRowCache(rowCacheFile, invalidRow);
          if (options.caliberSmokeOnly && !options.keepGoingSmoke) {
            break;
          }
          continue;
        }
        final caliberFix = _highestLeverageFix(caliberJudgment);
        final caliberVerdictText = _renderCaliberVerdict(caliberJudgment);
        caliberResults.add(
          _CaliberLaneResult(
            fixture: fixture,
            question: question,
            judgment: caliberJudgment,
            modelId: caliberJudgment.modelId,
            levelBand: caliberJudgment.levelBand,
            verdictText: caliberVerdictText,
            highestLeverageFix: caliberFix,
          ),
        );
        caliberFixByAnswerId[fixture.answerId] = caliberFix;
        final discrepancyRow = _discrepancyRow(fixture, caliberJudgment);
        discrepancyRows.add(discrepancyRow);
        final caliberRow = <String, Object?>{
          'row_schema_version': block10CaliberRowCacheSchemaVersion,
          'answer_id': fixture.answerId,
          'seed_band': fixture.seedBand,
          'quality_band': fixture.seedBand,
          'question_id': fixture.questionId,
          'scenario_kind': fixture.scenarioKind,
          'caliber_band': caliberJudgment.levelBand,
          'caliber_model_id': caliberJudgment.modelId,
          'caliber_verdict_text': caliberVerdictText,
          'caliber_judgment_json': caliberJudgment.toJson(),
          'provider_suggested_band': _providerSuggestedBand(caliberJudgment),
          'deterministic_level_band': _deterministicLevelBand(caliberJudgment),
          'caliber_highest_leverage_fix': caliberFix,
        };
        caliberRows.add(caliberRow);
        _appendRowCache(rowCacheFile, <String, Object?>{
          'status': 'valid',
          ...caliberRow,
          'discrepancy': discrepancyRow,
        });
      }
    }
  }

  for (final row in caliberRows) {
    final seedBand = row['seed_band'];
    final caliberBand = row['caliber_band'];
    if (seedBand is String && caliberBand is String) {
      caliberBandsBySeedBand
          .putIfAbsent(seedBand, () => <String, int>{})
          .update(caliberBand, (count) => count + 1, ifAbsent: () => 1);
    }
  }
  final duplicateFixLines = _duplicateFixLines(caliberFixByAnswerId);
  final stopBeforeBaselines =
      options.caliberDebugOne ||
      options.caliberSmokeOnly ||
      options.caliberOnly ||
      invalidRows.isNotEmpty ||
      duplicateFixLines.isNotEmpty;

  if (!stopBeforeBaselines) {
    for (final caliberResult in caliberResults) {
      final fixture = caliberResult.fixture;
      if (cachedBlindAnswerIds.contains(fixture.answerId)) {
        continue;
      }
      final question = caliberResult.question;
      final caliberFix = caliberResult.highestLeverageFix;
      final baselineResponses = <_GenericFeedbackResponse>[];
      final rowFallbackRows = <Map<String, Object?>>[];
      var rowHadBaselineFailure = false;
      for (final provider in options.baselines) {
        try {
          final response = await gateway.genericFeedback(
            provider: provider,
            fixture: fixture,
            question: question,
          );
          baselineResponses.add(response);
          if (response.modelId.startsWith('openrouter-fallback:')) {
            rowFallbackRows.add(<String, Object?>{
              'answer_id': fixture.answerId,
              'provider': response.provider,
              'model_id': response.modelId,
            });
          }
        } on Object catch (error) {
          final invalidRow = _classifiedInvalidRow(<String, Object?>{
            'answer_id': fixture.answerId,
            'provider': provider,
            'reason': 'baseline_failed_after_fallback',
            ..._safeBaselineErrorFields(error),
          });
          invalidRows.add(invalidRow);
          _appendRowCache(blindRowCacheFile, invalidRow);
          rowHadBaselineFailure = true;
        }
        if (provider.startsWith('openrouter') &&
            options.openRouterDelayMs > 0) {
          await Future<void>.delayed(
            Duration(milliseconds: options.openRouterDelayMs),
          );
        }
      }
      if (baselineResponses.length != options.baselines.length) {
        if (!rowHadBaselineFailure) {
          final invalidRow = _classifiedInvalidRow(<String, Object?>{
            'answer_id': fixture.answerId,
            'reason': 'baseline_incomplete_after_attempts',
            'completed_baselines': baselineResponses
                .map((response) => response.provider)
                .toList(growable: false),
          });
          invalidRows.add(invalidRow);
          _appendRowCache(blindRowCacheFile, invalidRow);
        }
        continue;
      }

      final verdicts = <_SourceVerdict>[
        _SourceVerdict(
          source: 'caliber',
          modelId: caliberResult.modelId,
          text: caliberResult.verdictText,
        ),
        for (final response in baselineResponses)
          _SourceVerdict(
            source: response.provider,
            modelId: response.modelId,
            text: response.verdict,
          ),
      ];
      final distinctSources = verdicts.map((verdict) => verdict.source).toSet();
      final distinctModelIds = verdicts
          .map((verdict) => verdict.modelId)
          .toSet();
      if (verdicts.length != 3 ||
          distinctSources.length != 3 ||
          distinctModelIds.length != 3) {
        final invalidRow = _classifiedInvalidRow(<String, Object?>{
          'answer_id': fixture.answerId,
          'reason': 'non_distinct_verdict_slots',
          'sources': distinctSources.toList()..sort(),
          'model_ids': distinctModelIds.toList()..sort(),
        });
        invalidRows.add(invalidRow);
        _appendRowCache(blindRowCacheFile, invalidRow);
        continue;
      }
      final blinded = _blind(verdicts, fixture.answerId);
      if (!_blindVerdictsAreDistinct(blinded)) {
        final invalidRow = _classifiedInvalidRow(<String, Object?>{
          'answer_id': fixture.answerId,
          'reason': 'non_distinct_blind_labels',
          'sources': blinded.map((verdict) => verdict.source).toSet().toList()
            ..sort(),
          'model_ids':
              blinded.map((verdict) => verdict.modelId).toSet().toList()
                ..sort(),
        });
        invalidRows.add(invalidRow);
        _appendRowCache(blindRowCacheFile, invalidRow);
        continue;
      }
      final blindCase = _BlindCase(
        fixture: fixture,
        question: question,
        blindedVerdicts: blinded,
      );
      final keyRow = <String, Object?>{
        'answer_id': fixture.answerId,
        'seed_band': fixture.seedBand,
        'quality_band': fixture.seedBand,
        'question_id': fixture.questionId,
        'scenario_kind': fixture.scenarioKind,
        'labels': <String, Object?>{
          for (final verdict in blinded) verdict.label: verdict.source,
        },
        'models': <String, Object?>{
          for (final verdict in blinded) verdict.source: verdict.modelId,
        },
        'caliber_band': caliberResult.levelBand,
        'caliber_highest_leverage_fix': caliberFix,
      };
      final rowBaselineCosts = baselineResponses
          .map(
            (response) => <String, Object?>{
              'answer_id': fixture.answerId,
              ...response.costRow,
            },
          )
          .toList(growable: false);
      cases.add(blindCase);
      keyRows.add(keyRow);
      fallbackRows.addAll(rowFallbackRows);
      baselineCosts.addAll(rowBaselineCosts);
      _appendRowCache(blindRowCacheFile, <String, Object?>{
        'status': 'valid',
        'row_schema_version': block10BlindRowCacheSchemaVersion,
        'answer_id': fixture.answerId,
        'blinded_verdicts': _blindVerdictsToJson(blinded),
      });
    }
  }

  final tokenSummaryAfter = _readGatewayTokenSummary(repoRoot);
  final currentGatewayTokenDelta = _summaryDelta(
    tokenSummaryBefore,
    tokenSummaryAfter,
  );
  final currentCaliberTokenDelta = _summaryDeltaForModel(
    tokenSummaryBefore,
    tokenSummaryAfter,
    block10ProductJudgeModelId,
  );
  final cachedCaliberTokenDelta = options.baselineOnly
      ? _readCaliberTokenDeltaForRun(outputDir, caliberRunId)
      : <String, Object?>{};
  final caliberTokenDelta = options.baselineOnly
      ? cachedCaliberTokenDelta
      : currentCaliberTokenDelta;
  final caliberCostSource = options.baselineOnly
      ? 'cached_caliber_run:$caliberRunId'
      : 'current_invocation';
  final zeroCaliberCallProof = _zeroCaliberCallProof(
    before: tokenSummaryBefore,
    after: tokenSummaryAfter,
    currentCaliberTokenDelta: currentCaliberTokenDelta,
  );
  final transportFailures = invalidRows
      .where((row) => row['failure_class'] == 'transport_failure')
      .toList(growable: false);
  final calibrationFailures = invalidRows
      .where((row) => row['failure_class'] == 'calibration_failure')
      .toList(growable: false);
  final baselineFailures = invalidRows
      .where((row) => row['failure_class'] == 'baseline_failure')
      .toList(growable: false);
  final tokenEconomics = _tokenEconomics(
    caliberTokenDelta,
    measuredRows: caliberResults.length,
    proofValidRows: caliberRows.length,
    tokenDeltaScope: caliberCostSource,
  );
  final baselineRatingCostUsd = baselineCosts.fold<double>(
    0,
    (sum, row) => sum + ((row['estimated_cost_usd'] as num?)?.toDouble() ?? 0),
  );
  final baselineConnectivitySmokeCostUsd = baselineConnectivitySmokeRows
      .fold<double>(0, (sum, row) {
        final cost = row['cost'];
        if (cost is Map<String, Object?>) {
          return sum + ((cost['estimated_cost_usd'] as num?)?.toDouble() ?? 0);
        }
        return sum;
      });
  final caliberSourceCostUsd = _costFromGatewaySummary(caliberTokenDelta);
  final grandTotalCostUsd =
      caliberSourceCostUsd +
      baselineRatingCostUsd +
      baselineConnectivitySmokeCostUsd;
  final midInflations = caliberRows
      .where(
        (row) =>
            row['seed_band'] == 'clearly_mid' &&
            const <String>{'at_bar', 'above_bar'}.contains(row['caliber_band']),
      )
      .map((row) => row['answer_id'] as String)
      .toList();
  final seniorDeflations = caliberRows
      .where(
        (row) =>
            row['seed_band'] == 'clearly_senior' &&
            row['caliber_band'] == 'below_bar',
      )
      .map((row) => row['answer_id'] as String)
      .toList();
  final expectedCaliberRowCount = _expectedCaliberRowCount(
    cachedCaliberRows: cachedCaliberRows,
    selectedAnswers: answers,
  );
  final fullPacketMode = !options.caliberSmokeOnly && !options.caliberOnly;
  final transportBlockedResumable =
      options.caliberOnly &&
      transportFailures.isNotEmpty &&
      calibrationFailures.isEmpty &&
      midInflations.isEmpty &&
      seniorDeflations.isEmpty &&
      duplicateFixLines.isEmpty;
  final criteria = fullPacketMode
      ? <String, bool>{
          'rated_rows_valid':
              invalidRows.isEmpty && cases.length == expectedCaliberRowCount,
          'three_distinct_verdicts_per_valid_row': keyRows.every(
            _hasThreeDistinctVerdictSlots,
          ),
          'zero_clearly_mid_at_bar_or_above': midInflations.isEmpty,
          'zero_clearly_senior_below_bar': seniorDeflations.isEmpty,
          'unique_caliber_fix_lines': duplicateFixLines.isEmpty,
          'evidence_quotes_are_answer_substrings': !invalidRowsContain(
            invalidRows,
            'evidence_quote_not_answer_substring',
          ),
          'evidence_spans_map_to_signed_rubric_criterion_id':
              !invalidRowsContain(invalidRows, 'criterion_id_'),
          'risks_and_fix_map_to_rubric_criteria': !invalidRowsContain(
            invalidRows,
            'criterion_mapping',
          ),
          'token_cost_recorded_per_lane': _costRecorded(
            validRows: cases.length,
            baselineProviders: options.baselines,
            caliberTokenDelta: caliberTokenDelta,
            baselineCosts: baselineCosts,
          ),
          'baseline_only_current_caliber_calls_zero':
              !options.baselineOnly ||
              (zeroCaliberCallProof['passes'] as bool? ?? false),
        }
      : <String, bool>{
          'caliber_rows_valid':
              invalidRows.isEmpty &&
              caliberRows.length == expectedCaliberRowCount,
          'transport_failures_separated':
              transportFailures.length == invalidRows.length ||
              transportFailures.isEmpty,
          'calibration_failures_separated': calibrationFailures.isEmpty,
          'zero_clearly_mid_at_bar_or_above': midInflations.isEmpty,
          'zero_clearly_senior_below_bar': seniorDeflations.isEmpty,
          'unique_caliber_fix_lines': duplicateFixLines.isEmpty,
          'evidence_quotes_are_answer_substrings': !invalidRowsContain(
            invalidRows,
            'evidence_quote_not_answer_substring',
          ),
          'evidence_spans_map_to_signed_rubric_criterion_id':
              !invalidRowsContain(invalidRows, 'criterion_id_'),
          'risks_and_fix_map_to_rubric_criteria': !invalidRowsContain(
            invalidRows,
            'criterion_mapping',
          ),
          'caliber_token_cost_recorded': _caliberCostRecorded(
            caliberTokenDelta,
          ),
        };
  final gatePassed = criteria.values.every((passed) => passed);
  final status = transportBlockedResumable
      ? 'caliber_only_transport_blocked_resumable'
      : _statusForRun(
          fullPacketMode: fullPacketMode,
          caliberSmokeOnly: options.caliberSmokeOnly,
          gatePassed: gatePassed,
        );
  final ratedRows = fullPacketMode ? cases.length : caliberRows.length;
  await markdownFile.writeAsString(
    _stripTrailingWhitespace(
      _renderBlindMarkdown(
        runId: runId,
        cases: cases,
        totalRows: expectedCaliberRowCount,
        invalidRows: invalidRows.length,
      ),
    ),
    encoding: utf8,
  );
  await keyFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'schema_version': 'caliber_block10_blind_key.v0.1',
      'run_id': runId,
      'run_mode': options.runMode,
      'caliber_source_run_id': caliberRunId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'do_not_open_until_after_rating': true,
      'rows': keyRows,
      'caliber_rows': caliberRows,
      'invalid_rows_excluded_from_rating': invalidRows,
    }),
    encoding: utf8,
  );
  await costFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'schema_version': 'caliber_block10_cost.v0.1',
      'run_id': runId,
      'run_mode': options.runMode,
      'caliber_source_run_id': caliberRunId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'gateway_base_url': gatewayBaseUrl,
      'answer_count': ratedRows,
      'total_rows': expectedCaliberRowCount,
      'valid_rows': ratedRows,
      'caliber_valid_rows': caliberResults.length,
      'blind_valid_rows': cases.length,
      'fixture_count': expectedCaliberRowCount,
      'archetype_count': answers
          .map((fixture) => fixture.questionId)
          .toSet()
          .length,
      'invalid_rows': invalidRows,
      'transport_failures': transportFailures,
      'calibration_failures': calibrationFailures,
      'baseline_failures': baselineFailures,
      'self_check': <String, Object?>{
        'total_rows': expectedCaliberRowCount,
        'valid_rows': ratedRows,
        'caliber_valid_rows': caliberRows.length,
        'blind_valid_rows': cases.length,
        'invalid_rows': invalidRows.length,
        'transport_failures': transportFailures.length,
        'calibration_failures': calibrationFailures.length,
        'three_distinct_verdicts_per_valid_row': keyRows.every(
          _hasThreeDistinctVerdictSlots,
        ),
      },
      'gate_criteria': criteria,
      'status': status,
      'confusion_table': caliberBandsBySeedBand,
      'separation_check': <String, Object?>{
        'clearly_mid_at_bar_or_above': midInflations,
        'clearly_senior_below_bar': seniorDeflations,
      },
      'duplicate_caliber_fix_lines': duplicateFixLines,
      'fallback_rows': fallbackRows,
      'provider_fanout_policy': <String, Object?>{
        'flutter_gateway_retries': 0,
        'gateway_provider_attempts_per_request': 1,
        'openrouter_delay_ms': options.openRouterDelayMs,
      },
      'baseline_provider_plan': options.baselines,
      'current_invocation_gateway_token_delta': currentGatewayTokenDelta,
      'current_invocation_caliber_token_delta': currentCaliberTokenDelta,
      'caliber_gateway_token_delta': caliberTokenDelta,
      'caliber_cost_source': caliberCostSource,
      'zero_caliber_call_proof': zeroCaliberCallProof,
      'caliber_token_economics': tokenEconomics,
      'baseline_provider_costs': baselineCosts,
      'baseline_connectivity_smoke': baselineConnectivitySmokeRows,
      'caliber_source_cost_usd': caliberSourceCostUsd,
      'baseline_rating_cost_usd': baselineRatingCostUsd,
      'baseline_connectivity_smoke_cost_usd': baselineConnectivitySmokeCostUsd,
      'grand_total_cost_usd': grandTotalCostUsd,
      'estimated_total_cost_usd': grandTotalCostUsd,
      'notes': <String>[
        'Caliber cost uses gateway token summary delta and configured OpenAI rates.',
        'Baseline costs use provider-reported usage when available, otherwise local token estimates.',
      ],
    }),
    encoding: utf8,
  );
  await discrepancyFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'schema_version': 'caliber_block10_discrepancy_packet.v0.1',
      'run_id': runId,
      'run_mode': options.runMode,
      'caliber_source_run_id': caliberRunId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'rows': discrepancyRows,
      'transport_failures': transportFailures,
      'calibration_failures': calibrationFailures,
    }),
    encoding: utf8,
  );
  final summary = <String, Object?>{
    'schema_version': 'caliber_block10_calibration_summary.v0.1',
    'run_id': runId,
    'run_mode': options.runMode,
    'caliber_source_run_id': caliberRunId,
    'created_at': DateTime.now().toUtc().toIso8601String(),
    'status': status,
    'fixture_count': expectedCaliberRowCount,
    'archetype_count': answers
        .map((fixture) => fixture.questionId)
        .toSet()
        .length,
    'valid_rows': ratedRows,
    'caliber_valid_rows': caliberRows.length,
    'blind_valid_rows': cases.length,
    'invalid_rows': invalidRows,
    'transport_failures': transportFailures,
    'calibration_failures': calibrationFailures,
    'baseline_failures': baselineFailures,
    'confusion_table': caliberBandsBySeedBand,
    'gate_criteria': criteria,
    'caliber_token_economics': tokenEconomics,
    'caliber_cost_source': caliberCostSource,
    'zero_caliber_call_proof': zeroCaliberCallProof,
    'grand_total_cost_usd': grandTotalCostUsd,
    'baseline_connectivity_smoke': baselineConnectivitySmokeRows,
    'row_cache_path': rowCacheFile.path,
    'blind_row_cache_path': blindRowCacheFile.path,
    'blind_packet_paths': <String, Object?>{
      'blind_markdown': markdownFile.path,
      'key_json': keyFile.path,
      'cost_json': costFile.path,
      'discrepancy_packet_json': discrepancyFile.path,
      if (options.caliberDebugOne) 'debug_smoke_markdown': debugSmokeFile.path,
      'senior_reviewer_scoring_sheet': scoringSheetFile.path,
    },
    'human_review_status': fullPacketMode && gatePassed
        ? 'blocked_until_block_10_5_code_rereview'
        : 'blocked_until_baselines_complete',
    'status_language_guardrail':
        'This is not product proof until human senior-engineer review is complete.',
  };
  await summaryFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(summary),
    encoding: utf8,
  );
  await scoringSheetFile.writeAsString(
    _stripTrailingWhitespace(
      _renderSeniorReviewerScoringSheet(runId: runId, cases: cases),
    ),
    encoding: utf8,
  );
  if (options.caliberDebugOne) {
    final fixture = answers.single;
    final scenario = corpus.kBackendDepthRubric.scenarioForQuestion(
      fixture.questionId,
    );
    final matchingResult = caliberResults
        .where((result) => result.fixture.answerId == fixture.answerId)
        .toList();
    final matchingInvalidRows = invalidRows
        .where((row) => row['answer_id'] == fixture.answerId)
        .toList();
    final judgment = matchingResult.isEmpty
        ? null
        : matchingResult.single.judgment;
    final validationFailures = matchingInvalidRows
        .expand((row) {
          final failures = row['failures'];
          return failures is List<Object?>
              ? failures.map((item) => item.toString())
              : const Iterable<String>.empty();
        })
        .toList(growable: false);
    await debugSmokeFile.writeAsString(
      renderBlock10DebugSmokeMarkdown(
        runId: runId,
        fixtureId: fixture.answerId,
        prompt: fixture.prompt,
        archetypeId: fixture.archetypeId,
        scenario: scenario,
        judgment: judgment,
        validationFailures: validationFailures,
        invalidReason: matchingInvalidRows.isEmpty
            ? null
            : _debugInvalidReason(matchingInvalidRows.first),
        tokenCostLedger: <String, Object?>{
          'run_id': runId,
          'caliber_gateway_token_delta': caliberTokenDelta,
          'estimated_cost_usd': _costFromGatewaySummary(caliberTokenDelta),
          'valid_rows': ratedRows,
          'invalid_rows': invalidRows,
        },
      ),
      encoding: utf8,
    );
  }

  stdout.writeln('Blind benchmark written: ${markdownFile.path}');
  stdout.writeln('Hidden answer key: ${keyFile.path}');
  stdout.writeln('Token/cost ledger: ${costFile.path}');
  stdout.writeln('Discrepancy packet: ${discrepancyFile.path}');
  stdout.writeln('Calibration summary: ${summaryFile.path}');
  stdout.writeln('Senior reviewer scoring sheet: ${scoringSheetFile.path}');
  if (options.caliberDebugOne) {
    stdout.writeln('Debug smoke artifact: ${debugSmokeFile.path}');
  }
  stdout.writeln(
    'Self-check: total=$expectedCaliberRowCount valid=$ratedRows invalid=${invalidRows.length}',
  );
  stdout.writeln('Gate criteria: ${jsonEncode(criteria)}');
  if (!gatePassed && !transportBlockedResumable) {
    stderr.writeln('GATE FAIL: Gate 0 criteria did not all hold.');
    exit(1);
  }
  if (transportBlockedResumable) {
    stderr.writeln(
      'GATE BLOCKED: transport failures separated; resume with '
      '--resume-run-id $runId --retry-transport-failures-only.',
    );
  }
}

Future<List<_BenchmarkFixture>> _loadFixtures(
  File file, {
  int? limit,
  int startIndex = 0,
  List<String> fixtureIds = const <String>[],
  bool smokeDefault = false,
  bool requireFullMatrix = true,
}) async {
  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! List<Object?>) {
    throw FormatException(
      'Fixture file must contain a JSON array: ${file.path}',
    );
  }
  final fixtures = <_BenchmarkFixture>[
    for (final item in decoded)
      _BenchmarkFixture.fromJson(item as Map<String, Object?>),
  ];
  List<_BenchmarkFixture> selected;
  if (fixtureIds.isNotEmpty) {
    final requested = fixtureIds.toSet();
    selected = <_BenchmarkFixture>[
      for (final fixture in fixtures)
        if (requested.contains(fixture.answerId)) fixture,
    ];
    final missing =
        requested
            .difference(selected.map((fixture) => fixture.answerId).toSet())
            .toList()
          ..sort();
    if (missing.isNotEmpty) {
      throw StateError('Unknown fixture ids: ${missing.join(', ')}');
    }
  } else if (smokeDefault) {
    selected = _defaultSmokeFixtures(fixtures);
  } else {
    if (startIndex < 0 || startIndex >= fixtures.length) {
      throw ArgumentError.value(
        startIndex,
        'startIndex',
        'Must select a fixture index in range.',
      );
    }
    final sliced = fixtures.skip(startIndex);
    selected = limit == null ? sliced.toList() : sliced.take(limit).toList();
  }
  final ids = <String>{};
  for (final fixture in selected) {
    if (!ids.add(fixture.answerId)) {
      throw StateError('Duplicate answer_id: ${fixture.answerId}');
    }
    _questionForFixture(fixture);
    final fixtureIssues = fixture.validateMetadata();
    if (fixtureIssues.isNotEmpty) {
      throw StateError(
        'Fixture ${fixture.answerId} is incomplete: ${fixtureIssues.join(', ')}',
      );
    }
  }
  if (!requireFullMatrix) return selected;
  final archetypeCount = selected
      .map((fixture) => fixture.questionId)
      .toSet()
      .length;
  if (archetypeCount < 12) {
    throw StateError(
      'Block 10 requires at least 12 archetypes; fixture has $archetypeCount.',
    );
  }
  final missingScenarioKinds = _requiredScenarioKinds.difference(
    selected.map((fixture) => fixture.scenarioKind).toSet(),
  );
  if (missingScenarioKinds.isNotEmpty) {
    throw StateError(
      'Block 10 fixture missing scenario kinds: ${missingScenarioKinds.join(', ')}',
    );
  }
  return selected;
}

List<_BenchmarkFixture> _defaultSmokeFixtures(
  List<_BenchmarkFixture> fixtures,
) {
  final selected = <_BenchmarkFixture>[];
  for (final seedBand in <String>[
    'clearly_mid',
    'borderline_senior',
    'clearly_senior',
  ]) {
    selected.add(
      fixtures.firstWhere(
        (fixture) => fixture.seedBand == seedBand,
        orElse: () => throw StateError(
          'Smoke mode requires a fixture with seed_band=$seedBand.',
        ),
      ),
    );
  }
  return selected;
}

List<List<_BenchmarkFixture>> _chunkFixtures(
  List<_BenchmarkFixture> fixtures,
  int? chunkSize,
) {
  if (chunkSize == null || chunkSize >= fixtures.length) {
    return <List<_BenchmarkFixture>>[fixtures];
  }
  return <List<_BenchmarkFixture>>[
    for (var index = 0; index < fixtures.length; index += chunkSize)
      fixtures.skip(index).take(chunkSize).toList(growable: false),
  ];
}

List<Map<String, Object?>> _loadRowCache(File file) {
  if (!file.existsSync()) return const <Map<String, Object?>>[];
  final rows = <Map<String, Object?>>[];
  for (final line in file.readAsLinesSync(encoding: utf8)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    final decoded = jsonDecode(trimmed);
    if (decoded is Map<String, Object?>) {
      rows.add(decoded);
    } else {
      throw FormatException('Row cache line must be a JSON object: $trimmed');
    }
  }
  return rows;
}

void _appendRowCache(File file, Map<String, Object?> row) {
  file.writeAsStringSync(
    '${jsonEncode(row)}\n',
    encoding: utf8,
    mode: FileMode.append,
  );
}

Set<String> _cachedAnswerIdsByFailureClass(
  List<Map<String, Object?>> rows,
  String failureClass,
) {
  return <String>{
    for (final row in _latestCachedRows(rows).values)
      if (row['failure_class'] == failureClass && row['answer_id'] is String)
        row['answer_id']! as String,
  };
}

List<Map<String, Object?>> _cachedCaliberRows(
  List<Map<String, Object?>> rows, {
  required Set<String> excludeAnswerIds,
  required Set<String> includeAnswerIds,
}) {
  return <Map<String, Object?>>[
    for (final row in _latestCachedRows(rows).values)
      if (row['status'] == 'valid' &&
          row['answer_id'] is String &&
          includeAnswerIds.contains(row['answer_id']) &&
          !excludeAnswerIds.contains(row['answer_id']))
        <String, Object?>{
          for (final entry in row.entries)
            if (!const <String>{'status', 'discrepancy'}.contains(entry.key))
              entry.key: entry.value,
        },
  ];
}

List<Map<String, Object?>> _loadKeyRows(File keyFile) {
  if (!keyFile.existsSync()) return const <Map<String, Object?>>[];
  final decoded = jsonDecode(keyFile.readAsStringSync(encoding: utf8));
  if (decoded is! Map<String, Object?>) {
    throw FormatException('Cached key file must contain a JSON object.');
  }
  final rows = decoded['rows'];
  if (rows is! List<Object?>) {
    throw FormatException('Cached key file missing rows list: ${keyFile.path}');
  }
  final parsed = <Map<String, Object?>>[];
  for (final item in rows) {
    if (item is! Map<String, Object?>) {
      throw FormatException('Cached key row must be a JSON object.');
    }
    parsed.add(item);
  }
  return parsed;
}

List<Map<String, Object?>> _loadCostRows(File costFile, String key) {
  if (!costFile.existsSync()) return const <Map<String, Object?>>[];
  final decoded = jsonDecode(costFile.readAsStringSync(encoding: utf8));
  if (decoded is! Map<String, Object?>) return const <Map<String, Object?>>[];
  final rows = decoded[key];
  if (rows is! List<Object?>) return const <Map<String, Object?>>[];
  return <Map<String, Object?>>[
    for (final item in rows)
      if (item is Map<String, Object?>) item,
  ];
}

List<Map<String, Object?>> _cachedInvalidRows(
  List<Map<String, Object?>> rows, {
  required Set<String> excludeAnswerIds,
}) {
  return <Map<String, Object?>>[
    for (final row in _latestCachedRows(rows).values)
      if (row['status'] != 'valid' &&
          row['answer_id'] is String &&
          !excludeAnswerIds.contains(row['answer_id']))
        row,
  ];
}

Map<String, Map<String, Object?>> _latestCachedRows(
  List<Map<String, Object?>> rows,
) {
  final latest = <String, Map<String, Object?>>{};
  for (final row in rows) {
    final answerId = row['answer_id'];
    if (answerId is String && answerId.trim().isNotEmpty) {
      latest[answerId] = row;
    }
  }
  return latest;
}

void _assertBaselineOnlyCaliberCache({
  required File rowCacheFile,
  required List<Map<String, Object?>> rows,
  required List<_BenchmarkFixture> answers,
}) {
  if (!rowCacheFile.existsSync()) {
    throw StateError(
      'Baseline-only mode requires existing Caliber row cache: '
      '${rowCacheFile.path}',
    );
  }
  final latest = _latestCachedRows(rows);
  final missing = <String>[];
  final malformed = <String, List<String>>{};
  for (final fixture in answers) {
    final row = latest[fixture.answerId];
    if (row == null || row['status'] != 'valid') {
      missing.add(fixture.answerId);
      continue;
    }
    final failures = _validateCachedCaliberRow(row, fixture);
    if (failures.isNotEmpty) {
      malformed[fixture.answerId] = failures;
    }
  }
  missing.sort();
  if (missing.isNotEmpty) {
    throw StateError(
      'Baseline-only mode cannot run until Caliber cache has valid rows for: '
      '${missing.join(', ')}',
    );
  }
  if (malformed.isNotEmpty) {
    throw StateError(
      'Baseline-only mode requires Caliber cache schema '
      '$block10CaliberRowCacheSchemaVersion with full verdict text. Invalid rows: '
      '${jsonEncode(malformed)}',
    );
  }
}

List<String> _validateCachedCaliberRow(
  Map<String, Object?> row,
  _BenchmarkFixture fixture,
) {
  final failures = <String>[];
  failures.addAll(
    validateBlock10CachedCaliberRow(
      row: row,
      expectedAnswerId: fixture.answerId,
      expectedQuestionId: fixture.questionId,
    ),
  );
  return failures.toSet().toList(growable: false)..sort();
}

List<_CaliberLaneResult> _caliberResultsFromCache(
  List<Map<String, Object?>> rows, {
  required List<_BenchmarkFixture> answers,
}) {
  final rowByAnswerId = <String, Map<String, Object?>>{
    for (final row in rows)
      if (row['answer_id'] is String) row['answer_id']! as String: row,
  };
  return <_CaliberLaneResult>[
    for (final fixture in answers)
      _cachedCaliberResult(fixture, rowByAnswerId[fixture.answerId]!),
  ];
}

_CaliberLaneResult _cachedCaliberResult(
  _BenchmarkFixture fixture,
  Map<String, Object?> row,
) {
  return _CaliberLaneResult(
    fixture: fixture,
    question: _questionForFixture(fixture),
    judgment: null,
    modelId: row['caliber_model_id']! as String,
    levelBand: row['caliber_band']! as String,
    verdictText: row['caliber_verdict_text']! as String,
    highestLeverageFix: row['caliber_highest_leverage_fix']! as String,
  );
}

Set<String> _cachedValidBlindAnswerIds(
  List<Map<String, Object?>> rows, {
  required Set<String> excludeAnswerIds,
}) {
  return <String>{
    for (final entry in _latestCachedRows(rows).entries)
      if (entry.value['status'] == 'valid' &&
          !excludeAnswerIds.contains(entry.key))
        entry.key,
  };
}

void _restoreCachedBlindRows(
  List<Map<String, Object?>> rows, {
  required List<_BenchmarkFixture> answers,
  required Set<String> excludedAnswerIds,
  required List<Map<String, Object?>> cachedKeyRows,
  required List<Map<String, Object?>> cachedBaselineCosts,
  required List<Map<String, Object?>> cachedFallbackRows,
  required List<_BlindCase> cases,
  required List<Map<String, Object?>> keyRows,
  required List<Map<String, Object?>> baselineCosts,
  required List<Map<String, Object?>> fallbackRows,
}) {
  final fixtureById = <String, _BenchmarkFixture>{
    for (final fixture in answers) fixture.answerId: fixture,
  };
  final keyRowByAnswerId = <String, Map<String, Object?>>{
    for (final row in cachedKeyRows)
      if (row['answer_id'] is String) row['answer_id']! as String: row,
  };
  final baselineCostsByAnswerId = _rowsByAnswerId(cachedBaselineCosts);
  final fallbackRowsByAnswerId = _rowsByAnswerId(cachedFallbackRows);
  for (final entry in _latestCachedRows(rows).entries) {
    if (excludedAnswerIds.contains(entry.key)) continue;
    final row = entry.value;
    if (row['status'] != 'valid') continue;
    final fixture = fixtureById[entry.key];
    if (fixture == null) continue;
    final keyRow = keyRowByAnswerId[entry.key];
    if (keyRow == null) {
      throw StateError(
        'Cannot resume blind row ${entry.key}: hidden key row is missing. '
        'The blind row cache is intentionally label/text-only.',
      );
    }
    final blinded = _blindVerdictsFromJson(
      row['blinded_verdicts'],
      keyRow: keyRow,
    );
    final restoreFailures = _validateRestoredBlindRow(
      row: row,
      keyRow: keyRow,
      blinded: blinded,
    );
    if (restoreFailures.isNotEmpty) {
      throw StateError(
        'Cached blind row ${entry.key} failed restore validation: '
        '${restoreFailures.join(', ')}',
      );
    }
    cases.add(
      _BlindCase(
        fixture: fixture,
        question: _questionForFixture(fixture),
        blindedVerdicts: blinded,
      ),
    );
    keyRows.add(keyRow);
    baselineCosts.addAll(baselineCostsByAnswerId[entry.key] ?? const []);
    fallbackRows.addAll(fallbackRowsByAnswerId[entry.key] ?? const []);
  }
}

Map<String, List<Map<String, Object?>>> _rowsByAnswerId(
  List<Map<String, Object?>> rows,
) {
  final grouped = <String, List<Map<String, Object?>>>{};
  for (final row in rows) {
    final answerId = row['answer_id'];
    if (answerId is String && answerId.trim().isNotEmpty) {
      grouped.putIfAbsent(answerId, () => <Map<String, Object?>>[]).add(row);
    }
  }
  return grouped;
}

List<Map<String, Object?>> _blindVerdictsToJson(List<_BlindVerdict> verdicts) {
  return <Map<String, Object?>>[
    for (final verdict in verdicts)
      <String, Object?>{'label': verdict.label, 'text': verdict.text},
  ];
}

List<_BlindVerdict> _blindVerdictsFromJson(
  Object? value, {
  required Map<String, Object?> keyRow,
}) {
  if (value is! List<Object?>) {
    throw FormatException('Cached blind verdicts must be a JSON list.');
  }
  if (value.length != 3) {
    throw FormatException('Cached blind verdicts must contain exactly 3 rows.');
  }
  final labels = keyRow['labels'];
  final models = keyRow['models'];
  if (labels is! Map<String, Object?> || models is! Map<String, Object?>) {
    throw FormatException('Cached key row must include labels and models.');
  }
  final verdicts = <_BlindVerdict>[];
  for (final item in value) {
    if (item is! Map<String, Object?>) {
      throw FormatException('Cached blind verdict item must be a JSON object.');
    }
    final label = _cachedBlindString(item, 'label');
    final source = _cachedSourceForLabel(labels, label);
    verdicts.add(
      _BlindVerdict(
        label: label,
        source: source,
        modelId: _cachedModelForSource(models, source),
        text: _cachedBlindString(item, 'text'),
      ),
    );
  }
  return verdicts;
}

String _cachedBlindString(Map<String, Object?> item, String key) {
  if (item.containsKey('source') || item.containsKey('model_id')) {
    throw FormatException('Blind row cache must not contain source/model ids.');
  }
  final value = item[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Cached blind verdict missing $key.');
  }
  return value.trim();
}

String _cachedSourceForLabel(Map<String, Object?> labels, String label) {
  final source = labels[label];
  if (source is! String || source.trim().isEmpty) {
    throw FormatException('Cached key row missing source for label $label.');
  }
  return source.trim();
}

String _cachedModelForSource(Map<String, Object?> models, String source) {
  final modelId = models[source];
  if (modelId is! String || modelId.trim().isEmpty) {
    throw FormatException('Cached key row missing model for source $source.');
  }
  return modelId.trim();
}

List<String> _validateRestoredBlindRow({
  required Map<String, Object?> row,
  required Map<String, Object?> keyRow,
  required List<_BlindVerdict> blinded,
}) {
  final failures = <String>[...validateBlock10BlindCacheRow(row)];
  if (!_blindVerdictsAreDistinct(blinded)) {
    failures.add('three_distinct_verdict_slots');
  }
  if (blinded.map((verdict) => verdict.text).toSet().length != 3) {
    failures.add('cloned_verdict_text');
  }
  if (!_hasThreeDistinctVerdictSlots(keyRow)) {
    failures.add('hidden_key_distinct_slots');
  }
  final labels = keyRow['labels'];
  if (labels is Map<String, Object?>) {
    final labelSet = labels.keys.toSet();
    final blindLabelSet = blinded.map((verdict) => verdict.label).toSet();
    if (labelSet.length != 3 || !labelSet.containsAll(blindLabelSet)) {
      failures.add('label_mismatch');
    }
  }
  return failures;
}

int _expectedCaliberRowCount({
  required List<Map<String, Object?>> cachedCaliberRows,
  required List<_BenchmarkFixture> selectedAnswers,
}) {
  return <String>{
    for (final row in cachedCaliberRows)
      if (row['answer_id'] is String) row['answer_id']! as String,
    for (final answer in selectedAnswers) answer.answerId,
  }.length;
}

Map<String, Object?> _classifiedInvalidRow(Map<String, Object?> row) {
  return <String, Object?>{
    'status': 'invalid',
    ...row,
    'failure_class': _failureClassFor(row),
  };
}

String _failureClassFor(Map<String, Object?> row) {
  final reason = row['reason']?.toString() ?? '';
  final category = row['failure_category']?.toString() ?? '';
  final error = row['error']?.toString() ?? '';
  if (reason.startsWith('baseline_')) return 'baseline_failure';
  if (category == 'provider_error' ||
      error.contains('GatewayTransportException') ||
      error.toLowerCase().contains('timeout')) {
    return 'transport_failure';
  }
  return 'calibration_failure';
}

const _requiredScenarioKinds = <String>{
  'system_design',
  'low_level_design',
  'debugging_code_review',
  'concurrency_productionization',
  'incident_reasoning',
  'project_deep_dive',
  'behavioral_leadership',
  'ai_in_the_loop_verification',
};

InterviewPracticeQuestion _questionForFixture(_BenchmarkFixture fixture) {
  final question = backendDepthPracticeQuestionFor(fixture.questionId);
  if (question.questionId != fixture.questionId) {
    throw StateError(
      'Fixture ${fixture.answerId} references unresolved question_id '
      '${fixture.questionId}.',
    );
  }
  return question;
}

String _renderCaliberVerdict(InterviewContentJudgment judgment) {
  final buffer = StringBuffer()
    ..writeln('Level read: ${judgment.levelBand}')
    ..writeln()
    ..writeln('Strengths:')
    ..writeln(_bullets(judgment.strengths))
    ..writeln()
    ..writeln('Down-level risks:')
    ..writeln(_bullets(judgment.risks))
    ..writeln()
    ..writeln('Highest-leverage next fix:')
    ..writeln(_bullets(judgment.recommendedActions))
    ..writeln()
    ..writeln('Evidence mapped to rubric:');
  for (final span in judgment.evidenceSpans) {
    buffer.writeln(
      '- ${span.metadata['criterion_label'] ?? span.metadata['criterion_id'] ?? 'criterion'}: '
      '"${span.quote ?? ''}"',
    );
    final reason = span.metadata['down_level_reason'];
    final fix = span.metadata['minimum_fix'];
    if (reason is String && reason.trim().isNotEmpty) {
      buffer.writeln('  Why: $reason');
    }
    if (fix is String && fix.trim().isNotEmpty) {
      buffer.writeln('  Fix: $fix');
    }
  }
  return buffer.toString().trim();
}

String _bullets(List<String> items) {
  if (items.isEmpty) return '- None returned.';
  return items.map((item) => '- $item').join('\n');
}

String _highestLeverageFix(InterviewContentJudgment judgment) {
  final actions = judgment.recommendedActions
      .map((action) => action.replaceAll(RegExp(r'\s+'), ' ').trim())
      .where((action) => action.isNotEmpty)
      .toList(growable: false);
  if (actions.length == 1 && !isGenericBlock10Fix(actions.single)) {
    return actions.single;
  }
  throw StateError(
    'Caliber verdict ${judgment.judgmentId} returned no specific fix.',
  );
}

String? _debugInvalidReason(Map<String, Object?> row) {
  final category = row['failure_category'];
  if (category is String && category.trim().isNotEmpty) {
    return category;
  }
  final reason = row['reason'];
  if (reason is String && reason.trim().isNotEmpty) {
    return reason;
  }
  return null;
}

List<String> _validateCaliberJudgment(
  _BenchmarkFixture fixture,
  InterviewPracticeQuestion question,
  InterviewContentJudgment judgment,
) {
  final validation = validateBlock10CaliberJudgment(
    scenario: corpus.kBackendDepthRubric.scenarioForQuestion(
      question.questionId,
    ),
    answer: fixture.candidateAnswer,
    judgment: judgment,
  );
  return validation.failures;
}

Map<String, Object?> _discrepancyRow(
  _BenchmarkFixture fixture,
  InterviewContentJudgment judgment,
) {
  final providerBand = _providerSuggestedBand(judgment);
  final deterministicBand = _deterministicLevelBand(judgment);
  final reasons = <String>[
    if (providerBand != deterministicBand)
      'provider_suggested_band_overridden_by_deterministic_policy',
    if (fixture.seedBand == 'clearly_mid' &&
        const <String>{'at_bar', 'above_bar'}.contains(deterministicBand))
      'seed_band_mid_inflation',
    if (fixture.seedBand == 'clearly_senior' &&
        deterministicBand == 'below_bar')
      'seed_band_senior_deflation',
  ];
  return <String, Object?>{
    'fixture_id': fixture.answerId,
    'seed_band': fixture.seedBand,
    'deterministic_band': deterministicBand,
    'provider_suggested_band': providerBand,
    'criterion_marks': _criterionMarksFor(judgment),
    'exact_quotes': <String>[
      for (final span in judgment.evidenceSpans)
        if ((span.quote ?? '').trim().isNotEmpty) span.quote!.trim(),
    ],
    'reason_for_mismatch': reasons.isEmpty ? 'no_mismatch' : reasons.join(','),
  };
}

String _providerSuggestedBand(InterviewContentJudgment judgment) {
  return _metadataBand(judgment, 'provider_suggested_band') ??
      judgment.levelBand;
}

String _deterministicLevelBand(InterviewContentJudgment judgment) {
  return _metadataBand(judgment, 'deterministic_level_band') ??
      judgment.levelBand;
}

String? _metadataBand(InterviewContentJudgment judgment, String key) {
  for (final span in judgment.evidenceSpans) {
    final value = span.metadata[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

List<Map<String, Object?>> _criterionMarksFor(
  InterviewContentJudgment judgment,
) {
  return <Map<String, Object?>>[
    for (var index = 0; index < judgment.evidenceSpans.length; index += 1)
      <String, Object?>{
        'criterion_id': judgment.evidenceSpans[index].metadata['criterion_id'],
        'criterion_label':
            judgment.evidenceSpans[index].metadata['criterion_label'],
        'status': judgment.evidenceSpans[index].metadata['criterion_status'],
        'exact_quote': judgment.evidenceSpans[index].quote,
      },
  ];
}

List<Map<String, Object?>> _duplicateFixLines(Map<String, String> fixes) {
  final ownersByFix = <String, List<String>>{};
  for (final entry in fixes.entries) {
    ownersByFix
        .putIfAbsent(entry.value.toLowerCase(), () => <String>[])
        .add(entry.key);
  }
  return <Map<String, Object?>>[
    for (final entry in ownersByFix.entries)
      if (entry.value.length > 1)
        <String, Object?>{
          'fix': fixes[entry.value.first],
          'answer_ids': entry.value..sort(),
        },
  ];
}

bool _costRecorded({
  required int validRows,
  required List<String> baselineProviders,
  required Map<String, Object?> caliberTokenDelta,
  required List<Map<String, Object?>> baselineCosts,
}) {
  if (validRows == 0) return false;
  final caliberHasTokens = <String>[
    'prompt_tokens',
    'estimated_prompt_tokens',
    'completion_tokens',
    'estimated_completion_tokens',
    'total_tokens',
    'estimated_total_tokens',
  ].any((key) => ((caliberTokenDelta[key] as num?) ?? 0) > 0);
  if (!caliberHasTokens) return false;
  final costsByProvider = <String, int>{};
  for (final row in baselineCosts) {
    final provider = row['provider'];
    if (provider is! String) continue;
    final hasTokens = <String>[
      'prompt_tokens',
      'estimated_prompt_tokens',
      'completion_tokens',
      'estimated_completion_tokens',
      'total_tokens',
      'estimated_total_tokens',
    ].any((key) => ((row[key] as num?) ?? 0) > 0);
    final hasCost = row['estimated_cost_usd'] is num;
    if (hasTokens && hasCost) {
      costsByProvider.update(provider, (count) => count + 1, ifAbsent: () => 1);
    }
  }
  return baselineProviders.every(
    (provider) => (costsByProvider[provider] ?? 0) == validRows,
  );
}

bool _caliberCostRecorded(Map<String, Object?> caliberTokenDelta) {
  return <String>[
    'prompt_tokens',
    'estimated_prompt_tokens',
    'completion_tokens',
    'estimated_completion_tokens',
    'total_tokens',
    'estimated_total_tokens',
  ].any((key) => ((caliberTokenDelta[key] as num?) ?? 0) > 0);
}

bool invalidRowsContain(List<Map<String, Object?>> invalidRows, String needle) {
  return invalidRows.any((row) => row['failures'].toString().contains(needle));
}

Map<String, Object?> _safeErrorFields(Object error) {
  if (error is GatewayHttpException) {
    final parsed = _decodeGatewayFailure(error.body);
    return <String, Object?>{
      'error': 'GatewayHttpException: HTTP ${error.statusCode}',
      if (parsed['failure_category'] != null)
        'failure_category': parsed['failure_category'],
      if (parsed['debug_artifact'] != null)
        'debug_artifact': parsed['debug_artifact'],
    };
  }
  if (error is GatewayTransportException) {
    return <String, Object?>{
      'error': 'GatewayTransportException after ${error.attempts} attempts',
      'failure_category': 'provider_error',
    };
  }
  return <String, Object?>{'error': error.toString()};
}

Map<String, Object?> _safeBaselineErrorFields(Object error) {
  return <String, Object?>{
    'error': redactBlock10ProviderError(error),
    'failure_category': _baselineFailureCategory(error),
  };
}

String _baselineFailureCategory(Object error) {
  final text = error.toString().toLowerCase();
  if (text.contains('429') || text.contains('rate_limit')) {
    return 'rate_limited';
  }
  if (text.contains('timeout') || text.contains('timed out')) {
    return 'timeout';
  }
  if (text.contains('benchmark_provider_key_missing') ||
      text.contains('need provider key')) {
    return 'missing_provider_key';
  }
  if (text.contains('benchmark_provider_model_missing')) {
    return 'missing_model_slug';
  }
  if (text.contains('non_distinct')) return 'non_distinct_verdict_slots';
  return 'provider_error';
}

Map<String, Object?> _decodeGatewayFailure(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, Object?>) {
      return const <String, Object?>{};
    }
    final detail = decoded['detail'];
    if (detail is Map<String, Object?>) {
      return <String, Object?>{
        'failure_category': detail['failure_category'],
        'debug_artifact': detail['debug_artifact'],
      };
    }
  } on Object {
    return const <String, Object?>{};
  }
  return const <String, Object?>{};
}

String _statusForRun({
  required bool fullPacketMode,
  required bool caliberSmokeOnly,
  required bool gatePassed,
}) {
  if (!gatePassed) {
    return fullPacketMode ? 'blocked_until_baselines_complete' : 'fail';
  }
  if (fullPacketMode) return 'blocked_until_block_10_5_code_rereview';
  if (caliberSmokeOnly) return 'caliber_smoke_passed';
  return 'caliber_only_passed_ready_for_baselines';
}

void _enforceCostGuard({
  required int rowCount,
  required int caliberCallCount,
  required int baselineCount,
}) {
  final projectedCalls = rowCount * (caliberCallCount + baselineCount);
  final maxProviderCalls = _optionalIntEnv(
    'CALIBER_BLOCK10_MAX_PROVIDER_CALLS',
  );
  if (maxProviderCalls != null && projectedCalls > maxProviderCalls) {
    throw StateError(
      'Projected Block 10 provider calls ($projectedCalls) exceed '
      'CALIBER_BLOCK10_MAX_PROVIDER_CALLS=$maxProviderCalls.',
    );
  }

  final projectedCostUsd = _projectedBlock10CostUsd(
    rowCount: rowCount,
    caliberCallCount: caliberCallCount,
    baselineCount: baselineCount,
  );
  final maxCostUsd = _optionalDoubleEnv(
    'CALIBER_BLOCK10_MAX_ESTIMATED_COST_USD',
  );
  if (maxCostUsd != null && projectedCostUsd > maxCostUsd) {
    throw StateError(
      'Projected Block 10 cost (\$${projectedCostUsd.toStringAsFixed(4)}) '
      'exceeds CALIBER_BLOCK10_MAX_ESTIMATED_COST_USD='
      '${maxCostUsd.toStringAsFixed(4)}.',
    );
  }
}

double _projectedBlock10CostUsd({
  required int rowCount,
  required int caliberCallCount,
  required int baselineCount,
}) {
  const conservativeCostPerProviderCallUsd = 0.008;
  return rowCount *
      (caliberCallCount + baselineCount) *
      conservativeCostPerProviderCallUsd;
}

int? _optionalIntEnv(String name) {
  final raw = Platform.environment[name]?.trim();
  if (raw == null || raw.isEmpty) return null;
  final parsed = int.tryParse(raw);
  if (parsed == null || parsed < 0) {
    throw ArgumentError.value(raw, name, 'Must be a non-negative integer.');
  }
  return parsed;
}

double? _optionalDoubleEnv(String name) {
  final raw = Platform.environment[name]?.trim();
  if (raw == null || raw.isEmpty) return null;
  final parsed = double.tryParse(raw);
  if (parsed == null || parsed < 0) {
    throw ArgumentError.value(raw, name, 'Must be a non-negative number.');
  }
  return parsed;
}

List<_BlindVerdict> _blind(List<_SourceVerdict> verdicts, String answerId) {
  final rotated = List<_SourceVerdict>.of(verdicts);
  final shift = _stableNumber(answerId) % rotated.length;
  for (var index = 0; index < shift; index += 1) {
    rotated.add(rotated.removeAt(0));
  }
  if (_stableNumber('$answerId:reverse').isOdd) {
    rotated.setAll(0, rotated.reversed.toList(growable: false));
  }
  const labels = <String>['A', 'B', 'C', 'D', 'E', 'F'];
  return <_BlindVerdict>[
    for (var index = 0; index < rotated.length; index += 1)
      _BlindVerdict(
        label: labels[index],
        source: rotated[index].source,
        modelId: rotated[index].modelId,
        text: rotated[index].text,
      ),
  ];
}

bool _blindVerdictsAreDistinct(List<_BlindVerdict> blinded) {
  return blinded.length == 3 &&
      blinded.map((verdict) => verdict.label).toSet().length == 3 &&
      blinded.map((verdict) => verdict.source).toSet().length == 3 &&
      blinded.map((verdict) => verdict.modelId).toSet().length == 3;
}

bool _hasThreeDistinctVerdictSlots(Map<String, Object?> row) {
  final labels = row['labels'];
  final models = row['models'];
  if (labels is! Map<String, Object?> || models is! Map<String, Object?>) {
    return false;
  }
  final labelSources = labels.values.whereType<String>().toList();
  final modelIds = models.values.whereType<String>().toList();
  return labels.length == 3 &&
      models.length == 3 &&
      labelSources.length == 3 &&
      labelSources.toSet().length == 3 &&
      modelIds.length == 3 &&
      modelIds.toSet().length == 3;
}

String _renderBlindMarkdown({
  required String runId,
  required List<_BlindCase> cases,
  required int totalRows,
  required int invalidRows,
}) {
  final buffer = StringBuffer()
    ..writeln('# Caliber Block 10 Blind Benchmark')
    ..writeln()
    ..writeln('Run: `$runId`')
    ..writeln('Total rows: $totalRows')
    ..writeln('Valid rated rows: ${cases.length}')
    ..writeln('Invalid excluded rows: $invalidRows')
    ..writeln()
    ..writeln('Do not open the matching `_key.json` file until after rating.')
    ..writeln()
    ..writeln('Reviewer task:')
    ..writeln(
      '- Rate which verdict is more specific, more correct, and more faithful to the candidate evidence.',
    )
    ..writeln('- Mark which verdict you would pay for, if any.')
    ..writeln('- Flag hallucinated, unsupported, or unfair critiques.')
    ..writeln()
    ..writeln('## Senior Reviewer Quick Sheet')
    ..writeln()
    ..writeln('| Answer | Most diagnostic/actionable | Would pay for | Notes |')
    ..writeln('|---|---|---|---|');
  for (final item in cases) {
    buffer.writeln('| `${item.fixture.answerId}` |  |  |  |');
  }
  buffer
    ..writeln()
    ..writeln('## Blind Cases');
  for (final item in cases) {
    buffer
      ..writeln()
      ..writeln('### ${item.fixture.answerId}')
      ..writeln()
      ..writeln('**Question:** ${item.question.prompt}')
      ..writeln()
      ..writeln('**Candidate answer:**')
      ..writeln()
      ..writeln(item.fixture.candidateAnswer)
      ..writeln();
    for (final verdict in item.blindedVerdicts) {
      buffer
        ..writeln('#### Verdict ${verdict.label}')
        ..writeln()
        ..writeln(verdict.text)
        ..writeln();
    }
  }
  return buffer.toString();
}

String _renderSeniorReviewerScoringSheet({
  required String runId,
  required List<_BlindCase> cases,
}) {
  final buffer = StringBuffer()
    ..writeln('# Senior Reviewer Scoring Sheet')
    ..writeln()
    ..writeln('Run: `$runId`')
    ..writeln()
    ..writeln(
      'Open this alongside the blind packet. Do not open the key file until rating is complete.',
    )
    ..writeln()
    ..writeln(
      '| Answer | More specific | More correct | Better evidence fidelity | Would pay for | Hallucinated or unfair critique? | Reviewer notes |',
    )
    ..writeln('|---|---|---|---|---|---|---|');
  for (final item in cases) {
    buffer.writeln('| `${item.fixture.answerId}` |  |  |  |  |  |  |');
  }
  buffer
    ..writeln()
    ..writeln('## Field Definitions')
    ..writeln()
    ..writeln(
      '- More specific: which verdict names the concrete missing/strong behavior most clearly.',
    )
    ..writeln(
      '- More correct: which verdict best matches a senior Backend interview rubric.',
    )
    ..writeln(
      '- Better evidence fidelity: which verdict cites the candidate answer most faithfully.',
    )
    ..writeln(
      '- Would pay for: which verdict would justify a paid calibration product.',
    )
    ..writeln(
      '- Hallucinated or unfair critique: note any claim unsupported by the answer.',
    )
    ..writeln(
      '- Reviewer notes: brief rationale or edge cases for adjudication.',
    );
  return buffer.toString();
}

String _stripTrailingWhitespace(String value) {
  final lines = const LineSplitter()
      .convert(value)
      .map((line) => line.trimRight())
      .toList();
  return '${lines.join('\n')}\n';
}

Future<List<Map<String, Object?>>> _runBaselineConnectivitySmoke({
  required _GatewayBenchmarkClient gateway,
  required List<String> baselines,
  required List<_BenchmarkFixture> answers,
  required int delayMs,
}) async {
  if (answers.isEmpty) {
    throw StateError(
      'Baseline connectivity smoke requires at least one fixture.',
    );
  }
  final seedFixture = answers.first;
  final question = _questionForFixture(seedFixture);
  final smokeFixture = _BenchmarkFixture(
    answerId: 'baseline_connectivity_smoke',
    questionId: seedFixture.questionId,
    archetypeId: seedFixture.archetypeId,
    prompt: seedFixture.prompt,
    candidateAnswer:
        'I would clarify the requirements, describe one tradeoff, and name the main operational risk.',
    seedBand: seedFixture.seedBand,
    scenarioKind: seedFixture.scenarioKind,
    expectedRubricMarks: seedFixture.expectedRubricMarks,
    rationaleForSeedBand: seedFixture.rationaleForSeedBand,
    provenanceNote: seedFixture.provenanceNote,
  );
  final rows = <Map<String, Object?>>[];
  stdout.writeln('Baseline connectivity smoke: ${baselines.join(', ')}');
  for (final provider in baselines) {
    try {
      final response = await gateway.genericFeedback(
        provider: provider,
        fixture: smokeFixture,
        question: question,
      );
      rows.add(<String, Object?>{
        'provider': provider,
        'status': 'ok',
        'model_id': response.modelId,
        'failure_category': null,
        'cost': response.costRow,
      });
      stdout.writeln('Baseline smoke $provider: ok model=${response.modelId}');
    } on Object catch (error) {
      final row = <String, Object?>{
        'provider': provider,
        'status': 'failed',
        ..._safeBaselineErrorFields(error),
      };
      rows.add(row);
      stdout.writeln(
        'Baseline smoke $provider: failed category=${row['failure_category']}',
      );
    }
    if (provider.startsWith('openrouter') && delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
  }
  final failures = rows
      .where((row) => row['status'] == 'failed')
      .toList(growable: false);
  if (failures.isNotEmpty) {
    throw StateError(
      'Baseline connectivity smoke failed: ${jsonEncode(failures)}',
    );
  }
  return rows;
}

Map<String, Object?> _readGatewayTokenSummary(Directory repoRoot) {
  final configuredCacheRoot = Platform
      .environment['CALIBER_AI_GATEWAY_CACHE_ROOT']
      ?.trim();
  final cacheRoot = configuredCacheRoot == null || configuredCacheRoot.isEmpty
      ? repoRoot.directory('.cache/ai_gateway')
      : Directory(configuredCacheRoot);
  final file = cacheRoot.file('token_usage_summary.json');
  if (!file.existsSync()) {
    return <String, Object?>{};
  }
  final decoded = jsonDecode(file.readAsStringSync());
  return decoded is Map<String, Object?> ? decoded : <String, Object?>{};
}

Map<String, Object?> _readCaliberTokenDeltaForRun(
  Directory outputDir,
  String runId,
) {
  final file = outputDir.file('blind_ab_${runId}_cost.json');
  if (!file.existsSync()) return <String, Object?>{};
  final decoded = jsonDecode(file.readAsStringSync(encoding: utf8));
  if (decoded is! Map<String, Object?>) return <String, Object?>{};
  final delta = decoded['caliber_gateway_token_delta'];
  return delta is Map<String, Object?> ? delta : <String, Object?>{};
}

Map<String, Object?> _summaryDelta(
  Map<String, Object?> before,
  Map<String, Object?> after,
) {
  final beforeTotals = _totals(before);
  final afterTotals = _totals(after);
  return <String, Object?>{
    for (final key in afterTotals.keys)
      key: (afterTotals[key] ?? 0) - (beforeTotals[key] ?? 0),
  };
}

Map<String, Object?> _summaryDeltaForModel(
  Map<String, Object?> before,
  Map<String, Object?> after,
  String modelId,
) {
  final beforeBucket = _modelBucket(before, modelId);
  final afterBucket = _modelBucket(after, modelId);
  return <String, Object?>{
    for (final key in _tokenBucketKeys)
      key: (afterBucket[key] ?? 0) - (beforeBucket[key] ?? 0),
  };
}

Map<String, int> _modelBucket(Map<String, Object?> summary, String modelId) {
  final byModel = summary['by_model'];
  if (byModel is! Map<String, Object?>) return _zeroTokenBucket();
  final raw = byModel[modelId];
  if (raw is! Map<String, Object?>) return _zeroTokenBucket();
  return <String, int>{
    for (final entry in raw.entries)
      if (entry.value is num) entry.key: (entry.value as num).toInt(),
  };
}

Map<String, int> _totals(Map<String, Object?> summary) {
  final raw = summary['totals'];
  if (raw is! Map<String, Object?>) {
    return <String, int>{};
  }
  return <String, int>{
    for (final entry in raw.entries)
      if (entry.value is num) entry.key: (entry.value as num).toInt(),
  };
}

const _tokenBucketKeys = <String>[
  'cache_hits',
  'provider_calls',
  'estimated_prompt_tokens',
  'estimated_completion_tokens',
  'estimated_total_tokens',
  'prompt_tokens',
  'completion_tokens',
  'total_tokens',
  'cache_saved_estimated_tokens',
];

Map<String, int> _zeroTokenBucket() => <String, int>{
  for (final key in _tokenBucketKeys) key: 0,
};

Map<String, Object?> _zeroCaliberCallProof({
  required Map<String, Object?> before,
  required Map<String, Object?> after,
  required Map<String, Object?> currentCaliberTokenDelta,
}) {
  final zero = _tokenBucketKeys.every(
    (key) => ((currentCaliberTokenDelta[key] as num?) ?? 0) == 0,
  );
  return <String, Object?>{
    'caliber_model_id': block10ProductJudgeModelId,
    'passes': zero,
    'before_model_bucket': _modelBucket(before, block10ProductJudgeModelId),
    'after_model_bucket': _modelBucket(after, block10ProductJudgeModelId),
    'current_invocation_caliber_token_delta': currentCaliberTokenDelta,
  };
}

double _costFromGatewaySummary(Map<String, Object?> delta) {
  final promptTokens = _tokenMetric(
    delta,
    'prompt_tokens',
    'estimated_prompt_tokens',
  );
  final completionTokens = _tokenMetric(
    delta,
    'completion_tokens',
    'estimated_completion_tokens',
  );
  return ((promptTokens * 1.0) + (completionTokens * 4.5)) / 1000000;
}

Map<String, Object?> _tokenEconomics(
  Map<String, Object?> delta, {
  required int measuredRows,
  required int proofValidRows,
  required String tokenDeltaScope,
}) {
  final promptTokens = _tokenMetric(
    delta,
    'prompt_tokens',
    'estimated_prompt_tokens',
  );
  final completionTokens = _tokenMetric(
    delta,
    'completion_tokens',
    'estimated_completion_tokens',
  );
  final totalTokens = _tokenMetric(
    delta,
    'total_tokens',
    'estimated_total_tokens',
  );
  final providerCalls = ((delta['provider_calls'] as num?) ?? measuredRows)
      .toInt();
  final estimatedCostUsd = _costFromGatewaySummary(delta);
  final perVerdictCost = measuredRows == 0
      ? 0.0
      : estimatedCostUsd / measuredRows;
  final perVerdictTokens = measuredRows == 0 ? 0.0 : totalTokens / measuredRows;
  return <String, Object?>{
    'valid_rows_measured': measuredRows,
    'proof_valid_rows': proofValidRows,
    'token_delta_scope': tokenDeltaScope,
    'provider_calls_measured': providerCalls,
    'prompt_tokens_measured_or_estimated': promptTokens,
    'completion_tokens_measured_or_estimated': completionTokens,
    'total_tokens_measured_or_estimated': totalTokens,
    'estimated_cost_usd': estimatedCostUsd,
    'avg_tokens_per_verdict': perVerdictTokens,
    'avg_cost_usd_per_verdict': perVerdictCost,
    'avg_cost_usd_per_provider_call': providerCalls == 0
        ? 0.0
        : estimatedCostUsd / providerCalls,
    'pricing_assumptions_usd_per_million_tokens': <String, Object?>{
      'input': 1.0,
      'output': 4.5,
    },
    'verdict_volume_projections': <Map<String, Object?>>[
      for (final count in <int>[40, 100, 1000, 10000])
        <String, Object?>{
          'verdicts': count,
          'projected_total_tokens': (perVerdictTokens * count).round(),
          'projected_cost_usd': perVerdictCost * count,
        },
    ],
    'ninety_day_pass_cost_scenarios': <Map<String, Object?>>[
      for (final evals in <int>[5, 10, 20, 40])
        <String, Object?>{
          'evals_per_user': evals,
          'projected_inference_cost_usd': perVerdictCost * evals,
          'gross_margin_before_fixed_costs_on_49_usd_pass':
              49.0 - (perVerdictCost * evals),
        },
    ],
  };
}

int _tokenMetric(
  Map<String, Object?> delta,
  String actualKey,
  String estimatedKey,
) {
  final actualValue = ((delta[actualKey] as num?) ?? 0).toInt();
  if (actualValue > 0) return actualValue;
  return ((delta[estimatedKey] as num?) ?? 0).toInt();
}

int _stableNumber(String input) {
  var hash = 17;
  for (final unit in input.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

String _utcStamp(DateTime value) {
  String two(int input) => input.toString().padLeft(2, '0');
  return '${value.year}${two(value.month)}${two(value.day)}T'
      '${two(value.hour)}${two(value.minute)}${two(value.second)}Z';
}

Never _gateBlocked(String reason) {
  stderr.writeln('GATE BLOCKED: $reason');
  exit(2);
}

Directory _findRepoRoot(Directory start) {
  var current = start.absolute;
  while (true) {
    if (current.file('config/ai/provider_adapter.yaml').existsSync()) {
      return current;
    }
    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError(
        'Could not locate caliber repo root from ${start.path}.',
      );
    }
    current = parent;
  }
}

Directory _resolveOutputDir(Directory repoRoot, String? configuredPath) {
  if (configuredPath == null || configuredPath.trim().isEmpty) {
    return repoRoot.directory(_outputRelativeDir);
  }
  final path = configuredPath.trim();
  if (path.startsWith(Platform.pathSeparator)) {
    return Directory(path);
  }
  return repoRoot.directory(path);
}

extension on Directory {
  File file(String relativePath) =>
      File('${pathSegments(path).join('/')}/$relativePath');

  Directory directory(String relativePath) =>
      Directory('${pathSegments(path).join('/')}/$relativePath');
}

List<String> pathSegments(String path) {
  return path
      .split(Platform.pathSeparator)
      .where((part) => part.isNotEmpty)
      .toList()
    ..insert(0, '');
}

final class _GatewayBenchmarkClient {
  const _GatewayBenchmarkClient(this.baseUrl);

  final String baseUrl;

  Future<bool> isReady() async {
    try {
      final request = await HttpClient()
          .getUrl(Uri.parse('$baseUrl/openapi.json'))
          .timeout(const Duration(seconds: 2));
      final response = await request.close().timeout(
        const Duration(seconds: 2),
      );
      await response.drain<void>();
      return response.statusCode == 200;
    } on Object {
      return false;
    }
  }

  Future<_GenericFeedbackResponse> genericFeedback({
    required String provider,
    required _BenchmarkFixture fixture,
    required InterviewPracticeQuestion question,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client.postUrl(
        Uri.parse('$baseUrl/v1/benchmark/generic-feedback'),
      );
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode(<String, Object?>{
          'provider': provider,
          'answer_id': fixture.answerId,
          'question_id': fixture.questionId,
          'role': question.target.title ?? 'Backend Engineer',
          'question': question.prompt,
          'answer': fixture.candidateAnswer,
          'max_completion_tokens': 700,
        }),
      );
      final response = await request.close();
      final body = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (body.contains('benchmark_provider_key_missing')) {
          _gateBlocked('need provider key for benchmark provider $provider');
        }
        throw HttpException(
          'Benchmark provider $provider failed with HTTP ${response.statusCode}: $body',
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, Object?>) {
        throw FormatException('Benchmark response must be a JSON object.');
      }
      return _GenericFeedbackResponse.fromJson(decoded);
    } finally {
      client.close(force: true);
    }
  }
}

final class _BenchmarkOptions {
  const _BenchmarkOptions({
    this.gatewayBaseUrl,
    this.outputDirPath,
    this.limit,
    required this.startIndex,
    required this.fixtureIds,
    required this.caliberDebugOne,
    required this.caliberSmokeOnly,
    required this.keepGoingSmoke,
    required this.caliberOnly,
    required this.baselineOnly,
    this.caliberRunId,
    this.resumeRunId,
    this.chunkSize,
    required this.retryTransportFailuresOnly,
    required this.baselines,
    required this.openRouterDelayMs,
    required this.skipBaselineConnectivitySmoke,
  });

  final String? gatewayBaseUrl;
  final String? outputDirPath;
  final int? limit;
  final int startIndex;
  final List<String> fixtureIds;
  final bool caliberDebugOne;
  final bool caliberSmokeOnly;
  final bool keepGoingSmoke;
  final bool caliberOnly;
  final bool baselineOnly;
  final String? caliberRunId;
  final String? resumeRunId;
  final int? chunkSize;
  final bool retryTransportFailuresOnly;
  final List<String> baselines;
  final int openRouterDelayMs;
  final bool skipBaselineConnectivitySmoke;

  bool get callsBaselines =>
      !caliberDebugOne && !caliberSmokeOnly && !caliberOnly;
  bool get requiresTwoBaselines => callsBaselines;
  bool get runsBaselineConnectivitySmoke =>
      callsBaselines && !skipBaselineConnectivitySmoke;
  bool get isChunked =>
      startIndex != 0 ||
      limit != null ||
      fixtureIds.isNotEmpty ||
      retryTransportFailuresOnly;
  bool get requiresFullMatrix => !caliberSmokeOnly && !isChunked;
  String get runMode {
    if (caliberDebugOne) return 'caliber_debug_one';
    if (caliberSmokeOnly) return 'caliber_smoke_only';
    if (caliberOnly) return 'caliber_only';
    if (baselineOnly && isChunked) return 'baseline_only_chunk';
    if (baselineOnly) return 'baseline_only_full';
    if (isChunked) return 'blind_packet_chunk';
    return 'blind_packet_full';
  }

  String? get debugFixtureId =>
      caliberDebugOne && fixtureIds.length == 1 ? fixtureIds.single : null;

  static _BenchmarkOptions parse(List<String> args) {
    String? gatewayBaseUrl;
    String? outputDirPath;
    int? limit;
    var startIndex = 0;
    var fixtureIds = const <String>[];
    var caliberDebugOne = false;
    var caliberSmokeOnly = false;
    var keepGoingSmoke = false;
    var caliberOnly = false;
    var baselineOnly = false;
    String? caliberRunId;
    String? resumeRunId;
    int? chunkSize;
    var retryTransportFailuresOnly = false;
    var baselines = _baselineList(
      Platform.environment['CALIBER_GATE0_BASELINES'] ??
          'openrouter_baseline1,openrouter_baseline2',
    );
    var openRouterDelayMs = int.parse(
      Platform.environment['CALIBER_OPENROUTER_DELAY_MS'] ?? '3200',
    );
    var skipBaselineConnectivitySmoke = false;
    for (var index = 0; index < args.length; index += 1) {
      switch (args[index]) {
        case '--gateway':
          gatewayBaseUrl = args[++index];
        case '--output-dir':
          outputDirPath = args[++index];
        case '--limit':
          limit = int.parse(args[++index]);
        case '--start-index':
          startIndex = int.parse(args[++index]);
        case '--fixture-ids':
          fixtureIds = _csvList(args[++index]);
        case '--fixture-id':
          fixtureIds = <String>[args[++index].trim()];
        case '--caliber-debug-one':
          caliberDebugOne = true;
          caliberSmokeOnly = true;
        case '--caliber-smoke-only':
          caliberSmokeOnly = true;
        case '--keep-going-smoke':
          keepGoingSmoke = true;
        case '--caliber-only':
          caliberOnly = true;
        case '--baseline-only':
          baselineOnly = true;
        case '--caliber-run-id':
          caliberRunId = args[++index];
        case '--resume-run-id':
          resumeRunId = args[++index];
        case '--chunk-size':
          chunkSize = int.parse(args[++index]);
        case '--retry-transport-failures-only':
          retryTransportFailuresOnly = true;
        case '--baselines':
          baselines = _baselineList(args[++index]);
        case '--openrouter-delay-ms':
          openRouterDelayMs = int.parse(args[++index]);
        case '--skip-baseline-connectivity-smoke':
          skipBaselineConnectivitySmoke = true;
        case '--help':
          stdout.writeln(
            'Usage: dart run bin/backend_gate0_blind_benchmark.dart '
            '[--gateway http://127.0.0.1:8000] [--limit 40] '
            '[--output-dir 04_build/_benchmark] '
            '[--start-index 0] [--fixture-ids id1,id2] '
            '[--caliber-debug-one --fixture-id id1] '
            '[--caliber-smoke-only] [--keep-going-smoke] [--caliber-only] '
            '[--baseline-only --caliber-run-id 20260608T171511Z] '
            '[--resume-run-id 20260608T000000Z] [--chunk-size 5] '
            '[--retry-transport-failures-only] '
            '[--baselines openrouter_baseline1,openrouter_baseline2] '
            '[--openrouter-delay-ms 3200] '
            '[--skip-baseline-connectivity-smoke]',
          );
          exit(0);
        default:
          throw ArgumentError('Unknown argument: ${args[index]}');
      }
    }
    if (caliberSmokeOnly && caliberOnly) {
      throw ArgumentError(
        'Choose either --caliber-smoke-only or --caliber-only.',
      );
    }
    if (baselineOnly && (caliberOnly || caliberSmokeOnly)) {
      throw ArgumentError(
        '--baseline-only cannot be combined with Caliber-only smoke modes.',
      );
    }
    if (baselineOnly && (caliberRunId == null || caliberRunId.isEmpty)) {
      throw ArgumentError('--baseline-only requires --caliber-run-id.');
    }
    if (caliberDebugOne && fixtureIds.length != 1) {
      throw ArgumentError(
        '--caliber-debug-one requires exactly one --fixture-id.',
      );
    }
    if (chunkSize != null && chunkSize <= 0) {
      throw ArgumentError('--chunk-size must be positive.');
    }
    if (retryTransportFailuresOnly && resumeRunId == null) {
      throw ArgumentError(
        '--retry-transport-failures-only requires --resume-run-id.',
      );
    }
    return _BenchmarkOptions(
      gatewayBaseUrl: gatewayBaseUrl,
      outputDirPath: outputDirPath,
      limit: limit,
      startIndex: startIndex,
      fixtureIds: fixtureIds,
      caliberDebugOne: caliberDebugOne,
      caliberSmokeOnly: caliberSmokeOnly,
      keepGoingSmoke: keepGoingSmoke,
      caliberOnly: caliberOnly,
      baselineOnly: baselineOnly,
      caliberRunId: caliberRunId,
      resumeRunId: resumeRunId,
      chunkSize: chunkSize,
      retryTransportFailuresOnly: retryTransportFailuresOnly,
      baselines: baselines,
      openRouterDelayMs: openRouterDelayMs,
      skipBaselineConnectivitySmoke: skipBaselineConnectivitySmoke,
    );
  }
}

List<String> _csvList(String value) {
  return value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<String> _baselineList(String value) {
  final parsed = _csvList(value);
  if (parsed.isEmpty) {
    throw ArgumentError.value(value, 'baselines', 'Must include a provider.');
  }
  const supported = <String>{
    'chatgpt',
    'claude',
    'openrouter',
    'openrouter_baseline1',
    'openrouter_baseline2',
  };
  for (final provider in parsed) {
    if (!supported.contains(provider)) {
      throw ArgumentError.value(provider, 'baselines', 'Unsupported provider.');
    }
  }
  return parsed;
}

final class _BenchmarkFixture {
  const _BenchmarkFixture({
    required this.answerId,
    required this.questionId,
    required this.archetypeId,
    required this.prompt,
    required this.candidateAnswer,
    required this.seedBand,
    required this.scenarioKind,
    required this.expectedRubricMarks,
    required this.rationaleForSeedBand,
    required this.provenanceNote,
  });

  final String answerId;
  final String questionId;
  final String archetypeId;
  final String prompt;
  final String candidateAnswer;
  final String seedBand;
  final String scenarioKind;
  final Map<String, String> expectedRubricMarks;
  final String rationaleForSeedBand;
  final String provenanceNote;

  String get qualityBand => seedBand;

  factory _BenchmarkFixture.fromJson(Map<String, Object?> json) {
    final marks = json['expected_rubric_marks'];
    return _BenchmarkFixture(
      answerId: json['answer_id']! as String,
      questionId: json['question_id']! as String,
      archetypeId:
          (json['archetype_id'] as String?) ?? (json['question_id']! as String),
      prompt: json['prompt']! as String,
      candidateAnswer:
          (json['candidate_answer'] as String?) ?? (json['answer']! as String),
      seedBand:
          (json['seed_band'] as String?) ?? (json['quality_band']! as String),
      scenarioKind: json['scenario_kind']! as String,
      expectedRubricMarks: marks is Map<String, Object?>
          ? <String, String>{
              for (final entry in marks.entries)
                entry.key: entry.value! as String,
            }
          : <String, String>{},
      rationaleForSeedBand: json['rationale_for_seed_band']! as String,
      provenanceNote: json['provenance_note']! as String,
    );
  }

  List<String> validateMetadata() {
    final issues = <String>[];
    if (answerId.trim().isEmpty) issues.add('answer_id');
    if (questionId.trim().isEmpty) issues.add('question_id');
    if (archetypeId.trim().isEmpty) issues.add('archetype_id');
    if (prompt.trim().isEmpty) issues.add('prompt');
    if (candidateAnswer.trim().isEmpty) issues.add('candidate_answer');
    if (!const <String>{
      'clearly_mid',
      'borderline_senior',
      'clearly_senior',
    }.contains(seedBand)) {
      issues.add('seed_band');
    }
    if (scenarioKind.trim().isEmpty) issues.add('scenario_kind');
    if (expectedRubricMarks.isEmpty) issues.add('expected_rubric_marks');
    for (final entry in expectedRubricMarks.entries) {
      if (!const <String>{'met', 'partial', 'missing'}.contains(entry.value)) {
        issues.add('expected_rubric_marks.${entry.key}');
      }
    }
    if (rationaleForSeedBand.trim().isEmpty) {
      issues.add('rationale_for_seed_band');
    }
    if (provenanceNote.trim().isEmpty) issues.add('provenance_note');
    return issues;
  }
}

final class _GenericFeedbackResponse {
  const _GenericFeedbackResponse({
    required this.provider,
    required this.modelId,
    required this.verdict,
    required this.costRow,
  });

  final String provider;
  final String modelId;
  final String verdict;
  final Map<String, Object?> costRow;

  factory _GenericFeedbackResponse.fromJson(Map<String, Object?> json) {
    return _GenericFeedbackResponse(
      provider: json['provider']! as String,
      modelId: json['model_id']! as String,
      verdict: json['verdict']! as String,
      costRow: <String, Object?>{
        'provider': json['provider'],
        'model_id': json['model_id'],
        'prompt_tokens': json['prompt_tokens'],
        'completion_tokens': json['completion_tokens'],
        'total_tokens': json['total_tokens'],
        'estimated_prompt_tokens': json['estimated_prompt_tokens'],
        'estimated_completion_tokens': json['estimated_completion_tokens'],
        'estimated_total_tokens': json['estimated_total_tokens'],
        'input_usd_per_million_tokens': json['input_usd_per_million_tokens'],
        'output_usd_per_million_tokens': json['output_usd_per_million_tokens'],
        'estimated_cost_usd': json['estimated_cost_usd'],
        'attempts': json['attempts'],
      },
    );
  }
}

final class _CaliberLaneResult {
  const _CaliberLaneResult({
    required this.fixture,
    required this.question,
    required this.judgment,
    required this.modelId,
    required this.levelBand,
    required this.verdictText,
    required this.highestLeverageFix,
  });

  final _BenchmarkFixture fixture;
  final InterviewPracticeQuestion question;
  final InterviewContentJudgment? judgment;
  final String modelId;
  final String levelBand;
  final String verdictText;
  final String highestLeverageFix;
}

final class _SourceVerdict {
  const _SourceVerdict({
    required this.source,
    required this.modelId,
    required this.text,
  });

  final String source;
  final String modelId;
  final String text;
}

final class _BlindVerdict extends _SourceVerdict {
  const _BlindVerdict({
    required this.label,
    required super.source,
    required super.modelId,
    required super.text,
  });

  final String label;
}

final class _BlindCase {
  const _BlindCase({
    required this.fixture,
    required this.question,
    required this.blindedVerdicts,
  });

  final _BenchmarkFixture fixture;
  final InterviewPracticeQuestion question;
  final List<_BlindVerdict> blindedVerdicts;
}
