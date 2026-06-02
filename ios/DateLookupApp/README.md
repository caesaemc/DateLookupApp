# DateLookupApp iOS

清爽日历原生 iOS MVP，使用 SwiftUI 构建，调用仓库中的 Java Spring Boot 后端。

## 打开方式

在 macOS 上使用 Xcode 打开：

```bash
open ios/DateLookupApp/DateLookupApp.xcodeproj
```

运行前先启动后端：

```bash
npm run dev:backend
```

默认 API 地址是 `http://localhost:4000`。如果在真机调试，需要把 `APIClient.defaultBaseURL` 改成局域网 IP，例如 `http://192.168.1.10:4000`。

## MVP 页面

- 月视图日历
- 每日详情分类卡片
- 快速记录表单
- 月度统计

