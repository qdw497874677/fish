extends RefCounted


static func build_view_model(state: Dictionary, fish_types: Array, level_config: Dictionary) -> Dictionary:
	var food_level := int(state["food_level"])
	var money := int(state["money"])
	var cores := int(state["cores"])
	var paused := bool(state["paused"])
	var game_over := bool(state["game_over"])
	var level_cleared := bool(state["level_cleared"])
	var current_level := int(state["current_level"])
	var max_level := int(state["max_level"])
	var fish_count := int(state["fish_count"])
	var enemy_count := int(state["enemy_count"])
	var enemy_spawn_timer := float(state["enemy_spawn_timer"])
	var no_fish_timer := float(state["no_fish_timer"])
	var total_play_seconds := float(state["total_play_seconds"])
	var no_fish_grace_time := float(state["no_fish_grace_time"])
	var core_cost := int(state["core_cost"])
	var food_upgrade_cost := int(state["food_upgrade_cost"])
	var pre_invasion_active := bool(state["pre_invasion_active"])
	var defense_active := bool(state["defense_active"])
	var safe_reward_active := bool(state["safe_reward_active"])
	var safe_reward_timer := float(state["safe_reward_timer"])
	var coin_combo_count := int(state["coin_combo_count"])
	var coin_combo_bonus_percent := int(state["coin_combo_bonus_percent"])
	var unlocked_cleaner_snail := bool(state["unlocked_cleaner_snail"])
	var unlocked_bubble_seahorse := bool(state["unlocked_bubble_seahorse"])
	var unlocked_electric_jellyfish := bool(state["unlocked_electric_jellyfish"])

	var helper_text := "助手：%s %s %s" % ["螺✓" if unlocked_cleaner_snail else "螺-", "海马✓" if unlocked_bubble_seahorse else "海马-", "水母✓" if unlocked_electric_jellyfish else "水母-"]
	var no_fish_text := ""
	if fish_count == 0 and not game_over and not level_cleared:
		no_fish_text = "  无鱼倒计时：%ds" % int(ceil(max(0.0, no_fish_grace_time - no_fish_timer)))
	var wave_text := "  安全奖励：%ds" % int(ceil(max(0.0, safe_reward_timer))) if safe_reward_active else ("  入侵预警：%ds" % int(ceil(max(0.0, enemy_spawn_timer))) if pre_invasion_active else "  下一波：%ds" % int(ceil(max(0.0, enemy_spawn_timer))))
	var defense_text := "  防守期：饥饿减缓" if defense_active else ""
	var safe_reward_text := "  成熟鱼金币 +20%" if safe_reward_active else ""
	var combo_text := "  收金币连击 x%d +%d%%" % [coin_combo_count, coin_combo_bonus_percent] if coin_combo_count >= 2 and coin_combo_bonus_percent > 0 else ""

	var fish_buttons := []
	for fish_config in fish_types:
		var cost := int(fish_config["cost"])
		fish_buttons.append({
			"text": "%s\n$%d" % [fish_shop_short_name(fish_config), cost],
			"disabled": money < cost or paused or game_over or level_cleared,
		})

	return {
		"money_text": "金币：%d  食物 Lv.%d  用时：%s" % [money, food_level, format_time(total_play_seconds)],
		"status_text": "第 %d/%d 关 %s  水晶：%d/3  鱼：%d  敌人：%d  %s%s%s%s%s%s" % [current_level, max_level, level_config["name"], cores, fish_count, enemy_count, helper_text, wave_text, defense_text, safe_reward_text, combo_text, no_fish_text],
		"fish_buttons": fish_buttons,
		"upgrade_food_disabled": money < food_upgrade_cost or food_level >= 3 or paused or game_over or level_cleared,
		"upgrade_food_text": "食物\n$%d" % food_upgrade_cost if food_level < 3 else "满级",
		"core_affordable": money >= core_cost and cores < 3 and not paused and not game_over and not level_cleared,
		"core_text": "水晶\n$%d" % core_cost,
		"pause_disabled": game_over or level_cleared,
		"pause_text": "继续" if paused else "暂停",
		"restart_text": _restart_text(level_cleared, current_level, max_level),
		"menu_disabled": false,
	}


static func format_time(seconds: float) -> String:
	var total_seconds := int(floor(seconds))
	var minutes := total_seconds / 60
	var remaining_seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]


static func fish_shop_short_name(fish_config: Dictionary) -> String:
	if bool(fish_config.get("guard", false)):
		return "护卫"
	if str(fish_config.get("id", "")) == "gold":
		return "金鱼"
	return "蓝鱼"


static func _restart_text(level_cleared: bool, current_level: int, max_level: int) -> String:
	if level_cleared and current_level < max_level:
		return "下一关"
	if level_cleared and current_level >= max_level:
		return "回菜单"
	return "重新开始"
