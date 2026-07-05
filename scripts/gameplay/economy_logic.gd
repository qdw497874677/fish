extends RefCounted


static func food_drop_cost(food_level: int) -> int:
	return 2 + food_level * 2


static func food_upgrade_cost(food_level: int) -> int:
	return 120 + food_level * 80


static func core_cost(level_config: Dictionary, cores: int) -> int:
	return level_config["core_base_cost"] + cores * level_config["core_step_cost"]


static func can_buy_core(money: int, core_cost_value: int, cores: int, paused: bool, game_over: bool, level_cleared: bool) -> bool:
	return money >= core_cost_value and cores < 3 and not paused and not game_over and not level_cleared


static func minimum_fish_cost(fish_types: Array) -> int:
	var minimum_cost := 999999
	for config in fish_types:
		minimum_cost = min(minimum_cost, int(config["cost"]))
	return minimum_cost


static func can_buy_fish(money: int, fish_config: Dictionary, game_over: bool, level_cleared: bool) -> bool:
	return money >= int(fish_config["cost"]) and not game_over and not level_cleared


static func can_upgrade_food(money: int, food_level: int, upgrade_cost: int, game_over: bool, level_cleared: bool) -> bool:
	return money >= upgrade_cost and food_level < 3 and not game_over and not level_cleared
