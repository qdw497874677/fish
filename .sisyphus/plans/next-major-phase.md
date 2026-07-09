# Five-Level Short Content Expansion

## TL;DR
> **Summary**: Expand the current 3-level Godot Web demo into a 5-level short content expansion using existing systems only. Add levels 4 and 5, adapt level selection and copy, preserve helper unlocks at levels 1–3, update docs, and regenerate the fixed Web PCK.
> **Deliverables**:
> - Level 4 and 5 configs using existing fish/enemy/helper/core systems
> - `MAX_LEVEL = 5` progression with 3 → 4 → 5 unlock flow
> - Existing helper unlocks preserved at levels 1, 2, and 3
> - Five visible level-select buttons without overlap/clipping
> - Challenge-preview text for levels 4 and 5
> - Generic final result copy that no longer says “three-level Demo”
> - Docs updated for the five-level Web build
> - `build/web/godot.pck` regenerated
> **Effort**: Short
> **Parallel**: YES - 3 waves
> **Critical Path**: Task 1 → Task 2 → Task 4 → Task 6 → Final Verification

## Context
### Original Request
用户请求：`计划一下下一个大阶段要做什么`。

### Interview Summary
- 用户选择下一大阶段方向：`扩关重玩性`。
- 用户选择阶段规模：`短阶段`。
- Decision: This phase targets 1–2 day scope: expand from 3 levels to 5 levels.
- Decision: Do **not** implement a full Boss system in this phase.
- Decision: Do **not** add new fish, enemy, helper, save slot, or core mechanics in this phase.

### Research Summary
- `scripts/data/game_data.gd` currently defines `LEVEL_CONFIGS` for levels 1–3 only.
- `scripts/aquarium_level.gd` currently has `const MAX_LEVEL := 3`, level-select button layout tuned for 3 buttons, reward preview text for levels 1–3, and final copy that says three-level Demo.
- `scripts/gameplay/progression_logic.gd` supports generic next-level unlocking via `unlocked_level_after_clear(current_level, highest_unlocked_level, max_level)`, but helper unlock semantics depend on level/final-level checks.
- `scripts/systems/save_system.gd` normalizes `highest_unlocked_level` and `cleared_levels` using `max_level`, so increased caps are structurally supported.
- Boss support is not ready: wave/enemy/combat systems lack Boss waves, Boss states, Boss UI, and Boss victory conditions.

### Metis Review (gaps addressed)
- Fixed decision: electric jellyfish remains a level-3 helper unlock, not a new final-level-5 unlock.
- Fixed decision: levels 4 and 5 have challenge-preview text, not new helper rewards.
- Fixed decision: old saves are compatible but no special migration/auto-unlock is added.
- Fixed guardrail: do not blindly replace all `3` references; preserve `3` save slots.
- Fixed guardrail: no Boss, no world map, no node migration, no broad `aquarium_level.gd` cleanup.

## Work Objectives
### Core Objective
Create a short, low-risk content expansion that makes the game feel larger by adding levels 4 and 5 while reusing the existing systems and preserving current MVP behavior.

### Deliverables
- Two new level configs in `scripts/data/game_data.gd`.
- Progression cap increased from 3 to 5.
- Helper unlock semantics fixed to levels 1/2/3.
- Five-level selection UI that fits the existing menu.
- Preview/copy updates for levels 4 and 5.
- Save compatibility verified with the new max level.
- Docs updated for current five-level state.
- Web PCK regenerated at `build/web/godot.pck`.

### Definition of Done (verifiable conditions with commands)
- `godot --headless --path . --quit-after 120` exits 0 with no new blocking errors.
- `godot --headless --path . --export-pack Web "build/web/godot.pck"` exits 0 and updates `build/web/godot.pck`.
- Static inspection confirms levels 4 and 5 exist in `scripts/data/game_data.gd`.
- Static inspection confirms max level is 5.
- Static inspection confirms no game-facing final copy says “three-level Demo” or equivalent stale wording.
- Static inspection confirms docs do not describe the active game as only 3 levels while preserving accurate “3 save slots” text.
- Agent-run QA evidence is stored under `.sisyphus/evidence/`.

