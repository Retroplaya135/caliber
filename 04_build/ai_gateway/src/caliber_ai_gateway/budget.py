from __future__ import annotations

from dataclasses import dataclass

from caliber_ai_gateway.models import FeaturePolicy, ProviderRequest
from caliber_ai_gateway.token_usage import estimate_provider_request_tokens


class TokenBudgetExceeded(RuntimeError):
    pass


@dataclass(frozen=True)
class BudgetEstimate:
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int
    estimated_cost_usd: float


def estimate_budget(request: ProviderRequest, policy: FeaturePolicy) -> BudgetEstimate:
    prompt_tokens = estimate_provider_request_tokens(request)
    completion_tokens = policy.max_completion_tokens
    total_tokens = prompt_tokens + completion_tokens
    estimated_cost_usd = (
        prompt_tokens * policy.input_usd_per_million_tokens
        + completion_tokens * policy.output_usd_per_million_tokens
    ) / 1_000_000
    return BudgetEstimate(
        prompt_tokens=prompt_tokens,
        completion_tokens=completion_tokens,
        total_tokens=total_tokens,
        estimated_cost_usd=estimated_cost_usd,
    )


def enforce_token_budget(request: ProviderRequest, policy: FeaturePolicy) -> BudgetEstimate:
    estimate = estimate_budget(request, policy)
    reasons: list[str] = []
    if estimate.prompt_tokens > policy.max_prompt_tokens:
        reasons.append(f"prompt_tokens>{policy.max_prompt_tokens}")
    if estimate.completion_tokens > policy.max_completion_tokens:
        reasons.append(f"completion_tokens>{policy.max_completion_tokens}")
    if estimate.total_tokens > policy.max_total_tokens:
        reasons.append(f"total_tokens>{policy.max_total_tokens}")
    if estimate.estimated_cost_usd > policy.max_estimated_cost_usd:
        reasons.append(f"estimated_cost_usd>{policy.max_estimated_cost_usd:.6f}")
    if reasons:
        joined = ",".join(reasons)
        raise TokenBudgetExceeded(f"token_budget_exceeded:{joined}")
    return estimate
