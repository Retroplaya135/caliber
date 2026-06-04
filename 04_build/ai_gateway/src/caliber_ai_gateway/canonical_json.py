from __future__ import annotations

import hashlib
import json
import unicodedata
from collections.abc import Mapping, Sequence
from typing import Any


def canonicalize_value(value: Any) -> Any:
    if isinstance(value, str):
        return unicodedata.normalize("NFKC", value).strip()
    if isinstance(value, Mapping):
        return {
            str(key): canonicalize_value(value[key])
            for key in sorted(value, key=lambda item: str(item))
        }
    if isinstance(value, Sequence) and not isinstance(value, (bytes, bytearray, str)):
        return [canonicalize_value(item) for item in value]
    return value


def canonical_json(value: Any) -> str:
    return json.dumps(
        canonicalize_value(value),
        ensure_ascii=False,
        separators=(",", ":"),
        sort_keys=True,
    )


def sha256_hex(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def canonical_hash(value: Any) -> str:
    return sha256_hex(canonical_json(value))

