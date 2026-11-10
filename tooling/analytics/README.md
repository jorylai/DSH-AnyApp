# AnyApp 前端事件协议 v1

[English](README.en.md)

本模块记录产品使用流程，不记录业务内容。旧 usage_stats_* 同意、随机标识、队列及旧上报器已停用；不能通过 DSH_USAGE_ENDPOINT 恢复。新开关默认关闭，不继承旧同意。它与 DeepSeek 引擎的模型请求会话日志及反馈诊断分别管理。

## 接收地址

构建时显式配置 `--dart-define=ANYAPP_ANALYTICS_ENDPOINT=https://<自有服务>/api/events`。默认没有地址；未配置时，用户主动开启后仅在本机记录和导出。配置只接受 HTTPS，不允许用户名、密码、query、fragment，不接受 dshtui.com 及其子域，不跟随重定向。客户端请求标识为 dsh-anyapp，无 Cookie/Authorization。

此仓库新增的是前端与协议，没有部署接收服务或运营看板，也没有实际发送测试数据。

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
| preset | 可选，voyo/calorie/imported |
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
