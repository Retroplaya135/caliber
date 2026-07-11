<div align="center">
  <img src="docs/cover.png" alt="Caliber" width="100%">
  <h3>Inspectable technical-interview practice, evaluation, and evidence.</h3>
  <p>
    <img alt="Status: engineering preview" src="https://img.shields.io/badge/status-engineering%20preview-334155">
    <img alt="Flutter 3.44.1" src="https://img.shields.io/badge/Flutter-3.44.1-02569B?logo=flutter&logoColor=white">
    <img alt="Dart 3.12.1" src="https://img.shields.io/badge/Dart-3.12.1-0175C2?logo=dart&logoColor=white">
    <img alt="Python 3.12 or newer" src="https://img.shields.io/badge/Python-3.12%2B-3776AB?logo=python&logoColor=white">
    <img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-16a34a">
  </p>
  <p>
    <a href="#overview">Overview</a> ·
    <a href="#system-map">System map</a> ·
    <a href="#quick-start">Quick start</a> ·
    <a href="#verification">Verification</a> ·
    <a href="#project-boundaries">Boundaries</a>
  </p>
</div>

## Overview

Caliber is an engineering preview of a technical-interview practice system built around inspectable evidence. It joins a Flutter application, deterministic retrieval and evaluation packages, local persistence, speech integration, a structured provider gateway, and isolated résumé-processing tools in one workspace.

The central problem is not displaying questions or producing a score. It is preserving the path from an answer to an assessment: which prompt and target were active, which evidence was retrieved, which rubric marks were applied, which provider response was accepted, and which output reached the user. Caliber keeps those boundaries explicit so they can be tested independently.

The repository uses synthetic fixtures for assessment, résumé, speech, and benchmark paths. It is suitable for studying and extending the system design; it does not claim that generated assessments are validated hiring decisions.

## System map

| Area | Responsibility |
| --- | --- |
| Flutter application | Composes onboarding, job-packet, practice, review, résumé, audio, storage, billing, and settings surfaces |
| App shell and state | Owns routing, feature gates, entitlements, Riverpod state, and runtime gateway configuration |
| Interview and evaluation | Manages questions, sessions, answers, rubrics, evidence spans, adjudication fixtures, and verdict rendering |
| Retrieval and contracts | Provides BM25 corpus retrieval plus versioned profile, target, document, transcript, and AI-output contracts |
| Storage and sync | Handles local databases, key management, migrations, backups, and signed corpus bundles |
| Speech stack | Normalizes transcripts behind capability-aware engines, glossary handling, and a local benchmark harness |
| AI gateway | Enforces structured schemas, budgets, redaction, caching, retries, audit events, and token accounting |
| Résumé worker | Parses supported documents, preserves evidence, reviews rewrites, and produces deterministic ATS reports |
| Guardrails | Checks repository boundaries, generated files, goldens, secrets, handoffs, and seeded failure cases |

The application can use a local deterministic judge or the Python gateway. Provider-backed execution is an explicit runtime choice; the default app remains usable without sending interview content to a provider.

## Implemented capabilities

### Practice and evaluation

- Question, session, engagement, memory, and answer-capture models.
- Local and gateway-backed structured judges behind a shared interface.
- Rubric-mapped verdicts with evidence spans, level bands, strengths, risks, and next-step guidance.
- Deterministic adjudication fixtures and benchmark envelopes for repeatable comparisons.
- Backend corpus retrieval and per-user evaluation memory kept separate from presentation code.

### Application and local data

- Local anonymous authentication and onboarding.
- Route-level feature gates and an entitlement-policy seam.
- Flutter screens for the current product flow, including practice and evidence inspection.
- Drift/SQLite persistence, encrypted database-key handling, migration backups, and storage factories.
- Signed corpus bundle verification and synchronization.

### Provider and document boundaries

- FastAPI endpoints for interview, résumé-bullet, ATS, and generic structured judgments.
- Strict Pydantic schemas, exact request hashing, schema-aware retry behavior, and safe provider-error labels.
- Redaction reports, audit records, token budgets, usage ledgers, and funnel-event storage.
- A default OpenAI execution adapter plus isolated OpenRouter and Anthropic benchmark adapters.
- PDF and DOCX résumé parsing, evidence extraction, rewrite review, ATS reporting, and black-box harnesses.

### Engineering controls

- A 15-package Dart and Flutter workspace coordinated with Melos.
- Source tests across application, contracts, persistence, speech, gateway, résumé, billing, and guardrail code.
- Golden fixtures for UI and structured outputs.
- Generated-code checks, style-token checks, contract-version checks, and synthetic secret scanning.
- Seeded violations that demonstrate the guardrails fail when expected.

## Quick start

Caliber pins Flutter 3.44.1 and Dart 3.12.1 in [SDK_PIN.md](SDK_PIN.md). The local application starts with the deterministic judge, so a provider credential is not required for the first run.

```bash
flutter pub get --enforce-lockfile
cd 04_build/frontend/app
flutter run -d chrome
```

