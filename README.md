# DateLookupApp

清爽日历 MVP：一个前后端分离的日历生活记录应用。

## 功能

- 原生 iOS SwiftUI MVP，包含月历、每日详情、快速记录和月度统计
- 月视图日历，展示每日记录摘要
- 每日详情，按运动、饮食、记账、Tips 分类展示
- 新增记录，支持时间、数值、备注与心情/强度字段
- 月度统计，展示运动、饮食、支出和打卡概览
- 后端 SQLite 持久化和 REST API

## 技术栈

- Frontend: React, TypeScript, Vite
- iOS: SwiftUI, XCTest
- Backend: Java 17, Spring Boot, SQLite

## 本地运行

后端和网页原型：

```bash
npm install
npm run dev
```

前端默认运行在 `http://localhost:5173`，后端默认运行在 `http://localhost:4000`。

后端也可以单独运行：

```bash
mvn -f backend/pom.xml spring-boot:run
```

iOS App：

```bash
open ios/DateLookupApp/DateLookupApp.xcodeproj
```

在 iOS 模拟器里访问本机后端可使用默认 `http://localhost:4000`。真机调试时，把 `ios/DateLookupApp/DateLookupApp/Services/APIClient.swift` 里的 `defaultBaseURL` 改成电脑的局域网地址。

Mac 上可以直接运行 iOS 测试：

```bash
cd ios/DateLookupApp
xcodebuild test -project DateLookupApp.xcodeproj -scheme DateLookupApp -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 构建与测试

```bash
npm run build
npm test
```
