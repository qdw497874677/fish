extends Node2D

const VIEWPORT_SIZE := Vector2(1280, 720)
const PLAY_RECT := Rect2(0, 96, 1280, 624)
const FISH_RADIUS := 18.0
const FOOD_RADIUS := 6.0
const COIN_RADIUS := 11.0
const ENEMY_RADIUS := 24.0
const FISH_SEPARATION_RADIUS := 58.0
const FISH_SEPARATION_FORCE := 115.0
const GUARD_FISH_ATTACK_RANGE := 180.0
const GUARD_FISH_ATTACK_COOLDOWN := 2.4
const NO_FISH_GRACE_TIME := 12.0
const PRE_INVASION_WARNING_TIME := 2.0
const DEFENSE_HUNGER_MULTIPLIER := 0.5
const MAX_LEVEL := 3
const SAVE_SLOT_COUNT := 3
const SAVE_PATH := "user://aquarium_guard_save.json"
const CLEANER_SNAIL_HOME := Vector2(110, 672)
const CLEANER_SNAIL_SPEED := 185.0
const CLEANER_SNAIL_COLLECT_RADIUS := 28.0

const LEVEL_CONFIGS := {
	1: {
		"name": "浅水练习缸",
		"initial_money": 230,
		"initial_fish": 3,
		"core_base_cost": 290,
		"core_step_cost": 160,
		"enemy_timer": 20.0,
		"tank_enemy_chance": 0.0,
		"thief_enemy_chance": 0.0,
		"goal": "购买 3 个水晶核心",
		"tip": "喂鱼成长，成熟鱼会定期产金币。",
	},
	2: {
		"name": "珊瑚收益缸",
		"initial_money": 270,
		"initial_fish": 3,
		"core_base_cost": 430,
		"core_step_cost": 230,
		"enemy_timer": 16.0,
		"tank_enemy_chance": 0.0,
		"thief_enemy_chance": 0.22,
		"goal": "提高收益并守住金币",
		"tip": "偷金币怪会优先抢金币，及时收钱或养护卫鱼。",
	},
	3: {
		"name": "深海防线缸",
		"initial_money": 320,
		"initial_fish": 4,
		"core_base_cost": 620,
		"core_step_cost": 330,
		"enemy_timer": 13.0,
		"tank_enemy_chance": 0.32,
		"thief_enemy_chance": 0.34,
		"goal": "完成最终防线",
		"tip": "甲壳怪更厚，成熟护卫鱼能自动攻击敌人。",
	},
}

const FISH_TYPES := [
	{
		"id": "blue",
		"name": "蓝泡鱼",
		"cost": 80,
		"body_color": "49d6ff",
		"belly_color": "38bdf8",
		"tail_color": "31abc9",
		"coin_value": 20,
		"coin_interval": 5.8,
		"growth_multiplier": 1.0,
		"scale": 1.0,
	},
	{
		"id": "gold",
		"name": "金鳞鱼",
		"cost": 150,
		"body_color": "facc15",
		"belly_color": "fde68a",
		"tail_color": "f59e0b",
		"coin_value": 38,
		"coin_interval": 6.6,
		"growth_multiplier": 0.86,
		"scale": 1.08,
	},
	{
		"id": "guard",
		"name": "护卫鱼",
		"cost": 120,
		"body_color": "34d399",
		"belly_color": "a7f3d0",
		"tail_color": "059669",
		"coin_value": 14,
		"coin_interval": 5.2,
		"growth_multiplier": 1.18,
		"scale": 1.18,
		"guard": true,
	},
]

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
var unlocked_cleaner_snail := false
var highest_unlocked_level := 1
var cleared_levels: Array[int] = []
var active_slot_index := -1
var save_slots: Array[Dictionary] = []
var cleaner_snail_position := CLEANER_SNAIL_HOME
var pet_message_time := 0.0
var screen_shake_time := 0.0
var screen_shake_strength := 0.0
var total_play_seconds := 0.0
var run_play_seconds := 0.0
var run_enemies_defeated := 0
var run_fish_lost := 0
var run_money_earned := 0
var run_fish_bought := 0
var run_peak_fish_count := 0

var fish_list: Array[Dictionary] = []
var food_list: Array[Dictionary] = []
var coin_list: Array[Dictionary] = []
var enemy_list: Array[Dictionary] = []
var hit_effects: Array[Dictionary] = []
var guard_effects: Array[Dictionary] = []

var chinese_font: Font

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


