
## Task 3 docs audit findings

- `docs/web-runbook.md` is the only clearly current-state doc that needs five-level wording after source implementation. Update its start-menu section and current difficulty baseline, but keep Web PCK instructions unchanged.
- Preserve 3 save slots. Matches in `docs/web-runbook.md` line 114 and line 152 refer to save-slot count, not level count.
- Preserve 3 crystal cores. Matches in `docs/web-runbook.md`, `docs/mvp-game-design.md`, and `docs/development-roadmap.md` describe per-level victory goals, not total level count.
- `docs/mvp-game-design.md` and `docs/development-roadmap.md` are mostly MVP or first-version historical context. They need no broad rewrite for the five-level short expansion.
- `docs/godot-web-technical-plan.md` platform constraints and `godot.pck` naming remain valid for five levels.

## Task 1 - level data/progression
- `scripts/data/game_data.gd` level configs use a flat numeric-key dictionary. New levels should reuse only the existing keys: `name`, `initial_money`, `initial_fish`, `core_base_cost`, `core_step_cost`, `enemy_timer`, `tank_enemy_chance`, `thief_enemy_chance`, `goal`, `tip`.
- Progression cap lives in `scripts/aquarium_level.gd` as `const MAX_LEVEL`; save slot count is separately delegated to `SaveSystem.SAVE_SLOT_COUNT` and should remain unchanged for content expansion.
- Helper unlock semantics belong in `scripts/gameplay/progression_logic.gd`; electric jellyfish needed a fixed level-3 rule once max level increased to 5.

## Task 2 - level selection UI/copy
- Existing menu UI uses `AquariumUIFactory` primitives only; keeping level buttons as factory-created `Button`s preserves style without adding new visual systems.
- Five levels fit the current `menu_panel` with a centered 3+2 grid: button size `(188,78)`, gap `(22,8)`, and local row y positions `306` / `392`; the resulting screen rects remain inside the panel.
- Level 4/5 menu card text should be challenge previews, not helper rewards: level 4 `挑战：混合入侵与护金`, level 5 `挑战：终段高压耐久`.
- Final max-level result copy is now generic current-stage wording (`当前阶段全部通关`) so later content expansion will not inherit stale three-level Demo text.

## Task 5 docs update
- `docs/web-runbook.md` now describes the active Web build as a five-level short expansion, with level selection documented as `第 1-5 关选择按钮`.
- Current docs keep level 1/2/3 helper unlocks as rewards and describe level 4/5 as challenge previews using existing helpers and enemies, not new helper or Boss content.
- Level 4/5 doc baselines match the source facts used for this phase: level 4 starts with 350 money and 4 fish; level 5 starts with 380 money and 5 fish.
- The Web runbook still preserves `3 个存档槽`, `3 格 水晶核心`, `build/web/godot.pck`, and `godot --headless --path . --export-pack Web "build/web/godot.pck"` exactly where needed.

## Task 4 - save compatibility QA
- `scripts/systems/save_system.gd` keeps `SAVE_SLOT_COUNT := 3` and `SAVE_PATH := "user://aquarium_guard_save.json"`; the five-level expansion does not change save slots or save file location.
- `SaveSystem.normalize_slot(raw_slot, max_level)` clamps `highest_unlocked_level` into `1..max_level` and clamps/de-duplicates `cleared_levels`, so passing `MAX_LEVEL := 5` safely bounds old or invalid level values.
- Old completed-three-level saves with `highest_unlocked_level: 3`, `cleared_levels: [1, 2, 3]`, and all helper flags true remain valid under max level 5; there is no load-time migration that automatically unlocks level 4.
- `scripts/aquarium_level.gd` still supports legacy single-save files by mapping them into slot 0 before normalization, then applying normalized progress through `_apply_slot_progress`.

## Task 6 - validation/export closeout
- Full Godot startup validation passed via `godot --headless --path . --quit-after 120`; output was saved to `.sisyphus/evidence/task-6-headless.txt` and only showed the known ObjectDB leak warning.
- Web PCK export passed via `godot --headless --path . --export-pack Web "build/web/godot.pck"`; `build/web/godot.pck` was regenerated at 11594632 bytes.
- Final scope evidence is in `.sisyphus/evidence/task-6-final-diff.txt`; tracked source/docs/PCK changes are limited to the five-level expansion, Web runbook, and regenerated PCK.