To use the structured provider gateway, start `04_build/ai_gateway/tool/run_local_gateway.sh` with `OPENAI_API_KEY` available. The runner requires Python 3.12 or newer, creates an isolated environment outside the repository, installs the gateway and its development dependencies, and serves it on `127.0.0.1:8000` by default.

For web builds, copy `04_build/frontend/app/web/caliber_runtime_config.example.json` to `caliber_runtime_config.json` in the same directory. That file selects the gateway judge and local gateway URL. Native builds use Dart environment defines documented by the runtime configuration loader.

## Practical usage

### Trace an interview judgment

Start with `04_build/frontend/interview`, then follow the structured-judge request through `04_build/frontend/gateway_client` and `04_build/ai_gateway`. The response schema keeps quoted evidence, rubric marks, derived level bands, and the final feedback view model connected. The adjudication fixtures under `04_build/frontend/eval` make this path reproducible without candidate data.

### Inspect local persistence

The `04_build/database/storage_sync` package separates user, cache, and corpus databases. Its tests cover key management, migration backups, storage construction, and signed-bundle synchronization. Callers receive interfaces and factories rather than opening storage directly from UI code.

### Exercise the speech boundary

The speech stack exposes engine capabilities, canonical transcript handling, glossary terms, schema projection, and an audio pipeline without binding interview logic to one recognition provider. Its jargon benchmark uses local fixtures and is intended to compare transcript behavior, not advertise universal accuracy.

### Work on résumé evidence

The worker under `04_build/workers/resume` keeps parsing, evidence, rewrite review, ATS reporting, profiling, and upstream-contract probes together. It requires Python 3.11 or newer and declares its document-processing dependencies in its own `pyproject.toml`.

## Verification

The root Melos commands cover the selected Dart and Flutter package matrix. Python components keep separate test commands because they have independent environments and dependency constraints.

```bash
dart run melos run analyze
dart run melos run test
python3 tool/guardrails/guardrails.py all

cd 04_build/ai_gateway && python3 -m pytest
cd ../workers/resume && python3 -m resume_worker.tools.test --coverage
```

Install each Python package and its dependencies before running its tests. The gateway's local runner installs the gateway development environment automatically. Billing tests live under `04_build/backend/billing/tests` and are also separate from the root Melos test command.

The repository currently contains source tests for application startup and flow, route and entitlement behavior, local authentication, interview rounds, gateway transport, structured judgments, storage, speech, shared contracts, résumé processing, billing, and guardrails. The benchmark scripts under `tool/` are optional provider exercises: they require explicit credentials, model selection, and cost configuration and are not part of the credential-free verification path.

## Repository map

| Path | Contents |
| --- | --- |
| `04_build/frontend` | Runnable app, shell, screens, state, authentication, interview, evaluation, prep brief, and gateway client |
| `04_build/backend` | Retrieval and evaluation backend plus billing and entitlement services |
| `04_build/database` | Evaluation memory, local databases, migrations, and corpus synchronization |
| `04_build/design_system` | Tokens, primitives, components, catalog, and golden tests |
| `04_build/integrations/speech_stack` | Recognition contracts, engines, canonicalization, and benchmark fixtures |
| `04_build/shared` | Versioned cross-package schemas and interfaces |
| `04_build/ai_gateway` | FastAPI structured-judgment service and provider boundary |
| `04_build/workers/resume` | Résumé parsing, evidence, rewrite, ATS, and verification tools |
| `config` | Provider and repository-guardrail configuration |
| `tool` | Guardrail and benchmark entry points |

## Project boundaries

Caliber is not a hosted service, a validated assessment instrument, or an automated employment-decision system. The public repository does not provide deployment topology, operator administration, production identity management, retention policy, or jurisdiction-specific review controls.

Before using real interview or résumé data, an operator must define authorization, encryption-key custody, provider credentials, retention and deletion rules, audit access, incident response, and mandatory human review. Provider-backed runs may transmit supplied content to the configured provider. Review that provider's terms and data controls before enabling the gateway.

Some application destinations remain prototype surfaces, and interfaces may change while the product boundary is refined. The exact SDK pin is documented, but the current CI workflow follows Flutter's stable channel rather than installing the pinned release through a dedicated version manager.

## Documentation

- [SDK pin](SDK_PIN.md) — supported Flutter and Dart versions.
- [Runtime gateway example](04_build/frontend/app/web/caliber_runtime_config.example.json) — web gateway selection and endpoints.
- [Adjudication fixtures](04_build/frontend/eval/fixtures/adjudication/README.md) — deterministic evaluation cases.
- [Contributing](CONTRIBUTING.md) — component boundaries, tests, and synthetic-data rules.
- [Security](SECURITY.md) — private reporting and sensitive-data guidance.

## Contributing, security, and license

Keep changes inside an existing component boundary unless the shared contracts change with them. Evaluation, retention, privacy, and persistence changes should include focused tests. Use synthetic evidence only; never commit résumés, recordings, credentials, provider payloads, or candidate records.

Report suspected vulnerabilities through GitHub's private security-advisory channel as described in [SECURITY.md](SECURITY.md).

Caliber is available under the [MIT License](LICENSE).
