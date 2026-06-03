from __future__ import annotations

from collections import defaultdict
from threading import RLock

from .models import LedgerDecision, LedgerEvent, LedgerName


class IdempotentLedgerStore:
    """Append-only in-memory ledger used by tests and local sandbox runs.

    The production adapter must replace the dictionaries with a transactional
    database table that has a unique index on (ledger, account_id,
    idempotency_key). The semantics here are the contract.
    """

    def __init__(self) -> None:
        self._lock = RLock()
        self._events: dict[tuple[LedgerName, str], list[LedgerEvent]] = defaultdict(list)
        self._idempotency: dict[tuple[LedgerName, str, str], LedgerDecision] = {}
        self._balances: dict[tuple[LedgerName, str], int] = defaultdict(int)

    def apply(self, event: LedgerEvent) -> LedgerDecision:
        key = (event.ledger, event.account_id, event.idempotency_key)
        account_key = (event.ledger, event.account_id)
        with self._lock:
            existing = self._idempotency.get(key)
            if existing is not None:
                return LedgerDecision(
                    event=event,
                    applied=False,
                    balance_after=existing.balance_after,
                    replay_of=event.idempotency_key,
                )

            balance_after = self._balances[account_key] + event.delta
            self._balances[account_key] = balance_after
            self._events[account_key].append(event)
            decision = LedgerDecision(
                event=event,
                applied=True,
                balance_after=balance_after,
            )
            self._idempotency[key] = decision
            return decision

    def balance(self, ledger: LedgerName, account_id: str) -> int:
        with self._lock:
            return self._balances[(ledger, account_id)]

    def events(self, ledger: LedgerName, account_id: str) -> tuple[LedgerEvent, ...]:
        with self._lock:
            return tuple(self._events[(ledger, account_id)])


class EntitlementLedger:
    def __init__(self, store: IdempotentLedgerStore) -> None:
        self._store = store

    def record(self, event: LedgerEvent) -> LedgerDecision:
        if event.ledger is not LedgerName.ENTITLEMENT:
            raise ValueError("entitlement ledger only accepts entitlement events")
        return self._store.apply(event)


class CreditLedger:
    def __init__(self, store: IdempotentLedgerStore) -> None:
        self._store = store

    def grant(self, event: LedgerEvent) -> LedgerDecision:
        if event.ledger is not LedgerName.CREDIT:
            raise ValueError("credit ledger only accepts credit events")
        if event.delta <= 0:
            raise ValueError("credit grants must be positive")
        return self._store.apply(event)

    def burn(self, event: LedgerEvent) -> LedgerDecision:
        if event.ledger is not LedgerName.CREDIT:
            raise ValueError("credit ledger only accepts credit events")
        if event.delta >= 0:
            raise ValueError("credit burns must be negative")
        if self._store.balance(LedgerName.CREDIT, event.account_id) + event.delta < 0:
            raise ValueError("insufficient server-side credits")
        return self._store.apply(event)


class RetentionLedger:
    def __init__(self, store: IdempotentLedgerStore) -> None:
        self._store = store

    def record(self, event: LedgerEvent) -> LedgerDecision:
        if event.ledger is not LedgerName.RETENTION:
            raise ValueError("retention ledger only accepts retention events")
        return self._store.apply(event)
