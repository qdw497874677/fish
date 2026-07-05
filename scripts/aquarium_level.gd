extends Node2D

const GameData := preload("res://scripts/data/game_data.gd")
const AudioSystem := preload("res://scripts/systems/audio_system.gd")
const SaveSystem := preload("res://scripts/systems/save_system.gd")
const AquariumUIFactory := preload("res://scripts/ui/aquarium_ui_factory.gd")
const AquariumHUDPresenter := preload("res://scripts/ui/aquarium_hud_presenter.gd")
const AquariumQueries := preload("res://scripts/gameplay/aquarium_queries.gd")
const FishLogic := preload("res://scripts/gameplay/fish_logic.gd")
const EnemyLogic := preload("res://scripts/gameplay/enemy_logic.gd")
const ResourceLogic := preload("res://scripts/gameplay/resource_logic.gd")
const CombatLogic := preload("res://scripts/gameplay/combat_logic.gd")
const WaveLogic := preload("res://scripts/gameplay/wave_logic.gd")
const EffectLogic := preload("res://scripts/gameplay/effect_logic.gd")
const EconomyLogic := preload("res://scripts/gameplay/economy_logic.gd")
const ComboLogic := preload("res://scripts/gameplay/combo_logic.gd")
const ProgressionLogic := preload("res://scripts/gameplay/progression_logic.gd")

const VIEWPORT_SIZE := Vector2(1280, 720)
const PLAY_RECT := Rect2(0, 96, 1280, 624)
const FISH_RADIUS := 18.0
const FOOD_RADIUS := 6.0
const COIN_RADIUS := 11.0
const COIN_SWEEP_RADIUS := 32.0
const COIN_MAGNET_RADIUS := 104.0
const COIN_MAGNET_PULL_SPEED := 420.0
const COIN_MAGNET_COLLECT_RADIUS := 10.0
const COIN_MAGNET_DURATION := 0.35
const ENEMY_RADIUS := 24.0
const FISH_SEPARATION_RADIUS := 58.0
const FISH_SEPARATION_FORCE := 115.0
const GUARD_FISH_ATTACK_RANGE := 180.0
const GUARD_FISH_ATTACK_COOLDOWN := 2.4
const NO_FISH_GRACE_TIME := 12.0
const PRE_INVASION_WARNING_TIME := 2.0
const DEFENSE_HUNGER_MULTIPLIER := 0.5
const SAFE_REWARD_TIME := 3.0
const SAFE_REWARD_COIN_MULTIPLIER := 1.2
const COIN_COMBO_WINDOW := 1.6
const COIN_COMBO_MAX := 8
const COIN_COMBO_BONUS_PER_STEP := 0.05
const COIN_COMBO_MAX_MULTIPLIER := 1.4
const MAX_LEVEL := 3
const SAVE_SLOT_COUNT := SaveSystem.SAVE_SLOT_COUNT
const CLEANER_SNAIL_HOME := Vector2(110, 672)
const CLEANER_SNAIL_SPEED := 185.0
const CLEANER_SNAIL_COLLECT_RADIUS := 28.0
const BUBBLE_SEAHORSE_HOME := Vector2(1188, 188)
const BUBBLE_SEAHORSE_SPEED := 220.0
const BUBBLE_SEAHORSE_FEED_RADIUS := 34.0
const BUBBLE_SEAHORSE_FEED_INTERVAL := 6.5
const BUBBLE_SEAHORSE_HUNGER_THRESHOLD := 55.0
const BUBBLE_SEAHORSE_MAX_FOOD := 3
const ELECTRIC_JELLYFISH_HOME := Vector2(656, 170)
const ELECTRIC_JELLYFISH_ATTACK_INTERVAL := 3.6
const ELECTRIC_JELLYFISH_ATTACK_RANGE := 720.0
const ELECTRIC_JELLYFISH_DAMAGE := 1
const HUD_HEIGHT := 96.0
const HUD_MARGIN := 18.0
const HUD_GAP := 16.0
const HUD_ACTION_BUTTON_Y := 20.0
const HUD_ACTION_BUTTON_HEIGHT := 56.0
const HUD_ACTION_BUTTON_GAP := 4.0
const HUD_ACTION_WIDTHS := [76.0, 78.0, 86.0, 66.0]
const HUD_SHOP_WIDTH := 410.0
const HUD_SHOP_HEIGHT := 68.0
const HUD_SHOP_TITLE_WIDTH := 66.0
const HUD_SHOP_FISH_BUTTON_WIDTH := 56.0
const HUD_SHOP_FISH_BUTTON_GAP := 4.0
const HUD_SHOP_RESOURCE_BUTTON_GAP := 8.0
const HUD_SHOP_FOOD_BUTTON_WIDTH := 58.0
const HUD_SHOP_CORE_BUTTON_WIDTH := 74.0

var money := 180
var food_level := 1
var cores := 0
var current_level := 1
var selected_fish_type_index := 0
var game_over := false
var level_cleared := false
var in_menu := true
var paused := false
var warning_time := 0.0
var last_enemy_type := "normal"
var no_fish_timer := 0.0
var goal_message_time := 0.0
var enemy_spawn_timer := 12.0
var safe_reward_timer := 0.0
var unlocked_cleaner_snail := false
var unlocked_bubble_seahorse := false
var unlocked_electric_jellyfish := false
var highest_unlocked_level := 1
var cleared_levels: Array[int] = []
var active_slot_index := -1
var save_slots: Array[Dictionary] = []
var cleaner_snail_position := CLEANER_SNAIL_HOME
var bubble_seahorse_position := BUBBLE_SEAHORSE_HOME
var bubble_seahorse_target := BUBBLE_SEAHORSE_HOME
var bubble_seahorse_timer := BUBBLE_SEAHORSE_FEED_INTERVAL
var bubble_seahorse_pending_feed := false
var electric_jellyfish_timer := ELECTRIC_JELLYFISH_ATTACK_INTERVAL
var pet_message_time := 0.0
var last_pet_unlock_message := ""
var screen_shake_time := 0.0
var screen_shake_strength := 0.0
var total_play_seconds := 0.0
var run_play_seconds := 0.0
var run_enemies_defeated := 0
var run_fish_lost := 0
var run_money_earned := 0
var run_fish_bought := 0
var run_peak_fish_count := 0
var audio_enabled := true
var coin_sweep_active := false
var coin_combo_count := 0
var coin_combo_timer := 0.0

var fish_list: Array[Dictionary] = []
var food_list: Array[Dictionary] = []
var coin_list: Array[Dictionary] = []
var enemy_list: Array[Dictionary] = []
var hit_effects: Array[Dictionary] = []
var guard_effects: Array[Dictionary] = []
var jellyfish_effects: Array[Dictionary] = []

var chinese_font: Font
var audio_system: AudioSystem

var hud_layer: CanvasLayer
var top_bar: Panel
var menu_panel: Panel
var continue_button: Button
var current_save_label: Label
var save_manager_button: Button
var save_panel: Panel
var slot_name_labels: Array[Label] = []
var slot_progress_labels: Array[Label] = []
var slot_enter_buttons: Array[Button] = []
var slot_delete_buttons: Array[Button] = []
var new_save_name_input: LineEdit
var create_save_button: Button
var save_message_label: Label
var back_to_menu_button: Button
var level_buttons: Array[Button] = []
var money_label: Label
var status_label: Label
var shop_panel: Panel
var fish_buy_buttons: Array[Button] = []
var upgrade_food_button: Button
var buy_core_button: Button
var core_hint_label: Label
var pause_button: Button
var restart_button: Button
var menu_button: Button
var audio_button: Button


func _ready() -> void:
	_load_chinese_font()
	_setup_audio_system()
	_setup_ui()
	_load_progress()
	_show_main_menu()


func _process(delta: float) -> void:
	if in_menu:
		queue_redraw()
		return

	if paused:
		_update_ui()
		queue_redraw()
		return

	if game_over or level_cleared:
		queue_redraw()
		_update_ui()
		return

	_update_food(delta)
	_update_fish(delta)
	_update_bubble_seahorse(delta)
	_update_guard_fish(delta)
	_update_cleaner_snail(delta)
	_update_coins(delta)
	_update_enemies(delta)
	_update_electric_jellyfish(delta)
	_update_hit_effects(delta)
	_update_guard_effects(delta)
	_update_jellyfish_effects(delta)
	_update_enemy_waves(delta)
	_update_coin_combo(delta)
	_update_play_time(delta)
	_check_failure(delta)
	_update_ui()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not _is_assist_click_key(event):
		return
	if in_menu or paused or game_over or level_cleared:
		return
	var click_position := get_viewport().get_mouse_position()
	if PLAY_RECT.has_point(click_position):
		_handle_assist_click(click_position)
	get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if in_menu or paused or game_over or level_cleared:
		coin_sweep_active = false
		return
	var click_position := Vector2.ZERO
	var pressed := false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		coin_sweep_active = event.pressed
		if event.pressed:
			click_position = event.position
			pressed = true
	elif event is InputEventMouseMotion and coin_sweep_active:
		_try_sweep_collect_coin(event.position)
	elif event is InputEventScreenTouch:
		coin_sweep_active = event.pressed
		if event.pressed:
			click_position = event.position
			pressed = true
	elif event is InputEventScreenDrag and coin_sweep_active:
		_try_sweep_collect_coin(event.position)

	if pressed:
		_handle_assist_click(click_position)


