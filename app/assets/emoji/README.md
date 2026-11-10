# AnyApp offline emoji catalog / 离线表情符号目录

This directory contains **3,944 fully-qualified Unicode Emoji 17.0 sequences**, with Chinese and English labels and search keywords from **Unicode CLDR 48**. Multi-codepoint flags, skin-tone and ZWJ sequences are preserved whole. Standalone skin-tone / hair components, unqualified duplicate spellings and arbitrary Unicode text are not separate picker entries.

此目录包含 Unicode Emoji 17.0 的 **3,944 个 fully-qualified 完整序列**，中文及英文名称、搜索关键词来自 Unicode CLDR 48。国旗、肤色、ZWJ 组合保持完整。肤色及发型修饰符不单独作为作品图标列出，未限定的重复写法及任意文字也不列为独立图标。

**No image artwork or emoji font is included.** The device's installed emoji font renders the selected sequence. Newer emoji may not render on older devices; catalog membership is not a claim of device font support. Text-presentation aliases such as `❤` can resolve to the catalog's `❤️` sequence.

**未捆绑任何表情图片或字体。** 图像由设备已安装的 Emoji 字体绘制。旧手机可能不能显示较新的表情；被目录收录不代表当前手机一定支持。`❤` 等文字显示形式可解析成标准的 `❤️` 序列。

## Provenance / 来源

- Emoji 17.0 official data: <https://www.unicode.org/Public/17.0.0/emoji/emoji-test.txt>
- CLDR release 48: <https://github.com/unicode-org/cldr/tree/release-48>
- Source URLs and pinned SHA-256 hashes: `sources.json`.
- Copyright © Unicode, Inc. Distributed under **Unicode License V3 (Unicode-3.0)**; full notice is retained in `LICENSE.txt`.
- Modifications: selected fully-qualified emoji; merged Chinese/English CLDR labels and keywords; compact array encoding. No Unicode labels were invented to fill missing translations.

来源地址和固定 SHA-256 见 `sources.json`。版权归 Unicode, Inc.，采用 Unicode License V3（Unicode-3.0），完整许可见 `LICENSE.txt`。加工仅包括完整序列筛选、中英文注释合并和紧凑编码。

## Regenerate / 重新生成

From the repository root / 在源码根目录执行：

```sh
python3 app/tool/update_emoji_catalog.py --download
python3 app/tool/update_emoji_catalog.py --check
```

`--download` fetches only the six official source files into the temporary `anyapp-emoji-inputs` directory and rejects changed hashes. `--check` is offline and compares deterministic generated outputs with those verified cached source files. Update the pinned versions and hashes deliberately when upgrading Unicode or CLDR.

`--download` 仅将六份官方来源文件下载到临时 `anyapp-emoji-inputs` 目录，并校验固定散列。`--check` 离线使用校验后的缓存重新生成并比较。升级时须明确修改 Unicode / CLDR 版本与散列。
