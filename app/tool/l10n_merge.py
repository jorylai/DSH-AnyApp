#!/usr/bin/env python3
# coding: utf-8
"""Merge the source ARB parts and regenerate Flutter localization classes."""
import argparse
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--check', action='store_true')
parser.add_argument('--no-gen', action='store_true')
args = parser.parse_args()
app = Path(__file__).resolve().parents[1]
root = app / 'lib' / 'l10n'
merged = {}
for lang in ('zh', 'en'):
    result = {'@@locale': lang}
    for source in sorted((root / 'parts').glob('*_' + lang + '.arb')):
        for key, value in json.loads(source.read_text(encoding='utf-8')).items():
            if key.startswith('@@'):
                continue
            if key in result:
                raise SystemExit('Duplicate localization key: ' + key)
            result[key] = value
    merged[lang] = result
keys = lambda data: {k for k in data if not k.startswith('@')}
if keys(merged['zh']) != keys(merged['en']):
    raise SystemExit('English and Chinese localization keys differ')
for lang, result in merged.items():
    target = root / ('app_' + lang + '.arb')
    text = json.dumps(result, ensure_ascii=False, indent=2) + '\n'
    if args.check:
        if target.read_text(encoding='utf-8') != text:
            raise SystemExit('Run app/tool/l10n_merge.py to update ' + target.name)
    else:
        target.write_text(text, encoding='utf-8')
if not args.check and not args.no_gen:
    subprocess.run(['flutter', 'gen-l10n'], cwd=str(app), check=True)
print('Localization sources are in sync.')