### Must Have
- Use existing fish types only: blue, gold, guard.
- Use existing enemy types only: normal, tank, thief.
- Use existing helper types only: cleaner snail, bubble seahorse, electric jellyfish.
- Keep helper unlocks:
  - Level 1 clear → cleaner snail
  - Level 2 clear → bubble seahorse
  - Level 3 clear → electric jellyfish
  - Level 4/5 clear → no new helper
- Use challenge-preview text for levels 4 and 5.
- Use minimal 5-button layout, recommended 3+2 grid/wrapped layout inside the existing menu.
- Keep old saves loadable. No save path/slot/schema redesign.
- Keep Web PCK path exactly `build/web/godot.pck`.

### Must NOT Have
- No Boss system, Boss enemy, Boss wave, Boss health bar, Boss phase, Boss victory condition, or Boss copy.
- No new fish/enemy/helper types.
- No new save slots; preserve current 3-slot save model.
- No node migration; entities remain `Array[Dictionary]`.
- No world map, pagination, new scene, level editor, or dynamic difficulty system.
- No broad refactor of `scripts/aquarium_level.gd` beyond directly required level-selection/progression/copy changes.
- No Web export pipeline redesign or PCK rename.
- No blind global replacement of `3`.

## Verification Strategy
> ZERO HUMAN INTERVENTION - all verification is agent-executed.
- Test decision: tests-after + Godot headless/manual scripted QA. There is no configured `.gd` LSP or formal Godot unit test suite in the current environment.
- QA policy: Every task has agent-executed scenarios.
- Evidence: `.sisyphus/evidence/task-{N}-{slug}.{ext}`.
- Known acceptable warning: `WARNING: 2 ObjectDB instances were leaked at exit`.

## Execution Strategy
### Parallel Execution Waves
> Target: 5-8 tasks per wave. <3 per wave (except final) = under-splitting.
> Extract shared dependencies as Wave-1 tasks for max parallelism.

Wave 1: Task 1 data/progression and Task 3 docs audit can run independently. Task 2 may do read-only layout preparation in parallel, but must not edit until Task 1 lands because both touch `scripts/aquarium_level.gd`.
Wave 2: Task 4 save compatibility QA and Task 5 docs update after source behavior is known.
Wave 3: Task 6 full validation/export/commit prep after all source and docs changes.

### Dependency Matrix (full, all tasks)
- Task 1 blocks Task 2, Task 4, Task 6.
- Task 2 blocks Task 4 and Task 6.
- Task 3 blocks Task 5.
- Task 4 blocks Task 6.
- Task 5 blocks Task 6.
- Task 6 blocks Final Verification.

### Agent Dispatch Summary (wave → task count → categories)
- Wave 1 → 3 tasks → quick, visual-engineering, writing
- Wave 2 → 2 tasks → quick, writing
- Wave 3 → 1 task → unspecified-high

## TODOs
> Implementation + Test = ONE task. Never separate.
> EVERY task MUST have: Agent Profile + Parallelization + QA Scenarios.

