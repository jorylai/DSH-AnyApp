#!/usr/bin/env python3
"""Build AnyApp's offline Emoji 17 catalog from pinned Unicode/CLDR data.

Network is used only with --download. No emoji image artwork is downloaded.
The generated catalog is data, not a bundled font: device font support varies.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import tempfile
import urllib.request
import xml.etree.ElementTree as ET

APP = Path(__file__).resolve().parents[1]
OUT = APP / 'assets' / 'emoji'
SOURCES = {
    'emoji-test.txt': (
        'https://www.unicode.org/Public/17.0.0/emoji/emoji-test.txt',
        '1d8a944f88d7952f7ef7c5167fef3c67995bcae24543949710231b03a201acda'),
    'zh.xml': (
        'https://raw.githubusercontent.com/unicode-org/cldr/release-48/common/annotations/zh.xml',
        '92389f71659998736530c72d4dcc86e453fe0be170cde5c5ad27094cab2a2de8'),
    'en.xml': (
        'https://raw.githubusercontent.com/unicode-org/cldr/release-48/common/annotations/en.xml',
        '8511aadd046fdba2f0ffe590266ced8bbf48175ad139b2675d85d7141057b235'),
    'zh-derived.xml': (
        'https://raw.githubusercontent.com/unicode-org/cldr/release-48/common/annotationsDerived/zh.xml',
        '777acebb7c4ed103c34f5605881a2537656e0a17d9d1127518da7cd54f612bcc'),
    'en-derived.xml': (
        'https://raw.githubusercontent.com/unicode-org/cldr/release-48/common/annotationsDerived/en.xml',
        'd76bd041c8c9e7b00b716aff8b7d9dbf509877010e191d5efd068be2553e066e'),
    'LICENSE.txt': (
        'https://raw.githubusercontent.com/unicode-org/cldr/release-48/LICENSE',
        'b4c0ae8ef04f7059f96ce5bbe0467f9fe6f6d81bbe13517701dfeb961fb4d0b6'),
}
GROUPS = {
    'Smileys & Emotion': 'smileys-emotion',
    'People & Body': 'people-body',
    'Animals & Nature': 'animals-nature',
    'Food & Drink': 'food-drink',
    'Travel & Places': 'travel-places',
    'Activities': 'activities',
    'Objects': 'objects',
    'Symbols': 'symbols',
    'Flags': 'flags',
}
ROW = re.compile(r'^([0-9A-F ]+)\s*;\s*fully-qualified\s*#\s*(\S+)\s+E([0-9.]+)\s+(.+)$')


def verified_sources(folder: Path, download: bool) -> dict[str, bytes]:
    result = {}
    for name, (url, expected) in SOURCES.items():
        target = folder / name
        if download:
            with urllib.request.urlopen(url, timeout=40) as response:
                content = response.read()
            if hashlib.sha256(content).hexdigest() != expected:
                raise ValueError(f'Source changed: {url}; review and pin the new hash first')
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)
        content = target.read_bytes()
        if hashlib.sha256(content).hexdigest() != expected:
            raise ValueError(f'Unverified source: {target}')
        result[name] = content
    return result


def annotations(data: dict[str, bytes], lang: str) -> dict[str, dict[str, str]]:
    result: dict[str, dict[str, str]] = {}
    for name in (f'{lang}.xml', f'{lang}-derived.xml'):
        for node in ET.fromstring(data[name]).findall('.//annotation'):
            cp = node.attrib['cp'].replace('\ufe0f', '')
            field = 'label' if node.attrib.get('type') == 'tts' else 'keywords'
            result.setdefault(cp, {})[field] = ''.join(node.itertext()).strip()
    return result


def build(data: dict[str, bytes]) -> dict[str, bytes]:
    zh, en = annotations(data, 'zh'), annotations(data, 'en')
    rows, group, seen = [], '', set()
    for line in data['emoji-test.txt'].decode('utf-8').splitlines():
        if line.startswith('# group: '):
            group = GROUPS.get(line.removeprefix('# group: '), '')
        match = ROW.match(line)
        if not match:
            continue
        codepoints, displayed, emoji_version, unicode_name = match.groups()
        emoji = ''.join(chr(int(c, 16)) for c in codepoints.split())
        if emoji != displayed or not group or emoji in seen:
            raise ValueError(f'Invalid or duplicate emoji row: {line}')
        seen.add(emoji)
        key = emoji.replace('\ufe0f', '')
        z, e = zh.get(key, {}), en.get(key, {})
        label_zh = z.get('label', '')
        if not label_zh:
            raise ValueError(f'Missing Chinese annotation for {unicode_name}')
        label_en = e.get('label', unicode_name)
        words = [unicode_name, label_zh, label_en]
        # Regional-indicator country flags are also searchable by ISO letters.
        points = [ord(c) for c in emoji]
        if len(points) == 2 and all(0x1F1E6 <= c <= 0x1F1FF for c in points):
            words.append(''.join(chr(c - 0x1F1E6 + ord('A')) for c in points))
        words.extend(z.get('keywords', '').split(' | '))
        words.extend(e.get('keywords', '').split(' | '))
        keywords = list(dict.fromkeys(w for w in words if w))
        rows.append([emoji, label_zh, label_en, group, keywords, emoji_version])
    if len(rows) != 3944:
        raise ValueError(f'Emoji 17 fully-qualified coverage changed: {len(rows)}')
    catalog = {
        'schema': 1,
        'unicodeVersion': '17.0',
        'cldrVersion': '48',
        'columns': ['emoji', 'labelZh', 'labelEn', 'group', 'keywords', 'emojiVersion'],
        'groups': list(GROUPS.values()),
        'entries': rows,
    }
    manifest = {
        'unicodeVersion': '17.0',
        'cldrVersion': '48',
        'entryCount': len(rows),
        'license': 'Unicode-3.0',
        'sources': [{'file': name, 'url': url, 'sha256': sha}
                    for name, (url, sha) in SOURCES.items()],
        'modifications': 'Fully-qualified Emoji 17 sequences; merged CLDR zh/en labels and keywords; regional-indicator country code keywords; compact array encoding. No artwork or fonts included.',
    }
    return {
        'catalog.json': (json.dumps(catalog, ensure_ascii=False, separators=(',', ':')) + '\n').encode(),
        'sources.json': (json.dumps(manifest, ensure_ascii=False, indent=2) + '\n').encode(),
        'LICENSE.txt': data['LICENSE.txt'],
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source-dir', type=Path,
                        default=Path(tempfile.gettempdir()) / 'anyapp-emoji-inputs')
    parser.add_argument('--download', action='store_true', help='Download and verify the pinned public sources')
    parser.add_argument('--check', action='store_true', help='Verify outputs without modifying them')
    args = parser.parse_args()
    outputs = build(verified_sources(args.source_dir, args.download))
    for name, content in outputs.items():
        target = OUT / name
        if args.check:
            if not target.exists() or target.read_bytes() != content:
                raise SystemExit(f'Out of date: {target}')
        else:
            OUT.mkdir(parents=True, exist_ok=True)
            target.write_bytes(content)
    print(f'Emoji 17.0 / CLDR 48: 3944 fully-qualified sequences; {"verified" if args.check else "generated"}.')


if __name__ == '__main__':
    main()
