# 《水族守卫》项目开发规范

本文档约束后续开发方式，目标是让 Godot Web 版本保持可运行、可导出、可渐进重构。新增功能前先读本规范；如果规范和临时代码冲突，优先调整代码边界，而不是绕过规范。

## 1. 当前项目目标

- 使用 Godot 4.7 制作网页版 2D 水族箱经营 + 防守游戏。
- 首发目标是稳定 Web Demo，不承诺小程序迁移。
- Web 包采用手动包装方式，资源包固定为 `build/web/godot.pck`。
- 每次核心玩法、脚本分层或 UI 连接改动后，都必须能通过 headless 验证。

## 2. 目录与职责

当前保留单主场景：

```text
scenes/aquarium_level.tscn
scripts/aquarium_level.gd
```

`scripts/aquarium_level.gd` 是关卡总控，只应负责：

- Godot 生命周期：`_ready`、`_process`、`_input`、`_draw`
- 场景编排：开始关卡、回菜单、暂停、通关、失败
- UI 连接：按钮事件、菜单/存档面板显示隐藏
- 跨系统副作用：扣钱/加钱、播放音效、写存档、列表增删、统计计数
- 绘制调度：调用各类 `_draw_*` 函数

不要再把新的纯规则直接写回 `aquarium_level.gd`。如果逻辑可以独立输入输出，应放到下面的分层里。

### 数据层

```text
scripts/data/game_data.gd
```

只放关卡配置、鱼类型配置等静态数据。新增鱼、敌人、关卡参数优先从这里扩展。

### 系统层

```text
scripts/systems/audio_system.gd
scripts/systems/save_system.gd
```

系统层可以有内部状态，但应只管理单一系统：音频、存档等。不要让系统层直接操作鱼、敌人、金币列表。

### 玩法规则层

```text
scripts/gameplay/aquarium_queries.gd
scripts/gameplay/fish_logic.gd
scripts/gameplay/enemy_logic.gd
scripts/gameplay/resource_logic.gd
scripts/gameplay/combat_logic.gd
scripts/gameplay/wave_logic.gd
scripts/gameplay/effect_logic.gd
scripts/gameplay/economy_logic.gd
scripts/gameplay/progression_logic.gd
```

玩法规则层原则：

- 优先写 `static func`。
- 输入通过参数传入，不读取场景节点。
- 不播放音效。
- 不直接写存档。
- 不直接更新 UI。
- 可以修改传入的 `Dictionary`，但跨系统结算应留在主脚本。
- 可以返回判断结果、索引、位置、成本、view data。

例子：

- 可以：计算敌人是否被击败。
- 可以：计算下一波敌人间隔。
- 可以：计算清洁螺目标位置。
- 不可以：在规则层里调用 `_play_sfx`。
- 不可以：在规则层里调用 `_save_progress`。
- 不可以：在规则层里创建或删除 Godot 节点。

### UI 层

```text
scripts/ui/aquarium_ui_factory.gd
scripts/ui/aquarium_hud_presenter.gd
```

UI 层原则：

- UI factory 只负责创建控件和应用统一样式。
- HUD presenter 只负责把状态转成展示文本、禁用状态、按钮文案。
- UI 层不修改金币、鱼、敌人、关卡进度。

## 3. 新功能开发流程

每个功能都按以下顺序做：

1. 判断功能属于哪一层。
2. 先写或调整规则层函数。
3. 在 `aquarium_level.gd` 中只接入编排和副作用。
4. 更新相关文档。
5. 运行验证命令。
6. 涉及 Web 包时重新导出 `build/web/godot.pck`。

不要先在主脚本里快速堆逻辑，再说之后重构。这个项目已经进入多模块阶段，新增逻辑必须直接放到合适层。

## 4. 代码风格

- 使用 GDScript 静态类型标注，特别是函数参数、返回值、重要局部变量。
- 字典字段名使用已有风格：`"pos"`、`"velocity"`、`"growth"`、`"hunger"`、`"type"`。
- 继续使用 `Array[Dictionary]` 保存当前实体状态，直到正式开始节点化重构。
- 不使用无意义缩写。
- 不为了省行数合并复杂表达式。
- 新增常量优先放在主脚本顶部或对应逻辑模块中，不散落在函数内部。
- 注释只解释不明显的设计原因，不复述代码做了什么。