- [x] 1. Add level 4/5 data and progression decisions

  **What to do**: Add level 4 and level 5 entries to `scripts/data/game_data.gd` using the exact existing `LEVEL_CONFIGS` schema. Tune only existing fields: `initial_money`, `initial_fish`, `core_base_cost`, `core_step_cost`, `enemy_timer`, `tank_enemy_chance`, `thief_enemy_chance`, `goal`, and `tip`. Increase the game max level from 3 to 5 in the existing max-level source. Ensure progression from 3 → 4 → 5 uses existing `ProgressionLogic.unlocked_level_after_clear(...)`. Update helper unlock semantics if needed so electric jellyfish remains unlocked by clearing level 3, not by clearing the new final level 5.
  **Must NOT do**: Do not add new config keys. Do not add new fish, enemy, helper, Boss, wave type, save slot, or core mechanic. Do not change `SaveSystem.SAVE_SLOT_COUNT`. Do not rename level config fields.

  **Recommended Agent Profile**:
  - Category: `quick` - Reason: focused data/progression edit with narrow file set.
  - Skills: [] - no special skill needed beyond Godot/repo rules.
  - Omitted: [`frontend-ui-ux`] - not changing layout in this task.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: [2, 4, 6] | Blocked By: []

  **References** (executor has NO interview context - be exhaustive):
  - Pattern: `scripts/data/game_data.gd` - follow existing `LEVEL_CONFIGS` entries for levels 1–3 exactly; add levels 4 and 5 with the same key set.
  - Pattern: `scripts/aquarium_level.gd` - current `const MAX_LEVEL := 3`; update to 5 only.
  - API/Type: `scripts/gameplay/progression_logic.gd` - `unlocked_level_after_clear(current_level, highest_unlocked_level, max_level)` already supports generic level cap.
  - Guardrail: `docs/development-guidelines.md` - static level data belongs in `scripts/data/`; pure progression rules belong in `scripts/gameplay/`.

  **Acceptance Criteria** (agent-executable only):
  - [ ] Static inspection confirms `scripts/data/game_data.gd` has entries for levels `4` and `5`.
  - [ ] Static inspection confirms level 4 and 5 configs use the same keys as levels 1–3.
  - [ ] Static inspection confirms max level is `5`.
  - [ ] Static inspection confirms no new enemy/fish/helper/Boss type is added.
  - [ ] Static inspection confirms electric jellyfish unlock is not accidentally moved to level 5.
  - [ ] `godot --headless --path . --quit-after 120` exits 0 except the known ObjectDB warning.

  **QA Scenarios** (MANDATORY - task incomplete without these):
  ```
  Scenario: Level data loads with five configured levels
    Tool: Bash
    Steps: Run `godot --headless --path . --quit-after 120`; inspect `scripts/data/game_data.gd` for `4:` and `5:` in `LEVEL_CONFIGS`.
    Expected: Godot exits 0; level 4/5 configs exist and no schema mismatch causes startup/script errors.
    Evidence: .sisyphus/evidence/task-1-level-data.txt

  Scenario: Helper unlock semantics are preserved
    Tool: Bash / static inspection
    Steps: Inspect `scripts/gameplay/progression_logic.gd` and `_on_buy_core_pressed()` helper unlock calls in `scripts/aquarium_level.gd`.
    Expected: Level 1 unlocks cleaner snail, level 2 unlocks bubble seahorse, level 3 unlocks electric jellyfish; levels 4/5 do not unlock new helpers.
    Evidence: .sisyphus/evidence/task-1-helper-unlocks.txt
  ```

  **Commit**: YES | Message: `feat: add levels four and five` | Files: [`scripts/data/game_data.gd`, `scripts/aquarium_level.gd`, `scripts/gameplay/progression_logic.gd` if needed]

