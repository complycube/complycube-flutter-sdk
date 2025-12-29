#!/usr/bin/env python3
from __future__ import annotations
import argparse, json
from pathlib import Path
from typing import Any, Dict, List

def load_results(results_dir: Path) -> List[Dict[str, Any]]:
    out: List[Dict[str, Any]] = []
    for p in sorted(results_dir.glob('*.json')):
        try:
            out.append(json.loads(p.read_text(encoding='utf-8')))
        except Exception as e:
            out.append({'id': p.stem, 'platform': 'unknown', 'requested': {}, 'detected': {}, 'outcome': 'fail', 'notes': f'Parse error: {e}'})
    return out

def sort_key(r: Dict[str, Any]):
    req = r.get('requested') or {}
    return (r.get('platform',''), req.get('flutter_version',''), req.get('jdk',''), r.get('id',''))

def emoji(outcome: str) -> str:
    return '✅' if outcome == 'pass' else '❌'

def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--results-dir', required=True)
    args = ap.parse_args()

    rows = load_results(Path(args.results_dir))
    rows.sort(key=sort_key)

    print('## Validated combinations (CI)\n')
    print('> This table is generated automatically by CI. Do not edit it manually.\n')
    print('| Row | Platform | Flutter | Runner OS | Build JDK | AGP | Gradle | Kotlin | Resolved compileSdk/targetSdk/minSdk | Xcode / Swift | CocoaPods / Ruby | Result |')
    print('| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |')

    for r in rows:
        req = r.get('requested') or {}
        det = r.get('detected') or {}
        platform = r.get('platform','')
        row_id = r.get('id','')
        flutter = req.get('flutter_version') or det.get('flutter_version') or ''
        os_name = det.get('runner_os','') or req.get('runs_on','')
        jdk = req.get('jdk','') if platform == 'android' else ''
        agp = det.get('agp_version','') or req.get('agp','')
        gradle = det.get('gradle_version','') or req.get('gradle','')
        kotlin = det.get('kotlin_version','') or req.get('kotlin','')
        sdk_triplet = det.get('android_sdk_triplet','')
        xcode_swift = ''
        pods_ruby = ''
        if platform == 'ios':
            xcode = det.get('xcode_version','')
            swift = det.get('swift_version','')
            pods = det.get('cocoapods_version','')
            ruby = det.get('ruby_version','')
            xcode_swift = ' / '.join([x for x in [xcode, swift] if x])
            pods_ruby = ' / '.join([x for x in [pods, ruby] if x])

        outcome = r.get('outcome','fail')
        print(f"| `{row_id}` | {platform} | {flutter} | {os_name} | {jdk} | {agp} | {gradle} | {kotlin} | {sdk_triplet} | {xcode_swift} | {pods_ruby} | {emoji(outcome)} {outcome} |")

    print('\n### Notes')
    print('- Android rows build a Debug APK using the repo\'s Gradle wrapper (`android/gradlew`).')
    print('- iOS rows build with `flutter build ios --no-codesign` and run `pod install`.')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
