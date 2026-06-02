# DateLookupApp

清爽日历 MVP：一个前后端分离的日历生活记录应用。

## 功能

- 月视图日历，展示每日记录摘要
- 每日详情，按运动、饮食、记账、Tips 分类展示
- 新增记录，支持时间、数值、备注与心情/强度字段
- 月度统计，展示运动、饮食、支出和打卡概览
- 后端 SQLite 持久化和 REST API

## 技术栈

- Frontend: React, TypeScript, Vite
- Backend: Node.js, Express, TypeScript, SQLite

## 本地运行

```bash
npm install
npm run dev
```

前端默认运行在 `http://localhost:5173`，后端默认运行在 `http://localhost:4000`。

## 构建与测试

```bash
npm run build
npm test
```