## 5. 实体数据约定

当前鱼、食物、金币、敌人仍是 `Dictionary`，不是独立节点。

### 鱼

常用字段：

```text
pos, velocity, wander_target, facing, type, growth, hunger, coin_timer, guard_cooldown, alive
```

鱼相关纯逻辑优先放在：

```text
scripts/gameplay/fish_logic.gd
```

### 敌人

常用字段：

```text
pos, hp, max_hp, speed, attack_cooldown, tank, type
```

敌人移动和攻击距离判断优先放在：

```text
scripts/gameplay/enemy_logic.gd
scripts/gameplay/combat_logic.gd
```

### 资源

食物字段：

```text
pos, nutrition, speed, life
```

金币字段：

```text
pos, value, speed, life
```

资源移动、生命周期和清洁螺目标选择优先放在：

```text
scripts/gameplay/resource_logic.gd
```

## 6. 副作用边界

以下操作暂时只允许在 `aquarium_level.gd` 或系统层中执行：

- `money += ...` / `money -= ...`
- `fish_list.append/remove_at`
- `enemy_list.append/remove_at`
- `coin_list.append/remove_at`
- `_play_sfx(...)`
- `_save_progress()`
- `_spawn_coin(...)`
- `_spawn_hit_effect(...)`
- `_spawn_guard_effect(...)`
- `queue_redraw()`

如果未来要把这些副作用下沉，必须先设计新的系统边界，不要在单个功能中顺手搬迁。

## 7. Web 导出规范

Web 包使用手动包装，PCK 名称固定：

```text
build/web/godot.pck
```

重新导出命令：

```bash
godot --headless --path . --export-pack Web "build/web/godot.pck"
```

不要改成 `game.pck` 或其他名称，否则 `build/web/index.html` 会加载失败。

完整 `--export-release Web` 当前仍可能受 preset 配置校验影响，不作为日常验证要求。日常使用 `--export-pack`。

## 8. 验证规范

每次修改脚本后至少运行：

```bash
godot --headless --path . --quit-after 120
```

涉及 Web 发布、脚本分层完成、资源路径变化后，再运行：

```bash
godot --headless --path . --export-pack Web "build/web/godot.pck"
```

已知非阻塞警告：

```text
WARNING: 2 ObjectDB instances were leaked at exit
```

如果只出现这个既有警告，可以继续；如果出现脚本错误、资源缺失、导出失败，必须先修复再继续。

## 9. 文档更新规范

以下情况必须更新文档：

- 新增脚本模块或改变模块职责：更新 `docs/web-runbook.md` 的“当前脚本分层”。
- 改变 Web 运行或导出方式：更新 `docs/web-runbook.md`。
- 改变玩法目标、关卡结构、核心循环：更新 `docs/mvp-game-design.md` 或 `docs/development-roadmap.md`。
- 改变架构原则或流程：更新本文档。

## 10. 未来节点化重构原则

当前阶段不把鱼、敌人、金币、食物拆成 `Node2D`。如果未来确实要节点化，必须作为单独阶段处理：

1. 先冻结当前 Dictionary 版本并通过 Web 导出。
2. 先节点化一种实体，例如只节点化鱼。
3. 保持旧逻辑模块作为规则层，不把规则写进 `_process`。
4. 每节点化一种实体都单独验证。
5. 不在同一步同时节点化鱼、敌人、金币和食物。

节点化的目标是改善绘制和生命周期管理，不是把规则重新塞进节点脚本里。

## 11. 提交前检查清单

提交或交付前检查：

- [ ] 新逻辑放在正确层级。
- [ ] `aquarium_level.gd` 没有新增大段纯规则。
- [ ] 文档已更新。
- [ ] `godot --headless --path . --quit-after 120` 通过。
- [ ] 如涉及 Web 包，`build/web/godot.pck` 已重新导出。
- [ ] `git status --short` 中只包含本次预期改动。