func _ready() -> void:
	_load_chinese_font()
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
	_update_guard_fish(delta)
	_update_cleaner_snail(delta)
	_update_coins(delta)
	_update_enemies(delta)
	_update_hit_effects(delta)
	_update_guard_effects(delta)
	_update_enemy_waves(delta)
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
		return
	var click_position := Vector2.ZERO
	var pressed := false

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click_position = event.position
		pressed = true
	elif event is InputEventScreenTouch and event.pressed:
		click_position = event.position
		pressed = true

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

	top_bar = Panel.new()
	top_bar.position = Vector2.ZERO
	top_bar.size = Vector2(VIEWPORT_SIZE.x, 96)
	hud_layer.add_child(top_bar)

	money_label = Label.new()
	_apply_control_font(money_label, 18)
	money_label.position = Vector2(18, 18)
	money_label.size = Vector2(240, 28)
	top_bar.add_child(money_label)

	status_label = Label.new()
	_apply_control_font(status_label, 16)
	status_label.position = Vector2(18, 52)
	status_label.size = Vector2(486, 34)
	status_label.clip_text = true
	top_bar.add_child(status_label)

	pause_button = Button.new()
	_apply_control_font(pause_button, 17)
	pause_button.text = "暂停"
	pause_button.position = Vector2(1018, 20)
	pause_button.size = Vector2(86, 56)
	pause_button.pressed.connect(_on_pause_pressed)
	top_bar.add_child(pause_button)

	restart_button = Button.new()
	_apply_control_font(restart_button, 17)
	restart_button.text = "重新开始"
	restart_button.position = Vector2(1108, 20)
	restart_button.size = Vector2(102, 56)
	restart_button.pressed.connect(_on_restart_pressed)
	top_bar.add_child(restart_button)

	menu_button = Button.new()
	_apply_control_font(menu_button, 17)
	menu_button.text = "菜单"
	menu_button.position = Vector2(1212, 20)
	menu_button.size = Vector2(72, 56)
	menu_button.pressed.connect(_on_menu_pressed)
	top_bar.add_child(menu_button)

	_setup_shop_panel()

	_setup_main_menu()


func _setup_shop_panel() -> void:
	shop_panel = Panel.new()
	shop_panel.position = Vector2(548, 14)
	shop_panel.size = Vector2(458, 68)
	shop_panel.visible = true
	top_bar.add_child(shop_panel)

	var title := Label.new()
	_apply_control_font(title, 13)
	title.text = "快捷购买"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(8, 4)
	title.size = Vector2(72, 20)
	shop_panel.add_child(title)

	fish_buy_buttons.clear()
	for fish_index in range(FISH_TYPES.size()):
		var fish_button := Button.new()
		_apply_control_font(fish_button, 13)
		fish_button.position = Vector2(86 + fish_index * 70, 14)
		fish_button.size = Vector2(64, 42)
		fish_button.pressed.connect(_on_buy_fish_type_pressed.bind(fish_index))
		fish_buy_buttons.append(fish_button)
		shop_panel.add_child(fish_button)

	upgrade_food_button = Button.new()
	_apply_control_font(upgrade_food_button, 13)
	upgrade_food_button.text = "升级食物 $200"
	upgrade_food_button.position = Vector2(302, 14)
	upgrade_food_button.size = Vector2(64, 42)
	upgrade_food_button.pressed.connect(_on_upgrade_food_pressed)
	shop_panel.add_child(upgrade_food_button)

	buy_core_button = Button.new()
	_apply_control_font(buy_core_button, 13)
	buy_core_button.text = "购买水晶 $500"
	buy_core_button.position = Vector2(374, 14)
	buy_core_button.size = Vector2(72, 42)
	buy_core_button.pressed.connect(_on_buy_core_pressed)
	shop_panel.add_child(buy_core_button)

	core_hint_label = Label.new()
	_apply_control_font(core_hint_label, 12)
	core_hint_label.text = "可买"
	core_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	core_hint_label.position = Vector2(374, 2)
	core_hint_label.size = Vector2(72, 18)
	core_hint_label.visible = false
	shop_panel.add_child(core_hint_label)


func _setup_main_menu() -> void:
	menu_panel = Panel.new()
	menu_panel.position = Vector2(250, 88)
	menu_panel.size = Vector2(780, 560)
	hud_layer.add_child(menu_panel)

	var title := Label.new()
	_apply_control_font(title, 44)
	title.text = "水族守卫"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 42)
	title.size = Vector2(menu_panel.size.x, 62)
	menu_panel.add_child(title)

	var subtitle := Label.new()
	_apply_control_font(subtitle, 20)
	subtitle.text = "经营鱼缸，守住水晶核心"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(0, 108)
	subtitle.size = Vector2(menu_panel.size.x, 34)
	menu_panel.add_child(subtitle)

	continue_button = Button.new()
	_apply_control_font(continue_button, 24)
	continue_button.text = "继续游戏"
	continue_button.position = Vector2(270, 172)
	continue_button.size = Vector2(240, 58)
	continue_button.pressed.connect(_on_continue_pressed)
	menu_panel.add_child(continue_button)

	current_save_label = Label.new()
	_apply_control_font(current_save_label, 17)
	current_save_label.text = "当前存档：未选择"
	current_save_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_save_label.position = Vector2(0, 238)
	current_save_label.size = Vector2(menu_panel.size.x, 28)
	menu_panel.add_child(current_save_label)

	var level_title := Label.new()
	_apply_control_font(level_title, 22)
	level_title.text = "选择关卡"
	level_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_title.position = Vector2(0, 268)
	level_title.size = Vector2(menu_panel.size.x, 34)
	menu_panel.add_child(level_title)

	for level in range(1, MAX_LEVEL + 1):
		var button := Button.new()
		_apply_control_font(button, 18)
		button.position = Vector2(95 + (level - 1) * 215, 326)
		button.size = Vector2(180, 88)
		button.pressed.connect(_on_level_button_pressed.bind(level))
		level_buttons.append(button)
		menu_panel.add_child(button)

	var helper_note := Label.new()
	_apply_control_font(helper_note, 18)
	helper_note.text = "助手：第 1 关通关后清洁螺会移动收集金币"
	helper_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	helper_note.position = Vector2(42, 438)
	helper_note.size = Vector2(menu_panel.size.x - 84, 34)
	menu_panel.add_child(helper_note)

	save_manager_button = Button.new()
	_apply_control_font(save_manager_button, 20)
	save_manager_button.text = "存档管理"
	save_manager_button.position = Vector2(290, 488)
	save_manager_button.size = Vector2(200, 54)
	save_manager_button.pressed.connect(_on_save_manager_pressed)
	menu_panel.add_child(save_manager_button)

	_setup_save_manager()