func _is_assist_click_key(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	if not event.pressed or event.echo:
		return false
	return event.keycode == KEY_SPACE or event.keycode == KEY_ENTER


func _handle_assist_click(click_position: Vector2) -> void:
	if not PLAY_RECT.has_point(click_position):
		return
	if _try_attack_enemy(click_position):
		return
	if _try_collect_coin(click_position):
		return
	_drop_food(click_position)


func _draw() -> void:
	var shake_offset := _get_screen_shake_offset()
	if shake_offset != Vector2.ZERO:
		draw_set_transform(shake_offset, 0.0, Vector2.ONE)
	_draw_background()
	if in_menu:
		_draw_menu_atmosphere()
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	_draw_core_progress_slots()
	_draw_food()
	_draw_pets()
	_draw_fish()
	_draw_coins()
	_draw_enemies()
	_draw_guard_effects()
	_draw_jellyfish_effects()
	_draw_hit_effects()
	_draw_core_purchase_hint()
	_draw_pre_invasion_warning()
	_draw_overlay_messages()
	_draw_pause_overlay()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_core_purchase_hint() -> void:
	if not _can_buy_core():
		return
	var pulse := (sin(Time.get_ticks_msec() / 170.0) + 1.0) * 0.5
	var button_rect := Rect2(shop_panel.position + buy_core_button.position - Vector2(5 + pulse * 5, 5 + pulse * 5), buy_core_button.size + Vector2(10 + pulse * 10, 10 + pulse * 10))
	draw_rect(button_rect, Color(1.0, 0.82, 0.22, 0.18 + pulse * 0.16), false, 3.0 + pulse * 2.0)
	draw_circle(button_rect.get_center(), 28.0 + pulse * 12.0, Color(1.0, 0.78, 0.18, 0.08 + pulse * 0.08))


func _draw_pre_invasion_warning() -> void:
	if not _is_pre_invasion_warning_active():
		return
	var remaining := int(ceil(max(0.0, enemy_spawn_timer)))
	var pulse := (sin(Time.get_ticks_msec() / 95.0) + 1.0) * 0.5
	var alpha := 0.18 + pulse * 0.18
	draw_rect(PLAY_RECT, Color("fb7185", alpha), false, 5.0 + pulse * 3.0)
	draw_rect(Rect2(PLAY_RECT.position, Vector2(18, PLAY_RECT.size.y)), Color("ef4444", 0.18 + pulse * 0.12), true)
	draw_rect(Rect2(Vector2(PLAY_RECT.end.x - 18, PLAY_RECT.position.y), Vector2(18, PLAY_RECT.size.y)), Color("ef4444", 0.18 + pulse * 0.12), true)
	var warning_rect := Rect2(Vector2(424, 116), Vector2(432, 66))
	draw_rect(warning_rect, Color("450a0a", 0.72), true)
	draw_rect(warning_rect, Color("fb7185", 0.72 + pulse * 0.24), false, 3.0)
	draw_string(chinese_font, Vector2(warning_rect.position.x, warning_rect.position.y + 42), "入侵即将到来  %d" % remaining, HORIZONTAL_ALIGNMENT_CENTER, warning_rect.size.x, 28, Color("fff7ed"))


func _draw_core_progress_slots() -> void:
	var panel_rect := Rect2(Vector2(412, 638), Vector2(456, 58))
	var pulse := (sin(Time.get_ticks_msec() / 210.0) + 1.0) * 0.5
	draw_rect(panel_rect, Color("042f3f", 0.62), true)
	draw_rect(panel_rect, Color("7dd3fc", 0.25), false, 2.0)
	draw_string(chinese_font, Vector2(panel_rect.position.x + 16, panel_rect.position.y + 36), "水晶核心", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("e0f2fe"))
	for index in range(3):
		var slot_center := Vector2(panel_rect.position.x + 142 + index * 92, panel_rect.position.y + 29)
		var slot_rect := Rect2(slot_center - Vector2(28, 22), Vector2(56, 44))
		var purchased := index < cores
		var next_slot := index == cores and cores < 3
		var next_cost := _core_cost()
		var near_ready := next_slot and money >= int(next_cost * 0.8)
		var ready := next_slot and _can_buy_core()
		var glow_alpha := 0.0
		if purchased:
			glow_alpha = 0.34
		elif ready:
			glow_alpha = 0.24 + pulse * 0.18
		elif near_ready:
			glow_alpha = 0.12 + pulse * 0.08
		if glow_alpha > 0.0:
			draw_circle(slot_center, 32.0 + pulse * 8.0, Color(0.99, 0.84, 0.28, glow_alpha))
		draw_rect(slot_rect, Color("0f4558", 0.72), true)
		draw_rect(slot_rect, Color("bae6fd", 0.35), false, 2.0)
		_draw_core_diamond(slot_center, purchased, ready, near_ready)
		if next_slot and not purchased:
			draw_string(chinese_font, Vector2(slot_rect.position.x, slot_rect.position.y + 42), "$%d" % next_cost, HORIZONTAL_ALIGNMENT_CENTER, slot_rect.size.x, 13, Color("fef3c7" if near_ready else "bfdbfe"))


func _draw_core_diamond(center: Vector2, purchased: bool, ready: bool, near_ready: bool) -> void:
	var pulse := (sin(Time.get_ticks_msec() / 190.0) + 1.0) * 0.5
	var radius := 13.0 + (pulse * 2.0 if ready else 0.0)
	var points := PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.82, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.82, 0),
	])
	var fill_color := Color("facc15") if purchased else Color("164e63")
	if ready:
		fill_color = Color(1.0, 0.86 + pulse * 0.12, 0.24)
	elif near_ready:
		fill_color = Color("fbbf24", 0.72)
	var outline := PackedVector2Array([points[0], points[1], points[2], points[3], points[0]])
	draw_polygon(points, [fill_color])
	draw_polyline(outline, Color("fff7ed", 0.85 if purchased or ready else 0.42), 2.0)
	if purchased or ready:
		draw_line(center + Vector2(-5, 0), center + Vector2(0, 6), Color("fff7ed", 0.95), 2.0)
		draw_line(center + Vector2(0, 6), center + Vector2(8, -7), Color("fff7ed", 0.95), 2.0)


func _load_chinese_font() -> void:
	var font_resource := load("res://assets/fonts/PingFangSC-Regular.ttf")
	if font_resource is Font:
		chinese_font = font_resource
	else:
		push_warning("中文字体加载失败，回退到 Godot 默认字体。")
		chinese_font = ThemeDB.fallback_font


func _setup_ui() -> void:
	hud_layer = CanvasLayer.new()
	add_child(hud_layer)

	top_bar = AquariumUIFactory.panel(Vector2.ZERO, Vector2(VIEWPORT_SIZE.x, HUD_HEIGHT))
	hud_layer.add_child(top_bar)

	money_label = AquariumUIFactory.label(chinese_font, 18, "")
	top_bar.add_child(money_label)

	status_label = AquariumUIFactory.label(chinese_font, 16, "")
	status_label.clip_text = true
	top_bar.add_child(status_label)

	pause_button = AquariumUIFactory.button(chinese_font, 17, "暂停")
	pause_button.pressed.connect(_on_pause_pressed)
	top_bar.add_child(pause_button)

	audio_button = AquariumUIFactory.button(chinese_font, 17, "音效")
	audio_button.pressed.connect(_on_audio_toggle_pressed)
	top_bar.add_child(audio_button)

	restart_button = AquariumUIFactory.button(chinese_font, 17, "重新开始")
	restart_button.pressed.connect(_on_restart_pressed)
	top_bar.add_child(restart_button)

	menu_button = AquariumUIFactory.button(chinese_font, 17, "菜单")
	menu_button.pressed.connect(_on_menu_pressed)
	top_bar.add_child(menu_button)

	_setup_shop_panel()
	_layout_top_hud()

	_setup_main_menu()


func _setup_shop_panel() -> void:
	shop_panel = AquariumUIFactory.panel(Vector2.ZERO, Vector2(HUD_SHOP_WIDTH, HUD_SHOP_HEIGHT), true)
	top_bar.add_child(shop_panel)

	var title := AquariumUIFactory.label(chinese_font, 13, "快捷购买", Vector2(6, 4), Vector2(HUD_SHOP_TITLE_WIDTH, 20), HORIZONTAL_ALIGNMENT_CENTER)
	shop_panel.add_child(title)

	fish_buy_buttons.clear()
	for fish_index in range(GameData.FISH_TYPES.size()):
		var fish_button := AquariumUIFactory.button(chinese_font, 13, "")
		fish_button.pressed.connect(_on_buy_fish_type_pressed.bind(fish_index))
		fish_buy_buttons.append(fish_button)
		shop_panel.add_child(fish_button)

	upgrade_food_button = AquariumUIFactory.button(chinese_font, 13, "升级食物 $200")
	upgrade_food_button.pressed.connect(_on_upgrade_food_pressed)
	shop_panel.add_child(upgrade_food_button)

	buy_core_button = AquariumUIFactory.button(chinese_font, 13, "购买水晶 $500")
	buy_core_button.pressed.connect(_on_buy_core_pressed)
	shop_panel.add_child(buy_core_button)

	core_hint_label = AquariumUIFactory.label(chinese_font, 12, "可买", Vector2.ZERO, Vector2(HUD_SHOP_CORE_BUTTON_WIDTH, 18), HORIZONTAL_ALIGNMENT_CENTER)
	core_hint_label.visible = false
	shop_panel.add_child(core_hint_label)
	_layout_shop_panel_contents()


func _layout_top_hud() -> void:
	var action_buttons := [pause_button, audio_button, restart_button, menu_button]
	var action_width := _sum_float_array(HUD_ACTION_WIDTHS) + HUD_ACTION_BUTTON_GAP * float(action_buttons.size() - 1)
	var action_x := VIEWPORT_SIZE.x - HUD_MARGIN - action_width
	for index in range(action_buttons.size()):
		var button: Button = action_buttons[index]
		button.position = Vector2(action_x, HUD_ACTION_BUTTON_Y)
		button.size = Vector2(HUD_ACTION_WIDTHS[index], HUD_ACTION_BUTTON_HEIGHT)
		action_x += HUD_ACTION_WIDTHS[index] + HUD_ACTION_BUTTON_GAP

	var action_left := VIEWPORT_SIZE.x - HUD_MARGIN - action_width
	var shop_x := action_left - HUD_GAP - HUD_SHOP_WIDTH
	shop_panel.position = Vector2(shop_x, (HUD_HEIGHT - HUD_SHOP_HEIGHT) * 0.5)
	shop_panel.size = Vector2(HUD_SHOP_WIDTH, HUD_SHOP_HEIGHT)

	money_label.position = Vector2(HUD_MARGIN, 18)
	money_label.size = Vector2(shop_x - HUD_MARGIN - HUD_GAP, 28)
	status_label.position = Vector2(HUD_MARGIN, 52)
	status_label.size = Vector2(shop_x - HUD_MARGIN - HUD_GAP, 34)


func _layout_shop_panel_contents() -> void:
	var button_y := 14.0
	var button_height := 42.0
	var x := HUD_SHOP_TITLE_WIDTH + 8.0
	for fish_button in fish_buy_buttons:
		fish_button.position = Vector2(x, button_y)
		fish_button.size = Vector2(HUD_SHOP_FISH_BUTTON_WIDTH, button_height)
		x += HUD_SHOP_FISH_BUTTON_WIDTH + HUD_SHOP_FISH_BUTTON_GAP
	x += HUD_SHOP_RESOURCE_BUTTON_GAP
	upgrade_food_button.position = Vector2(x, button_y)
	upgrade_food_button.size = Vector2(HUD_SHOP_FOOD_BUTTON_WIDTH, button_height)
	x += HUD_SHOP_FOOD_BUTTON_WIDTH + HUD_SHOP_RESOURCE_BUTTON_GAP
	buy_core_button.position = Vector2(x, button_y)
	buy_core_button.size = Vector2(HUD_SHOP_CORE_BUTTON_WIDTH, button_height)
	core_hint_label.position = Vector2(x, 2)
	core_hint_label.size = Vector2(HUD_SHOP_CORE_BUTTON_WIDTH, 18)


func _sum_float_array(values: Array) -> float:
	var total := 0.0
	for value in values:
		total += float(value)
	return total


func _setup_main_menu() -> void:
	menu_panel = AquariumUIFactory.panel(Vector2(250, 88), Vector2(780, 560))
	hud_layer.add_child(menu_panel)

	var title := AquariumUIFactory.label(chinese_font, 44, "水族守卫", Vector2(0, 42), Vector2(menu_panel.size.x, 62), HORIZONTAL_ALIGNMENT_CENTER)
	menu_panel.add_child(title)

	var subtitle := AquariumUIFactory.label(chinese_font, 20, "经营鱼缸，守住水晶核心", Vector2(0, 108), Vector2(menu_panel.size.x, 34), HORIZONTAL_ALIGNMENT_CENTER)
	menu_panel.add_child(subtitle)

	continue_button = AquariumUIFactory.button(chinese_font, 24, "继续游戏", Vector2(270, 172), Vector2(240, 58))
	continue_button.pressed.connect(_on_continue_pressed)
	menu_panel.add_child(continue_button)

	current_save_label = AquariumUIFactory.label(chinese_font, 17, "当前存档：未选择", Vector2(0, 238), Vector2(menu_panel.size.x, 28), HORIZONTAL_ALIGNMENT_CENTER)
	menu_panel.add_child(current_save_label)

	var level_title := AquariumUIFactory.label(chinese_font, 22, "选择关卡", Vector2(0, 268), Vector2(menu_panel.size.x, 34), HORIZONTAL_ALIGNMENT_CENTER)
	menu_panel.add_child(level_title)

	for level in range(1, MAX_LEVEL + 1):
		var button := AquariumUIFactory.button(chinese_font, 18, "", Vector2(95 + (level - 1) * 215, 326), Vector2(180, 88))
		button.pressed.connect(_on_level_button_pressed.bind(level))
		level_buttons.append(button)
		menu_panel.add_child(button)

	var helper_note := AquariumUIFactory.label(chinese_font, 18, "助手：第 1 关通关后清洁螺会移动收集金币", Vector2(42, 438), Vector2(menu_panel.size.x - 84, 34), HORIZONTAL_ALIGNMENT_CENTER)
	menu_panel.add_child(helper_note)

	save_manager_button = AquariumUIFactory.button(chinese_font, 20, "存档管理", Vector2(290, 488), Vector2(200, 54))
	save_manager_button.pressed.connect(_on_save_manager_pressed)
	menu_panel.add_child(save_manager_button)

	_setup_save_manager()


