from __future__ import annotations

from copy import deepcopy
from typing import Any

from pydantic import BaseModel


STRIP_KEYS = {"default", "examples", "title"}


def strict_json_schema(model: type[BaseModel]) -> dict[str, Any]:
    schema = deepcopy(model.model_json_schema())
    return _sanitize_schema(schema)


def _sanitize_schema(value: Any) -> Any:
    if isinstance(value, dict):
        sanitized: dict[str, Any] = {}
        for key, item in value.items():
            if key in STRIP_KEYS and not isinstance(item, dict):
                continue
            if key == "properties" and isinstance(item, dict):
                sanitized[key] = {
                    property_key: _sanitize_schema(property_schema)
                    for property_key, property_schema in item.items()
                    if not (
                        isinstance(property_schema, dict)
                        and property_schema.get("gateway_derived") is True
                    )
                }
                continue
            sanitized[key] = _sanitize_schema(item)
        if sanitized.get("type") == "object":
            properties = sanitized.get("properties", {})
            if not isinstance(properties, dict):
                properties = {}
            sanitized["properties"] = properties
            sanitized["additionalProperties"] = False
            sanitized["required"] = list(properties.keys())
        sanitized.pop("gateway_derived", None)
        return sanitized
    if isinstance(value, list):
        return [_sanitize_schema(item) for item in value]
    return value
