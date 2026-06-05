from __future__ import annotations

import re
from collections.abc import Mapping, Sequence
from typing import Any

from caliber_ai_gateway.models import RedactionReport


EMAIL_RE = re.compile(r"\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b", re.IGNORECASE)
PHONE_RE = re.compile(r"(?<!\d)(?:\+?1[-.\s]?)?(?:\(?\d{3}\)?[-.\s]?)\d{3}[-.\s]?\d{4}(?!\d)")
SSN_RE = re.compile(r"\b\d{3}-\d{2}-\d{4}\b")
SENSITIVE_KEYS = {"email", "phone", "phone_number", "ssn", "name", "full_name"}


class Redactor:
    def redact(self, value: Any) -> tuple[Any, RedactionReport]:
        counts: dict[str, int] = {"email": 0, "phone": 0, "ssn": 0, "field": 0}
        fields: list[str] = []
        redacted = self._redact_value(value, counts, fields, path="$")
        report = RedactionReport(counts={k: v for k, v in counts.items() if v}, redacted_fields=fields)
        return redacted, report

    def _redact_value(self, value: Any, counts: dict[str, int], fields: list[str], path: str) -> Any:
        if isinstance(value, str):
            return self._redact_string(value, counts)
        if isinstance(value, Mapping):
            result: dict[str, Any] = {}
            for key, item in value.items():
                key_str = str(key)
                child_path = f"{path}.{key_str}"
                if key_str.lower() in SENSITIVE_KEYS:
                    counts["field"] += 1
                    fields.append(child_path)
                    result[key_str] = "[REDACTED_FIELD]"
                else:
                    result[key_str] = self._redact_value(item, counts, fields, child_path)
            return result
        if isinstance(value, Sequence) and not isinstance(value, (bytes, bytearray, str)):
            return [self._redact_value(item, counts, fields, f"{path}[{index}]") for index, item in enumerate(value)]
        return value

    def _redact_string(self, value: str, counts: dict[str, int]) -> str:
        value, email_count = EMAIL_RE.subn("[REDACTED_EMAIL]", value)
        value, phone_count = PHONE_RE.subn("[REDACTED_PHONE]", value)
        value, ssn_count = SSN_RE.subn("[REDACTED_SSN]", value)
        counts["email"] += email_count
        counts["phone"] += phone_count
        counts["ssn"] += ssn_count
        return value

