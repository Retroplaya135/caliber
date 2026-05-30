from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml
from pydantic import BaseModel, ConfigDict, Field


class ProviderAdapterConfig(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True, strict=True)

    default_model: str = Field(min_length=1)
    strict_structured_outputs: bool
    gateway_only: bool
    notes: list[str] = Field(default_factory=list)


class GatewayConfig(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True, strict=True)

    provider_adapter: ProviderAdapterConfig


def load_gateway_config(path: Path) -> GatewayConfig:
    data: dict[str, Any] = yaml.safe_load(path.read_text(encoding="utf-8"))
    return GatewayConfig.model_validate(data)

