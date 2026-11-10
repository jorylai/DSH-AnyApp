#!/usr/bin/env python3
"""Reserve a strictly increasing AnyApp versionCode without rewriting pubspec.

This fork already shipped codes near 2,026,110,905. The upstream minute format
is smaller and must not be used for later updates. Reservations are local build
state, contain no credentials, and are consumed even if packaging later fails.
"""
from __future__ import annotations

import argparse
import fcntl
import json
import os
from pathlib import Path
import re
import tempfile

LIMIT = 2_100_000_000

def reserve(pubspec: Path, state: Path, requested: int | None = None) -> int:
    match = re.search(r'^version:\s*[^\s+]+\+(\d+)\s*$', pubspec.read_text(), re.M)
    if match is None:
        raise ValueError('pubspec must contain the last shipped versionCode')
    floor = int(match.group(1))
    state.parent.mkdir(parents=True, exist_ok=True)
    with state.with_suffix('.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        previous = floor
        if state.exists():
            saved = json.loads(state.read_text())
            if saved.get('format') != 1 or type(saved.get('last')) is not int:
                raise ValueError('invalid build reservation; do not reset it silently')
            previous = max(previous, saved['last'])
        code = previous + 1 if requested is None else requested
        if type(code) is not int or not previous < code <= LIMIT:
            raise ValueError(f'new versionCode must be greater than {previous} and at most {LIMIT}')
        fd, temporary = tempfile.mkstemp(prefix='anyapp-number-', dir=state.parent)
        try:
            with os.fdopen(fd, 'w') as output:
                json.dump({'format': 1, 'last': code}, output)
                output.flush()
                os.fsync(output.fileno())
            os.replace(temporary, state)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
        return code

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pubspec', type=Path, required=True)
    parser.add_argument('--state', type=Path, required=True)
    parser.add_argument('--requested', type=int)
    args = parser.parse_args()
    try:
        print(reserve(args.pubspec, args.state, args.requested))
    except (ValueError, OSError) as error:
        parser.exit(1, f'anyapp-build-number: {error}\n')

if __name__ == '__main__':
    main()
