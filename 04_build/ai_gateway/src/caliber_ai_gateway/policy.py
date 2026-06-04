from __future__ import annotations

from dataclasses import dataclass

from caliber_ai_gateway.models import FeatureName
from caliber_ai_gateway.models import FeaturePolicy, JudgeRequest


@dataclass(frozen=True)
class TokenBudget:
    max_prompt_tokens: int
    max_completion_tokens: int
    max_total_tokens: int
    max_estimated_cost_usd: float


DEFAULT_TOKEN_BUDGETS: dict[FeatureName, TokenBudget] = {
    "interview_content": TokenBudget(
        max_prompt_tokens=12_000,
        max_completion_tokens=1_800,
        max_total_tokens=12_900,
        max_estimated_cost_usd=0.02,
    ),
    "resume_bullet": TokenBudget(
        max_prompt_tokens=4_000,
        max_completion_tokens=450,
        max_total_tokens=4_450,
        max_estimated_cost_usd=0.0065,
    ),
    "ats_report": TokenBudget(
        max_prompt_tokens=5_000,
        max_completion_tokens=700,
        max_total_tokens=5_700,
        max_estimated_cost_usd=0.009,
    ),
}


INPUT_USD_PER_MILLION_TOKENS = 1.0
OUTPUT_USD_PER_MILLION_TOKENS = 4.5


class PolicyEngine:
    def attach(self, request: JudgeRequest, provider_name: str) -> FeaturePolicy:
        budget = DEFAULT_TOKEN_BUDGETS[request.feature]
        return FeaturePolicy(
            feature=request.feature,
            provider_name=provider_name,
            max_attempts=1,
            timeout_seconds=20.0,
            allow_pii_to_provider=False,
            policy_version=request.routing_policy_version,
            max_prompt_tokens=budget.max_prompt_tokens,
            max_completion_tokens=budget.max_completion_tokens,
            max_total_tokens=budget.max_total_tokens,
            input_usd_per_million_tokens=INPUT_USD_PER_MILLION_TOKENS,
            output_usd_per_million_tokens=OUTPUT_USD_PER_MILLION_TOKENS,
            max_estimated_cost_usd=budget.max_estimated_cost_usd,
        )
