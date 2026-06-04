from __future__ import annotations

import os
import re
from pathlib import Path

REQUEST_HASH_RE = re.compile(r"^[a-f0-9]{64}$")


def validate_request_hash(request_hash: str) -> None:
    if REQUEST_HASH_RE.fullmatch(request_hash) is None:
        raise ValueError("request_hash must be a lowercase sha256 hex digest")


class ExactCache:
    def get(self, request_hash: str) -> str | None:
        raise NotImplementedError

    def set(self, request_hash: str, canonical_json: str) -> None:
        raise NotImplementedError


class MemoryExactCache(ExactCache):
    def __init__(self) -> None:
        self._values: dict[str, str] = {}

    def get(self, request_hash: str) -> str | None:
        validate_request_hash(request_hash)
        return self._values.get(request_hash)

    def set(self, request_hash: str, canonical_json: str) -> None:
        validate_request_hash(request_hash)
        self._values[request_hash] = canonical_json


class FileExactCache(ExactCache):
    def __init__(self, root: Path) -> None:
        self.root = root
        self.root.mkdir(parents=True, exist_ok=True)

    def _path(self, request_hash: str) -> Path:
        validate_request_hash(request_hash)
        return self.root / f"{request_hash}.json"

    def get(self, request_hash: str) -> str | None:
        path = self._path(request_hash)
        if not path.exists():
            return None
        return path.read_text(encoding="utf-8")

    def set(self, request_hash: str, canonical_json: str) -> None:
        path = self._path(request_hash)
        tmp = path.with_name(f"{path.name}.{os.getpid()}.tmp")
        with tmp.open("w", encoding="utf-8") as handle:
            handle.write(canonical_json)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(tmp, path)
        self._fsync_root()

    def _fsync_root(self) -> None:
        directory_fd = os.open(self.root, os.O_RDONLY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