- [x] 2. Adapt level selection UI and game-facing copy for five levels

  **What to do**: Update the existing start-menu level selection to show five level buttons without overlap/clipping in the current 1280×720 viewport. Use the minimal existing-style layout: recommended 3 buttons in the first row and 2 buttons in the second row inside the current menu area. Add explicit level 4/5 preview text as challenge descriptions, not helper rewards. Replace hardcoded final copy that says “three-level Demo” or equivalent with generic current-content completion copy.
  **Must NOT do**: Do not create a world map, pagination, new scene, new menu mode, new art asset system, or Boss-themed final copy. Do not alter save slot UI. Do not change Web viewport constants unless absolutely required and justified.

  **Recommended Agent Profile**:
  - Category: `visual-engineering` - Reason: menu layout and copy must fit visually and avoid overlap.
  - Skills: [`frontend-ui-ux`] - useful for layout polish and copy hierarchy.
  - Omitted: [`playwright`] - Godot UI is canvas-driven and no browser automation is required for this task plan.

  **Parallelization**: Can Parallel: NO | Wave 1 | Blocks: [4, 6] | Blocked By: [1]

  **References**:
  - Pattern: `scripts/aquarium_level.gd` - level button creation/layout currently loops over `MAX_LEVEL`; adapt existing button style and state logic.
  - Pattern: `scripts/aquarium_level.gd` - `_level_reward_preview_text(level)` currently handles levels 1–3; add explicit challenge text for 4 and 5.
  - Pattern: `scripts/aquarium_level.gd` - `_draw_result_panel(...)` usage in `_draw_overlay_messages()` contains final completion copy.
  - Pattern: `scripts/ui/aquarium_hud_presenter.gd` - restart button text already uses `current_level < max_level`, should remain compatible.
  - Guardrail: Preserve “3 save slots” wording/behavior if encountered.

  **Acceptance Criteria**:
  - [ ] Five level buttons are created and positioned within the current menu panel bounds.
  - [ ] Locked/unlocked/cleared visual states still apply to levels 1–5.
  - [ ] Level 4 preview describes challenge/content and does not say “奖励：助手”.
  - [ ] Level 5 preview describes final/current-stage challenge and does not mention Boss.
  - [ ] Final completion copy no longer says “三关”, “three-level Demo”, or “三关全部通过”.
  - [ ] `godot --headless --path . --quit-after 120` exits 0 except known ObjectDB warning.

  **QA Scenarios**:
  ```
  Scenario: Five-button menu layout is statically bounded
    Tool: Bash / static inspection
    Steps: Inspect the level button positioning logic in `scripts/aquarium_level.gd`; calculate each button rect for levels 1-5 using current constants/positions.
    Expected: All five button rects are inside the menu panel area and do not overlap each other.
    Evidence: .sisyphus/evidence/task-2-level-layout.txt

  Scenario: Final copy is future-safe
    Tool: Bash / content search
    Steps: Search game-facing source strings for stale final copy: `三关`, `three-level`, `三关全部通过`, `Demo 完成`.
    Expected: No stale copy remains for active final completion; save-slot count references are unaffected.
    Evidence: .sisyphus/evidence/task-2-final-copy.txt
  ```

  **Commit**: YES | Message: `feat: update level selection for five levels` | Files: [`scripts/aquarium_level.gd`, `scripts/ui/aquarium_hud_presenter.gd` only if needed]

- [x] 3. Audit docs for five-level wording and stale three-level claims

  **What to do**: Before editing docs, audit `docs/web-runbook.md`, `docs/mvp-game-design.md`, `docs/development-roadmap.md`, and `docs/godot-web-technical-plan.md` for statements that conflict with the active five-level short expansion. Produce a small evidence note listing which docs require edits and which “3” references must remain because they refer to save slots or the original MVP history.
  **Must NOT do**: Do not edit docs in this task. Do not rewrite broad design history. Do not change technical-plan statements about Web/single-thread/small-program risk unless they are directly stale.

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: documentation audit and wording classification.
  - Skills: [] - no Obsidian-specific syntax needed.
  - Omitted: [`obsidian-markdown`] - docs are plain repository markdown, no Obsidian features.

  **Parallelization**: Can Parallel: YES | Wave 1 | Blocks: [5] | Blocked By: []

  **References**:
  - Pattern: `docs/web-runbook.md` - current user-facing runbook; must reflect current playable content.
  - Pattern: `docs/mvp-game-design.md` - may mention original MVP 3-level scope; only update if it claims current implementation is 3 levels.
  - Pattern: `docs/development-roadmap.md` - historical roadmap; update only if needed to note next phase completion.
  - Pattern: `docs/godot-web-technical-plan.md` - platform constraints likely remain unchanged.

  **Acceptance Criteria**:
  - [ ] Evidence lists all docs inspected.
  - [ ] Evidence separates stale active-game wording from valid historical/MVP wording.
  - [ ] Evidence explicitly calls out “3 save slots” as preserved if present.

  **QA Scenarios**:
  ```
  Scenario: Documentation audit catches active stale claims
    Tool: Bash / content search
    Steps: Search docs for `3 关`, `三关`, `1-3`, `3 levels`, `Demo` and classify matches.
    Expected: Audit identifies only active-current-state claims for update; historical MVP context and save-slot references are not blindly changed.
    Evidence: .sisyphus/evidence/task-3-doc-audit.md

  Scenario: No docs edited during audit
    Tool: Bash
    Steps: Check `git diff -- docs` after this task.
    Expected: No doc modifications from audit-only task.
    Evidence: .sisyphus/evidence/task-3-no-doc-edits.txt
  ```

  **Commit**: NO | Message: N/A | Files: []