func _setup_save_manager() -> void:
	save_panel = Panel.new()
	save_panel.position = Vector2(120, 72)
	save_panel.size = Vector2(1040, 584)
	save_panel.visible = false
	hud_layer.add_child(save_panel)

	var title := Label.new()
	_apply_control_font(title, 36)
	title.text = "存档管理"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 28)
	title.size = Vector2(save_panel.size.x, 54)
	save_panel.add_child(title)

	for slot_index in range(SAVE_SLOT_COUNT):
		var x := 60.0 + float(slot_index) * 326.0
		var slot_title := Label.new()
		_apply_control_font(slot_title, 21)
		slot_title.text = "槽位 %d" % (slot_index + 1)
		slot_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_title.position = Vector2(x, 104)
		slot_title.size = Vector2(270, 32)
		save_panel.add_child(slot_title)

		var name_label := Label.new()
		_apply_control_font(name_label, 18)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.position = Vector2(x, 146)
		name_label.size = Vector2(270, 32)
		slot_name_labels.append(name_label)
		save_panel.add_child(name_label)

		var progress_label := Label.new()
		_apply_control_font(progress_label, 16)
		progress_label.position = Vector2(x + 22, 188)
		progress_label.size = Vector2(226, 104)
		slot_progress_labels.append(progress_label)
		save_panel.add_child(progress_label)

		var enter_button := Button.new()
		_apply_control_font(enter_button, 17)
		enter_button.text = "进入"
		enter_button.position = Vector2(x + 22, 320)
		enter_button.size = Vector2(104, 48)
		enter_button.pressed.connect(_on_enter_slot_pressed.bind(slot_index))
		slot_enter_buttons.append(enter_button)
		save_panel.add_child(enter_button)

		var delete_button := Button.new()
		_apply_control_font(delete_button, 17)
		delete_button.text = "删除"
		delete_button.position = Vector2(x + 144, 320)
		delete_button.size = Vector2(104, 48)
		delete_button.pressed.connect(_on_delete_slot_pressed.bind(slot_index))
		slot_delete_buttons.append(delete_button)
		save_panel.add_child(delete_button)

	new_save_name_input = LineEdit.new()
	_apply_control_font(new_save_name_input, 17)
	new_save_name_input.placeholder_text = "新存档名称"
	new_save_name_input.position = Vector2(270, 420)
	new_save_name_input.size = Vector2(300, 48)
	save_panel.add_child(new_save_name_input)

	create_save_button = Button.new()
	_apply_control_font(create_save_button, 18)
	create_save_button.text = "新建存档"
	create_save_button.position = Vector2(590, 420)
	create_save_button.size = Vector2(160, 48)
	create_save_button.pressed.connect(_on_create_save_pressed)
	save_panel.add_child(create_save_button)

	save_message_label = Label.new()
	_apply_control_font(save_message_label, 17)
	save_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_message_label.position = Vector2(80, 482)
	save_message_label.size = Vector2(880, 28)
	save_panel.add_child(save_message_label)

	back_to_menu_button = Button.new()
	_apply_control_font(back_to_menu_button, 20)
	back_to_menu_button.text = "返回菜单"
	back_to_menu_button.position = Vector2(420, 520)
	back_to_menu_button.size = Vector2(200, 58)
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	save_panel.add_child(back_to_menu_button)


