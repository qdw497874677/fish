# 《水族守卫》Godot Web 技术方案

## 1. 技术路线

本项目使用 Godot 开发，首发目标为 Web 版。

推荐配置：

- 引擎：Godot 4.x Stable
- 语言：GDScript
- 类型：2D
- 渲染：Compatibility 优先，降低 Web 兼容风险
- 导出：Godot Web Export
- 线程：优先使用单线程 Web 导出

## 2. 为什么使用单线程 Web 导出

Godot Web 导出如果启用多线程，会依赖浏览器的 SharedArrayBuffer。根据官方文档，多线程 Web 导出需要服务器提供跨源隔离响应头：

```text
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

这会提高部署门槛，尤其是在免费静态托管、嵌入页、小游戏平台或部分 WebView 环境中容易出问题。

因此 MVP 阶段建议：

```text
关闭 Use Threads / 使用单线程 Web 导出
```

好处：

- 更容易部署
- 更容易在浏览器中打开
- 避免 SharedArrayBuffer 相关安全头配置
- 更适合轻量 2D 点击游戏

代价：

- 音频延迟和多线程性能不如开启线程
- 需要控制实体数量和特效数量

对于《水族守卫》这种 2D 休闲点击游戏，单线程足够。

## 3. 项目目录建议

Godot 项目初始化后建议使用以下结构：

```text
res://
  scenes/
    main/
      MainMenu.tscn
      AquariumLevel.tscn
      ResultScreen.tscn
    entities/
      Fish.tscn
      Food.tscn
      Coin.tscn
      Enemy.tscn
      Pet.tscn
    ui/
      Hud.tscn
      ShopBar.tscn
      WarningBanner.tscn

  scripts/
    core/
      game_manager.gd
      save_manager.gd
      config_loader.gd
      event_bus.gd
    entities/
      fish.gd
      food.gd
      coin.gd
      enemy.gd
      pet.gd
    systems/
      economy_system.gd
      level_system.gd
      spawn_system.gd
      enemy_wave_system.gd
    ui/
      hud.gd
      shop_bar.gd
      result_screen.gd

  data/
    fish.json
    food.json
    enemies.json
    pets.json
    levels.json

  art/
    sprites/
    backgrounds/
    ui/

  audio/
    sfx/
    music/
```

## 4. 场景结构

### 4.1 AquariumLevel.tscn

建议结构：

```text
AquariumLevel (Node2D)
├── Background (Sprite2D)
├── PlayArea (Node2D)
│   ├── FishLayer (Node2D)
│   ├── FoodLayer (Node2D)
│   ├── CoinLayer (Node2D)
│   ├── EnemyLayer (Node2D)
│   └── PetLayer (Node2D)
├── Systems (Node)
│   ├── EconomySystem
│   ├── LevelSystem
│   ├── SpawnSystem
│   └── EnemyWaveSystem
├── CanvasLayer
│   ├── Hud
│   ├── ShopBar
│   └── WarningBanner
└── AudioPlayers
```

## 5. 主要脚本职责

### Fish

负责：

- 随机游动
- 寻找食物
- 进食
- 成长
- 饥饿死亡
- 定时产金币
- 被敌人攻击

### Food

负责：

- 从投放点下沉
- 被鱼锁定
- 被吃掉
- 触底消失

### Coin

负责：

- 下沉
- 点击收集
- 超时消失

### Enemy

负责：

- 入侵移动
- 选择目标鱼
- 追逐
- 被点击扣血
- 击杀鱼
- 死亡奖励

### Pet

负责：

- 自动行为
- 被动技能
- 与金币、食物、敌人等系统交互

## 6. 输入设计

Godot Web 版需要同时兼容鼠标和触摸。

建议统一使用 Godot 的输入事件：

```gdscript
func _unhandled_input(event):
    if event is InputEventMouseButton and event.pressed:
        handle_pointer_down(event.position)
    elif event is InputEventScreenTouch and event.pressed:
        handle_pointer_down(event.position)
```

输入优先级：

1. 如果点中 UI，由 UI 处理
2. 如果点中金币，收集金币
3. 如果敌人存在且点中敌人，攻击敌人
4. 否则在水体区域投喂食物

## 7. 数据配置

为了方便调数，鱼、敌人、关卡、助手都应从 JSON 或 Resource 配置读取。

MVP 可先用 JSON：

```json
{
  "id": "blue_bubble_fish",
  "name": "蓝泡鱼",
  "price": 100,
  "growth_seconds": 20,
  "coin_value": 15,
  "coin_interval": 8,
  "hunger_seconds": 25
}
```

后续如果需要编辑器内调参，可以改为 Godot 自定义 Resource。

## 8. Web 导出注意事项

当前项目暂时采用手动 Web 包装方式：官方 Web runtime 文件 + `godot.pck` + 自定义 `index.html`。因为 `index.html` 中 `GODOT_CONFIG.executable` 为 `"godot"`，所以 PCK 文件必须命名为 `godot.pck`，否则浏览器会报 `Failed loading file 'godot.pck'`。

### 8.1 资源体积

网页版应尽量控制首包大小。

建议：

- 使用压缩纹理或尺寸较小的 PNG/WebP
- 音频使用 OGG 或 MP3，长度控制
- MVP 阶段不要放大体积背景音乐
- 避免过多大尺寸图集

### 8.2 音频启动

浏览器通常要求用户交互后才能播放音频。背景音乐应在玩家点击“开始游戏”后播放。

### 8.3 移动浏览器

Web 版应从第一天考虑移动浏览器：

- UI 按钮足够大
- 不依赖键盘
- 不依赖右键
- 控制实体数量
- 避免复杂粒子效果

### 8.4 部署

MVP 可部署到：

- itch.io
- GitHub Pages
- Netlify
- Vercel
- 自有服务器

如果启用多线程，则部署服务器必须配置 COOP/COEP 响应头；MVP 阶段不建议启用。

## 9. 小程序迁移备注

当前技术路线以 Godot Web 为主。后续迁移微信小游戏存在高风险，需要单独评估：

- Godot Web 导出依赖 WebAssembly
- 小游戏环境不是标准浏览器
- 包体、音频、WebGL 和平台 API 都需要适配
- 可能需要社区插件或自定义导出模板

因此小程序迁移不作为 MVP 阶段目标。

## 10. 开发原则

- 先做可玩闭环，再做视觉完善
- 所有数值可配置
- 场景和实体尽量复用
- 不在实体脚本里硬编码关卡流程
- 优先保证 Web 可运行
- 每个阶段都导出 Web 测试一次
