# Mac iOS Runbook

这份文档用于在 Mac 上运行 `DateLookupApp` 的原生 iOS App，并连接仓库里的 Java Spring Boot 后端。

## 1. 环境要求

- macOS
- Xcode 16 或更新版本
- Java 17
- Maven 3.9+
- Node.js 20+
- npm

检查命令：

```bash
xcodebuild -version
java -version
mvn -version
node -v
npm -v
```

## 2. 拉取项目

```bash
git clone git@github.com:caesaemc/DateLookupApp.git
cd DateLookupApp
```

## 3. 安装前端脚本依赖

根目录脚本使用 `npm` 同时管理网页原型和后端启动命令。

```bash
npm install
```

## 4. 启动 Java 后端

iOS App 当前默认请求：

```text
http://localhost:4000
```

启动后端：

```bash
npm run dev:backend
```

确认后端可用：

```bash
curl http://localhost:4000/api/health
```

预期返回：

```json
{"ok":true}
```

查看当前记录数据：

```bash
curl "http://localhost:4000/api/records?month=2026-06"
```

后端数据库位置：

```text
backend/data/app.sqlite
```

## 5. 打开 iOS 工程

另开一个终端窗口：

```bash
open ios/DateLookupApp/DateLookupApp.xcodeproj
```

在 Xcode 中：

1. 选择 scheme：`DateLookupApp`
2. 选择模拟器：推荐 `iPhone 16`
3. 点击 Run

## 6. 命令行运行 iOS 测试

如果你想先用命令行确认工程能编译测试：

```bash
cd ios/DateLookupApp
xcodebuild test \
  -project DateLookupApp.xcodeproj \
  -scheme DateLookupApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

也可以运行脚本：

```bash
cd ios/DateLookupApp
bash scripts/xcode-test.sh
```

## 7. 当前 iOS 页面长什么样

当前 App 是一个单页纵向滚动界面，结构如下：

```text
清爽日历                         今天
记录生活，发现美好

[ 2026年6月  < > ]
日 一 二 三 四 五 六
月历网格
每天格子里显示最多 3 条小标签：
跑步 5.02km / 早餐 360 / 支出 25

每日详情
6月2日 星期二
[运动] [饮食] [记账] [Tips]

横向滑动记录卡片：
- 晨跑
  07:30 · 运动
  距离 5.02 公里
  消耗 320 kcal
  时长 30 分钟
  状态轻松，配速稳定。

快速记录
[运动] [饮食] [记账] [Tips]
标题
时间
距离 km / 消耗 kcal
心情：轻松 / 适中 / 较高 / 愉快
笔记
[保存记录]

月度趋势
跑步距离 / 总消耗 / 摄入热量 / 支出
运动、饮食、记账、Tips 四个环形统计
```

视觉方向：

- 白色卡片
- 浅青背景
- 青绿色主色
- 8px 圆角
- SF Symbols 图标
- 接近设计图里的“清爽日历”风格

## 8. 模拟器和真机的后端地址

### iOS 模拟器

模拟器访问 Mac 本机后端时，可以使用默认地址：

```text
http://localhost:4000
```

当前配置位置：

```text
ios/DateLookupApp/DateLookupApp/Info.plist
```

键名：

```text
API_BASE_URL
```

### iPhone 真机

真机不能用 `localhost` 访问 Mac。需要把 `API_BASE_URL` 改成 Mac 的局域网 IP。

查看 Mac IP：

```bash
ipconfig getifaddr en0
```

如果输出是：

```text
192.168.1.10
```

则把 `Info.plist` 中的：

```text
http://localhost:4000
```

改为：

```text
http://192.168.1.10:4000
```

然后重启 iOS App。

## 9. App 功能验证流程

启动后端和 iOS App 后，按这个顺序检查：

1. 首页显示“清爽日历”和“记录生活，发现美好”
2. 月历显示当月日期
3. 有示例记录时，日期格子里出现小标签
4. 点击日期，下面“每日详情”切换到对应日期
5. 点击分类按钮：运动、饮食、记账、Tips
6. 在“快速记录”里修改标题或数值
7. 点击“保存记录”
8. 月历当天标签增加
9. 每日详情出现新记录卡片
10. 月度趋势统计更新
11. 点击记录卡上的删除图标，记录被删除

## 10. 常见问题

### 后端没启动

现象：

```text
加载失败，请确认后端服务已启动。
```

处理：

```bash
npm run dev:backend
curl http://localhost:4000/api/health
```

### 真机访问不到后端

处理：

1. 确认 iPhone 和 Mac 在同一个 Wi-Fi
2. 用 `ipconfig getifaddr en0` 获取 Mac IP
3. 修改 `Info.plist` 的 `API_BASE_URL`
4. 确认 Mac 防火墙没有拦截 4000 端口

### Xcode 找不到模拟器名称

查看可用模拟器：

```bash
xcrun simctl list devices available
```

然后把 `xcodebuild` 命令里的 `iPhone 16` 改成实际存在的设备名。

### App 图标警告

当前工程已有 `AppIcon.appiconset` 占位，但还没有真实 1024x1024 图标图片。这个不影响 Debug 运行。后续上架前需要补齐完整 App Icon。

## 11. 当前代码入口

iOS App 入口：

```text
ios/DateLookupApp/DateLookupApp/DateLookupApp.swift
```

主界面：

```text
ios/DateLookupApp/DateLookupApp/Views/ContentView.swift
```

后端 API Client：

```text
ios/DateLookupApp/DateLookupApp/Services/APIClient.swift
```

后端地址配置：

```text
ios/DateLookupApp/DateLookupApp/Info.plist
```

Java 后端入口：

```text
backend/src/main/java/com/datelookup/DateLookupApplication.java
```