func _apply_control_font(control: Control, font_size: int) -> void:
	control.add_theme_font_override("font", chinese_font)
	control.add_theme_font_size_override("font_size", font_size)
	if control is Button:
		control.focus_mode = Control.FOCUS_NONE


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
	enemy_spawn_timer = config["enemy_timer"]
	fish_list.clear()
	food_list.clear()
	coin_list.clear()
	enemy_list.clear()
	hit_effects.clear()
	guard_effects.clear()
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
	fish_list.clear()
	food_list.clear()
	coin_list.clear()
	enemy_list.clear()
	hit_effects.clear()
	guard_effects.clear()
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
	var helper_text := "清洁螺已解锁" if unlocked_cleaner_snail else "通关第 1 关解锁清洁螺"
	for index in range(level_buttons.size()):
		var level := index + 1
		var button := level_buttons[index]
		var config: Dictionary = LEVEL_CONFIGS[level]
		var unlocked := has_active_save and level <= highest_unlocked_level
		var clear_mark := " ✓" if cleared_levels.has(level) else ""
		button.text = "第 %d 关%s\n%s" % [level, clear_mark, config["name"]]
		button.disabled = not unlocked
		button.tooltip_text = helper_text if level == 2 and not unlocked_cleaner_snail else ""


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
			slot_name_labels[slot_index].text = "%s%s" % [str(slot.get("name", "未命名存档")), active_mark]
			slot_progress_labels[slot_index].text = "最高：第 %d 关\n通关：%d / %d\n用时：%s\n清洁螺：%s" % [
				int(slot.get("highest_unlocked_level", 1)),
				_slot_cleared_count(slot),
				MAX_LEVEL,
				_format_time(float(slot.get("total_play_seconds", 0.0))),
				snail_text,
			]
		else:
			slot_name_labels[slot_index].text = "空槽"
			slot_progress_labels[slot_index].text = "等待新存档占用\n新存档从第 1 关开始\n清洁螺未解锁"
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
	var slot_levels: Variant = slot.get("cleared_levels", [])
	if slot_levels is Array:
		return slot_levels.size()
	return 0


func _spawn_fish(spawn_position: Vector2, fish_type_id := "blue") -> void:
	fish_list.append({
		"pos": spawn_position,
		"velocity": Vector2(randf_range(-70.0, 70.0), randf_range(-35.0, 35.0)),
		"wander_target": _random_play_position(),
		"facing": 1.0 if randf() >= 0.5 else -1.0,
		"type": fish_type_id,
		"growth": 0.0,
		"hunger": 28.0,
		"coin_timer": _fish_config(fish_type_id)["coin_interval"],
		"guard_cooldown": randf_range(0.4, 1.4),
		"alive": true,
	})
	run_peak_fish_count = max(run_peak_fish_count, fish_list.size())


func _drop_food(drop_position: Vector2) -> void:
	var cost := 2 + food_level * 2
	if money < cost:
		return
	money -= cost
	food_list.append({
		"pos": drop_position,
		"nutrition": float(food_level),
		"speed": 82.0,
		"life": 11.0,
	})


func _spawn_coin(spawn_position: Vector2, value: int) -> void:
	coin_list.append({
		"pos": _clamp_to_play_rect(spawn_position, COIN_RADIUS),
		"value": value,
		"speed": 55.0,
		"life": 9.0,
	})
	run_money_earned += value


func _coin_spawn_position_for_fish(fish: Dictionary) -> Vector2:
	var velocity: Vector2 = fish["velocity"]
	var direction := Vector2.RIGHT
	if velocity.length() > 1.0:
		direction = velocity.normalized()
	var side_offset := Vector2(-direction.y, direction.x) * randf_range(-18.0, 18.0)
	return _clamp_to_play_rect(fish["pos"] + direction * 44.0 + side_offset + Vector2(0, -8.0), COIN_RADIUS)


func _spawn_hit_effect(position: Vector2, defeated: bool) -> void:
	hit_effects.append({
		"pos": position,
		"life": 0.36 if defeated else 0.24,
		"max_life": 0.36 if defeated else 0.24,
		"defeated": defeated,
		"text": "+%d" % (40 if defeated else 1) if defeated else "-1",
	})
	screen_shake_time = 0.16 if defeated else 0.09
	screen_shake_strength = 6.0 if defeated else 3.5


func _spawn_guard_effect(origin: Vector2, target: Vector2) -> void:
	guard_effects.append({
		"origin": origin,
		"target": target,
		"life": 0.22,
		"max_life": 0.22,
	})


func _spawn_enemy() -> void:
	var side := randi() % 2
	var spawn_x := PLAY_RECT.position.x + ENEMY_RADIUS if side == 0 else PLAY_RECT.end.x - ENEMY_RADIUS
	var spawn_y := randf_range(PLAY_RECT.position.y + ENEMY_RADIUS, PLAY_RECT.end.y - ENEMY_RADIUS)
	var config := _get_level_config()
	var roll := randf()
	var is_thief: bool = roll < float(config["thief_enemy_chance"])
	var is_tank: bool = not is_thief and randf() < float(config["tank_enemy_chance"])
	var enemy_type := "thief" if is_thief else ("tank" if is_tank else "normal")
	enemy_list.append({
		"pos": Vector2(spawn_x, spawn_y),
		"hp": 4 if is_thief else (9 if is_tank else 5),
		"max_hp": 4 if is_thief else (9 if is_tank else 5),
		"speed": 96.0 if is_thief else (52.0 if is_tank else 78.0),
		"attack_cooldown": 0.0,
		"tank": is_tank,
		"type": enemy_type,
	})
	last_enemy_type = enemy_type
	warning_time = 1.6