func _setup_save_manager() -> void:
	save_panel = AquariumUIFactory.panel(Vector2(120, 72), Vector2(1040, 584), false)
	hud_layer.add_child(save_panel)

	var title := AquariumUIFactory.label(chinese_font, 36, "存档管理", Vector2(0, 28), Vector2(save_panel.size.x, 54), HORIZONTAL_ALIGNMENT_CENTER)
	save_panel.add_child(title)

	for slot_index in range(SAVE_SLOT_COUNT):
		var x := 60.0 + float(slot_index) * 326.0
		var slot_title := AquariumUIFactory.label(chinese_font, 21, "槽位 %d" % (slot_index + 1), Vector2(x, 104), Vector2(270, 32), HORIZONTAL_ALIGNMENT_CENTER)
		save_panel.add_child(slot_title)

		var name_label := AquariumUIFactory.label(chinese_font, 18, "", Vector2(x, 146), Vector2(270, 32), HORIZONTAL_ALIGNMENT_CENTER)
		slot_name_labels.append(name_label)
		save_panel.add_child(name_label)

		var progress_label := AquariumUIFactory.label(chinese_font, 16, "", Vector2(x + 22, 188), Vector2(226, 104))
		slot_progress_labels.append(progress_label)
		save_panel.add_child(progress_label)

		var enter_button := AquariumUIFactory.button(chinese_font, 17, "进入", Vector2(x + 22, 320), Vector2(104, 48))
		enter_button.pressed.connect(_on_enter_slot_pressed.bind(slot_index))
		slot_enter_buttons.append(enter_button)
		save_panel.add_child(enter_button)

		var delete_button := AquariumUIFactory.button(chinese_font, 17, "删除", Vector2(x + 144, 320), Vector2(104, 48))
		delete_button.pressed.connect(_on_delete_slot_pressed.bind(slot_index))
		slot_delete_buttons.append(delete_button)
		save_panel.add_child(delete_button)

	new_save_name_input = AquariumUIFactory.line_edit(chinese_font, 17, "新存档名称", Vector2(270, 420), Vector2(300, 48))
	save_panel.add_child(new_save_name_input)

	create_save_button = AquariumUIFactory.button(chinese_font, 18, "新建存档", Vector2(590, 420), Vector2(160, 48))
	create_save_button.pressed.connect(_on_create_save_pressed)
	save_panel.add_child(create_save_button)

	save_message_label = AquariumUIFactory.label(chinese_font, 17, "", Vector2(80, 482), Vector2(880, 28), HORIZONTAL_ALIGNMENT_CENTER)
	save_panel.add_child(save_message_label)

	back_to_menu_button = AquariumUIFactory.button(chinese_font, 20, "返回菜单", Vector2(420, 520), Vector2(200, 58))
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	save_panel.add_child(back_to_menu_button)


func _apply_control_font(control: Control, font_size: int) -> void:
	AquariumUIFactory.apply_control_font(control, chinese_font, font_size)


func _setup_audio_system() -> void:
	audio_system = AudioSystem.new()
	add_child(audio_system)
	audio_system.set_enabled(audio_enabled)


func _play_sfx(sound_name: String) -> void:
	if audio_system == null:
		return
	audio_system.play_sfx(sound_name)


func _update_audio_state() -> void:
	if audio_button != null:
		audio_button.text = "音效开" if audio_enabled else "音效关"
	if audio_system != null:
		audio_system.set_enabled(audio_enabled)


func _start_level(level: int) -> void:
	if active_slot_index < 0:
		_show_save_manager()
		return
	in_menu = false
	paused = false
	menu_panel.visible = false
	save_panel.visible = false
	top_bar.visible = true
	shop_panel.visible = true
	current_level = level
	var config := _get_level_config()
	money = config["initial_money"]
	food_level = 1
	cores = 0
	game_over = false
	level_cleared = false
	warning_time = 0.0
	last_enemy_type = "normal"
	no_fish_timer = 0.0
	goal_message_time = 5.0
	pet_message_time = 0.0
	bubble_seahorse_position = BUBBLE_SEAHORSE_HOME
	bubble_seahorse_target = BUBBLE_SEAHORSE_HOME
	bubble_seahorse_timer = BUBBLE_SEAHORSE_FEED_INTERVAL
	bubble_seahorse_pending_feed = false
	electric_jellyfish_timer = ELECTRIC_JELLYFISH_ATTACK_INTERVAL
	last_pet_unlock_message = ""
	enemy_spawn_timer = config["enemy_timer"]
	safe_reward_timer = 0.0
	_reset_coin_combo()
	fish_list.clear()
	food_list.clear()
	coin_list.clear()
	enemy_list.clear()
	hit_effects.clear()
	guard_effects.clear()
	jellyfish_effects.clear()
	screen_shake_time = 0.0
	screen_shake_strength = 0.0
	run_play_seconds = 0.0
	run_enemies_defeated = 0
	run_fish_lost = 0
	run_money_earned = 0
	run_fish_bought = 0
	run_peak_fish_count = 0

	for index in range(config["initial_fish"]):
		_spawn_fish(Vector2(420 + index * 110, 310 + (index % 2) * 75), "blue")
	run_peak_fish_count = fish_list.size()
	_update_ui()
	queue_redraw()


func _show_main_menu() -> void:
	_save_progress()
	in_menu = true
	paused = false
	game_over = false
	level_cleared = false
	warning_time = 0.0
	last_enemy_type = "normal"
	no_fish_timer = 0.0
	goal_message_time = 0.0
	pet_message_time = 0.0
	bubble_seahorse_position = BUBBLE_SEAHORSE_HOME
	bubble_seahorse_target = BUBBLE_SEAHORSE_HOME
	bubble_seahorse_timer = BUBBLE_SEAHORSE_FEED_INTERVAL
	bubble_seahorse_pending_feed = false
	electric_jellyfish_timer = ELECTRIC_JELLYFISH_ATTACK_INTERVAL
	last_pet_unlock_message = ""
	safe_reward_timer = 0.0
	_reset_coin_combo()
	fish_list.clear()
	food_list.clear()
	coin_list.clear()
	enemy_list.clear()
	hit_effects.clear()
	guard_effects.clear()
	jellyfish_effects.clear()
	screen_shake_time = 0.0
	screen_shake_strength = 0.0
	top_bar.visible = false
	menu_panel.visible = true
	save_panel.visible = false
	shop_panel.visible = false
	_update_menu_ui()
	queue_redraw()


func _update_menu_ui() -> void:
	var has_active_save := active_slot_index >= 0 and bool(save_slots[active_slot_index].get("exists", false))
	if has_active_save:
		var slot_name := str(save_slots[active_slot_index].get("name", "未命名存档"))
		continue_button.text = "继续第 %d 关" % highest_unlocked_level
		continue_button.disabled = false
		current_save_label.text = "当前存档：%s" % slot_name
	else:
		continue_button.text = "请先新建存档"
		continue_button.disabled = true
		current_save_label.text = "当前存档：未选择"
	var helper_text := _next_helper_unlock_text()
	for index in range(level_buttons.size()):
		var level := index + 1
		var button := level_buttons[index]
		var config: Dictionary = GameData.LEVEL_CONFIGS[level]
		var unlocked := has_active_save and level <= highest_unlocked_level
		var clear_mark := " ✓" if cleared_levels.has(level) else ""
		button.text = "第 %d 关%s\n%s" % [level, clear_mark, config["name"]]
		button.disabled = not unlocked
		button.tooltip_text = helper_text if (level == 2 and not unlocked_cleaner_snail) or (level == 3 and not unlocked_bubble_seahorse) else ""


func _show_save_manager() -> void:
	in_menu = true
	top_bar.visible = false
	menu_panel.visible = false
	save_panel.visible = true
	_update_save_manager()
	queue_redraw()


func _update_save_manager(message := "") -> void:
	for slot_index in range(SAVE_SLOT_COUNT):
		var slot := save_slots[slot_index]
		var exists := bool(slot.get("exists", false))
		var active_mark := "  当前" if slot_index == active_slot_index and exists else ""
		if exists:
			var snail_text := "已解锁" if bool(slot.get("unlocked_cleaner_snail", false)) else "未解锁"
			var seahorse_text := "已解锁" if bool(slot.get("unlocked_bubble_seahorse", false)) else "未解锁"
			var jellyfish_text := "已解锁" if bool(slot.get("unlocked_electric_jellyfish", false)) else "未解锁"
			slot_name_labels[slot_index].text = "%s%s" % [str(slot.get("name", "未命名存档")), active_mark]
			slot_progress_labels[slot_index].text = "最高：第 %d 关\n通关：%d / %d\n用时：%s\n螺：%s 海马：%s 水母：%s" % [
				int(slot.get("highest_unlocked_level", 1)),
				_slot_cleared_count(slot),
				MAX_LEVEL,
				_format_time(float(slot.get("total_play_seconds", 0.0))),
				snail_text,
				seahorse_text,
				jellyfish_text,
			]
		else:
			slot_name_labels[slot_index].text = "空槽"
			slot_progress_labels[slot_index].text = "等待新存档占用\n新存档从第 1 关开始\n助手未解锁"
		slot_enter_buttons[slot_index].visible = exists
		slot_delete_buttons[slot_index].visible = exists
		slot_enter_buttons[slot_index].disabled = not exists
		slot_delete_buttons[slot_index].disabled = not exists
	var has_empty_slot := _first_empty_slot_index() >= 0
	new_save_name_input.editable = has_empty_slot
	create_save_button.disabled = not has_empty_slot
	create_save_button.text = "槽位已满" if not has_empty_slot else "新建存档"
	save_message_label.text = message


func _slot_cleared_count(slot: Dictionary) -> int:
	return SaveSystem.slot_cleared_count(slot)


func _spawn_fish(spawn_position: Vector2, fish_type_id := "blue") -> void:
	fish_list.append(FishLogic.create_fish(spawn_position, fish_type_id, _fish_config(fish_type_id), _random_play_position()))
	run_peak_fish_count = max(run_peak_fish_count, fish_list.size())


func _drop_food(drop_position: Vector2) -> void:
	var cost := EconomyLogic.food_drop_cost(food_level)
	if money < cost:
		return
	money -= cost
	food_list.append(ResourceLogic.create_food(drop_position, food_level))
	_play_sfx("feed")


func _drop_auto_food(drop_position: Vector2) -> void:
	food_list.append(ResourceLogic.create_food(_clamp_to_play_rect(drop_position, FOOD_RADIUS), max(1, food_level - 1)))
	_play_sfx("feed")


func _spawn_coin(spawn_position: Vector2, value: int) -> void:
	coin_list.append(ResourceLogic.create_coin(_clamp_to_play_rect(spawn_position, COIN_RADIUS), value))
	run_money_earned += value


func _coin_spawn_position_for_fish(fish: Dictionary) -> Vector2:
	return _clamp_to_play_rect(ResourceLogic.coin_spawn_position_for_fish(fish), COIN_RADIUS)


func _spawn_hit_effect(position: Vector2, defeated: bool) -> void:
	hit_effects.append(EffectLogic.create_hit_effect(position, defeated))
	screen_shake_time = EffectLogic.shake_time_for_hit(defeated)
	screen_shake_strength = EffectLogic.shake_strength_for_hit(defeated)


func _spawn_guard_effect(origin: Vector2, target: Vector2) -> void:
	guard_effects.append(EffectLogic.create_guard_effect(origin, target))


func _spawn_jellyfish_effect(origin: Vector2, target: Vector2) -> void:
	jellyfish_effects.append(EffectLogic.create_jellyfish_effect(origin, target))


