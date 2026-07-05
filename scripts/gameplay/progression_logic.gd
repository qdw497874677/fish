extends RefCounted


static func should_fail_without_fish(fish_count: int, money: int, minimum_fish_cost: int, no_fish_timer: float, no_fish_grace_time: float) -> bool:
	if fish_count > 0:
		return false
	return money < minimum_fish_cost or no_fish_timer >= no_fish_grace_time


static func next_no_fish_timer(fish_count: int, no_fish_timer: float, delta: float) -> float:
	if fish_count > 0:
		return 0.0
	return no_fish_timer + delta


static func unlocked_level_after_clear(current_level: int, highest_unlocked_level: int, max_level: int) -> int:
	if current_level < max_level:
		return max(highest_unlocked_level, current_level + 1)
	return highest_unlocked_level


static func should_unlock_cleaner_snail(current_level: int, unlocked_cleaner_snail: bool) -> bool:
	return current_level == 1 and not unlocked_cleaner_snail


static func should_unlock_bubble_seahorse(current_level: int, unlocked_bubble_seahorse: bool) -> bool:
	return current_level == 2 and not unlocked_bubble_seahorse


static func should_unlock_electric_jellyfish(current_level: int, max_level: int, unlocked_electric_jellyfish: bool) -> bool:
	return current_level == max_level and not unlocked_electric_jellyfish


static func should_clear_level(cores: int) -> bool:
	return cores >= 3


static func next_action_hint(state: Dictionary, level_config: Dictionary, minimum_fish_cost: int) -> String:
	var money := int(state["money"])
	var fish_count := int(state["fish_count"])
	var enemy_count := int(state["enemy_count"])
	var food_count := int(state["food_count"])
	var coin_count := int(state["coin_count"])
	var hungry_fish_count := int(state["hungry_fish_count"])
	var core_cost := int(state["core_cost"])
	var cores := int(state["cores"])
	var pre_invasion_active := bool(state["pre_invasion_active"])
	var safe_reward_active := bool(state["safe_reward_active"])
	var game_over := bool(state["game_over"])
	var level_cleared := bool(state["level_cleared"])
	if game_over or level_cleared:
		return ""
	if fish_count <= 0:
		if money >= minimum_fish_cost:
			return "鱼群断档了，先在快捷购买栏补一条蓝泡鱼。"
		return "鱼群断档且金币不足，尽快收金币争取补鱼。"
	if enemy_count > 0:
		return "敌人在场，先点击敌人；防守期鱼饥饿会减缓。"
	if pre_invasion_active:
		return "入侵预警中，先收金币并准备点击敌人。"
	if cores < 3 and money >= core_cost:
		return "金币足够，优先购买水晶核心推进通关。"
	if cores < 3 and money >= int(float(core_cost) * 0.8):
		return "快够买下一颗水晶了，继续收金币冲目标。"
	if hungry_fish_count > 0 and food_count <= hungry_fish_count:
		return "有鱼饿了，点击水体投喂让鱼继续成长产钱。"
	if coin_count > 0:
		return "场上有金币，点击、拖拽或点附近触发磁吸来收集。"
	if safe_reward_active:
		return "安全奖励中，成熟鱼金币提高，趁机扩张经济。"
	return str(level_config.get("tip", "喂鱼成长，收金币并购买水晶核心。"))