func _update_food(delta: float) -> void:
	for index in range(food_list.size() - 1, -1, -1):
		var food := food_list[index]
		food["pos"] = food["pos"] + Vector2(0, food["speed"] * delta)
		food["life"] = food["life"] - delta
		if food["pos"].y > PLAY_RECT.end.y - 10.0 or food["life"] <= 0.0:
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

		var target_food_index := _find_nearest_food_index(fish["pos"])
		if target_food_index >= 0:
			var target_food := food_list[target_food_index]
			var direction: Vector2 = (target_food["pos"] - fish["pos"]).normalized()
			fish["velocity"] = direction * 125.0
			if fish["pos"].distance_to(target_food["pos"]) < FISH_RADIUS + FOOD_RADIUS:
				fish["hunger"] = min(32.0, fish["hunger"] + 12.0 + target_food["nutrition"] * 4.0)
				fish["growth"] = min(1.0, fish["growth"] + 0.21 * target_food["nutrition"] * fish_config["growth_multiplier"])
				food_list.remove_at(target_food_index)
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
				_spawn_coin(_coin_spawn_position_for_fish(fish), fish_config["coin_value"])
				fish["coin_timer"] = fish_config["coin_interval"]

		fish_list[index] = fish


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
		coin["pos"] = coin["pos"] + Vector2(0, coin["speed"] * delta)
		coin["life"] = coin["life"] - delta
		if unlocked_cleaner_snail and coin["pos"].distance_to(cleaner_snail_position) < CLEANER_SNAIL_COLLECT_RADIUS:
			money += coin["value"]
			coin_list.remove_at(index)
			continue
		if coin["pos"].y > PLAY_RECT.end.y - 8.0 or coin["life"] <= 0.0:
			coin_list.remove_at(index)
		else:
			coin_list[index] = coin


func _update_cleaner_snail(delta: float) -> void:
	if not unlocked_cleaner_snail:
		cleaner_snail_position = CLEANER_SNAIL_HOME
		return

	var target := CLEANER_SNAIL_HOME
	var nearest_distance := 999999.0
	for coin in coin_list:
		var coin_position: Vector2 = coin["pos"]
		var distance := cleaner_snail_position.distance_to(coin_position)
		if distance < nearest_distance:
			nearest_distance = distance
			target = coin_position

	var to_target := target - cleaner_snail_position
	if to_target.length() > 2.0:
		cleaner_snail_position += to_target.normalized() * CLEANER_SNAIL_SPEED * delta
	cleaner_snail_position = _clamp_to_play_rect(cleaner_snail_position, 22.0)


func _update_enemies(delta: float) -> void:
	for enemy_index in range(enemy_list.size() - 1, -1, -1):
		var enemy := enemy_list[enemy_index]
		var enemy_type := str(enemy.get("type", "tank" if enemy.get("tank", false) else "normal"))
		if enemy_type == "thief" and _update_thief_enemy(enemy, enemy_index, delta):
			continue
		var target_index := _find_nearest_fish_index(enemy["pos"])
		if target_index >= 0:
			var target_fish := fish_list[target_index]
			var direction: Vector2 = (target_fish["pos"] - enemy["pos"]).normalized()
			enemy["pos"] = enemy["pos"] + direction * enemy["speed"] * delta
			enemy["attack_cooldown"] = max(0.0, enemy["attack_cooldown"] - delta)
			if enemy["pos"].distance_to(target_fish["pos"]) < ENEMY_RADIUS + FISH_RADIUS and enemy["attack_cooldown"] <= 0.0:
				fish_list.remove_at(target_index)
				run_fish_lost += 1
				enemy["attack_cooldown"] = 1.2
		else:
			enemy["pos"] = enemy["pos"] + Vector2(0, 20.0 * delta)
		enemy["pos"] = _clamp_to_play_rect(enemy["pos"], ENEMY_RADIUS)
		enemy_list[enemy_index] = enemy


func _update_thief_enemy(enemy: Dictionary, enemy_index: int, delta: float) -> bool:
	var target_coin_index := _find_nearest_coin_index(enemy["pos"])
	if target_coin_index >= 0:
		var target_coin := coin_list[target_coin_index]
		var direction: Vector2 = (target_coin["pos"] - enemy["pos"]).normalized()
		enemy["pos"] = enemy["pos"] + direction * enemy["speed"] * delta
		if enemy["pos"].distance_to(target_coin["pos"]) < ENEMY_RADIUS + COIN_RADIUS:
			_spawn_hit_effect(target_coin["pos"], false)
			coin_list.remove_at(target_coin_index)
		enemy["pos"] = _clamp_to_play_rect(enemy["pos"], ENEMY_RADIUS)
		enemy_list[enemy_index] = enemy
		return true
	return false


func _update_enemy_waves(delta: float) -> void:
	warning_time = max(0.0, warning_time - delta)
	pet_message_time = max(0.0, pet_message_time - delta)
	goal_message_time = max(0.0, goal_message_time - delta)
	enemy_spawn_timer -= delta
	if enemy_spawn_timer <= 0.0:
		_spawn_enemy()
		var base_timer: float = _get_level_config()["enemy_timer"]
		enemy_spawn_timer = randf_range(base_timer, base_timer + 7.0)