func _spawn_enemy() -> void:
	var side := randi() % 2
	var spawn_x := PLAY_RECT.position.x + ENEMY_RADIUS if side == 0 else PLAY_RECT.end.x - ENEMY_RADIUS
	var spawn_y := randf_range(PLAY_RECT.position.y + ENEMY_RADIUS, PLAY_RECT.end.y - ENEMY_RADIUS)
	var enemy := EnemyLogic.create_enemy(Vector2(spawn_x, spawn_y), _get_level_config())
	enemy_list.append(enemy)
	last_enemy_type = str(enemy["type"])
	warning_time = 1.6


func _update_food(delta: float) -> void:
	for index in range(food_list.size() - 1, -1, -1):
		var food := food_list[index]
		ResourceLogic.update_food(food, delta)
		if ResourceLogic.should_remove_food(food, PLAY_RECT):
			food_list.remove_at(index)
		else:
			food_list[index] = food


func _update_fish(delta: float) -> void:
	var hunger_delta := delta * _hunger_drain_multiplier()
	for index in range(fish_list.size() - 1, -1, -1):
		var fish := fish_list[index]
		var fish_config := _fish_config(str(fish.get("type", "blue")))
		fish["hunger"] = fish["hunger"] - hunger_delta

		if fish["hunger"] <= 0.0:
			fish_list.remove_at(index)
			run_fish_lost += 1
			continue

		var guard_enemy_index := _guard_enemy_target_index(fish, fish_config)
		if guard_enemy_index >= 0:
			_update_guard_fish_movement(fish, guard_enemy_index)
		elif _try_update_fish_feeding(fish, fish_config):
			pass
		else:
			if fish["pos"].distance_to(fish["wander_target"]) < 24.0:
				fish["wander_target"] = _random_play_position()
			var wander_direction: Vector2 = (fish["wander_target"] - fish["pos"]).normalized()
			fish["velocity"] = fish["velocity"].lerp(wander_direction * 72.0, 0.04)

		var separation := _fish_separation_vector(index)
		if separation != Vector2.ZERO:
			fish["velocity"] = fish["velocity"] + separation * FISH_SEPARATION_FORCE * delta
			fish["velocity"] = fish["velocity"].limit_length(145.0)

		var velocity: Vector2 = fish["velocity"]
		if abs(velocity.x) > 8.0:
			fish["facing"] = 1.0 if velocity.x >= 0.0 else -1.0

		fish["pos"] = fish["pos"] + fish["velocity"] * delta
		fish["pos"] = _clamp_to_play_rect(fish["pos"], FISH_RADIUS)

		if fish["growth"] >= 1.0:
			fish["coin_timer"] = fish["coin_timer"] - delta
			if fish["coin_timer"] <= 0.0:
				_spawn_coin(_coin_spawn_position_for_fish(fish), _safe_reward_coin_value(int(fish_config["coin_value"])))
				fish["coin_timer"] = fish_config["coin_interval"]

		fish_list[index] = fish


func _try_update_fish_feeding(fish: Dictionary, fish_config: Dictionary) -> bool:
	return FishLogic.try_update_feeding(fish, fish_config, food_list, _find_nearest_food_index(fish["pos"]), FISH_RADIUS, FOOD_RADIUS)


func _guard_enemy_target_index(fish: Dictionary, fish_config: Dictionary) -> int:
	return FishLogic.guard_target_index(fish, fish_config, enemy_list, _find_nearest_enemy_index(fish["pos"], 999999.0))


func _update_guard_fish_movement(fish: Dictionary, enemy_index: int) -> void:
	FishLogic.update_guard_movement(fish, enemy_list[enemy_index]["pos"], GUARD_FISH_ATTACK_RANGE)


func _update_guard_fish(delta: float) -> void:
	if enemy_list.is_empty():
		return
	for fish_index in range(fish_list.size()):
		var fish := fish_list[fish_index]
		var fish_config := _fish_config(str(fish.get("type", "blue")))
		if not bool(fish_config.get("guard", false)) or float(fish["growth"]) < 1.0:
			continue
		fish["guard_cooldown"] = max(0.0, float(fish.get("guard_cooldown", 0.0)) - delta)
		if fish["guard_cooldown"] <= 0.0:
			var target_index := _find_nearest_enemy_index(fish["pos"], GUARD_FISH_ATTACK_RANGE)
			if target_index >= 0:
				_guard_fish_attack(fish["pos"], target_index)
				fish["guard_cooldown"] = GUARD_FISH_ATTACK_COOLDOWN
		fish_list[fish_index] = fish


func _update_coins(delta: float) -> void:
	for index in range(coin_list.size() - 1, -1, -1):
		var coin := coin_list[index]
		if bool(coin.get("magnet_active", false)):
			ResourceLogic.update_magnetized_coin(coin, COIN_MAGNET_PULL_SPEED, delta)
			if ResourceLogic.should_collect_magnetized_coin(coin, COIN_MAGNET_COLLECT_RADIUS):
				_collect_player_coin(coin)
				coin_list.remove_at(index)
				_play_sfx("coin")
				continue
			if ResourceLogic.should_cancel_magnet(coin):
				ResourceLogic.cancel_magnet(coin)
		else:
			ResourceLogic.update_coin(coin, delta)
		if unlocked_cleaner_snail and ResourceLogic.should_collect_with_snail(coin, cleaner_snail_position, CLEANER_SNAIL_COLLECT_RADIUS):
			money += coin["value"]
			coin_list.remove_at(index)
			_play_sfx("coin")
			continue
		if ResourceLogic.should_remove_coin(coin, PLAY_RECT):
			coin_list.remove_at(index)
		else:
			coin_list[index] = coin


func _update_cleaner_snail(delta: float) -> void:
	if not unlocked_cleaner_snail:
		cleaner_snail_position = CLEANER_SNAIL_HOME
		return

	var target := ResourceLogic.cleaner_snail_target(coin_list, CLEANER_SNAIL_HOME, cleaner_snail_position)
	cleaner_snail_position = ResourceLogic.update_cleaner_snail_position(cleaner_snail_position, target, CLEANER_SNAIL_SPEED, delta)
	cleaner_snail_position = _clamp_to_play_rect(cleaner_snail_position, 22.0)


func _update_bubble_seahorse(delta: float) -> void:
	if not unlocked_bubble_seahorse:
		bubble_seahorse_position = BUBBLE_SEAHORSE_HOME
		bubble_seahorse_target = BUBBLE_SEAHORSE_HOME
		bubble_seahorse_timer = BUBBLE_SEAHORSE_FEED_INTERVAL
		bubble_seahorse_pending_feed = false
		return

	var target := bubble_seahorse_target if bubble_seahorse_pending_feed else BUBBLE_SEAHORSE_HOME
	bubble_seahorse_position = ResourceLogic.update_bubble_seahorse_position(bubble_seahorse_position, target, BUBBLE_SEAHORSE_SPEED, delta)
	bubble_seahorse_position = _clamp_to_play_rect(bubble_seahorse_position, 24.0)

	if bubble_seahorse_pending_feed:
		if bubble_seahorse_position.distance_to(bubble_seahorse_target) > BUBBLE_SEAHORSE_FEED_RADIUS:
			return
		_drop_auto_food(bubble_seahorse_target)
		bubble_seahorse_pending_feed = false
		bubble_seahorse_timer = BUBBLE_SEAHORSE_FEED_INTERVAL
		return

	bubble_seahorse_timer = max(0.0, bubble_seahorse_timer - delta)
	if bubble_seahorse_timer > 0.0:
		return
	if not ResourceLogic.should_auto_feed_with_seahorse(fish_list, food_list.size(), BUBBLE_SEAHORSE_MAX_FOOD, BUBBLE_SEAHORSE_HUNGER_THRESHOLD):
		bubble_seahorse_timer = BUBBLE_SEAHORSE_FEED_INTERVAL
		return
	bubble_seahorse_target = _clamp_to_play_rect(ResourceLogic.bubble_seahorse_feed_position(fish_list, bubble_seahorse_position), FOOD_RADIUS)
	bubble_seahorse_pending_feed = true


func _update_electric_jellyfish(delta: float) -> void:
	if not unlocked_electric_jellyfish:
		electric_jellyfish_timer = ELECTRIC_JELLYFISH_ATTACK_INTERVAL
		return
	if enemy_list.is_empty():
		electric_jellyfish_timer = min(electric_jellyfish_timer, 0.8)
		return
	electric_jellyfish_timer = max(0.0, electric_jellyfish_timer - delta)
	if electric_jellyfish_timer > 0.0:
		return
	electric_jellyfish_timer = ELECTRIC_JELLYFISH_ATTACK_INTERVAL
	var target_index := ResourceLogic.electric_jellyfish_target_index(ELECTRIC_JELLYFISH_HOME, enemy_list, ELECTRIC_JELLYFISH_ATTACK_RANGE)
	if target_index < 0:
		return
	_electric_jellyfish_attack(target_index)


func _update_enemies(delta: float) -> void:
	for enemy_index in range(enemy_list.size() - 1, -1, -1):
		var enemy := enemy_list[enemy_index]
		var enemy_type := str(enemy.get("type", "tank" if enemy.get("tank", false) else "normal"))
		if enemy_type == "thief" and _update_thief_enemy(enemy, enemy_index, delta):
			continue
		var target_index := _find_nearest_fish_index(enemy["pos"])
		if target_index >= 0:
			var target_fish := fish_list[target_index]
			EnemyLogic.update_chase_fish(enemy, target_fish, delta)
			if EnemyLogic.can_attack_fish(enemy, target_fish, ENEMY_RADIUS, FISH_RADIUS):
				fish_list.remove_at(target_index)
				run_fish_lost += 1
				EnemyLogic.reset_attack_cooldown(enemy)
				_play_sfx("hit")
		else:
			EnemyLogic.update_drift_without_fish(enemy, delta)
		enemy["pos"] = _clamp_to_play_rect(enemy["pos"], ENEMY_RADIUS)
		enemy_list[enemy_index] = enemy


func _update_thief_enemy(enemy: Dictionary, enemy_index: int, delta: float) -> bool:
	var target_coin_index := _find_nearest_coin_index(enemy["pos"])
	if target_coin_index >= 0:
		var target_coin := coin_list[target_coin_index]
		EnemyLogic.update_chase_coin(enemy, target_coin, delta)
		if EnemyLogic.can_steal_coin(enemy, target_coin, ENEMY_RADIUS, COIN_RADIUS):
			_spawn_hit_effect(target_coin["pos"], false)
			coin_list.remove_at(target_coin_index)
			_play_sfx("hit")
		enemy["pos"] = _clamp_to_play_rect(enemy["pos"], ENEMY_RADIUS)
		enemy_list[enemy_index] = enemy
		return true
	return false


func _update_enemy_waves(delta: float) -> void:
	warning_time = WaveLogic.tick_timer(warning_time, delta)
	pet_message_time = WaveLogic.tick_timer(pet_message_time, delta)
	goal_message_time = WaveLogic.tick_timer(goal_message_time, delta)
	safe_reward_timer = WaveLogic.tick_safe_reward_timer(safe_reward_timer, delta)
	if _is_safe_reward_active():
		return
	enemy_spawn_timer = WaveLogic.tick_spawn_timer(enemy_spawn_timer, delta)
	if WaveLogic.should_spawn_enemy(enemy_spawn_timer):
		_spawn_enemy()
		_play_sfx("warning")
		var base_timer: float = _get_level_config()["enemy_timer"]
		enemy_spawn_timer = WaveLogic.next_enemy_spawn_timer(base_timer)


