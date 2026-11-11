# AnyApp 前端事件协议 v1


## Android 友盟接入（0.10.12）

Android 使用官方 umeng-cli 0.2.17、umeng-skills-index 1.13.0 的 umeng-onboarding 流程。全流程包装器在 Mac 上错误地强制要求 CocoaPods，因此保留编排阶段记录，补调同一官方套件内未修改的 Flutter 核心安装程序；未创建 iOS 工程。安装顺序为统计，再安装 APM 及原生崩溃配置。

实际解析的 Flutter 依赖为 umeng_common_sdk 1.3.1、umeng_apm_sdk 2.3.7；Android 为 Common 10.0.1、ASMS 1.8.7.2、APM 2.0.1。公共依赖通过 Flutter 插件传递引入一次。渠道为用户指定的 `https://github.com/jorylai/DSH-AnyApp`，不接入推送，不需要 Message Secret。保留应用 http 1.6.x，通过 override 兼容 APM 的旧版约束；APM 使用的 MultipartRequest/MultipartFile API 保持兼容。

初始化顺序：Application 配置 UMCrash 并 preInit → 页面启动 → 用户同意本版本披露并保存 → 原生同意状态核对 → initCommon → APM.init → 页面观察及固定枚举事件。官方 Common Flutter 插件的 initCommon 在 Android 不返回 MethodChannel 结果，调用遵循官方示例，不 await 未完成的 Future；避免挡住后续 APM 初始化。APM 不重复创建 Flutter binding 或重启 Widget 树，保留原有动画时钟。未开启自动网络请求追踪，不向统计事件添加账号、提示词或作品内容。

默认关闭。旧版仅本机统计的同意不自动授予友盟；统计记录增加 diagnosticsConsent 版本。关闭时明确确认退出应用以终止 SDK 内部计时器；原生撤回记录优先于过期的 Dart 同意记录。应用账号、作品和业务记录不属于清理范围。诊断 SDK 本身处理设备/应用信息、性能和异常日志，详见应用内友盟隐私链接。

清洁构建时，先安装官方技能，再在 flutter pub get 后运行套件自带的 `scripts/umeng-flutter-apm-integration/plugin_fixer.py <app路径>`，修复官方插件的桩文件、compileSdk 和 jcenter 兼容问题；不要把本机 pub-cache 的修改误认为已经写入源码。

验证以本轮启动前后的 getTodayData 增量、端侧 SDK 证据及 APM 异常记录分别判断。初始化或编译通过不等于数据已入库；免费版采样及接口权限限制须在验证记录中单独标注。

[English](README.en.md)

本模块记录产品使用流程，不记录业务内容。旧 usage_stats_* 同意、随机标识、队列及旧上报器已停用；不能通过 DSH_USAGE_ENDPOINT 恢复。新开关默认关闭，不继承旧同意。它与 DeepSeek 引擎的模型请求会话日志及反馈诊断分别管理。

## 接收地址

构建时显式配置 `--dart-define=ANYAPP_ANALYTICS_ENDPOINT=https://<自有服务>/api/events`。默认没有自有服务地址；未配置时自有队列仅在本机记录和导出。Android 用户开启友盟开关后，固定事件仍由独立 SDK 发送友盟。配置只接受 HTTPS，不允许用户名、密码、query、fragment，不接受 dshtui.com 及其子域，不跟随重定向。客户端请求标识为 dsh-anyapp，无 Cookie/Authorization。

本节仅描述可选自有接收服务；不代表该接收服务已部署。友盟 SDK 走前述独立接入路径。

## 请求与确认

一次 JSON POST：`{"schema":"dsh-anyapp.analytics/1","events":[...]}`，最多20条。事件固定字段：

| 字段 | 含义 |
| --- | --- |
| id | 随机事件ID，重试不变；服务端必须据此去重 |
| event | AnyappEvent 固定枚举 |
| at | UTC 时间 |
| install_id | 随机安装统计标识，7天轮换；不是系统设备ID |
| session_id | 本次进程随机标识 |
| app_version | 当前构建版本 |
| page | 可选，固定页面枚举 |
| outcome | 可选，start/success/failure/cancelled/skipped |
| preset | 可选，voyo/calorie/radar/pomodoro/imported |
| elapsed_ms | 可选，非负耗时，上限24小时 |

没有自由文本属性入口，不传作品ID/名称、提示词、对话、账号、授权网址、错误消息、截图、读屏内容、商品、健康或行程记录。

接收服务须在可靠保存整批事件后返回2xx；前端会删除该批。网络超时可能发生在服务器已保存后，重试仍带相同事件ID。非2xx保留本批并退避重试，禁止以重定向更换接收方。服务端仍需自行实现限流、字段验证、留存和删除规则；不要将本协议视为服务端已上线。

## 前端可靠性

队列最多200条，超限删除最旧记录；统计不应阻塞用户操作。超时8秒，失败从30秒开始指数退避，最大6小时，跨重启保留退避。事件和随机标识最长7天，到期清理；重启更换session。关闭或清除时取消在途客户端连接并清理待处理队列，不回收服务器已经收到的请求。关闭的本机保存若失败，界面显示失败并提供“重试保存”；不能把当前进程的关闭误当成持久化完成。

导出仅包含本机待处理/待发送事件，成功发送的事件不保留完整本地历史。请不要用导出文件估算已发送的全部使用量。

## 事件口径

- appOpen：本进程第一次获得有效同意后一次；未同意期间不补记历史。
- pageView/onboardingStep：实际页面或阶段变化时记录，不放在每次build中。
- runtimeInstall：本地安装尝试，核验真实安装状态后记结果；已安装环境的重启不是一次新安装。
- loginResult：以DSH实际结果为准，浏览器成功打开不等于已登录；离开/取消与失败区分。
- creatorResult：创作者会话创建的结果，不等于作品已经开发完成。
- workOpen：从作品卡片发起的打开；workReady以真实页面就绪握手为准。已就绪缓存重现后，按实际帧计热开耗时；未就绪缓存不能记成功。
- presetInstall/presetResult：一次独立副本安装尝试与终态；恢复时已published的部分只核验，不重复记新安装。
- permissionResult：重新读取原生状态后记录，打开授权页本身不代表授权成功。

固定枚举及唯一实现见 `app/lib/analytics/anyapp_analytics.dart`。源头埋点覆盖引导、登录、首页、创作、作品界面与预置入口。模型内部推理、后台任务执行完成率未在这版前端事件中冒充已验收。

本轮验证（2026-11-11）：26 项统计／界面测试、静态检查、文案一致性检查通过；正式包 0.10.12+2026110935 已覆盖安装，首页仍有原有 8 个作品。U-App 官方接口确认启动 0→1、新增 0→1；UMCrash 捕获一次已授权的原生测试崩溃，重启恢复。U-APM 云端回查返回 threshold_free，未确认异常云端入库；未单独注入 Dart 异常。