func _update_hit_effects(delta: float) -> void:
	screen_shake_time = max(0.0, screen_shake_time - delta)
	if screen_shake_time <= 0.0:
		screen_shake_strength = 0.0
	for index in range(hit_effects.size() - 1, -1, -1):
		var effect := hit_effects[index]
		effect["life"] = effect["life"] - delta
		effect["pos"] = effect["pos"] + Vector2(0, -42.0 * delta)
		if effect["life"] <= 0.0:
			hit_effects.remove_at(index)
		else:
			hit_effects[index] = effect


func _update_guard_effects(delta: float) -> void:
	for index in range(guard_effects.size() - 1, -1, -1):
		var effect := guard_effects[index]
		effect["life"] = effect["life"] - delta
		if effect["life"] <= 0.0:
			guard_effects.remove_at(index)
		else:
			guard_effects[index] = effect


func _try_collect_coin(click_position: Vector2) -> bool:
	for index in range(coin_list.size() - 1, -1, -1):
		var coin := coin_list[index]
		if click_position.distance_to(coin["pos"]) <= COIN_RADIUS + 10.0:
			money += coin["value"]
			coin_list.remove_at(index)
			return true
	return false


func _try_attack_enemy(click_position: Vector2) -> bool:
	for index in range(enemy_list.size() - 1, -1, -1):
		var enemy := enemy_list[index]
		if click_position.distance_to(enemy["pos"]) <= ENEMY_RADIUS + 12.0:
			enemy["hp"] = enemy["hp"] - 1
			if enemy["hp"] <= 0:
				run_enemies_defeated += 1
				_spawn_hit_effect(enemy["pos"], true)
				_spawn_coin(enemy["pos"], _enemy_coin_reward(enemy))
				enemy_list.remove_at(index)
			else:
				_spawn_hit_effect(enemy["pos"], false)
				enemy_list[index] = enemy
			return true
	return false


func _find_nearest_food_index(origin: Vector2) -> int:
	var nearest_index := -1
	var nearest_distance := 999999.0
	for index in range(food_list.size()):
		var distance := origin.distance_to(food_list[index]["pos"])
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = index
	return nearest_index


func _find_nearest_fish_index(origin: Vector2) -> int:
	var nearest_index := -1
	var nearest_distance := 999999.0
	for index in range(fish_list.size()):
		var distance := origin.distance_to(fish_list[index]["pos"])
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = index
	return nearest_index


