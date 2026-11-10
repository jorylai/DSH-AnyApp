# DSH AnyApp 发行素材

本分支发行包使用 AnyApp 自有视觉资源。原 DSH Go 品牌与吉祥物不随本发行包分发。历史兼容路径和内部标识继续保留，不代表仍使用原美术素材。

- 应用标识、启动图标：`tooling/anyapp-art.cjs` 与 `tooling/anyapp-release-art.cjs` 生成的窗口加号图形。
- 单色图标与 Flutter 矢量：`app/lib/ui/shell/brand_glyph_anyapp.dart`，使用自有几何图形。
- 活动指示、兼容桌宠包和提示插图：`tooling/anyapp-release-art.cjs` 生成的星点轨道，无第三方图片输入。旧资源目录名仅为保存设置兼容。
- 这些自有资源随本仓库按 AGPL-3.0 提供，见 LICENSE。
- 比价雷达的图标随作者提供的 1.25.0 插件原样预置，见 `products/radar-release/README.txt`。
- 第三方代码、字体、图标、运行时仍适用各自许可，署名及全文见 `THIRD_PARTY_NOTICES.md`，本次素材替换不改变第三方代码许可。

重新生成：先运行 `node tooling/anyapp-art.cjs`，再运行 `node tooling/anyapp-release-art.cjs`。两者需要 Sharp。
