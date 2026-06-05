from __future__ import annotations

import json
from dataclasses import dataclass
from enum import StrEnum
from typing import Protocol


class LifecycleTemplate(StrEnum):
    WELCOME = "caliber_welcome_paid"
    BILLING_ISSUE = "caliber_billing_issue"
    GRACE_ENDING = "caliber_grace_ending"
    REFUND_CONFIRMATION = "caliber_refund_confirmation"
    RETENTION_OFFER = "caliber_retention_offer"


@dataclass(frozen=True, slots=True)
class LifecycleEmail:
    template: LifecycleTemplate
    to_address: str
    template_data: dict[str, str]


class SesLikeClient(Protocol):
    def send_templated_email(self, **kwargs: object) -> object:
        """Subset of boto3 SES client used by the lifecycle sender."""


class SesLifecycleEmailSender:
    def __init__(self, *, ses_client: SesLikeClient, source_address: str) -> None:
        if not source_address:
            raise ValueError("source_address is required")
        self._ses_client = ses_client
        self._source_address = source_address

    def send(self, email: LifecycleEmail) -> object:
        if "llm" in json.dumps(email.template_data, sort_keys=True).lower():
            raise ValueError("billing lifecycle email path must not include LLM content")
        return self._ses_client.send_templated_email(
            Source=self._source_address,
            Destination={"ToAddresses": [email.to_address]},
            Template=email.template.value,
            TemplateData=json.dumps(email.template_data, sort_keys=True),
        )


def build_boto3_ses_sender(*, region_name: str, source_address: str) -> SesLifecycleEmailSender:
    import boto3

    return SesLifecycleEmailSender(
        ses_client=boto3.client("ses", region_name=region_name),
        source_address=source_address,
    )