- [x] 4. Verify save compatibility and progression edge cases for max level 5

  **What to do**: Verify that old and new saves normalize safely under max level 5 without changing save path, slot count, or broad schema. If code changes are needed, keep them minimal and local to `scripts/systems/save_system.gd` or existing call sites. Confirm old saves with `highest_unlocked_level = 3` and `cleared_levels = [1, 2, 3]` remain valid; do not add special auto-migration to unlock level 4 unless the existing normal progression path does it after replay/clear. Confirm invalid levels above 5 clamp to 5 and below 1 normalize to 1.
  **Must NOT do**: Do not add a fourth save slot. Do not change `SAVE_PATH`. Do not rewrite save JSON format. Do not reset existing saves. Do not create cloud save, account save, or migration framework.

  **Recommended Agent Profile**:
  - Category: `quick` - Reason: focused compatibility verification and possible tiny fix.
  - Skills: [] - no special skill needed.
  - Omitted: [`git-master`] - no git operations inside implementation task unless committing later.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: [6] | Blocked By: [1, 2]

  **References**:
  - API/Type: `scripts/systems/save_system.gd` - `normalize_slot(slot, max_level)` is the save compatibility choke point.
  - API/Type: `scripts/aquarium_level.gd` - `_load_progress()`, `_save_progress()`, `_record_level_clear()` call save/progression functions.
  - API/Type: `scripts/gameplay/progression_logic.gd` - `unlocked_level_after_clear(...)` controls next-level unlock.
  - Guardrail: `SaveSystem.SAVE_SLOT_COUNT` stays 3.

  **Acceptance Criteria**:
  - [ ] Static inspection confirms `SAVE_SLOT_COUNT` remains 3.
  - [ ] Static inspection confirms `SAVE_PATH` is unchanged.
  - [ ] Static inspection confirms `normalize_slot(..., max_level)` can clamp `highest_unlocked_level` to 5.
  - [ ] Static inspection confirms cleared levels outside `1..5` cannot break display/progression.
  - [ ] No special auto-unlock migration is added for old completed-three-level saves.
  - [ ] `godot --headless --path . --quit-after 120` exits 0 except known ObjectDB warning.

  **QA Scenarios**:
  ```
  Scenario: Old completed-three-level save remains compatible
    Tool: Bash / static inspection or temporary user data setup if available
    Steps: Verify normalization behavior for a slot with `highest_unlocked_level: 3` and `cleared_levels: [1, 2, 3]` under `max_level = 5`.
    Expected: Slot remains valid; highest unlocked is not clamped down; helpers remain unlocked; no save reset path is triggered.
    Evidence: .sisyphus/evidence/task-4-old-save.txt

  Scenario: Invalid level values are bounded
    Tool: Bash / static inspection or temporary user data setup if available
    Steps: Verify normalization behavior for `highest_unlocked_level: 99`, `highest_unlocked_level: 0`, and cleared levels containing values outside `1..5`.
    Expected: Highest level clamps into `1..5`; invalid cleared-level entries do not crash UI or progression.
    Evidence: .sisyphus/evidence/task-4-invalid-save.txt
  ```

  **Commit**: YES if code changes are needed | Message: `fix: keep saves compatible with five levels` | Files: [`scripts/systems/save_system.gd`, `scripts/aquarium_level.gd` only if needed]

