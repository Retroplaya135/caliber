import unittest

from caliber_billing import BillingService, FeatureId, LedgerName, RevenueCatEventType
from caliber_billing.email.lifecycle_email import (
    LifecycleEmail,
    LifecycleTemplate,
    SesLifecycleEmailSender,
)


def revenuecat_payload(event_id: str, event_type: str, account_id: str = "acct_1") -> dict:
    return {
        "event": {
            "id": event_id,
            "app_user_id": account_id,
            "type": event_type,
            "product_id": "caliber_pro_monthly",
            "entitlement_id": "pro",
            "purchased_at_ms": 1_779_999_000_000,
        }
    }


class BillingLedgerTests(unittest.TestCase):
    def test_revenuecat_purchase_replay_does_not_double_grant(self) -> None:
        service = BillingService()
        payload = revenuecat_payload("evt_purchase_1", RevenueCatEventType.INITIAL_PURCHASE.value)

        first = service.handle_provider_payload("revenuecat", payload)
        replay = service.handle_provider_payload("revenuecat", payload)

        self.assertTrue(first.entitlement.applied)
        self.assertFalse(replay.entitlement.applied)
        self.assertEqual(service.balance(LedgerName.ENTITLEMENT, "acct_1"), 1)
        self.assertEqual(service.balance(LedgerName.CREDIT, "acct_1"), 100)
        self.assertEqual(service.balance(LedgerName.RETENTION, "acct_1"), 0)

    def test_credit_burn_replay_does_not_double_burn(self) -> None:
        service = BillingService()
        service.handle_provider_payload(
            "revenuecat",
            revenuecat_payload("evt_purchase_2", RevenueCatEventType.INITIAL_PURCHASE.value),
        )

        first = service.burn_server_feature_credit(
            account_id="acct_1",
            feature_id=FeatureId.GATEWAY_INTERVIEW_EVAL,
            request_id="req_eval_1",
        )
        replay = service.burn_server_feature_credit(
            account_id="acct_1",
            feature_id=FeatureId.GATEWAY_INTERVIEW_EVAL,
            request_id="req_eval_1",
        )

        self.assertTrue(first.applied)
        self.assertFalse(replay.applied)
        self.assertEqual(service.balance(LedgerName.CREDIT, "acct_1"), 99)

    def test_client_cannot_self_grant_expensive_feature(self) -> None:
        service = BillingService()

        decision = service.decide_feature("acct_client_claim", FeatureId.RESUME_REWRITE)

        self.assertFalse(decision.allowed)
        with self.assertRaises(PermissionError):
            service.burn_server_feature_credit(
                account_id="acct_client_claim",
                feature_id=FeatureId.RESUME_REWRITE,
                request_id="client_claimed_paid",
            )

    def test_local_first_feature_is_free_and_does_not_burn_credit(self) -> None:
        service = BillingService()

        decision = service.decide_feature("acct_free", FeatureId.LOCAL_ATS_REPORT)
        burn = service.burn_server_feature_credit(
            account_id="acct_free",
            feature_id=FeatureId.LOCAL_ATS_REPORT,
            request_id="local_ats_1",
        )

        self.assertTrue(decision.allowed)
        self.assertFalse(decision.requires_credit)
        self.assertFalse(burn.applied)
        self.assertEqual(service.balance(LedgerName.CREDIT, "acct_free"), 0)

    def test_retention_ledger_replay_is_idempotent(self) -> None:
        service = BillingService()
        payload = revenuecat_payload("evt_issue_1", RevenueCatEventType.BILLING_ISSUE.value)

        first = service.handle_provider_payload("revenuecat", payload)
        replay = service.handle_provider_payload("revenuecat", payload)

        self.assertTrue(first.retention.applied)
        self.assertFalse(replay.retention.applied)
        self.assertEqual(service.balance(LedgerName.RETENTION, "acct_1"), 1)


class LifecycleEmailTests(unittest.TestCase):
    def test_ses_templated_email_uses_static_template_data(self) -> None:
        class FakeSes:
            def __init__(self) -> None:
                self.calls = []

            def send_templated_email(self, **kwargs):
                self.calls.append(kwargs)
                return {"MessageId": "msg_1"}

        fake = FakeSes()
        sender = SesLifecycleEmailSender(
            ses_client=fake,
            source_address="billing@caliber.example",
        )

        result = sender.send(
            LifecycleEmail(
                template=LifecycleTemplate.BILLING_ISSUE,
                to_address="user@example.com",
                template_data={"first_name": "Ada", "manage_url": "https://caliber.example/billing"},
            )
        )

        self.assertEqual(result["MessageId"], "msg_1")
        self.assertEqual(fake.calls[0]["Template"], "caliber_billing_issue")

    def test_lifecycle_email_rejects_llm_content_marker(self) -> None:
        class FakeSes:
            def send_templated_email(self, **kwargs):
                raise AssertionError("should not send")

        sender = SesLifecycleEmailSender(
            ses_client=FakeSes(),
            source_address="billing@caliber.example",
        )

        with self.assertRaises(ValueError):
            sender.send(
                LifecycleEmail(
                    template=LifecycleTemplate.RETENTION_OFFER,
                    to_address="user@example.com",
                    template_data={"body": "generated by llm"},
                )
            )


if __name__ == "__main__":
    unittest.main()
