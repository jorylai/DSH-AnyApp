# 图标规范：Emoji、内置符号与 AI 原创矢量

作品图标统一输出256×256 PNG，与「墨蓝微光」的圆角、渐变和内缘一致。用户选定的名称和图标优先；作品只通过 `work.describe` 声明默认值。换图标不改变作品 ID、profile、会话或记录。生成结果先预览，用户应用后才替换；取消或失败保留原图。

## 三种创作方式

- **Emoji：**离线收录 Unicode Emoji17.0 的3944个完整合格序列，覆盖9类及肤色、家庭、旗帜等组合；支持中英文名称和关键词搜索。单独肤色/发型修饰符不是独立图标。目录版本不等于手机字体支持版本，手机选择器会检测所选表情的系统字形；不支持时保留原图并提示换一个。插件仍需在真实手机预览确认。图案使用手机自带 Emoji 字体，没有复制 Apple 或其他厂商的 Emoji 图片。
- **内置符号：**使用宿主实际提供的 Material 语义符号；完整键名见 `components.json`。适合克制、统一的工具类作品，也作为旧图标和异常显示的兜底。
- **AI 原创矢量：**用户可以描述「橙色碗与一片叶子」等构想，或让当前已登录模型按作品用途设计。模型创作圆形、圆角矩形和折线组成的独有符号，宿主校验后绘成 PNG；不再只是从少量现成符号里随机选择。使用现有 DSH 模型会话，不索取第二个模型账号。这是文本模型辅助矢量设计，目前没有把图片理解接口当作图片生成接口，也不会凭空新增图片生成网址。

## 公共渲染 API

```js
// 旧作品继续可用：
await dshWish.icons.render({glyph:'book',palette:'indigo',variant:0});

// Emoji 必须是目录内完整序列，保留 ZWJ、肤色、旗帜及表现选择符：
await dshWish.icons.render({kind:'emoji',emoji:'🍋',palette:'mint',variant:1});

// 原创几何图标；以下只用于示范结构，应根据作品设计自己的构图：
await dshWish.icons.render({
  kind:'vector',palette:'amber',variant:0,
  shapes:[
    {type:'circle',cx:32,cy:32,r:15,fill:'foreground'},
    {type:'roundRect',x:29,y:20,w:6,h:20,r:3,fill:'background'},
    {type:'path',points:[[22,44],[32,50],[42,44]],closed:false,
      fill:'none',stroke:'accent',width:3}
  ]
});
```

返回对象包含 `{bitmap:base64,builtin,kind,palette,variant,styleVersion}`，Emoji 另含 `emoji`；可用 `data:image/png;base64,${bitmap}` 预览。原生持久化经过校验的 PNG，各入口复用该结果，不在首页重新调用 AI 或重新生成。实际字段与允许值以宿主桥为准；不能用这条 API 装载外部 URL、SVG、脚本或任意绘制代码。

## 造型与校验

背景采用256方形、60px圆角与轻微光晕，主视觉居中。保持醒目的外轮廓和足够留白，32px仍能辨识，禁止小字、品牌商标拼贴和过度复杂的插画。Emoji 自身已有颜色，避免再叠加模糊描边。先看真实预览，不以目录名称代替视觉验收。

- 调色板：`indigo/violet/mint/amber/rose`；`variant` 为0、1、2。
- 矢量画布为64×64，主体建议落在8..56。所有路径点、圆形和矩形的边界必须在2..62内；数值有限，不能使用表达式。
- 最多16个图形，所有折线路径合计最多96个点。圆半径及矩形宽高至少1；圆角半径允许0，不能大于短边一半。
- 支持 `circle(cx,cy,r)`、`roundRect(x,y,w,h,r)`、`path(points,closed)`。每个点是 `[x,y]` 数组；不接受 SVG path 字符串。填充路径须闭合且至少3点。
- `fill/stroke` 只允许 `foreground/accent/white/background/none`，且至少一个可见；描边宽度0.5..6，统一圆头和圆角。颜色使用语义角色，不能混入外部图片、文字、URL或事件属性。

## 来源与能力边界

Emoji 数据来自 [Unicode emoji-test17.0](https://www.unicode.org/Public/17.0.0/emoji/emoji-test.txt)，中文/英文搜索标签来自 [Unicode CLDR48](https://github.com/unicode-org/cldr/tree/release-48)。版本、来源哈希、许可及再生成说明见 `app/assets/emoji/sources.json`、`LICENSE.txt` 与 `README.md`；这些是文字数据，不包含第三方绘图素材。现有 Material 图标字体按 Flutter 随附许可分发。

当前 AI 图标入口通过 `WishModels.complete` 复用运行中 DSH 的登录和模型路由，仅解析受控几何 JSON。DeepSeek 官方 [Vision 文档](https://api-docs.deepseek.com/guides/vision/)介绍的是图片输入与理解，不能据此声称已提供图片生成。仓库内另有独立媒体插件，需要实际配置图片服务与凭据；本图标入口未自动启用该服务，也未改变用户模型配置。
