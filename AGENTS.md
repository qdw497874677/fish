# AGENTS.md

本项目是 Godot 4.7 Web 游戏《水族守卫》。后续 agent 开发前先阅读：

- `docs/development-guidelines.md`：项目开发规范，包含分层边界、验证流程和 Web 导出规则。
- `docs/web-runbook.md`：Web 运行、PCK 打包、当前脚本分层和已知注意事项。

核心约定：

- `scripts/aquarium_level.gd` 只做关卡总控、输入、UI 连接、绘制调度和跨系统副作用。
- 新增纯玩法规则不要直接塞回 `aquarium_level.gd`，优先放到 `scripts/gameplay/*_logic.gd`。
- 数据配置放 `scripts/data/`，系统能力放 `scripts/systems/`，UI 创建/展示模型放 `scripts/ui/`。
- 当前实体仍使用 `Array[Dictionary]`，不要顺手把鱼、敌人、金币、食物改成节点；节点化必须作为单独阶段小步验证。
- Web PCK 固定导出到 `build/web/godot.pck`，不要改名。

脚本改动后至少运行：

```bash
godot --headless --path . --quit-after 120
```

涉及 Web 包或阶段性收尾时再运行：

```bash
godot --headless --path . --export-pack Web "build/web/godot.pck"
```

已知非阻塞警告：`WARNING: 2 ObjectDB instances were leaked at exit`。