func _update_hit_effects(delta: float) -> void:
	screen_shake_time = max(0.0, screen_shake_time - delta)
	if screen_shake_time <= 0.0:
		screen_shake_strength = 0.0
	for index in range(hit_effects.size() - 1, -1, -1):
		var effect := hit_effects[index]
		EffectLogic.update_hit_effect(effect, delta)
		if EffectLogic.should_remove_effect(effect):
			hit_effects.remove_at(index)
		else:
			hit_effects[index] = effect


func _update_guard_effects(delta: float) -> void:
	for index in range(guard_effects.size() - 1, -1, -1):
		var effect := guard_effects[index]
		EffectLogic.update_guard_effect(effect, delta)
		if EffectLogic.should_remove_effect(effect):
			guard_effects.remove_at(index)
		else:
			guard_effects[index] = effect


func _update_jellyfish_effects(delta: float) -> void:
	for index in range(jellyfish_effects.size() - 1, -1, -1):
		var effect := jellyfish_effects[index]
		EffectLogic.update_jellyfish_effect(effect, delta)
		if EffectLogic.should_remove_effect(effect):
			jellyfish_effects.remove_at(index)
		else:
			jellyfish_effects[index] = effect


func _try_collect_coin(click_position: Vector2) -> bool:
	for index in range(coin_list.size() - 1, -1, -1):
		var coin := coin_list[index]
		if ResourceLogic.should_collect_coin_at(coin, click_position, COIN_RADIUS + 10.0):
			_collect_player_coin(coin)
			coin_list.remove_at(index)
			_play_sfx("coin")
			return true
	return _try_start_coin_magnet(click_position)


func _try_sweep_collect_coin(sweep_position: Vector2) -> bool:
	if not PLAY_RECT.has_point(sweep_position):
		return false
	var collected := false
	for index in range(coin_list.size() - 1, -1, -1):
		var coin := coin_list[index]
		if ResourceLogic.should_collect_coin_at(coin, sweep_position, COIN_SWEEP_RADIUS):
			_collect_player_coin(coin)
			coin_list.remove_at(index)
			collected = true
	if collected:
		_play_sfx("coin")
	return collected


func _try_start_coin_magnet(origin: Vector2) -> bool:
	if not PLAY_RECT.has_point(origin):
		return false
	var started := false
	for index in range(coin_list.size() - 1, -1, -1):
		var coin := coin_list[index]
		if ResourceLogic.can_start_player_magnet(coin, origin, COIN_MAGNET_RADIUS):
			ResourceLogic.start_player_magnet(coin, origin, COIN_MAGNET_DURATION)
			coin_list[index] = coin
			started = true
	return started


func _try_attack_enemy(click_position: Vector2) -> bool:
	var index := CombatLogic.enemy_hit_index(click_position, enemy_list, ENEMY_RADIUS + 12.0)
	if index < 0:
		return false
	var enemy := enemy_list[index]
	if CombatLogic.apply_enemy_damage(enemy, 1):
		run_enemies_defeated += 1
		_spawn_hit_effect(enemy["pos"], true)
		_spawn_coin(enemy["pos"], _enemy_coin_reward(enemy))
		enemy_list.remove_at(index)
		_try_start_safe_reward_window()
		_play_sfx("defeat")
	else:
		_spawn_hit_effect(enemy["pos"], false)
		enemy_list[index] = enemy
		_play_sfx("hit")
	return true


func _find_nearest_food_index(origin: Vector2) -> int:
	return AquariumQueries.find_nearest_index(origin, food_list)


func _find_nearest_fish_index(origin: Vector2) -> int:
	return AquariumQueries.find_nearest_index(origin, fish_list)


func _find_nearest_enemy_index(origin: Vector2, max_distance: float) -> int:
	return AquariumQueries.find_nearest_index(origin, enemy_list, max_distance)


func _find_nearest_coin_index(origin: Vector2) -> int:
	return AquariumQueries.find_nearest_index(origin, coin_list)


func _guard_fish_attack(origin: Vector2, enemy_index: int) -> void:
	var enemy := enemy_list[enemy_index]
	_spawn_guard_effect(origin, enemy["pos"])
	if CombatLogic.apply_enemy_damage(enemy, 1):
		run_enemies_defeated += 1
		_spawn_hit_effect(enemy["pos"], true)
		_spawn_coin(enemy["pos"], _enemy_coin_reward(enemy))
		enemy_list.remove_at(enemy_index)
		_try_start_safe_reward_window()
		_play_sfx("defeat")
	else:
		_spawn_hit_effect(enemy["pos"], false)
		enemy_list[enemy_index] = enemy
		_play_sfx("hit")


func _electric_jellyfish_attack(enemy_index: int) -> void:
	var enemy := enemy_list[enemy_index]
	_spawn_jellyfish_effect(ELECTRIC_JELLYFISH_HOME, enemy["pos"])
	if CombatLogic.apply_enemy_damage(enemy, ELECTRIC_JELLYFISH_DAMAGE):
		run_enemies_defeated += 1
		_spawn_hit_effect(enemy["pos"], true)
		_spawn_coin(enemy["pos"], _enemy_coin_reward(enemy))
		enemy_list.remove_at(enemy_index)
		_try_start_safe_reward_window()
		_play_sfx("defeat")
	else:
		_spawn_hit_effect(enemy["pos"], false)
		enemy_list[enemy_index] = enemy
		_play_sfx("hit")


func _fish_separation_vector(fish_index: int) -> Vector2:
	return AquariumQueries.fish_separation_vector(fish_index, fish_list, FISH_SEPARATION_RADIUS)


func _random_play_position() -> Vector2:
	return AquariumQueries.random_play_position()


func _clamp_to_play_rect(value: Vector2, margin: float) -> Vector2:
	return AquariumQueries.clamp_to_rect(value, PLAY_RECT, margin)


func _update_play_time(delta: float) -> void:
	run_play_seconds += delta
	total_play_seconds += delta


func _check_failure(delta: float) -> void:
	no_fish_timer = ProgressionLogic.next_no_fish_timer(fish_list.size(), no_fish_timer, delta)
	if ProgressionLogic.should_fail_without_fish(fish_list.size(), money, _minimum_fish_cost(), no_fish_timer, NO_FISH_GRACE_TIME):
		_trigger_game_over()
		_save_progress()


func _update_coin_combo(delta: float) -> void:
	coin_combo_timer = ComboLogic.tick_combo_timer(coin_combo_timer, delta)
	if ComboLogic.should_reset_streak(coin_combo_timer):
		coin_combo_count = 0


func _collect_player_coin(coin: Dictionary) -> void:
	coin_combo_count = ComboLogic.advance_streak(coin_combo_count, COIN_COMBO_MAX)
	coin_combo_timer = COIN_COMBO_WINDOW
	var base_value := int(coin["value"])
	var collected_value := ComboLogic.collected_coin_value(base_value, coin_combo_count, COIN_COMBO_BONUS_PER_STEP, COIN_COMBO_MAX_MULTIPLIER)
	money += collected_value
	if collected_value > base_value:
		run_money_earned += collected_value - base_value


func _reset_coin_combo() -> void:
	coin_combo_count = 0
	coin_combo_timer = 0.0


func _trigger_game_over() -> void:
	if game_over:
		return
	game_over = true
	_reset_coin_combo()
	_play_sfx("fail")


func _update_ui() -> void:
	var view_model := AquariumHUDPresenter.build_view_model(_hud_state(), GameData.FISH_TYPES, _get_level_config())
	money_label.text = view_model["money_text"]
	status_label.text = view_model["status_text"]
	var fish_button_states: Array = view_model["fish_buttons"]
	for fish_index in range(min(fish_buy_buttons.size(), fish_button_states.size())):
		var button_state: Dictionary = fish_button_states[fish_index]
		fish_buy_buttons[fish_index].text = button_state["text"]
		fish_buy_buttons[fish_index].disabled = button_state["disabled"]
	upgrade_food_button.disabled = view_model["upgrade_food_disabled"]
	upgrade_food_button.text = view_model["upgrade_food_text"]
	var core_affordable: bool = view_model["core_affordable"]
	buy_core_button.disabled = not core_affordable
	buy_core_button.text = view_model["core_text"]
	_update_core_purchase_hint(core_affordable)
	pause_button.disabled = view_model["pause_disabled"]
	pause_button.text = view_model["pause_text"]
	restart_button.text = view_model["restart_text"]
	menu_button.disabled = view_model["menu_disabled"]


func _hud_state() -> Dictionary:
	return {
		"money": money,
		"food_level": food_level,
		"cores": cores,
		"current_level": current_level,
		"max_level": MAX_LEVEL,
		"fish_count": fish_list.size(),
		"enemy_count": enemy_list.size(),
		"paused": paused,
		"game_over": game_over,
		"level_cleared": level_cleared,
		"unlocked_cleaner_snail": unlocked_cleaner_snail,
		"unlocked_bubble_seahorse": unlocked_bubble_seahorse,
		"unlocked_electric_jellyfish": unlocked_electric_jellyfish,
		"enemy_spawn_timer": enemy_spawn_timer,
		"no_fish_timer": no_fish_timer,
		"no_fish_grace_time": NO_FISH_GRACE_TIME,
		"total_play_seconds": total_play_seconds,
		"core_cost": _core_cost(),
		"food_upgrade_cost": _food_upgrade_cost(),
		"pre_invasion_active": _is_pre_invasion_warning_active(),
		"defense_active": _is_defense_pressure_active(),
		"safe_reward_active": _is_safe_reward_active(),
		"safe_reward_timer": safe_reward_timer,
		"coin_combo_count": coin_combo_count,
		"coin_combo_bonus_percent": ComboLogic.bonus_percent(coin_combo_count, COIN_COMBO_BONUS_PER_STEP, COIN_COMBO_MAX_MULTIPLIER),
	}


func _food_upgrade_cost() -> int:
	return EconomyLogic.food_upgrade_cost(food_level)


func _can_buy_core() -> bool:
	return EconomyLogic.can_buy_core(money, _core_cost(), cores, paused, game_over, level_cleared)


func _is_pre_invasion_warning_active() -> bool:
	return WaveLogic.is_pre_invasion_warning_active(enemy_spawn_timer, PRE_INVASION_WARNING_TIME, game_over, level_cleared)


func _is_defense_pressure_active() -> bool:
	return WaveLogic.is_defense_pressure_active(enemy_list.size(), game_over, level_cleared)


func _is_safe_reward_active() -> bool:
	return WaveLogic.is_safe_reward_active(safe_reward_timer, game_over, level_cleared)


func _hunger_drain_multiplier() -> float:
	return DEFENSE_HUNGER_MULTIPLIER if _is_defense_pressure_active() or _is_safe_reward_active() else 1.0


func _safe_reward_coin_value(base_value: int) -> int:
	if not _is_safe_reward_active():
		return base_value
	return int(ceil(float(base_value) * SAFE_REWARD_COIN_MULTIPLIER))


func _try_start_safe_reward_window() -> void:
	if not WaveLogic.should_start_safe_reward(enemy_list.size(), game_over, level_cleared):
		return
	safe_reward_timer = SAFE_REWARD_TIME
	warning_time = 0.0
	_play_sfx("coin")


func _update_core_purchase_hint(core_affordable: bool) -> void:
	core_hint_label.visible = core_affordable
	if core_affordable:
		var pulse := (sin(Time.get_ticks_msec() / 180.0) + 1.0) * 0.5
		buy_core_button.modulate = Color(1.0, 0.92 + pulse * 0.08, 0.42 + pulse * 0.28)
		buy_core_button.scale = Vector2.ONE * (1.0 + pulse * 0.045)
		core_hint_label.modulate = Color(1.0, 0.96, 0.55, 0.72 + pulse * 0.28)
	else:
		buy_core_button.modulate = Color.WHITE
		buy_core_button.scale = Vector2.ONE
		core_hint_label.modulate = Color.WHITE


func _core_cost() -> int:
	return EconomyLogic.core_cost(_get_level_config(), cores)


func _get_level_config() -> Dictionary:
	return GameData.LEVEL_CONFIGS.get(current_level, GameData.LEVEL_CONFIGS[1])


