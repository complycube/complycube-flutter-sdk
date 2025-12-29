#!/usr/bin/env python3
"""
Extract rows from scripts/ci/matrix.json for GitHub Actions matrices.

Examples:
  python3 scripts/ci/extract_matrix_rows.py --matrix scripts/ci/matrix.json
  python3 scripts/ci/extract_matrix_rows.py --matrix scripts/ci/matrix.json --filter support_level=recommended
  python3 scripts/ci/extract_matrix_rows.py --matrix scripts/ci/matrix.json --ids android-flutter-3.29.3-jdk17,ios-flutter-3.29.3
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, List, Tuple

def parse_filters(filters: List[str]) -> List[Tuple[str, str]]:
    out: List[Tuple[str, str]] = []
    for f in filters:
        if "=" not in f:
            raise SystemExit(f"Invalid --filter '{f}'. Expected key=value.")
        k, v = f.split("=", 1)
        out.append((k.strip(), v.strip()))
    return out

def matches(row: Dict[str, Any], filters: List[Tuple[str, str]]) -> bool:
    for k, v in filters:
        if str(row.get(k, "")) != v:
            return False
    return True

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--matrix", default="scripts/ci/matrix.json")
    ap.add_argument("--filter", action="append", default=[], help="Filter rows by key=value (repeatable)")
    ap.add_argument("--ids", default="", help="Comma-separated row IDs to include")
    args = ap.parse_args()

    data = json.loads(Path(args.matrix).read_text(encoding="utf-8"))
    rows: List[Dict[str, Any]] = list(data.get("rows", []))

    filters = parse_filters(args.filter)

    if args.ids.strip():
        allowed = set([x.strip() for x in args.ids.split(",") if x.strip()])
        rows = [r for r in rows if r.get("id") in allowed]

    if filters:
        rows = [r for r in rows if matches(r, filters)]

    # Print compact JSON (one line) to make it safe for GitHub output
    print(json.dumps(rows, separators=(",", ":")))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
