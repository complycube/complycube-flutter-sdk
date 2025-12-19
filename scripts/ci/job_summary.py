#!/usr/bin/env python3

"""
Append-friendly GitHub Actions job summary renderer for a single matrix row result JSON.

Usage:
  python3 scripts/ci/job_summary.py --platform android --json artifacts/results/<id>.json
  python3 scripts/ci/job_summary.py --platform ios --json artifacts/results/<id>.json
"""
import argparse
import json
import pathlib

def _truncate(s: str, max_chars: int) -> str:
    if max_chars <= 0:
        return ""
    if len(s) <= max_chars:
        return s
    # Keep the most recent tail; build failures are usually at the end.
    return s[-max_chars:]

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--platform", choices=["android", "ios"], required=True)
    ap.add_argument("--json", dest="json_path", required=True)
    ap.add_argument("--max-log-chars", type=int, default=6000)
    args = ap.parse_args()

    p = pathlib.Path(args.json_path)
    if not p.exists():
        print(f"### {args.platform.upper()} · (missing result JSON)")
        print(f"- Outcome: **no result JSON produced**")
        return 0

    try:
        d = json.loads(p.read_text(encoding="utf-8"))
    except Exception as e:
        print(f"### {args.platform.upper()} · (invalid JSON)")
        print(f"- Outcome: **invalid JSON**")
        print(f"- Error: {e}")
        return 0

    det = d.get("detected") or {}
    out = d.get("outcome", "")
    notes = d.get("notes", "")

    row_id = d.get("id") or pathlib.Path(args.json_path).stem
    title_platform = "Android" if args.platform == "android" else "iOS"

    print(f"### {title_platform} · {row_id}")
    print(f"- Outcome: **{out}**" if out else "- Outcome: **unknown**")
    if notes:
        print(f"- Notes: {notes}")

    # Common
    fv = det.get("flutter_version", "")
    dv = det.get("dart_version", "")
    if fv:
        print(f"- Flutter: {fv}")
    if dv:
        print(f"- Dart: {dv}")

    if args.platform == "android":
        jv = det.get("java_version", "")
        agp = det.get("agp_version", "")
        kv = det.get("kotlin_version", "")
        gv = det.get("gradle_version", "")
        if jv:
            print(f"- Java: {jv}")
        if agp:
            print(f"- AGP: {agp}")
        if kv:
            print(f"- Kotlin: {kv}")
        if gv:
            print(f"- Gradle: {gv}")
    else:
        xv = det.get("xcode_version", "")
        sv = det.get("swift_version", "")
        pv = det.get("cocoapods_version", "")
        rv = det.get("ruby_version", "")
        if xv:
            print(f"- Xcode: {xv}")
        if sv:
            print(f"- Swift: {sv}")
        if pv:
            print(f"- CocoaPods: {pv}")
        if rv:
            print(f"- Ruby: {rv}")

    log = (d.get("log_tail") or "").strip()
    if log:
        log = _truncate(log, args.max_log_chars)
        print("\n<details><summary>Log tail</summary>\n\n```")
        print(log)
        print("```\n</details>\n")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())
