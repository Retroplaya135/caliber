from __future__ import annotations

import os
from dataclasses import dataclass
from importlib import import_module
from collections.abc import Iterator
from typing import TypeAlias

from pydantic import BaseModel

from caliber_ai_gateway.models import ATSReport, FeatureName, InterviewContentJudgment, ResumeBullet


SCHEMA_CORE_MODULE_ENV = "CALIBER_SCHEMA_CORE_MODULE"
SCHEMA_CORE_CANDIDATES = (
    "caliber_shared.ai_output_schemas",
    "caliber_shared.schemas.ai_outputs",
    "caliber_schema_core.ai_outputs",
)
SchemaModel: TypeAlias = type[BaseModel]

SCHEMA_EXPORTS: dict[FeatureName, tuple[str, str]] = {
    "interview_content": ("interview_content_judgment", "InterviewContentJudgment"),
    "resume_bullet": ("resume_bullet", "ResumeBullet"),
    "ats_report": ("ats_report", "ATSReport"),
}
LOCAL_FALLBACK_MODELS: dict[FeatureName, SchemaModel] = {
    "interview_content": InterviewContentJudgment,
    "resume_bullet": ResumeBullet,
    "ats_report": ATSReport,
}
LOCAL_FALLBACK_ORIGIN = "gateway.local_strict_fallback_until_schema_core_package_lands"
REQUIRED_SCHEMA_FIELDS: dict[str, frozenset[str]] = {
    "InterviewContentJudgment": frozenset(
        {
            "schema_version",
            "judgment_id",
            "profile_id",
            "target",
            "question_id",
            "answer_transcript_id",
            "rubric_version",
            "prompt_version",
            "model_id",
            "content_score",
            "level_band",
            "provider_suggested_band",
            "deterministic_level_band",
            "strengths",
            "risks",
            "recommended_actions",
            "criterion_marks",
            "evidence_spans",
            "created_at",
        }
    ),
    "ResumeBullet": frozenset(
        {
            "schema_version",
            "bullet_id",
            "document_id",
            "text",
            "evidence_atom_ids",
            "evidence_spans",
            "rewrite_policy_version",
            "prompt_version",
            "model_id",
            "source_bullet_id",
            "confidence",
        }
    ),
    "ATSReport": frozenset(
        {
            "schema_version",
            "report_id",
            "document_id",
            "target",
            "ats_test_matrix_version",
            "keyword_match_version",
            "extractable_fields",
            "matched_keywords",
            "coverage_gaps",
            "reasoning",
            "evidence_spans",
            "created_at",
        }
    ),
}
FORBIDDEN_GATEWAY_ENVELOPE_FIELDS = frozenset(
    {
        "corpus_bundle_version",
        "routing_policy_version",
        "route_hash",
        "request_hash",
        "audit_ref",
    }
)
PINNED_OUTPUT_FIELDS = frozenset(
    {
        "schema_version",
        "prompt_version",
        "model_id",
    }
)


@dataclass(frozen=True)
class OutputSchema:
    feature: FeatureName
    schema_name: str
    model: SchemaModel
    origin: str


def schema_core_candidates() -> Iterator[tuple[str, bool]]:
    configured = os.environ.get(SCHEMA_CORE_MODULE_ENV, "").strip()
    if configured:
        yield configured, True
    for module_name in SCHEMA_CORE_CANDIDATES:
        yield module_name, False


def load_output_schemas() -> dict[FeatureName, OutputSchema]:
    for module_name, required in schema_core_candidates():
        try:
            module = import_module(module_name)
        except ModuleNotFoundError:
            if required:
                raise RuntimeError(f"configured Schema Core module {module_name!r} is not importable")
            continue
        return schema_map_from_module(module, module_name, required=required)
    return local_fallback_schema_map()


def load_interview_content_judgment_schema() -> tuple[SchemaModel, str]:
    schema = load_output_schemas()["interview_content"]
    return schema.model, schema.origin


def schema_map_from_module(module: object, origin: str, *, required: bool) -> dict[FeatureName, OutputSchema]:
    schemas: dict[FeatureName, OutputSchema] = {}
    for feature, (schema_name, export_name) in SCHEMA_EXPORTS.items():
        model = getattr(module, export_name, None)
        if not (isinstance(model, type) and issubclass(model, BaseModel)):
            if required:
                raise RuntimeError(f"configured Schema Core module {origin!r} must export a Pydantic {export_name}")
            raise RuntimeError(f"Schema Core module {origin!r} must export a Pydantic {export_name}")
        validate_gateway_schema_contract(model, origin, export_name)
        schemas[feature] = OutputSchema(
            feature=feature,
            schema_name=schema_name,
            model=model,
            origin=f"{origin}:{schema_name}",
        )
    return schemas


def local_fallback_schema_map() -> dict[FeatureName, OutputSchema]:
    schemas: dict[FeatureName, OutputSchema] = {}
    for feature, model in LOCAL_FALLBACK_MODELS.items():
        schema_name = SCHEMA_EXPORTS[feature][0]
        validate_gateway_schema_contract(model, LOCAL_FALLBACK_ORIGIN, model.__name__)
        schemas[feature] = OutputSchema(
            feature=feature,
            schema_name=schema_name,
            model=model,
            origin=f"{LOCAL_FALLBACK_ORIGIN}:{schema_name}",
        )
    return schemas


def validate_gateway_schema_contract(model: SchemaModel, origin: str, export_name: str) -> None:
    required = REQUIRED_SCHEMA_FIELDS[export_name]
    missing = sorted(required.difference(model.model_fields))
    if missing:
        raise RuntimeError(
            f"Schema Core {export_name} from "
            f"{origin!r} is missing required strict AI-output fields: {', '.join(missing)}"
        )
    forbidden = sorted(FORBIDDEN_GATEWAY_ENVELOPE_FIELDS.intersection(model.model_fields))
    if forbidden:
        raise RuntimeError(
            f"Schema Core {export_name} from "
            f"{origin!r} must keep gateway envelope fields in hash/audit, not output: {', '.join(forbidden)}"
        )