func _find_nearest_enemy_index(origin: Vector2, max_distance: float) -> int:
	var nearest_index := -1
	var nearest_distance := max_distance
	for index in range(enemy_list.size()):
		var enemy_position: Vector2 = enemy_list[index]["pos"]
		var distance := origin.distance_to(enemy_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = index
	return nearest_index


func _find_nearest_coin_index(origin: Vector2) -> int:
	var nearest_index := -1
	var nearest_distance := 999999.0
	for index in range(coin_list.size()):
		var coin_position: Vector2 = coin_list[index]["pos"]
		var distance := origin.distance_to(coin_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = index
	return nearest_index


func _guard_fish_attack(origin: Vector2, enemy_index: int) -> void:
	var enemy := enemy_list[enemy_index]
	enemy["hp"] = enemy["hp"] - 1
	_spawn_guard_effect(origin, enemy["pos"])
	if enemy["hp"] <= 0:
		run_enemies_defeated += 1
		_spawn_hit_effect(enemy["pos"], true)
		_spawn_coin(enemy["pos"], _enemy_coin_reward(enemy))
		enemy_list.remove_at(enemy_index)
	else:
		_spawn_hit_effect(enemy["pos"], false)
		enemy_list[enemy_index] = enemy


func _fish_separation_vector(fish_index: int) -> Vector2:
	var fish := fish_list[fish_index]
	var origin: Vector2 = fish["pos"]
	var separation := Vector2.ZERO
	for other_index in range(fish_list.size()):
		if other_index == fish_index:
			continue
		var other_position: Vector2 = fish_list[other_index]["pos"]
		var offset := origin - other_position
		var distance := offset.length()
		if distance > 0.01 and distance < FISH_SEPARATION_RADIUS:
			var strength := 1.0 - distance / FISH_SEPARATION_RADIUS
			separation += offset.normalized() * strength
	return separation.limit_length(1.0)


func _random_play_position() -> Vector2:
	return Vector2(randf_range(80.0, 1200.0), randf_range(150.0, 650.0))


func _clamp_to_play_rect(value: Vector2, margin: float) -> Vector2:
	return Vector2(
		clamp(value.x, PLAY_RECT.position.x + margin, PLAY_RECT.end.x - margin),
		clamp(value.y, PLAY_RECT.position.y + margin, PLAY_RECT.end.y - margin)
	)


func _update_play_time(delta: float) -> void:
	run_play_seconds += delta
	total_play_seconds += delta


func _check_failure(delta: float) -> void:
	if fish_list.is_empty():
		if money < _minimum_fish_cost():
			game_over = true
			_save_progress()
			return
		no_fish_timer += delta
		if no_fish_timer >= NO_FISH_GRACE_TIME:
			game_over = true
			_save_progress()
	else:
		no_fish_timer = 0.0


func _update_ui() -> void:
	money_label.text = "金币：%d  食物 Lv.%d  用时：%s" % [money, food_level, _format_time(total_play_seconds)]
	var helper_text := "清洁螺：已解锁" if unlocked_cleaner_snail else "清洁螺：未解锁"
	var no_fish_text := "  无鱼倒计时：%ds" % int(ceil(max(0.0, NO_FISH_GRACE_TIME - no_fish_timer))) if fish_list.is_empty() and not game_over and not level_cleared else ""
	var wave_text := "  入侵预警：%ds" % int(ceil(max(0.0, enemy_spawn_timer))) if _is_pre_invasion_warning_active() else "  下一波：%ds" % int(ceil(max(0.0, enemy_spawn_timer)))
	var defense_text := "  防守期：饥饿减缓" if _is_defense_pressure_active() else ""
	status_label.text = "第 %d/%d 关 %s  水晶：%d/3  鱼：%d  敌人：%d  %s%s%s%s" % [current_level, MAX_LEVEL, _get_level_config()["name"], cores, fish_list.size(), enemy_list.size(), helper_text, wave_text, defense_text, no_fish_text]
	for fish_index in range(fish_buy_buttons.size()):
		var fish_config: Dictionary = FISH_TYPES[fish_index]
		var cost := int(fish_config["cost"])
		fish_buy_buttons[fish_index].text = "%s\n$%d" % [_fish_shop_short_name(fish_config), cost]
		fish_buy_buttons[fish_index].disabled = money < cost or paused or game_over or level_cleared
	upgrade_food_button.disabled = money < _food_upgrade_cost() or food_level >= 3 or paused or game_over or level_cleared
	upgrade_food_button.text = "食物\n$%d" % _food_upgrade_cost() if food_level < 3 else "满级"
	var core_affordable := _can_buy_core()
	buy_core_button.disabled = not core_affordable
	buy_core_button.text = "水晶\n$%d" % _core_cost()
	_update_core_purchase_hint(core_affordable)
	pause_button.disabled = game_over or level_cleared
	pause_button.text = "继续" if paused else "暂停"
	if level_cleared and current_level < MAX_LEVEL:
		restart_button.text = "下一关"
	elif level_cleared and current_level >= MAX_LEVEL:
		restart_button.text = "回菜单"
	else:
		restart_button.text = "重新开始"
	menu_button.disabled = false


func _food_upgrade_cost() -> int:
	return 120 + food_level * 80


func _can_buy_core() -> bool:
	return money >= _core_cost() and cores < 3 and not paused and not game_over and not level_cleared


func _is_pre_invasion_warning_active() -> bool:
	return enemy_spawn_timer > 0.0 and enemy_spawn_timer <= PRE_INVASION_WARNING_TIME and not game_over and not level_cleared


func _is_defense_pressure_active() -> bool:
	return not enemy_list.is_empty() and not game_over and not level_cleared


func _hunger_drain_multiplier() -> float:
	return DEFENSE_HUNGER_MULTIPLIER if _is_defense_pressure_active() else 1.0


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
	var config := _get_level_config()
	return config["core_base_cost"] + cores * config["core_step_cost"]


func _get_level_config() -> Dictionary:
	return LEVEL_CONFIGS.get(current_level, LEVEL_CONFIGS[1])


func _fish_shop_short_name(fish_config: Dictionary) -> String:
	if bool(fish_config.get("guard", false)):
		return "护卫"
	if str(fish_config.get("id", "")) == "gold":
		return "金鱼"
	return "蓝鱼"


func _fish_config(fish_type_id: String) -> Dictionary:
	for config in FISH_TYPES:
		if config["id"] == fish_type_id:
			return config
	return FISH_TYPES[0]


func _minimum_fish_cost() -> int:
	var minimum_cost := 999999
	for config in FISH_TYPES:
		minimum_cost = min(minimum_cost, int(config["cost"]))
	return minimum_cost


func _enemy_coin_reward(enemy: Dictionary) -> int:
	var enemy_type := str(enemy.get("type", "tank" if enemy.get("tank", false) else "normal"))
	if enemy_type == "thief":
		return 30
	return 35 if bool(enemy.get("tank", false)) else 22


func _format_time(seconds: float) -> String:
	var total_seconds := int(floor(seconds))
	var minutes := total_seconds / 60
	var remaining_seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]


func _load_progress() -> void:
	save_slots.clear()
	for slot_index in range(SAVE_SLOT_COUNT):
		save_slots.append(_empty_slot())
	active_slot_index = -1
	_reset_runtime_progress()

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		push_warning("读取存档失败：%s" % SAVE_PATH)
		return

	var parsed: Variant = JSON.parse_string(save_file.get_as_text())
	if not parsed is Dictionary:
		push_warning("存档格式无效，已忽略。")
		return

	var save_data: Dictionary = parsed
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
	slot["cleared_levels"] = cleared_levels.duplicate()
	slot["total_play_seconds"] = total_play_seconds
	save_slots[active_slot_index] = slot
	_write_save_data()


func _write_save_data() -> void:
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_warning("写入存档失败：%s" % SAVE_PATH)
		return
	var save_data := {
		"active_slot_index": active_slot_index,
		"slots": save_slots,
	}
	save_file.store_string(JSON.stringify(save_data))


func _empty_slot() -> Dictionary:
	return {
		"exists": false,
		"name": "",
		"highest_unlocked_level": 1,
		"unlocked_cleaner_snail": false,
		"cleared_levels": [],
		"total_play_seconds": 0.0,
	}


func _normalize_slot(raw_slot: Dictionary) -> Dictionary:
	var normalized := _empty_slot()
	normalized["exists"] = bool(raw_slot.get("exists", false))
	normalized["name"] = str(raw_slot.get("name", "未命名存档")).strip_edges()
	if normalized["name"] == "":
		normalized["name"] = "未命名存档"
	normalized["highest_unlocked_level"] = clamp(int(raw_slot.get("highest_unlocked_level", 1)), 1, MAX_LEVEL)
	normalized["unlocked_cleaner_snail"] = bool(raw_slot.get("unlocked_cleaner_snail", false))
	normalized["total_play_seconds"] = max(0.0, float(raw_slot.get("total_play_seconds", 0.0)))
	var levels: Array[int] = []
	var raw_levels: Variant = raw_slot.get("cleared_levels", [])
	if raw_levels is Array:
		for level_value in raw_levels:
			var level: int = clamp(int(level_value), 1, MAX_LEVEL)
			if not levels.has(level):
				levels.append(level)
	normalized["cleared_levels"] = levels
	return normalized


func _reset_runtime_progress() -> void:
	highest_unlocked_level = 1
	unlocked_cleaner_snail = false
	cleared_levels.clear()
	cleaner_snail_position = CLEANER_SNAIL_HOME
	total_play_seconds = 0.0
	run_play_seconds = 0.0
	no_fish_timer = 0.0


func _apply_slot_progress(slot_index: int) -> void:
	var slot := save_slots[slot_index]
	highest_unlocked_level = int(slot.get("highest_unlocked_level", 1))
	unlocked_cleaner_snail = bool(slot.get("unlocked_cleaner_snail", false))
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


func _first_existing_slot_index() -> int:
	for slot_index in range(save_slots.size()):
		if bool(save_slots[slot_index].get("exists", false)):
			return slot_index
	return -1


func _first_empty_slot_index() -> int:
	for slot_index in range(save_slots.size()):
		if not bool(save_slots[slot_index].get("exists", false)):
			return slot_index
	return -1


func _record_level_clear() -> void:
	if not cleared_levels.has(current_level):
		cleared_levels.append(current_level)
	if current_level < MAX_LEVEL:
		highest_unlocked_level = max(highest_unlocked_level, current_level + 1)
	_save_progress()


func _on_buy_fish_type_pressed(fish_index: int) -> void:
	if fish_index < 0 or fish_index >= FISH_TYPES.size():
		return
	var fish_config: Dictionary = FISH_TYPES[fish_index]
	var cost := int(fish_config["cost"])
	if money < cost or game_over or level_cleared:
		return
	money -= cost
	_spawn_fish(_random_play_position(), str(fish_config["id"]))
	run_fish_bought += 1
	no_fish_timer = 0.0


func _on_buy_fish_pressed() -> void:
	_on_buy_fish_type_pressed(selected_fish_type_index)


func _on_upgrade_food_pressed() -> void:
	var cost := _food_upgrade_cost()
	if money < cost or food_level >= 3 or game_over or level_cleared:
		return
	money -= cost
	food_level += 1


func _on_buy_core_pressed() -> void:
	var cost := _core_cost()
	if money < cost or game_over or level_cleared:
		return
	money -= cost
	cores += 1
	if cores >= 3:
		if current_level == 1 and not unlocked_cleaner_snail:
			unlocked_cleaner_snail = true
			pet_message_time = 6.0
		_record_level_clear()
		level_cleared = true
		_save_progress()


func _on_restart_pressed() -> void:
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
	_update_ui()
	queue_redraw()


func _on_menu_pressed() -> void:
	_show_main_menu()


func _on_continue_pressed() -> void:
	if active_slot_index < 0:
		_show_save_manager()
		return
	_start_level(highest_unlocked_level)


func _on_level_button_pressed(level: int) -> void:
	if level > highest_unlocked_level:
		return
	_start_level(level)


func _on_save_manager_pressed() -> void:
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


func _on_enter_slot_pressed(slot_index: int) -> void:
	if not bool(save_slots[slot_index].get("exists", false)):
		return
	active_slot_index = slot_index
	_apply_slot_progress(slot_index)
	_write_save_data()
	_update_menu_ui()
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


func _on_back_to_menu_pressed() -> void:
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
	if not unlocked_cleaner_snail:
		return
	var t := Time.get_ticks_msec() / 1000.0
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
	if pet_message_time > 0.0:
		draw_string(chinese_font, Vector2(430, 175), "新助手解锁：清洁螺会自动捡起底部附近金币", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("e9d5ff"))
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