func _fish_shop_short_name(fish_config: Dictionary) -> String:
	return AquariumHUDPresenter.fish_shop_short_name(fish_config)


func _fish_config(fish_type_id: String) -> Dictionary:
	for config in GameData.FISH_TYPES:
		if config["id"] == fish_type_id:
			return config
	return GameData.FISH_TYPES[0]


func _minimum_fish_cost() -> int:
	return EconomyLogic.minimum_fish_cost(GameData.FISH_TYPES)


func _enemy_coin_reward(enemy: Dictionary) -> int:
	return CombatLogic.enemy_coin_reward(enemy)


func _format_time(seconds: float) -> String:
	return AquariumHUDPresenter.format_time(seconds)


func _load_progress() -> void:
	save_slots = SaveSystem.default_slots()
	active_slot_index = -1
	_reset_runtime_progress()

	var save_data := SaveSystem.read_save_file()
	if save_data.is_empty():
		return
	if save_data.has("slots"):
		var parsed_slots: Variant = save_data.get("slots", [])
		if parsed_slots is Array:
			for slot_index in range(min(SAVE_SLOT_COUNT, parsed_slots.size())):
				var raw_slot: Variant = parsed_slots[slot_index]
				if raw_slot is Dictionary:
					save_slots[slot_index] = _normalize_slot(raw_slot)
		active_slot_index = clamp(int(save_data.get("active_slot_index", -1)), -1, SAVE_SLOT_COUNT - 1)
	else:
		save_slots[0] = _normalize_slot({
			"exists": true,
			"name": "旧存档",
			"highest_unlocked_level": save_data.get("highest_unlocked_level", 1),
			"unlocked_cleaner_snail": save_data.get("unlocked_cleaner_snail", false),
			"unlocked_bubble_seahorse": save_data.get("unlocked_bubble_seahorse", false),
			"unlocked_electric_jellyfish": save_data.get("unlocked_electric_jellyfish", false),
			"cleared_levels": save_data.get("cleared_levels", []),
			"total_play_seconds": save_data.get("total_play_seconds", 0.0),
		})
		active_slot_index = 0
		_write_save_data()

	if active_slot_index >= 0 and bool(save_slots[active_slot_index].get("exists", false)):
		_apply_slot_progress(active_slot_index)
	else:
		active_slot_index = _first_existing_slot_index()
		if active_slot_index >= 0:
			_apply_slot_progress(active_slot_index)


func _save_progress() -> void:
	if active_slot_index < 0:
		return
	var slot := save_slots[active_slot_index]
	if not bool(slot.get("exists", false)):
		return
	slot["highest_unlocked_level"] = highest_unlocked_level
	slot["unlocked_cleaner_snail"] = unlocked_cleaner_snail
	slot["unlocked_bubble_seahorse"] = unlocked_bubble_seahorse
	slot["unlocked_electric_jellyfish"] = unlocked_electric_jellyfish
	slot["cleared_levels"] = cleared_levels.duplicate()
	slot["total_play_seconds"] = total_play_seconds
	save_slots[active_slot_index] = slot
	_write_save_data()


func _write_save_data() -> void:
	SaveSystem.write_save_file(active_slot_index, save_slots)


func _empty_slot() -> Dictionary:
	return SaveSystem.empty_slot()


func _normalize_slot(raw_slot: Dictionary) -> Dictionary:
	return SaveSystem.normalize_slot(raw_slot, MAX_LEVEL)


func _reset_runtime_progress() -> void:
	highest_unlocked_level = 1
	unlocked_cleaner_snail = false
	unlocked_bubble_seahorse = false
	unlocked_electric_jellyfish = false
	cleared_levels.clear()
	cleaner_snail_position = CLEANER_SNAIL_HOME
	bubble_seahorse_position = BUBBLE_SEAHORSE_HOME
	bubble_seahorse_target = BUBBLE_SEAHORSE_HOME
	bubble_seahorse_timer = BUBBLE_SEAHORSE_FEED_INTERVAL
	bubble_seahorse_pending_feed = false
	electric_jellyfish_timer = ELECTRIC_JELLYFISH_ATTACK_INTERVAL
	total_play_seconds = 0.0
	run_play_seconds = 0.0
	no_fish_timer = 0.0


func _apply_slot_progress(slot_index: int) -> void:
	var slot := save_slots[slot_index]
	highest_unlocked_level = int(slot.get("highest_unlocked_level", 1))
	unlocked_cleaner_snail = bool(slot.get("unlocked_cleaner_snail", false))
	unlocked_bubble_seahorse = bool(slot.get("unlocked_bubble_seahorse", false))
	unlocked_electric_jellyfish = bool(slot.get("unlocked_electric_jellyfish", false))
	total_play_seconds = float(slot.get("total_play_seconds", 0.0))
	run_play_seconds = 0.0
	no_fish_timer = 0.0
	cleared_levels.clear()
	var slot_levels: Variant = slot.get("cleared_levels", [])
	if slot_levels is Array:
		for level_value in slot_levels:
			var level: int = clamp(int(level_value), 1, MAX_LEVEL)
			if not cleared_levels.has(level):
				cleared_levels.append(level)
	cleaner_snail_position = CLEANER_SNAIL_HOME
	bubble_seahorse_position = BUBBLE_SEAHORSE_HOME
	bubble_seahorse_target = BUBBLE_SEAHORSE_HOME
	bubble_seahorse_timer = BUBBLE_SEAHORSE_FEED_INTERVAL
	bubble_seahorse_pending_feed = false
	electric_jellyfish_timer = ELECTRIC_JELLYFISH_ATTACK_INTERVAL


func _next_helper_unlock_text() -> String:
	if not unlocked_cleaner_snail:
		return "通关第 1 关解锁清洁螺"
	if not unlocked_bubble_seahorse:
		return "通关第 2 关解锁泡泡海马"
	if not unlocked_electric_jellyfish:
		return "通关第 3 关解锁电光水母"
	return "清洁螺、泡泡海马与电光水母已解锁"


func _first_existing_slot_index() -> int:
	return SaveSystem.first_existing_slot_index(save_slots)


func _first_empty_slot_index() -> int:
	return SaveSystem.first_empty_slot_index(save_slots)


func _record_level_clear() -> void:
	if not cleared_levels.has(current_level):
		cleared_levels.append(current_level)
	highest_unlocked_level = ProgressionLogic.unlocked_level_after_clear(current_level, highest_unlocked_level, MAX_LEVEL)
	_save_progress()


func _on_buy_fish_type_pressed(fish_index: int) -> void:
	if fish_index < 0 or fish_index >= GameData.FISH_TYPES.size():
		return
	var fish_config: Dictionary = GameData.FISH_TYPES[fish_index]
	var cost := int(fish_config["cost"])
	if not EconomyLogic.can_buy_fish(money, fish_config, game_over, level_cleared):
		return
	money -= cost
	_spawn_fish(_random_play_position(), str(fish_config["id"]))
	run_fish_bought += 1
	no_fish_timer = 0.0
	_play_sfx("buy")


func _on_buy_fish_pressed() -> void:
	_on_buy_fish_type_pressed(selected_fish_type_index)


func _on_upgrade_food_pressed() -> void:
	var cost := _food_upgrade_cost()
	if not EconomyLogic.can_upgrade_food(money, food_level, cost, game_over, level_cleared):
		return
	money -= cost
	food_level += 1
	_play_sfx("buy")


func _on_buy_core_pressed() -> void:
	var cost := _core_cost()
	if money < cost or game_over or level_cleared:
		return
	money -= cost
	cores += 1
	_play_sfx("buy")
	if ProgressionLogic.should_clear_level(cores):
		if ProgressionLogic.should_unlock_cleaner_snail(current_level, unlocked_cleaner_snail):
			unlocked_cleaner_snail = true
			pet_message_time = 6.0
			last_pet_unlock_message = "新助手解锁：清洁螺会自动捡起底部附近金币"
		if ProgressionLogic.should_unlock_bubble_seahorse(current_level, unlocked_bubble_seahorse):
			unlocked_bubble_seahorse = true
			bubble_seahorse_position = BUBBLE_SEAHORSE_HOME
			bubble_seahorse_target = BUBBLE_SEAHORSE_HOME
			bubble_seahorse_timer = 1.2
			bubble_seahorse_pending_feed = false
			pet_message_time = 6.0
			last_pet_unlock_message = "新助手解锁：泡泡海马会自动给饥饿鱼投喂"
		if ProgressionLogic.should_unlock_electric_jellyfish(current_level, MAX_LEVEL, unlocked_electric_jellyfish):
			unlocked_electric_jellyfish = true
			electric_jellyfish_timer = 1.2
			pet_message_time = 6.0
			last_pet_unlock_message = "新助手解锁：电光水母会自动电击入侵敌人"
		_record_level_clear()
		level_cleared = true
		_play_sfx("clear")
		_save_progress()


func _on_restart_pressed() -> void:
	_play_sfx("buy")
	if level_cleared and current_level < MAX_LEVEL:
		_start_level(current_level + 1)
	elif level_cleared and current_level >= MAX_LEVEL:
		_show_main_menu()
	else:
		_start_level(current_level)


func _on_pause_pressed() -> void:
	if in_menu or game_over or level_cleared:
		return
	paused = not paused
	_play_sfx("buy")
	_update_ui()
	queue_redraw()


func _on_audio_toggle_pressed() -> void:
	audio_enabled = not audio_enabled
	_update_audio_state()
	if audio_enabled:
		_play_sfx("coin")


func _on_menu_pressed() -> void:
	_play_sfx("buy")
	_show_main_menu()


func _on_continue_pressed() -> void:
	if active_slot_index < 0:
		_show_save_manager()
		return
	_play_sfx("buy")
	_start_level(highest_unlocked_level)


func _on_level_button_pressed(level: int) -> void:
	if level > highest_unlocked_level:
		return
	_play_sfx("buy")
	_start_level(level)


func _on_save_manager_pressed() -> void:
	_play_sfx("buy")
	_show_save_manager()


func _on_create_save_pressed() -> void:
	var slot_index := _first_empty_slot_index()
	if slot_index < 0:
		_update_save_manager("三个槽位都已有存档，请先删除一个。")
		return
	var save_name := new_save_name_input.text.strip_edges()
	if save_name == "":
		save_name = "存档 %d" % (slot_index + 1)
	save_slots[slot_index] = _normalize_slot({
		"exists": true,
		"name": save_name,
		"highest_unlocked_level": 1,
		"unlocked_cleaner_snail": false,
		"cleared_levels": [],
		"total_play_seconds": 0.0,
	})
	active_slot_index = slot_index
	_apply_slot_progress(slot_index)
	_write_save_data()
	new_save_name_input.text = ""
	_update_save_manager("已新建并选择：%s" % save_name)
	_update_menu_ui()
	_play_sfx("buy")


func _on_enter_slot_pressed(slot_index: int) -> void:
	if not bool(save_slots[slot_index].get("exists", false)):
		return
	active_slot_index = slot_index
	_apply_slot_progress(slot_index)
	_write_save_data()
	_update_menu_ui()
	_play_sfx("buy")
	_start_level(highest_unlocked_level)


func _on_delete_slot_pressed(slot_index: int) -> void:
	if not bool(save_slots[slot_index].get("exists", false)):
		return
	var deleted_name := str(save_slots[slot_index].get("name", "未命名存档"))
	save_slots[slot_index] = _empty_slot()
	if active_slot_index == slot_index:
		active_slot_index = _first_existing_slot_index()
		if active_slot_index >= 0:
			_apply_slot_progress(active_slot_index)
		else:
			_reset_runtime_progress()
	_write_save_data()
	_update_save_manager("已删除：%s" % deleted_name)
	_update_menu_ui()
	_play_sfx("hit")