- [x] 5. Update docs for the five-level short expansion

  **What to do**: Use Task 3 audit results to update only docs that actively describe current playable content. At minimum update `docs/web-runbook.md` to describe five selectable levels, level 4/5 challenge focus, unchanged three save slots, unchanged Web PCK export path, and no Boss system. Update `docs/mvp-game-design.md` or `docs/development-roadmap.md` only if they contain active-current-state claims that conflict with five levels. Preserve historical MVP context where useful.
  **Must NOT do**: Do not rewrite the entire design document. Do not remove platform constraints. Do not change Web export instructions. Do not replace “3 save slots” with “5 save slots”. Do not claim Boss exists.

  **Recommended Agent Profile**:
  - Category: `writing` - Reason: precise technical documentation update.
  - Skills: [] - plain Markdown docs.
  - Omitted: [`obsidian-markdown`] - not using Obsidian-specific syntax.

  **Parallelization**: Can Parallel: NO | Wave 2 | Blocks: [6] | Blocked By: [3]

  **References**:
  - Pattern: `docs/web-runbook.md` - source of truth for current Web run/runbook and gameplay explanation.
  - Pattern: `docs/mvp-game-design.md` - design context and post-MVP optimization notes.
  - Pattern: `docs/development-roadmap.md` - historical roadmap; update sparingly.
  - Guardrail: Web PCK remains `build/web/godot.pck`.

  **Acceptance Criteria**:
  - [ ] `docs/web-runbook.md` accurately says the game has five playable/selectable levels after progression.
  - [ ] Docs state levels 4/5 are challenge/content expansion using existing systems, not Boss/new helpers.
  - [ ] Docs preserve the three-save-slot behavior if mentioned.
  - [ ] Docs preserve `godot --headless --path . --export-pack Web "build/web/godot.pck"`.
  - [ ] Content search confirms no active current-state doc falsely says only 3 levels.

  **QA Scenarios**:
  ```
  Scenario: Current docs match five-level game state
    Tool: Bash / content search
    Steps: Search docs for `三关`, `3 关`, `1-3`, `3 levels`; inspect matches.
    Expected: Active current-state sections reflect five levels; historical MVP and three-save-slot references remain accurate.
    Evidence: .sisyphus/evidence/task-5-doc-state.txt

  Scenario: Web runbook retains export instructions
    Tool: Bash / content search
    Steps: Search `docs/web-runbook.md` for `build/web/godot.pck` and export-pack command.
    Expected: Fixed PCK filename/path and export command are present and unchanged.
    Evidence: .sisyphus/evidence/task-5-web-export-doc.txt
  ```

  **Commit**: YES | Message: `docs: document five-level progression` | Files: [`docs/web-runbook.md`, `docs/mvp-game-design.md` if needed, `docs/development-roadmap.md` if needed]

