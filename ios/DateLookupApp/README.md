# DateLookupApp iOS

清爽日历原生 iOS MVP，使用 SwiftUI 构建，调用仓库中的 Java Spring Boot 后端。

## 打开方式

在 macOS 上使用 Xcode 打开：

```bash
open ios/DateLookupApp/DateLookupApp.xcodeproj
```

或直接用命令行测试：

```bash
cd ios/DateLookupApp
xcodebuild test -project DateLookupApp.xcodeproj -scheme DateLookupApp -destination 'platform=iOS Simulator,name=iPhone 16'
```

运行前先启动后端：

```bash
npm run dev:backend
```

默认 API 地址在 `DateLookupApp/Info.plist` 的 `API_BASE_URL` 中，当前为 `http://localhost:4000`。如果在真机调试，需要改成电脑的局域网 IP，例如 `http://192.168.1.10:4000`。

## MVP 页面

- 月视图日历
- 每日详情分类卡片
- 快速记录表单
- 月度统计