func _on_back_to_menu_pressed() -> void:
	_play_sfx("buy")
	_show_main_menu()


func _draw_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color("073244"), true)
	draw_rect(PLAY_RECT, Color("0b6f8f"), true)
	for y in range(150, 700, 70):
		draw_line(Vector2(0, y), Vector2(1280, y + 18), Color(1, 1, 1, 0.04), 3.0)
	for x in range(80, 1280, 150):
		draw_circle(Vector2(x, 680 + sin(Time.get_ticks_msec() / 500.0 + x) * 6.0), 5.0, Color(0.75, 0.95, 1.0, 0.35))


func _draw_menu_atmosphere() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color("052634", 0.38), true)
	for index in range(12):
		var x := 90.0 + index * 105.0
		var y := 610.0 + sin(Time.get_ticks_msec() / 700.0 + index) * 18.0
		draw_circle(Vector2(x, y), 10.0 + float(index % 3) * 4.0, Color(0.67, 0.93, 1.0, 0.18))
	draw_circle(Vector2(210, 250), 44.0, Color("49d6ff", 0.2))
	draw_circle(Vector2(1060, 190), 62.0, Color("ffd166", 0.13))
	draw_circle(Vector2(1020, 560), 46.0, Color("c4b5fd", 0.16))


func _draw_fish() -> void:
	for fish in fish_list:
		var position: Vector2 = fish["pos"]
		var fish_config := _fish_config(str(fish.get("type", "blue")))
		var mature: bool = fish["growth"] >= 1.0
		var type_scale: float = float(fish_config["scale"])
		var scale: float = (1.25 if mature else 0.85) * type_scale
		var facing: float = fish.get("facing", 1.0)
		var velocity: Vector2 = fish["velocity"]
		var swim_tilt: float = clamp(velocity.y / 160.0, -0.28, 0.28)
		var forward: Vector2 = Vector2(facing, swim_tilt).normalized()
		var up: Vector2 = Vector2(-forward.y, forward.x)
		var body_color: Color = Color(str(fish_config["body_color"])) if mature else Color(str(fish_config["belly_color"]))
		var tail_color: Color = Color(str(fish_config["tail_color"]))
		var body_points := PackedVector2Array([
			position + forward * 24.0 * scale,
			position + forward * 13.0 * scale + up * 13.0 * scale,
			position - forward * 12.0 * scale + up * 15.0 * scale,
			position - forward * 23.0 * scale,
			position - forward * 12.0 * scale - up * 15.0 * scale,
			position + forward * 13.0 * scale - up * 13.0 * scale,
		])
		var tail_base: Vector2 = position - forward * 22.0 * scale
		draw_polygon(PackedVector2Array([
			tail_base,
			tail_base - forward * 19.0 * scale + up * 13.0 * scale,
			tail_base - forward * 19.0 * scale - up * 13.0 * scale,
		]), [tail_color])
		draw_polygon(body_points, [body_color])
		draw_circle(position - forward * 5.0 * scale - up * 7.0 * scale, 4.0 * scale, Color("0891b2", 0.45))
		draw_polygon(PackedVector2Array([
			position - forward * 2.0 * scale + up * 15.0 * scale,
			position - forward * 9.0 * scale + up * 27.0 * scale,
			position + forward * 8.0 * scale + up * 14.0 * scale,
		]), [tail_color.lightened(0.28)])
		if str(fish_config["id"]) == "gold":
			draw_circle(position - forward * 2.0 * scale + up * 2.0 * scale, 2.2 * scale, Color("fff7ad"))
			draw_circle(position + forward * 5.0 * scale + up * 3.0 * scale, 1.8 * scale, Color("fff7ad"))
		elif str(fish_config["id"]) == "guard":
			if mature:
				draw_circle(position, 34.0 * scale, Color("34d399", 0.12))
			draw_line(position - forward * 4.0 * scale - up * 12.0 * scale, position + forward * 11.0 * scale - up * 12.0 * scale, Color("064e3b"), 3.0 * scale)
		draw_circle(position + forward * 12.0 * scale - up * 5.0 * scale, 3.2 * scale, Color("06384a"))
		draw_circle(position + forward * 13.0 * scale - up * 6.0 * scale, 1.0 * scale, Color.WHITE)
		var hunger_ratio: float = clamp(fish["hunger"] / 32.0, 0.0, 1.0)
		var hunger_color := Color("22c55e")
		if hunger_ratio < 0.2:
			var flash := 0.65 + sin(Time.get_ticks_msec() / 90.0) * 0.35
			hunger_color = Color(1.0, 0.12 + flash * 0.18, 0.12, 1.0)
			draw_circle(position + forward * 20.0 * scale - up * 16.0 * scale, 4.0 * scale, Color("ef4444"))
		elif hunger_ratio < 0.45:
			hunger_color = Color("facc15")
		draw_rect(Rect2(position + Vector2(-20, 23), Vector2(40, 6)), Color("0f172a", 0.65), true)
		draw_rect(Rect2(position + Vector2(-18, 24), Vector2(36 * hunger_ratio, 4)), hunger_color, true)


func _draw_food() -> void:
	for food in food_list:
		var position: Vector2 = food["pos"]
		var nutrition := int(food["nutrition"])
		if nutrition <= 1:
			draw_circle(position, FOOD_RADIUS + 1.0, Color("ffd166"))
			draw_circle(position + Vector2(-2, -2), 2.0, Color("fff3b0"))
		elif nutrition == 2:
			draw_circle(position, FOOD_RADIUS + 3.0, Color("f97316"))
			draw_circle(position, FOOD_RADIUS, Color("fed7aa"))
			draw_circle(position + Vector2(5, -4), 3.0, Color("fb923c"))
		else:
			draw_circle(position, FOOD_RADIUS + 5.0, Color("facc15"))
			draw_circle(position, FOOD_RADIUS + 1.0, Color("fde68a"))
			for index in range(4):
				var angle := TAU * float(index) / 4.0 + Time.get_ticks_msec() / 500.0
				draw_circle(position + Vector2(cos(angle), sin(angle)) * 10.0, 2.0, Color("fff7ed"))


func _draw_coins() -> void:
	for coin in coin_list:
		var position: Vector2 = coin["pos"]
		var pulse := 1.0 + sin(Time.get_ticks_msec() / 140.0 + position.x) * 0.08
		draw_circle(position, (COIN_RADIUS + 5.0) * pulse, Color("fff7ad", 0.24))
		draw_circle(position, COIN_RADIUS + 2.0, Color("8a4b00"))
		draw_circle(position, COIN_RADIUS, Color("ffca3a"))
		draw_circle(position, COIN_RADIUS - 4.0, Color("ffe08a"))
		draw_line(position + Vector2(-4, -1), position + Vector2(4, -1), Color("b7791f"), 2.0)


func _draw_pets() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	if unlocked_cleaner_snail:
		_draw_cleaner_snail(t)
	if unlocked_bubble_seahorse:
		_draw_bubble_seahorse(t)
	if unlocked_electric_jellyfish:
		_draw_electric_jellyfish(t)


func _draw_cleaner_snail(t: float) -> void:
	var bob := sin(t * 5.0) * 2.0
	var crawl := sin(t * 8.0) * 3.0
	var base := cleaner_snail_position + Vector2(0, bob)
	_draw_ellipse_poly(base + Vector2(-2, 14), Vector2(24, 6), Color("312e81", 0.28))
	draw_circle(base + Vector2(-4, 0), 21.0, Color("8b5cf6"))
	draw_circle(base + Vector2(-4, 0), 14.0, Color("a78bfa"))
	draw_circle(base + Vector2(-4, 0), 7.0, Color("6d28d9"))
	draw_arc(base + Vector2(-4, 0), 18.0, 0.2, TAU * 0.82, 26, Color("ede9fe", 0.72), 2.0)
	_draw_ellipse_poly(base + Vector2(21, 5), Vector2(16, 9), Color("c4b5fd"))
	draw_circle(base + Vector2(31, -8), 7.5, Color("ddd6fe"))
	draw_circle(base + Vector2(34, -10), 2.0, Color("1e1b4b"))
	draw_line(base + Vector2(25, -13), base + Vector2(18 + crawl, -29), Color("f5f3ff"), 2.0)
	draw_line(base + Vector2(31, -12), base + Vector2(36 - crawl, -28), Color("f5f3ff"), 2.0)
	draw_circle(base + Vector2(18 + crawl, -29), 2.5, Color("f5f3ff"))
	draw_circle(base + Vector2(36 - crawl, -28), 2.5, Color("f5f3ff"))
	draw_line(base + Vector2(-20, 16), base + Vector2(-28 + crawl, 22), Color("ddd6fe", 0.75), 2.0)
	draw_line(base + Vector2(8, 16), base + Vector2(16 - crawl, 22), Color("ddd6fe", 0.75), 2.0)


func _draw_bubble_seahorse(t: float) -> void:
	var bob := sin(t * 3.2) * 6.0
	var tail := sin(t * 6.0) * 4.0
	var base := bubble_seahorse_position + Vector2(0, bob)
	if bubble_seahorse_pending_feed:
		draw_line(base + Vector2(-18, -24), bubble_seahorse_target, Color("bae6fd", 0.2), 2.0)
		draw_circle(bubble_seahorse_target, 13.0 + sin(t * 8.0) * 3.0, Color("e0f2fe", 0.18))
	_draw_ellipse_poly(base + Vector2(2, 22), Vector2(24, 7), Color("075985", 0.24))
	_draw_ellipse_poly(base, Vector2(18, 31), Color("38bdf8"))
	_draw_ellipse_poly(base + Vector2(-2, -2), Vector2(11, 23), Color("bae6fd", 0.72))
	draw_circle(base + Vector2(-8, -28), 15.0, Color("67e8f9"))
	draw_circle(base + Vector2(-13, -31), 2.4, Color("083344"))
	draw_line(base + Vector2(-19, -24), base + Vector2(-34, -20 + tail), Color("22d3ee"), 5.0)
	draw_arc(base + Vector2(2, 26), 16.0, 0.25, TAU * 0.86, 24, Color("0e7490"), 4.0)
	draw_polygon(PackedVector2Array([base + Vector2(12, -6), base + Vector2(32, -18 + tail), base + Vector2(24, 6 + tail)]), [Color("0891b2")])
	for index in range(3):
		var bubble_offset := Vector2(-34.0 - float(index) * 14.0, -38.0 - float(index) * 18.0 + sin(t * 4.0 + index) * 5.0)
		draw_circle(base + bubble_offset, 5.0 + float(index), Color("e0f2fe", 0.28))


func _draw_electric_jellyfish(t: float) -> void:
	var bob := sin(t * 2.6) * 7.0
	var pulse := 0.5 + sin(t * 5.0) * 0.5
	var base := ELECTRIC_JELLYFISH_HOME + Vector2(0, bob)
	draw_circle(base, 38.0 + pulse * 6.0, Color("a5f3fc", 0.08 + pulse * 0.06))
	_draw_ellipse_poly(base, Vector2(30, 22), Color("67e8f9", 0.78))
	_draw_ellipse_poly(base + Vector2(-4, -4), Vector2(20, 14), Color("ecfeff", 0.45))
	draw_arc(base + Vector2(0, 3), 28.0, 0.05, TAU * 0.48, 18, Color("0891b2", 0.8), 3.0)
	for index in range(5):
		var x_offset := -22.0 + float(index) * 11.0
		var wave := sin(t * 6.0 + float(index)) * 6.0
		var start := base + Vector2(x_offset, 16)
		var middle := base + Vector2(x_offset + wave, 36)
		var end := base + Vector2(x_offset - wave * 0.5, 54 + sin(t * 4.0 + index) * 5.0)
		draw_line(start, middle, Color("cffafe", 0.72), 2.0)
		draw_line(middle, end, Color("22d3ee", 0.62), 2.0)
	draw_circle(base + Vector2(-9, -2), 2.2, Color("164e63"))
	draw_circle(base + Vector2(9, -2), 2.2, Color("164e63"))