- [x] 6. Run full validation, export Web PCK, and prepare atomic commits

  **What to do**: Run full required validation after source/docs are complete. Regenerate `build/web/godot.pck`. Inspect final diff for scope creep, generated files, stale copy, and unexpected changes. Use `git-master` for commit planning and commit execution if committing/pushing is requested during implementation. Store command outputs and final changed-file summary as evidence.
  **Must NOT do**: Do not run full `--export-release Web` if the known preset issue remains; use `--export-pack Web "build/web/godot.pck"`. Do not skip validation because earlier tasks ran partial checks. Do not commit without git-master. Do not include unrelated files.

  **Recommended Agent Profile**:
  - Category: `unspecified-high` - Reason: cross-cutting final validation, generated artifact, git hygiene.
  - Skills: [`git-master`] - required for git operations if commits are made.
  - Omitted: [`review-work`] - final verification wave below covers multi-agent review; use review-work only if user explicitly asks.

  **Parallelization**: Can Parallel: NO | Wave 3 | Blocks: [Final Verification] | Blocked By: [1, 2, 4, 5]

  **References**:
  - Command: `godot --headless --path . --quit-after 120` - required after script changes.
  - Command: `godot --headless --path . --export-pack Web "build/web/godot.pck"` - required for Web package update.
  - Artifact: `build/web/godot.pck` - must exist and be updated.
  - Guardrail: known acceptable warning is only `WARNING: 2 ObjectDB instances were leaked at exit`.
  - Pattern: repo commit style is semantic English (`feat: ...`, `docs: ...`, `build: ...`).

  **Acceptance Criteria**:
  - [ ] `godot --headless --path . --quit-after 120` exits 0.
  - [ ] `godot --headless --path . --export-pack Web "build/web/godot.pck"` exits 0.
  - [ ] `build/web/godot.pck` exists after export.
  - [ ] Final diff contains only intended source/docs/PCK changes.
  - [ ] Static inspection confirms no Boss/new fish/new enemy/new helper/save-slot changes.
  - [ ] Static inspection confirms no active stale three-level final copy remains.
  - [ ] If committing, commits are atomic and semantic, with generated PCK isolated or explicitly justified by git-master.

  **QA Scenarios**:
  ```
  Scenario: Full Godot startup validation
    Tool: Bash
    Steps: Run `godot --headless --path . --quit-after 120` from repo root.
    Expected: Exit code 0; no new parse/resource/startup errors; known ObjectDB warning is acceptable.
    Evidence: .sisyphus/evidence/task-6-headless.txt

  Scenario: Web PCK export validation
    Tool: Bash
    Steps: Run `godot --headless --path . --export-pack Web "build/web/godot.pck"` from repo root; check changed artifact.
    Expected: Exit code 0; `build/web/godot.pck` exists and is updated; PCK path unchanged.
    Evidence: .sisyphus/evidence/task-6-export-pack.txt
  ```

  **Commit**: YES | Message: `build: update web package` | Files: [`build/web/godot.pck`] plus commit source/docs according to git-master plan

## Final Verification Wave (MANDATORY — after ALL implementation tasks)
> 4 review agents run in PARALLEL. ALL must APPROVE. Present consolidated results to user and get explicit "okay" before completing.
> **Do NOT auto-proceed after verification. Wait for user's explicit approval before marking work complete.**
> **Never mark F1-F4 as checked before getting user's okay.** Rejection or user feedback -> fix -> re-run -> present again -> wait for okay.
- [x] F1. Plan Compliance Audit — oracle
- [x] F2. Code Quality Review — unspecified-high
- [x] F3. Real Manual QA — unspecified-high
- [x] F4. Scope Fidelity Check — deep

## Commit Strategy
- Use `git-master` before committing.
- Expected semantic commits, matching repo style:
  1. `feat: add levels four and five`
  2. `feat: update level selection for five levels`
  3. `docs: document five-level progression`
  4. `build: update web package`
- If save compatibility requires source changes in `scripts/systems/save_system.gd`, use separate commit: `fix: keep saves compatible with five levels`.
- Do not combine generated `build/web/godot.pck` with source/doc commits unless git-master review explicitly decides otherwise.

## Success Criteria
- The game has five configured levels.
- Existing 1–3 helper unlock progression is preserved.
- Levels 4/5 are playable/unlockable using existing systems.
- Level select shows five buttons without overlap/clipping.
- Final completion copy is generic and future-safe.
- Old saves remain loadable under max level 5.
- Docs and Web package reflect the new five-level short expansion.
