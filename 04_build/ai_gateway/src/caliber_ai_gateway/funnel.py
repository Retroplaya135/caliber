from __future__ import annotations

import json
import os
import threading
from collections import Counter, defaultdict
from pathlib import Path
from typing import Iterable, Protocol

from caliber_ai_gateway.models import (
    FunnelConversionStep,
    FunnelEventName,
    FunnelEventRequest,
    FunnelReadoutResponse,
)

FUNNEL_READOUT_SCHEMA_VERSION = "caliber_funnel_readout.v1"
FUNNEL_EVENT_ORDER: tuple[FunnelEventName, ...] = (
    "packet_created",
    "brief_completed",
    "email_capture",
    "practice_start_click",
    "first_paid_eval_started",
    "verdict_completed",
    "inspect_opened",
    "retest_started",
)
FUNNEL_CONVERSION_STEPS: tuple[tuple[FunnelEventName, FunnelEventName], ...] = (
    ("packet_created", "brief_completed"),
    ("brief_completed", "practice_start_click"),
    ("practice_start_click", "first_paid_eval_started"),
    ("first_paid_eval_started", "verdict_completed"),
    ("verdict_completed", "inspect_opened"),
    ("verdict_completed", "retest_started"),
    ("brief_completed", "first_paid_eval_started"),
)


class FunnelStore(Protocol):
    def append(self, event: FunnelEventRequest) -> int:
        """Persist one event and return the durable event count."""

    def readout(self) -> FunnelReadoutResponse:
        """Return aggregate counts and profile-level funnel conversion."""


class JsonlFunnelStore:
    def __init__(self, path: Path) -> None:
        self.path = path
        self._lock = threading.Lock()

    def append(self, event: FunnelEventRequest) -> int:
        payload = event.model_dump(mode="json")
        line = json.dumps(payload, sort_keys=True, separators=(",", ":"))
        with self._lock:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            with self.path.open("a", encoding="utf-8") as handle:
                handle.write(f"{line}\n")
                handle.flush()
                os.fsync(handle.fileno())
            return sum(1 for _ in self._events_unlocked())

    def readout(self) -> FunnelReadoutResponse:
        with self._lock:
            events = list(self._events_unlocked())
        return build_funnel_readout(events)

    def _events_unlocked(self) -> Iterable[FunnelEventRequest]:
        if not self.path.exists():
            return ()
        parsed = []
        with self.path.open("r", encoding="utf-8") as handle:
            for line in handle:
                raw = line.strip()
                if not raw:
                    continue
                parsed.append(FunnelEventRequest.model_validate_json(raw))
        return parsed


def build_funnel_readout(events: Iterable[FunnelEventRequest]) -> FunnelReadoutResponse:
    materialized = list(events)
    counts = Counter(event.event_type for event in materialized)
    profiles_by_event: dict[FunnelEventName, set[str]] = defaultdict(set)
    all_profiles = set[str]()
    for event in materialized:
        profiles_by_event[event.event_type].add(event.anon_profile_id)
        all_profiles.add(event.anon_profile_id)

    unique_counts = {
        event_name: len(profiles_by_event[event_name])
        for event_name in FUNNEL_EVENT_ORDER
    }
    conversion = [
        _conversion_step(from_event, to_event, profiles_by_event)
        for from_event, to_event in FUNNEL_CONVERSION_STEPS
    ]
    return FunnelReadoutResponse(
        schema_version=FUNNEL_READOUT_SCHEMA_VERSION,
        total_events=len(materialized),
        unique_profiles=len(all_profiles),
        counts={event_name: counts[event_name] for event_name in FUNNEL_EVENT_ORDER},
        unique_profile_counts=unique_counts,
        conversion=conversion,
    )


def _conversion_step(
    from_event: FunnelEventName,
    to_event: FunnelEventName,
    profiles_by_event: dict[FunnelEventName, set[str]],
) -> FunnelConversionStep:
    from_profiles = profiles_by_event[from_event]
    converted_profiles = from_profiles.intersection(profiles_by_event[to_event])
    from_count = len(from_profiles)
    to_count = len(converted_profiles)
    return FunnelConversionStep(
        from_event=from_event,
        to_event=to_event,
        from_profiles=from_count,
        to_profiles=to_count,
        rate=0 if from_count == 0 else to_count / from_count,
    )