func _draw_ellipse_poly(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in range(18):
		var angle := TAU * float(index) / 18.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_polygon(points, [color])


func _draw_enemies() -> void:
	for enemy in enemy_list:
		var position: Vector2 = enemy["pos"]
		var t := Time.get_ticks_msec() / 1000.0
		var enemy_type := str(enemy.get("type", "tank" if enemy.get("tank", false) else "normal"))
		var is_tank: bool = enemy["tank"]
		var is_thief := enemy_type == "thief"
		var pulse := 1.0 + sin(t * (4.0 if is_tank else 7.0) + position.x * 0.02) * 0.07
		var color := Color("7c3aed") if is_thief else (Color("991b1b") if is_tank else Color("ef476f"))
		var edge_color := Color("facc15") if is_thief else (Color("fecaca") if is_tank else Color("fda4af"))
		for i in range(8 if is_tank else 6):
			var angle := TAU * float(i) / 6.0
			if is_tank:
				angle = TAU * float(i) / 8.0
			var wave := sin(t * 5.0 + float(i)) * 0.22
			var direction := Vector2(cos(angle + wave), sin(angle + wave))
			var length := 42.0 if is_tank else 36.0
			draw_line(position + direction * 12.0, position + direction * length, color, 7.0 if is_tank else 5.0)
			draw_circle(position + direction * length, 4.0 if is_tank else 3.0, edge_color)
		if is_thief:
			draw_circle(position, ENEMY_RADIUS * 0.92 * pulse, color)
			draw_circle(position + Vector2(0, 8), ENEMY_RADIUS * 0.42, Color("facc15"))
			draw_line(position + Vector2(-8, 8), position + Vector2(8, 8), Color("92400e"), 2.5)
		elif is_tank:
			draw_circle(position, ENEMY_RADIUS * 1.14 * pulse, Color("7f1d1d"))
			draw_circle(position, ENEMY_RADIUS * 0.82 * pulse, Color("dc2626"))
			draw_line(position + Vector2(-18, -12), position + Vector2(18, 12), Color("fecaca", 0.55), 3.0)
			draw_line(position + Vector2(-18, 12), position + Vector2(18, -12), Color("fecaca", 0.55), 3.0)
		else:
			draw_circle(position, ENEMY_RADIUS * pulse, color)
			draw_circle(position + Vector2(0, 5), ENEMY_RADIUS * 0.52, Color("fb7185"))
		var eye_offset := Vector2(0, 0)
		var target_index := _find_nearest_fish_index(position)
		if target_index >= 0:
			eye_offset = (fish_list[target_index]["pos"] - position).normalized() * 2.5
		draw_circle(position + Vector2(-7, -6) + eye_offset, 4.5, Color("fde68a") if is_thief else Color.WHITE)
		draw_circle(position + Vector2(7, -6) + eye_offset, 4.5, Color("fde68a") if is_thief else Color.WHITE)
		draw_circle(position + Vector2(-7, -6) + eye_offset * 1.4, 2.0, Color("111827"))
		draw_circle(position + Vector2(7, -6) + eye_offset * 1.4, 2.0, Color("111827"))
		draw_line(position + Vector2(-9, 9), position + Vector2(9, 9), Color("450a0a"), 3.0)
		var hp_ratio: float = float(enemy["hp"]) / float(enemy["max_hp"])
		draw_rect(Rect2(position + Vector2(-24, -36), Vector2(48, 5)), Color("2b1111"), true)
		draw_rect(Rect2(position + Vector2(-24, -36), Vector2(48 * hp_ratio, 5)), Color("fb7185"), true)


func _draw_guard_effects() -> void:
	for effect in guard_effects:
		var origin: Vector2 = effect["origin"]
		var target: Vector2 = effect["target"]
		var max_life: float = effect["max_life"]
		var life: float = effect["life"]
		var alpha: float = clamp(life / max_life, 0.0, 1.0)
		draw_line(origin, target, Color("34d399", alpha), 5.0)
		draw_line(origin, target, Color("ecfdf5", alpha), 2.0)
		draw_circle(target, 12.0 * alpha, Color("6ee7b7", 0.5 * alpha))


func _draw_jellyfish_effects() -> void:
	for effect in jellyfish_effects:
		var origin: Vector2 = effect["origin"]
		var target: Vector2 = effect["target"]
		var max_life: float = effect["max_life"]
		var life: float = effect["life"]
		var alpha: float = clamp(life / max_life, 0.0, 1.0)
		var direction := target - origin
		var normal := Vector2(-direction.y, direction.x).normalized() if direction.length() > 0.1 else Vector2.UP
		var mid := origin.lerp(target, 0.52) + normal * sin(Time.get_ticks_msec() / 45.0) * 18.0
		draw_line(origin, mid, Color("22d3ee", alpha), 5.0)
		draw_line(mid, target, Color("a5f3fc", alpha), 5.0)
		draw_line(origin, target, Color("ecfeff", alpha * 0.68), 2.0)
		draw_circle(target, 17.0 * alpha, Color("67e8f9", 0.38 * alpha))


func _draw_hit_effects() -> void:
	for effect in hit_effects:
		var position: Vector2 = effect["pos"]
		var max_life: float = effect["max_life"]
		var life: float = effect["life"]
		var progress: float = 1.0 - life / max_life
		var alpha: float = clamp(life / max_life, 0.0, 1.0)
		var defeated: bool = effect["defeated"]
		var ring_color: Color = Color("ffd166", alpha) if defeated else Color("ffffff", alpha)
		draw_arc(position, 24.0 + progress * 34.0, 0.0, TAU, 28, ring_color, 4.0)
		for i in range(8):
			var angle: float = TAU * float(i) / 8.0 + progress * 0.9
			var start: Vector2 = position + Vector2(cos(angle), sin(angle)) * (18.0 + progress * 12.0)
			var end: Vector2 = position + Vector2(cos(angle), sin(angle)) * (34.0 + progress * 24.0)
			draw_line(start, end, Color("fff7ad", alpha), 3.0 if defeated else 2.0)
		var text_color: Color = Color("ffd166", alpha) if defeated else Color("ffffff", alpha)
		draw_string(chinese_font, position + Vector2(-18, -46 - progress * 18.0), effect["text"], HORIZONTAL_ALIGNMENT_LEFT, -1, 22 if defeated else 18, text_color)


func _get_screen_shake_offset() -> Vector2:
	if screen_shake_time <= 0.0 or screen_shake_strength <= 0.0:
		return Vector2.ZERO
	var shake := screen_shake_strength * (screen_shake_time / 0.16)
	return Vector2(randf_range(-shake, shake), randf_range(-shake, shake))


func _draw_overlay_messages() -> void:
	if goal_message_time > 0.0 and not game_over and not level_cleared:
		var config := _get_level_config()
		draw_rect(Rect2(Vector2(344, 148), Vector2(592, 132)), Color("082f49", 0.82), true)
		draw_rect(Rect2(Vector2(344, 148), Vector2(592, 132)), Color("7dd3fc", 0.55), false, 3.0)
		draw_string(chinese_font, Vector2(384, 190), "本关目标：%s" % str(config["goal"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color.WHITE)
		draw_string(chinese_font, Vector2(384, 226), str(config["tip"]), HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("bae6fd"))
		draw_string(chinese_font, Vector2(384, 256), "快捷键：把光标移到目标上，按空格/回车辅助点击。", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("fef3c7"))
	if warning_time > 0.0:
		var warning_text := "偷金币怪来了！保护金币" if last_enemy_type == "thief" else "入侵警报！点击敌人保护鱼群"
		draw_string(chinese_font, Vector2(500, 135), warning_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("ffdd57"))
		draw_string(chinese_font, Vector2(510, 164), "防守期鱼饥饿减缓，先处理敌人", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("fed7aa"))
	if _is_safe_reward_active():
		var remaining := int(ceil(max(0.0, safe_reward_timer)))
		draw_rect(Rect2(Vector2(400, 132), Vector2(480, 72)), Color("064e3b", 0.68), true)
		draw_rect(Rect2(Vector2(400, 132), Vector2(480, 72)), Color("86efac", 0.72), false, 3.0)
		draw_string(chinese_font, Vector2(430, 174), "防守成功！安全奖励 %d 秒" % remaining, HORIZONTAL_ALIGNMENT_LEFT, -1, 27, Color("dcfce7"))
		draw_string(chinese_font, Vector2(438, 198), "成熟鱼金币 +20%，下一波暂停倒计时", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("bbf7d0"))
	if pet_message_time > 0.0:
		draw_string(chinese_font, Vector2(430, 175), last_pet_unlock_message, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("e9d5ff"))
	if fish_list.is_empty() and not game_over and not level_cleared:
		var remaining := int(ceil(max(0.0, NO_FISH_GRACE_TIME - no_fish_timer)))
		draw_rect(Rect2(Vector2(396, 198), Vector2(488, 96)), Color("3b0a0a", 0.74), true)
		draw_rect(Rect2(Vector2(396, 198), Vector2(488, 96)), Color("fb7185", 0.8), false, 3.0)
		draw_string(chinese_font, Vector2(462, 238), "鱼群断档！%d 秒内购买新鱼" % remaining, HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
		draw_string(chinese_font, Vector2(470, 270), "否则本局经营失败", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("fecdd3"))
	if game_over:
		draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0, 0, 0, 0.45), true)
		_draw_result_panel("经营失败", "点击顶部“重新开始”再试一次，或回到菜单选关", Color("fecaca"))
	elif level_cleared:
		draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0, 0, 0, 0.35), true)
		if current_level < MAX_LEVEL:
			_draw_result_panel("通关！水晶核心已集齐", "点击顶部“下一关”继续，或回菜单查看已解锁关卡", Color("bbf7d0"))
		else:
			_draw_result_panel("Demo 完成！三关全部通过", "点击顶部“回菜单”查看存档，或重玩任意已解锁关卡", Color("bbf7d0"))


func _draw_result_panel(title: String, subtitle: String, accent: Color) -> void:
	var panel_rect := Rect2(Vector2(354, 178), Vector2(572, 372))
	draw_rect(panel_rect, Color("061826", 0.9), true)
	draw_rect(panel_rect, accent, false, 3.0)
	draw_string(chinese_font, Vector2(panel_rect.position.x, 238), title, HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 34, Color.WHITE)
	var stats := [
		"用时：%s" % _format_time(run_play_seconds),
		"击败敌人：%d" % run_enemies_defeated,
		"损失鱼：%d" % run_fish_lost,
		"金币收入：%d" % run_money_earned,
		"购买鱼：%d" % run_fish_bought,
		"最高鱼数：%d" % run_peak_fish_count,
	]
	for index in range(stats.size()):
		draw_string(chinese_font, Vector2(438, 294 + index * 32), stats[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("dbeafe"))
	draw_string(chinese_font, Vector2(panel_rect.position.x, 510), subtitle, HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 21, Color("cbd5e1"))


func _draw_pause_overlay() -> void:
	if not paused or game_over or level_cleared or in_menu:
		return
	draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0.02, 0.12, 0.18, 0.46), true)
	var panel_rect := Rect2(Vector2(360, 236), Vector2(560, 220))
	draw_rect(panel_rect, Color(0.02, 0.22, 0.30, 0.88), true)
	draw_rect(panel_rect, Color("7dd3fc", 0.55), false, 3.0)
	draw_string(chinese_font, Vector2(panel_rect.position.x, 314), "游戏已暂停", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 38, Color.WHITE)
	draw_string(chinese_font, Vector2(panel_rect.position.x, 366), "点击顶部“继续”恢复", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 22, Color("bae6fd"))
	draw_string(chinese_font, Vector2(panel_rect.position.x, 398), "或点击“菜单”返回选关", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x, 22, Color("bae6fd"))
