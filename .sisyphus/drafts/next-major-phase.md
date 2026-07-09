# Draft: Next Major Phase

## Requirements (confirmed)
- 用户请求："计划一下下一个大阶段要做什么"
- 目标是规划下一大阶段，而不是立即实现。

## Technical Decisions
- 暂不直接进入实现；先基于现有路线图、已完成 UX 小步、关卡数据和 Boss/扩关技术缝隙，形成阶段选项。
- 规划应保持 Godot Web 首发、PCK 固定 `build/web/godot.pck`、脚本分层边界不变。
- 用户已选择阶段方向：扩关重玩性。
- 用户已选择阶段规模：短阶段。
- 本阶段默认范围：扩到第 5 关，修关卡选择布局、奖励/文案、文档与 Web PCK；不做完整 Boss 系统，不改通关条件。

## Research Findings
- 当前仓库已超过基础 MVP：3 关、3 鱼、3 敌人、3 助手、多存档、Web 包、移动端提示、金币减负、动态提示、水晶反馈均已落地。
- 旧路线图 `docs/development-roadmap.md` 多数 P0/P1 已完成；后续主要空白集中在更多内容、长期成长、装饰/排行/云存档/小程序等 P2 方向。
- 4-6 关扩展主要是数据扩展 + 少量主控/UI 文案改造：`scripts/data/game_data.gd` 增关卡配置，`scripts/aquarium_level.gd` 调 `MAX_LEVEL`、关卡选择布局、奖励预览、终局文案。
- Boss 当前不是简单配置问题：`wave_logic.gd` 只支持单只随机刷怪，`enemy_logic.gd` 只有 normal/tank/thief，`combat_logic.gd` 只有固定点击伤害/奖励，缺 Boss 波、Boss 状态、血条/阶段/胜利条件。
- 推荐默认方向：先扩到 5-6 关，6 关先做常规高压或最小精英怪；完整 Boss 系统作为后续独立阶段。

## Open Questions
- 无阻塞问题；Boss 完整系统排除在本短阶段外。

## Recommended Phase Options
- A 推荐：内容扩展与重玩性阶段。交付 4-6 关、关卡选择两排布局、4/5 关压力主题、第 6 关高压终局或最小精英怪预留。
- B：长期成长/Meta 阶段。交付关卡星级、助手强化、长期研究/升级、重玩收益。
- C：发布前体验打磨阶段。交付浏览器/移动端 QA、音频/性能/结算/引导打磨、发布清单。
- D：架构稳固阶段。继续拆主控与规则边界，但不做节点化大迁移；用户感知较弱，建议只作为配套。

## Scope Boundaries
- INCLUDE: 下一大阶段目标、交付物、关键任务、验证策略、风险。
- EXCLUDE: 本轮不直接修改游戏源码、不提交功能实现。
