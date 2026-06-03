from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class AuditRecord:
    audit_ref: str
    request_hash: str
    output_hash: str | None
    cache_hit: bool
    provider_name: str
    model_id: str
    attempts: int
    status: str
    redaction_counts: dict[str, int]
    version_pins: dict[str, str]
    created_at: str = field(default_factory=lambda: datetime.now(UTC).isoformat())

    def safe_dump(self) -> dict[str, Any]:
        return {
            "audit_ref": self.audit_ref,
            "request_hash": self.request_hash,
            "output_hash": self.output_hash,
            "cache_hit": self.cache_hit,
            "provider_name": self.provider_name,
            "model_id": self.model_id,
            "attempts": self.attempts,
            "status": self.status,
            "redaction_counts": dict(self.redaction_counts),
            "version_pins": dict(self.version_pins),
            "created_at": self.created_at,
        }


class AuditSink:
    def record(self, record: AuditRecord) -> None:
        raise NotImplementedError


class InMemoryAuditSink(AuditSink):
    def __init__(self) -> None:
        self.records: list[AuditRecord] = []

    def record(self, record: AuditRecord) -> None:
        self.records.append(record)


class FileAuditSink(AuditSink):
    def __init__(self, path: Path) -> None:
        self.path = path
        self.path.parent.mkdir(parents=True, exist_ok=True)

    def record(self, record: AuditRecord) -> None:
        line = json.dumps(record.safe_dump(), sort_keys=True, separators=(",", ":"))
        with self.path.open("a", encoding="utf-8") as handle:
            handle.write(line)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
