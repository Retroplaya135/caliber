from __future__ import annotations

from typing import Mapping, Protocol

from .models import RevenueCatEvent, RevenueCatEventType


class BillingProvider(Protocol):
    def parse_server_event(self, payload: Mapping[str, object]) -> RevenueCatEvent:
        """Return a server-verified billing event.

        Client SDK state is useful for UX but never authoritative. Implementors
        must parse webhook/API payloads received by the backend.
        """


class RevenueCatBillingProvider:
    provider_name = "revenuecat"

    def parse_server_event(self, payload: Mapping[str, object]) -> RevenueCatEvent:
        event = payload.get("event")
        if not isinstance(event, Mapping):
            raise ValueError("RevenueCat payload missing event object")

        event_id = _required_string(event, "id")
        account_id = _required_string(event, "app_user_id")
        event_type = RevenueCatEventType(_required_string(event, "type"))
        product_id = _optional_string(event, "product_id")
        entitlement_id = _optional_string(event, "entitlement_id")
        purchased_at_ms = event.get("purchased_at_ms")
        if purchased_at_ms is not None and not isinstance(purchased_at_ms, int):
            raise ValueError("purchased_at_ms must be an integer when present")

        return RevenueCatEvent(
            event_id=event_id,
            account_id=account_id,
            event_type=event_type,
            product_id=product_id,
            entitlement_id=entitlement_id,
            purchased_at_ms=purchased_at_ms,
            raw=payload,
        )


class BillingProviderRegistry:
    def __init__(self) -> None:
        self._providers: dict[str, BillingProvider] = {}

    def register(self, name: str, provider: BillingProvider) -> None:
        if name in self._providers:
            raise ValueError(f"billing provider already registered: {name}")
        self._providers[name] = provider

    def provider(self, name: str) -> BillingProvider:
        try:
            return self._providers[name]
        except KeyError as exc:
            raise KeyError(f"unknown billing provider: {name}") from exc


def default_billing_registry() -> BillingProviderRegistry:
    registry = BillingProviderRegistry()
    registry.register(RevenueCatBillingProvider.provider_name, RevenueCatBillingProvider())
    return registry


def _required_string(payload: Mapping[str, object], key: str) -> str:
    value = payload.get(key)
    if not isinstance(value, str) or not value:
        raise ValueError(f"missing required RevenueCat field: {key}")
    return value


def _optional_string(payload: Mapping[str, object], key: str) -> str | None:
    value = payload.get(key)
    if value is None:
        return None
    if not isinstance(value, str):
        raise ValueError(f"RevenueCat field must be a string: {key}")
    return value
