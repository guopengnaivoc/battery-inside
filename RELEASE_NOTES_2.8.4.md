## 电池内显 2.8.4

- 修复部分 Intel Mac 中 Finder 已显示圆角、但启动台或应用列表仍显示旧方形图标的问题
- 将应用图标资源从旧的 `AppIcon.icns` 更名为 `BatteryInsideRoundedIcon.icns`，主动绕开旧资源缓存
- 提升应用构建版本，促使 Launch Services 重新读取图标声明
- 保留原 Bundle ID，不影响现有设置、登录启动状态和菜单栏位置记忆
- 应用继续同时支持 Intel (`x86_64`) 与 Apple 芯片 (`arm64`)

升级时请退出旧版，将新版拖入“应用程序”并选择替换。若启动台仍短暂显示旧图标，重启 Mac 后系统会重新载入新版资源。
